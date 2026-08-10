// -----------------------------------------------------------------------------
// Script Name: executor.js
// Module:      Execution, 1 of 4
// Stack:       JavaScript (ES2020), depends on the CPU core and the assembler
// Description: Executes one assembled instruction at a time against a live CPU.
//
//              Responsibilities are deliberately narrow. This file resolves
//              operands to values, dispatches on the mnemonic, and moves the
//              instruction pointer. It does not know how to shift, how to
//              multiply, or how the flags work; those belong to the core
//              modules and are called into. Keeping the dispatch free of
//              arithmetic is what makes both halves testable.
//
//              Operand width is inferred rather than assumed. A register
//              operand states its own width, an explicit BYTE PTR or WORD PTR
//              overrides everything, and only when neither is present does the
//              executor fall back to a word. Guessing wrongly here is how an
//              emulator ends up writing two bytes where the program meant one.
//
// Authors:     Amey Thakur
// Repository:  https://github.com/Amey-Thakur/8086-ASSEMBLY-LANGUAGE-PROGRAMS
// License:     CC BY 4.0
// -----------------------------------------------------------------------------

'use strict';

import { OPERAND, effectiveAddress, segmentBaseOf } from '../asm/operands.js';
import { SYMBOL }                                   from '../asm/assembler.js';
import { Shifter, SHIFT_OPERATIONS }                from '../cpu/shifter.js';
import { ALU, DivideError }                         from '../cpu/alu.js';
import { ExecutionError }                           from '../cpu/cpu.js';
import { registerStringHandlers }                   from './strings.js';
import { registerInterruptHandlers }                from './interrupts.js';

/** Conditional jumps, mapped to a predicate over the flag register. Several
 *  mnemonics are synonyms, which is why the table is keyed by every spelling
 *  a student might reasonably write. */
/** How many instructions one call to run() will execute before handing control
 *  back. Sized so a browser frame is never held for long. */
export const RUN_BUDGET = 500_000;

/** The point at which runToCompletion() gives up and calls it a runaway loop.
 *  Set above the cost of a real one second delay loop, which is about thirty
 *  five million instructions, so that genuine timing code still finishes. */
export const COMPLETION_CEILING = 80_000_000;

export const JUMP_CONDITIONS = {
    JE:   f => f.ZF === 1,                       JZ:   f => f.ZF === 1,
    JNE:  f => f.ZF === 0,                       JNZ:  f => f.ZF === 0,
    JC:   f => f.CF === 1,                       JB:   f => f.CF === 1,
    JNAE: f => f.CF === 1,                       JNC:  f => f.CF === 0,
    JNB:  f => f.CF === 0,                       JAE:  f => f.CF === 0,
    JA:   f => f.CF === 0 && f.ZF === 0,         JNBE: f => f.CF === 0 && f.ZF === 0,
    JBE:  f => f.CF === 1 || f.ZF === 1,         JNA:  f => f.CF === 1 || f.ZF === 1,
    JS:   f => f.SF === 1,                       JNS:  f => f.SF === 0,
    JO:   f => f.OF === 1,                       JNO:  f => f.OF === 0,
    JP:   f => f.PF === 1,                       JPE:  f => f.PF === 1,
    JNP:  f => f.PF === 0,                       JPO:  f => f.PF === 0,
    JL:   f => f.SF !== f.OF,                    JNGE: f => f.SF !== f.OF,
    JGE:  f => f.SF === f.OF,                    JNL:  f => f.SF === f.OF,
    JLE:  f => f.ZF === 1 || f.SF !== f.OF,      JNG:  f => f.ZF === 1 || f.SF !== f.OF,
    JG:   f => f.ZF === 0 && f.SF === f.OF,      JNLE: f => f.ZF === 0 && f.SF === f.OF
};

/** Instructions that only ever act on a single implied operand or none. */
const NO_OPERAND = new Set([
    'NOP', 'HLT', 'RET', 'IRET', 'CLC', 'STC', 'CMC', 'CLD', 'STD', 'CLI', 'STI',
    'PUSHF', 'POPF', 'CBW', 'CWD', 'DAA', 'DAS', 'AAA', 'AAS', 'XLAT', 'XLATB'
]);

// -----------------------------------------------------------------------------
// EXECUTOR
// -----------------------------------------------------------------------------
export class Executor {

    /**
     * @param {CPU}    cpu      the machine to run against
     * @param {object} program  the assembler's output
     */
    constructor(cpu, program) {
        this.cpu     = cpu;
        this.program = program;
        this.handlers = new Map();

        this.registerHandlers();
    }

    // -------------------------------------------------------------------------
    // OPERAND ACCESS
    // -------------------------------------------------------------------------

    /**
     * Decide how many bytes an operation moves.
     *
     * Order of authority: an explicit size hint, then any register operand,
     * then a data symbol's declared width, and only then the word default.
     */
    widthOf(...operands) {
        for (const operand of operands) {
            if (operand?.width) return operand.width;
        }

        for (const operand of operands) {
            if (operand?.kind === OPERAND.REGISTER) return operand.width;
        }

        for (const operand of operands) {
            const named = operand?.symbol ?? (operand?.kind === OPERAND.SYMBOL ? operand.name : null);

            if (named) {
                const symbol = this.program.symbols[named.toUpperCase()];

                if (symbol?.kind === SYMBOL.DATA) return symbol.width;
            }
        }

        return 2;
    }

    /** Resolve a symbol operand to a concrete value or address. */
    resolveSymbol(name) {
        const upper = String(name).toUpperCase();

        if (upper === '@DATA' || upper === '@STACK') return this.cpu.registers.get('DS');
        if (upper === '@CODE') return this.cpu.registers.get('CS');

        const symbol = this.program.symbols[upper];

        if (!symbol) throw new ExecutionError(`"${name}" is not defined`);

        return symbol;
    }

    /** Read the value an operand denotes. */
    read(operand, width) {
        switch (operand.kind) {

            case OPERAND.IMMEDIATE:
                return operand.value & (width === 1 ? 0xFF : 0xFFFF);

            case OPERAND.REGISTER:
                return this.cpu.registers.get(operand.name);

            case OPERAND.MEMORY: {
                const offset = effectiveAddress(this.cpu, operand, this.program.symbols);

                return this.cpu.readMemory(offset, width, segmentBaseOf(operand), operand.override);
            }

            case OPERAND.SYMBOL: {
                const symbol = this.resolveSymbol(operand.name);

                // A bare constant or segment value reads as itself.
                if (typeof symbol === 'number') return symbol;
                if (symbol.kind === SYMBOL.CONSTANT) return symbol.value & 0xFFFF;
                if (symbol.kind === SYMBOL.CODE)     return symbol.index & 0xFFFF;

                // A data name used as a value means the contents at that offset.
                return this.cpu.readMemory(symbol.offset, width, null, operand.override);
            }

            default:
                throw new ExecutionError(`cannot read operand of kind "${operand.kind}"`);
        }
    }

    /** Write a value to whatever an operand denotes. */
    write(operand, value, width) {
        switch (operand.kind) {

            case OPERAND.REGISTER:
                this.cpu.registers.set(operand.name, value);
                return;

            case OPERAND.MEMORY: {
                const offset = effectiveAddress(this.cpu, operand, this.program.symbols);

                this.cpu.writeMemory(offset, value, width, segmentBaseOf(operand), operand.override);
                return;
            }

            case OPERAND.SYMBOL: {
                const symbol = this.resolveSymbol(operand.name);

                if (typeof symbol === 'number' || symbol.kind !== SYMBOL.DATA) {
                    throw new ExecutionError(`"${operand.name}" cannot be written to`);
                }
                this.cpu.writeMemory(symbol.offset, value, width, null, operand.override);
                return;
            }

            default:
                throw new ExecutionError('an immediate value cannot be a destination');
        }
    }

    /** The offset a symbol or memory operand refers to, without reading it.
     *  This is what LEA needs. */
    addressOf(operand) {
        if (operand.kind === OPERAND.MEMORY) {
            return effectiveAddress(this.cpu, operand, this.program.symbols);
        }

        if (operand.kind === OPERAND.SYMBOL) {
            const symbol = this.resolveSymbol(operand.name);

            if (typeof symbol !== 'number' && symbol.kind === SYMBOL.DATA) return symbol.offset;
            if (typeof symbol !== 'number' && symbol.kind === SYMBOL.CONSTANT) return symbol.value;
        }

        throw new ExecutionError('LEA needs a memory operand');
    }

    /**
     * Resolve a branch target to an instruction index.
     *
     * A target is usually a label, but it may also be held in a register or in
     * memory. "JMP TABLE[BX]" reads the word the table holds and jumps there,
     * which is how a switch statement is written in assembly.
     */
    branchTarget(operand) {
        if (operand.kind === OPERAND.SYMBOL) {
            const symbol = this.resolveSymbol(operand.name);

            if (typeof symbol !== 'number' && symbol.kind === SYMBOL.CODE) return symbol.index;

            // A data name used as a target holds the address to jump to.
            if (typeof symbol !== 'number' && symbol.kind === SYMBOL.DATA) {
                return this.cpu.readMemory(symbol.offset, 2);
            }

            throw new ExecutionError(`"${operand.name}" is not a jump target`);
        }

        if (operand.kind === OPERAND.IMMEDIATE) return operand.value;
        if (operand.kind === OPERAND.REGISTER)  return this.read(operand, 2);
        if (operand.kind === OPERAND.MEMORY)    return this.read(operand, 2);

        throw new ExecutionError('a jump needs a label');
    }

    /**
     * Work out which port an IN or OUT is addressing.
     *
     * An immediate port number fits in one byte. Anything above that has to be
     * placed in DX first, which is why "OUT DX, AL" is so common.
     */
    portNumber(operand, instruction) {
        if (operand.kind === OPERAND.REGISTER) {
            if (operand.name !== 'DX') {
                throw new ExecutionError(
                    `only DX can hold a port number, not ${operand.name}`,
                    instruction?.line
                );
            }
            return this.cpu.registers.get('DX');
        }

        return this.read(operand, 2) & 0xFFFF;
    }

    // -------------------------------------------------------------------------
    // DISPATCH
    // -------------------------------------------------------------------------

    define(mnemonics, handler) {
        for (const mnemonic of mnemonics) {
            this.handlers.set(mnemonic, handler);
        }
    }

    /**
     * Execute the instruction at IP. Advances IP first, so a handler that
     * branches simply overwrites it, exactly as the real fetch cycle behaves.
     *
     * @returns {boolean} false once the machine has halted
     */
    step() {
        const cpu   = this.cpu;
        const index = cpu.registers.get('IP');

        if (cpu.halted) return false;

        if (index >= this.program.instructions.length) {
            cpu.halted = true;
            return false;
        }

        const instruction = this.program.instructions[index];

        cpu.registers.set('IP', index + 1);
        cpu.countInstruction();

        const handler = this.handlers.get(instruction.mnemonic);

        if (!handler) {
            throw new ExecutionError(
                `"${instruction.mnemonic}" is not a recognised 8086 instruction`,
                instruction.line
            );
        }

        try {
            handler(instruction.operands, instruction);
        } catch (error) {
            if (error instanceof DivideError) {
                throw new ExecutionError(`${error.message} (interrupt 0)`, instruction.line);
            }
            if (error instanceof ExecutionError && error.line === null) {
                error.line = instruction.line;
            }
            throw error;
        }

        return !cpu.halted;
    }

    /**
     * Run until the program stops or the budget for this call runs out.
     *
     * A budget is necessary because a program is allowed to loop forever: a
     * traffic light controller or a keyboard monitor is supposed to. Running
     * out of budget is therefore not an error, it just means the program is
     * still going, and calling run() again continues from where it stopped.
     * That is what keeps the page responsive without lying about the program.
     *
     * @param {number} budget  instructions to execute before returning
     * @returns {{reason: 'halted'|'running', executed: number}}
     */
    run(budget = RUN_BUDGET) {
        let executed = 0;

        while (executed < budget) {
            if (!this.step()) {
                return { reason: 'halted', executed, snapshot: this.cpu.snapshot() };
            }
            executed++;
        }

        return { reason: 'running', executed, snapshot: this.cpu.snapshot() };
    }

    /** Run to completion, however long that takes. Used by the test suites,
     *  where blocking is acceptable and a definite answer is what is wanted. */
    runToCompletion(ceiling = COMPLETION_CEILING) {
        let executed = 0;

        while (executed < ceiling) {
            if (!this.step()) return this.cpu.snapshot();
            executed++;
        }

        throw new ExecutionError(
            `execution stopped after ${ceiling.toLocaleString('en-US')} instructions, ` +
            `which usually means a loop never terminates`
        );
    }

    // -------------------------------------------------------------------------
    // INSTRUCTION HANDLERS
    // -------------------------------------------------------------------------
    registerHandlers() {
        const cpu   = this.cpu;
        const flags = this.cpu.flags;

        const expect = (operands, count, mnemonic) => {
            if (operands.length !== count) {
                throw new ExecutionError(
                    `${mnemonic} expects ${count} operand${count === 1 ? '' : 's'}, ` +
                    `found ${operands.length}`
                );
            }
        };

        // ---- data movement ---------------------------------------------------
        this.define(['MOV'], operands => {
            expect(operands, 2, 'MOV');
            const width = this.widthOf(operands[0], operands[1]);

            this.write(operands[0], this.read(operands[1], width), width);
        });

        this.define(['XCHG'], operands => {
            expect(operands, 2, 'XCHG');
            const width = this.widthOf(operands[0], operands[1]);
            const left  = this.read(operands[0], width);
            const right = this.read(operands[1], width);

            this.write(operands[0], right, width);
            this.write(operands[1], left,  width);
        });

        this.define(['LEA'], operands => {
            expect(operands, 2, 'LEA');
            this.write(operands[0], this.addressOf(operands[1]), 2);
        });

        this.define(['PUSH'], operands => {
            expect(operands, 1, 'PUSH');
            cpu.push(this.read(operands[0], 2));
        });

        this.define(['POP'], operands => {
            expect(operands, 1, 'POP');
            this.write(operands[0], cpu.pop(), 2);
        });

        this.define(['PUSHF'], () => cpu.push(flags.toWord()));
        this.define(['POPF'],  () => flags.fromWord(cpu.pop()));

        // XLAT reads the byte at DS:BX+AL, the classic lookup table instruction.
        this.define(['XLAT', 'XLATB'], () => {
            const offset = (cpu.registers.get('BX') + cpu.registers.get('AL')) & 0xFFFF;

            cpu.registers.set('AL', cpu.readMemory(offset, 1, 'BX'));
        });

        // ---- arithmetic ------------------------------------------------------
        const arithmetic = (mnemonic, compute, writesBack) => {
            this.define([mnemonic], operands => {
                expect(operands, 2, mnemonic);
                const width = this.widthOf(operands[0], operands[1]);
                const left  = this.read(operands[0], width);
                const right = this.read(operands[1], width);
                const result = compute(left, right, width);

                if (writesBack) this.write(operands[0], result, width);
            });
        };

        arithmetic('ADD', (a, b, w) => flags.applyAddition(a, b, 0, w), true);
        arithmetic('ADC', (a, b, w) => flags.applyAddition(a, b, flags.CF, w), true);
        arithmetic('SUB', (a, b, w) => flags.applySubtraction(a, b, 0, w), true);
        arithmetic('SBB', (a, b, w) => flags.applySubtraction(a, b, flags.CF, w), true);
        arithmetic('CMP', (a, b, w) => flags.applySubtraction(a, b, 0, w), false);

        this.define(['INC'], operands => {
            expect(operands, 1, 'INC');
            const width = this.widthOf(operands[0]);

            this.write(operands[0], flags.applyIncrement(this.read(operands[0], width), width), width);
        });

        this.define(['DEC'], operands => {
            expect(operands, 1, 'DEC');
            const width = this.widthOf(operands[0]);

            this.write(operands[0], flags.applyDecrement(this.read(operands[0], width), width), width);
        });

        this.define(['NEG'], operands => {
            expect(operands, 1, 'NEG');
            const width = this.widthOf(operands[0]);

            this.write(operands[0], ALU.negate(flags, this.read(operands[0], width), width), width);
        });

        this.define(['MUL'],  operands => {
            expect(operands, 1, 'MUL');
            const width = this.widthOf(operands[0]);
            ALU.multiply(cpu.registers, flags, this.read(operands[0], width), width);
        });

        this.define(['IMUL'], operands => {
            expect(operands, 1, 'IMUL');
            const width = this.widthOf(operands[0]);
            ALU.multiplySigned(cpu.registers, flags, this.read(operands[0], width), width);
        });

        this.define(['DIV'],  operands => {
            expect(operands, 1, 'DIV');
            const width = this.widthOf(operands[0]);
            ALU.divide(cpu.registers, flags, this.read(operands[0], width), width);
        });

        this.define(['IDIV'], operands => {
            expect(operands, 1, 'IDIV');
            const width = this.widthOf(operands[0]);
            ALU.divideSigned(cpu.registers, flags, this.read(operands[0], width), width);
        });

        this.define(['CBW'], () => ALU.convertByteToWord(cpu.registers));
        this.define(['CWD'], () => ALU.convertWordToDouble(cpu.registers));
        this.define(['DAA'], () => ALU.decimalAdjustAfterAddition(cpu.registers, flags));
        this.define(['DAS'], () => ALU.decimalAdjustAfterSubtraction(cpu.registers, flags));
        this.define(['AAA'], () => ALU.asciiAdjustAfterAddition(cpu.registers, flags));
        this.define(['AAS'], () => ALU.asciiAdjustAfterSubtraction(cpu.registers, flags));

        this.define(['AAM'], operands => {
            const base = operands.length ? this.read(operands[0], 1) : 10;
            ALU.asciiAdjustAfterMultiply(cpu.registers, flags, base);
        });

        this.define(['AAD'], operands => {
            const base = operands.length ? this.read(operands[0], 1) : 10;
            ALU.asciiAdjustBeforeDivide(cpu.registers, flags, base);
        });

        // ---- logic -----------------------------------------------------------
        const logical = (mnemonic, combine, writesBack) => {
            this.define([mnemonic], operands => {
                expect(operands, 2, mnemonic);
                const width  = this.widthOf(operands[0], operands[1]);
                const result = flags.applyLogical(
                    combine(this.read(operands[0], width), this.read(operands[1], width)), width
                );

                if (writesBack) this.write(operands[0], result, width);
            });
        };

        logical('AND',  (a, b) => a & b, true);
        logical('OR',   (a, b) => a | b, true);
        logical('XOR',  (a, b) => a ^ b, true);
        logical('TEST', (a, b) => a & b, false);

        // NOT is the one logical operation that touches no flag at all.
        this.define(['NOT'], operands => {
            expect(operands, 1, 'NOT');
            const width = this.widthOf(operands[0]);
            const mask  = width === 1 ? 0xFF : 0xFFFF;

            this.write(operands[0], (~this.read(operands[0], width)) & mask, width);
        });

        // ---- shifts and rotates ----------------------------------------------
        this.define(SHIFT_OPERATIONS, (operands, instruction) => {
            const width = this.widthOf(operands[0]);
            const value = this.read(operands[0], width);

            // A missing second operand means a count of one, which is how
            // "SHL AL" is written in a good deal of student code.
            const count = operands.length > 1 ? this.read(operands[1], 1) : 1;

            this.write(operands[0],
                       Shifter.execute(flags, instruction.mnemonic, value, count, width),
                       width);
        });

        // ---- control transfer -------------------------------------------------
        this.define(['JMP'], operands => {
            expect(operands, 1, 'JMP');
            cpu.jumpTo(this.branchTarget(operands[0]));
        });

        for (const [mnemonic, predicate] of Object.entries(JUMP_CONDITIONS)) {
            this.define([mnemonic], operands => {
                expect(operands, 1, mnemonic);
                if (predicate(flags)) cpu.jumpTo(this.branchTarget(operands[0]));
            });
        }

        this.define(['JCXZ'], operands => {
            expect(operands, 1, 'JCXZ');
            if (cpu.registers.get('CX') === 0) cpu.jumpTo(this.branchTarget(operands[0]));
        });

        // LOOP decrements CX and branches while it is non zero. CX is decremented
        // BEFORE the test, so CX = 1 runs the body once more and then falls out.
        const loop = (mnemonic, extra) => {
            this.define([mnemonic], operands => {
                expect(operands, 1, mnemonic);
                const remaining = (cpu.registers.get('CX') - 1) & 0xFFFF;

                cpu.registers.set('CX', remaining);

                if (remaining !== 0 && extra(flags)) cpu.jumpTo(this.branchTarget(operands[0]));
            });
        };

        loop('LOOP',   () => true);
        loop('LOOPE',  f => f.ZF === 1);
        loop('LOOPZ',  f => f.ZF === 1);
        loop('LOOPNE', f => f.ZF === 0);
        loop('LOOPNZ', f => f.ZF === 0);

        this.define(['CALL'], operands => {
            expect(operands, 1, 'CALL');
            cpu.callTo(this.branchTarget(operands[0]),
                       operands[0].kind === OPERAND.SYMBOL ? operands[0].name : null);
        });

        this.define(['RET', 'RETN', 'RETF'], operands => {
            const discard = operands.length ? this.read(operands[0], 2) : 0;
            cpu.returnFromCall(discard);
        });

        // ---- port input and output --------------------------------------------
        // A peripheral lives in its own address space, reached only by IN and
        // OUT. The port number is either an immediate or, when it needs more
        // than eight bits, whatever is in DX.
        this.define(['IN'], (operands, instruction) => {
            expect(operands, 2, 'IN');

            const width = operands[0].name === 'AL' ? 1 : 2;
            const port  = this.portNumber(operands[1], instruction);

            this.write(operands[0], cpu.ports.read(port, width), width);
        });

        this.define(['OUT'], (operands, instruction) => {
            expect(operands, 2, 'OUT');

            const width = operands[1].name === 'AL' ? 1 : 2;
            const port  = this.portNumber(operands[0], instruction);

            cpu.ports.write(port, this.read(operands[1], width), width);
        });

        // ---- flag control -----------------------------------------------------
        this.define(['CLC'], () => { flags.CF = 0; });
        this.define(['STC'], () => { flags.CF = 1; });
        this.define(['CMC'], () => { flags.CF = flags.CF ? 0 : 1; });
        this.define(['CLD'], () => { flags.DF = 0; });
        this.define(['STD'], () => { flags.DF = 1; });
        this.define(['CLI'], () => { flags.IF = 0; });
        this.define(['STI'], () => { flags.IF = 1; });

        // ---- machine control --------------------------------------------------
        this.define(['NOP'], () => { /* deliberately nothing */ });
        this.define(['HLT'], () => { cpu.halted = true; });

        // ---- delegated groups -------------------------------------------------
        // String handling and the DOS services are large enough to own their own
        // files. They register into this same dispatch table.
        registerStringHandlers(this);
        registerInterruptHandlers(this);
    }

    /** True when the executor knows the mnemonic. Used by the editor to
     *  underline unknown instructions before the program is ever run. */
    knows(mnemonic) {
        return this.handlers.has(String(mnemonic).toUpperCase());
    }
}

export { NO_OPERAND };
