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

import { Memory }                    from './memory.js';
import { RegisterFile }              from './registers.js';
import { Flags }                     from './flags.js';
import { PortSpace, FileStore, Clock, PixelPlane } from '../exec/devices.js';

/** Where the assembler places code and data by default. Chosen so the layout
 *  matches what a small .COM style program under DOS would see. */
/** The text screen the BIOS services describe: eighty columns by twenty five
 *  rows, which is mode 3 and what every DOS program assumes. */
export const SCREEN_COLUMNS = 80;
export const SCREEN_ROWS    = 25;

export const DEFAULT_CODE_SEGMENT = 0x0700;
export const DEFAULT_DATA_SEGMENT = 0x0800;
export const DEFAULT_STACK_SEGMENT = 0x0900;

// How long a run is allowed to go on is decided by the executor, not here.
// See RUN_BUDGET and COMPLETION_CEILING in exec/executor.js.

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

        // The world outside the processor. Kept on the machine rather than in
        // the interrupt handlers so a program's effect on it survives a step
        // and can be shown while execution is paused.
        this.ports  = new PortSpace();
        this.files  = new FileStore();
        this.clock  = new Clock();

        // The graphics screen. A program in a graphics mode plots pixels and
        // reads them back, and both need somewhere to live.
        this.pixels = new PixelPlane();

        this.reset();
    }

    // -------------------------------------------------------------------------
    // LIFECYCLE
    // -------------------------------------------------------------------------

    reset() {
        this.memory.clear();
        this.registers.reset();
        this.flags.reset();
        this.ports.reset();
        this.files.reset();
        this.clock.reset();
        this.pixels.reset();

        this.registers.set('CS', DEFAULT_CODE_SEGMENT);
        this.registers.set('DS', DEFAULT_DATA_SEGMENT);
        this.registers.set('ES', DEFAULT_DATA_SEGMENT);
        this.registers.set('SS', DEFAULT_STACK_SEGMENT);

        this.installVectors();

        this.halted            = false;
        this.instructionCount  = 0;
        this.consoleOutput     = '';
        this.pendingInput      = '';

        // How many times the program has rung the bell. The interface plays a
        // tone for each ring it has not played yet.
        this.bellCount         = 0;

        // Set by INT 21h service 4Ch. Null until the program terminates through
        // it, which distinguishes "exited with zero" from "never exited".
        this.exitCode = null;

        // Maintained by INT 10h service 02h. There is no addressable screen
        // here, so this exists for the interface to display.
        this.cursor = { row: 0, column: 0 };

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

    /**
     * Lay down an interrupt vector table.
     *
     * The first kilobyte of memory is 256 far pointers, one per interrupt, and
     * a program is entitled to read them: that is how a handler is chained, and
     * how a program checks whether a service is present at all. Leaving them all
     * zero would make every vector look uninstalled, which is a state a real
     * machine is never in once the BIOS has run.
     *
     * The addresses below are the ones an IBM PC left in place, so a program
     * that recognises them sees what it would have seen in 1983. They are fixed
     * rather than invented afresh, because a simulator whose memory differs
     * between runs cannot be tested.
     *
     * Nothing executes at these addresses. The interrupts are serviced by the
     * handlers in interrupts.js, exactly as they were before. The table is there
     * to be read.
     */
    installVectors() {
        const BIOS_SEGMENT = 0xF000;
        const DOS_SEGMENT  = 0x0116;

        // The BIOS pointed every unused vector at a single instruction that
        // returns immediately, so an unexpected interrupt did nothing rather
        // than running off into whatever happened to be at address zero.
        const DUMMY_HANDLER = 0xFF53;

        for (let vector = 0; vector < 256; vector++) {
            this.memory.writeWord(0, vector * 4,     DUMMY_HANDLER);
            this.memory.writeWord(0, vector * 4 + 2, BIOS_SEGMENT);
        }

        // The handlers a program is actually likely to look at.
        const KNOWN = {
            0x00: 0x0163,   // divide by zero
            0x01: 0xFF53,   // single step, unused
            0x02: 0xFF53,   // non-maskable interrupt
            0x03: 0xFF53,   // breakpoint
            0x04: 0xFF53,   // overflow, reached by INTO
            0x05: 0xFF54,   // print screen
            0x08: 0xFEA5,   // timer tick, eighteen and a fifth times a second
            0x09: 0xE987,   // keyboard
            0x0E: 0xEF57,   // diskette
            0x10: 0xF065,   // video
            0x11: 0xF84D,   // equipment list
            0x12: 0xF841,   // memory size
            0x13: 0xEC59,   // disc
            0x14: 0xE739,   // serial
            0x15: 0xF859,   // system services
            0x16: 0xE82E,   // keyboard services
            0x17: 0xEFD2,   // printer
            0x19: 0xE6F2,   // bootstrap
            0x1A: 0xFE6E    // clock services
        };

        for (const [vector, offset] of Object.entries(KNOWN)) {
            this.memory.writeWord(0, Number(vector) * 4, offset);
        }

        // The DOS vectors live in the resident part of DOS rather than in the
        // BIOS, so their segment differs. 21h is the one every program uses.
        for (const vector of [0x20, 0x21, 0x22, 0x23, 0x24, 0x25, 0x26, 0x27, 0x2F]) {
            this.memory.writeWord(0, vector * 4,     0x1160 + (vector & 0x0F) * 0x10);
            this.memory.writeWord(0, vector * 4 + 2, DOS_SEGMENT);
        }
    }

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

    /**
     * Write one character to the console and move the cursor as it would move.
     *
     * The cursor is tracked even though there is no addressable screen here,
     * because INT 10h service 03h reports it and a program that positions text
     * relative to where it just printed would otherwise be told the wrong
     * column. Carriage return and line feed are emitted by DOS as a pair, so
     * the pair collapses into one newline for the transcript while still
     * moving the cursor the way each one does.
     */
    writeCharacter(code) {
        if (code === 0x0D) {                     // return to the left margin
            this.cursor.column = 0;
            return;
        }

        if (code === 0x0A) {                     // down one line
            this.consoleOutput += '\n';
            this.cursor.column = 0;
            if (this.cursor.row < SCREEN_ROWS - 1) this.cursor.row++;
            return;
        }

        if (code === 0x08) {                     // backspace
            if (this.cursor.column > 0) this.cursor.column--;
            this.consoleOutput += String.fromCharCode(code);
            return;
        }

        if (code === 0x07) {                     // bell
            // BEL is a sound, not a glyph. Appending it put an invisible
            // control character in the transcript and rang nothing at all,
            // so a program written to beep appeared to do nothing.
            //
            // The count is what the interface watches: it plays a tone for each
            // ring it has not yet played. Nothing is added to the transcript,
            // and the cursor does not move, which is what a terminal does.
            this.bellCount++;
            return;
        }

        this.consoleOutput += String.fromCharCode(code);

        // Past the right hand edge the cursor wraps to the next line, exactly
        // as the teletype service does on real hardware.
        if (++this.cursor.column < SCREEN_COLUMNS) return;

        this.cursor.column = 0;
        if (this.cursor.row < SCREEN_ROWS - 1) this.cursor.row++;
    }

    // -------------------------------------------------------------------------
    // EXECUTION BUDGET
    // -------------------------------------------------------------------------

    /**
     * Count one instruction.
     *
     * Deliberately without a ceiling. A program that never ends is not
     * necessarily wrong: a traffic light controller is supposed to run until
     * the power is cut. Deciding when to stop belongs to whoever is driving
     * the machine, so the executor holds the budget and this only counts.
     */
    countInstruction() {
        this.instructionCount++;
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
            exitCode:         this.exitCode,
            cursor:           { ...this.cursor },
            ports:            this.ports.snapshot(),
            files:            this.files.snapshot(),
            callDepth:        this.callTrace.length,
            stack:            this.peekStack()
        };
    }
}
