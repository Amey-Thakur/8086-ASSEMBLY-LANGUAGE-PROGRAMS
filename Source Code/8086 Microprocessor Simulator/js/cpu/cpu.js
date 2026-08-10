// -----------------------------------------------------------------------------
// Script Name: cpu.js
// Module:      CPU Core, 6 of 6
// Stack:       JavaScript (ES2020), depends on memory, registers, flags, shifter, alu
// Description: Binds the five core modules into one machine and owns the state
//              that belongs to the processor as a whole rather than to any
//              single part of it: the stack, segment selection, the halt
//              condition, the console buffer and the execution journal.
//
//              Two rules encoded here are easy to get wrong and matter a great
//              deal in practice:
//
//                - the stack grows DOWNWARD. PUSH decrements SP first and then
//                  writes; POP reads first and then increments. Doing it in the
//                  other order leaves the stack off by two and corrupts RET.
//
//                - the default segment depends on the base register. Anything
//                  addressed through BP or SP belongs to the stack segment,
//                  everything else to the data segment, and string destinations
//                  are always ES:DI regardless of any override.
//
// Authors:     Amey Thakur
// Repository:  https://github.com/Amey-Thakur/8086-ASSEMBLY-LANGUAGE-PROGRAMS
// License:     CC BY 4.0
// -----------------------------------------------------------------------------

'use strict';

import { Memory }       from './memory.js';
import { RegisterFile } from './registers.js';
import { Flags }        from './flags.js';

/** Where the assembler places code and data by default. Chosen so the layout
 *  matches what a small .COM style program under DOS would see. */
export const DEFAULT_CODE_SEGMENT = 0x0700;
export const DEFAULT_DATA_SEGMENT = 0x0800;
export const DEFAULT_STACK_SEGMENT = 0x0900;

/** A run is abandoned after this many instructions. A student program that
 *  loops forever should report a clear diagnosis, not hang the browser tab. */
export const INSTRUCTION_LIMIT = 2_000_000;

/** Raised when execution cannot continue. Carries the source line so the
 *  editor can point at the offending instruction. */
export class ExecutionError extends Error {
    constructor(message, line = null) {
        super(message);
        this.name = 'ExecutionError';
        this.line = line;
    }
}

// -----------------------------------------------------------------------------
// CPU
// -----------------------------------------------------------------------------
export class CPU {

    constructor() {
        this.memory    = new Memory();
        this.registers = new RegisterFile();
        this.flags     = new Flags();

        this.reset();
    }

    // -------------------------------------------------------------------------
    // LIFECYCLE
    // -------------------------------------------------------------------------

    reset() {
        this.memory.clear();
        this.registers.reset();
        this.flags.reset();

        this.registers.set('CS', DEFAULT_CODE_SEGMENT);
        this.registers.set('DS', DEFAULT_DATA_SEGMENT);
        this.registers.set('ES', DEFAULT_DATA_SEGMENT);
        this.registers.set('SS', DEFAULT_STACK_SEGMENT);

        this.halted            = false;
        this.instructionCount  = 0;
        this.consoleOutput     = '';
        this.pendingInput      = '';

        // Populated by CALL and unwound by RET, purely so the interface can show
        // a call stack. The processor itself keeps this information on the stack.
        this.callTrace = [];
    }

    // -------------------------------------------------------------------------
    // STACK
    //
    // The 8086 stack is full-descending: SP always points at the last item
    // written, and it moves down as the stack grows.
    // -------------------------------------------------------------------------

    push(value) {
        const stackPointer = (this.registers.get('SP') - 2) & 0xFFFF;

        this.registers.set('SP', stackPointer);
        this.memory.writeWord(this.registers.get('SS'), stackPointer, value);
    }

    pop() {
        const stackPointer = this.registers.get('SP');
        const value        = this.memory.readWord(this.registers.get('SS'), stackPointer);

        this.registers.set('SP', (stackPointer + 2) & 0xFFFF);
        return value;
    }

    /** Read what is on top of the stack without removing it. Used by the
     *  interface to render the stack view during single stepping. */
    peekStack(depth = 8) {
        const segment = this.registers.get('SS');
        const base    = this.registers.get('SP');
        const items   = [];

        for (let index = 0; index < depth; index++) {
            const offset = (base + index * 2) & 0xFFFF;

            if (offset < base) break;   // wrapped past the top of the segment

            items.push({ offset, value: this.memory.readWord(segment, offset) });
        }
        return items;
    }

    // -------------------------------------------------------------------------
    // SEGMENT SELECTION
    //
    // An instruction may carry an explicit override such as ES:[BX]. Absent
    // that, the base register decides: BP and SP imply the stack segment
    // because they are normally used to walk a stack frame.
    // -------------------------------------------------------------------------

    resolveSegment(baseRegister, override = null) {
        if (override) {
            return this.registers.get(override);
        }

        const base = baseRegister ? String(baseRegister).toUpperCase() : '';

        return (base === 'BP' || base === 'SP')
            ? this.registers.get('SS')
            : this.registers.get('DS');
    }

    // -------------------------------------------------------------------------
    // MEMORY PORTS
    //
    // Everything that touches memory goes through these so segment selection
    // stays in exactly one place.
    // -------------------------------------------------------------------------

    readMemory(offset, width, baseRegister = null, override = null) {
        const segment = this.resolveSegment(baseRegister, override);

        return width === 1
            ? this.memory.readByte(segment, offset)
            : this.memory.readWord(segment, offset);
    }

    writeMemory(offset, value, width, baseRegister = null, override = null) {
        const segment = this.resolveSegment(baseRegister, override);

        if (width === 1) {
            this.memory.writeByte(segment, offset, value);
        } else {
            this.memory.writeWord(segment, offset, value);
        }
    }

    /** String destinations are always ES:DI. No override applies to them, which
     *  is a genuine architectural quirk rather than a simplification here. */
    readExtraSegment(offset, width) {
        const segment = this.registers.get('ES');

        return width === 1
            ? this.memory.readByte(segment, offset)
            : this.memory.readWord(segment, offset);
    }

    writeExtraSegment(offset, value, width) {
        const segment = this.registers.get('ES');

        if (width === 1) {
            this.memory.writeByte(segment, offset, value);
        } else {
            this.memory.writeWord(segment, offset, value);
        }
    }

    // -------------------------------------------------------------------------
    // CONTROL TRANSFER
    // -------------------------------------------------------------------------

    /** Jump within the current code segment. */
    jumpTo(offset) {
        this.registers.set('IP', offset & 0xFFFF);
    }

    /** CALL pushes the return address before transferring. */
    callTo(offset, label = null) {
        this.push(this.registers.get('IP'));
        this.callTrace.push({ target: offset, label, returnTo: this.registers.get('IP') });
        this.jumpTo(offset);
    }

    /** RET pops it back. An optional immediate discards that many bytes of
     *  arguments, which is how stdcall style cleanup is expressed. */
    returnFromCall(bytesToDiscard = 0) {
        if (this.registers.get('SP') === 0xFFFE) {
            // Nothing was ever pushed, so there is no caller to return to.
            this.halted = true;
            return;
        }

        const target = this.pop();

        if (bytesToDiscard > 0) {
            this.registers.set('SP', (this.registers.get('SP') + bytesToDiscard) & 0xFFFF);
        }

        this.callTrace.pop();
        this.jumpTo(target);
    }

    // -------------------------------------------------------------------------
    // CONSOLE
    //
    // The DOS services write here rather than to the DOM, so the core stays
    // testable from Node with no browser present.
    // -------------------------------------------------------------------------

    write(text) {
        this.consoleOutput += text;
    }

    writeCharacter(code) {
        // Carriage return and line feed are emitted by DOS as a pair; collapse
        // the pair into one newline so the transcript reads naturally.
        if (code === 0x0D) return;
        if (code === 0x0A) { this.consoleOutput += '\n'; return; }

        this.consoleOutput += String.fromCharCode(code);
    }

    // -------------------------------------------------------------------------
    // EXECUTION BUDGET
    // -------------------------------------------------------------------------

    countInstruction() {
        this.instructionCount++;

        if (this.instructionCount > INSTRUCTION_LIMIT) {
            throw new ExecutionError(
                `execution stopped after ${INSTRUCTION_LIMIT.toLocaleString()} instructions, ` +
                `which usually means a loop never terminates`
            );
        }
    }

    // -------------------------------------------------------------------------
    // INSPECTION
    // -------------------------------------------------------------------------

    /** Everything the interface needs to render one frame of machine state. */
    snapshot() {
        return {
            registers:        this.registers.snapshot(),
            flags:            this.flags.snapshot(),
            halted:           this.halted,
            instructionCount: this.instructionCount,
            output:           this.consoleOutput,
            callDepth:        this.callTrace.length,
            stack:            this.peekStack()
        };
    }
}
