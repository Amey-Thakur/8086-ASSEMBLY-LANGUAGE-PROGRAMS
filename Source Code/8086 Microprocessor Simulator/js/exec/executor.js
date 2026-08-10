// -----------------------------------------------------------------------------
// Script Name: executor.js
// Module:      Execution, 1 of 3
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
import { ExecutionError, DEFAULT_CODE_SEGMENT,
         DEFAULT_DATA_SEGMENT, DEFAULT_STACK_SEGMENT } from '../cpu/cpu.js';
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

    /**
     * Resolve a symbol operand to a concrete value or address.
     *
     * @DATA and its companions are constants fixed when the program was
     * loaded, not readings of whatever the segment registers currently hold.
     * The distinction matters: a program that points DS somewhere else, as
     * LDS does, then restores it with MOV AX, @DATA. If @DATA reported the
     * live DS it would hand back the segment being replaced, and the restore
     * would silently do nothing.
     */
    resolveSymbol(name) {
        const upper = String(name).toUpperCase();

        if (upper === '@DATA')  return DEFAULT_DATA_SEGMENT;
        if (upper === '@STACK') return DEFAULT_STACK_SEGMENT;
        if (upper === '@CODE')  return DEFAULT_CODE_SEGMENT;

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
     * Find the instruction a misspelling was most likely meant to be.
     *
     * Almost every mistake of this kind is one wrong letter, one letter too
     * many or one too few, so anything more than two edits away is more likely
     * to be a different word than a typed one. Below three letters no
     * suggestion is offered at all, because at that length everything is close
     * to everything else.
     */
    nearestMnemonic(mnemonic) {
        const typed = String(mnemonic).toUpperCase();

        if (typed.length < 2) return null;

        // A short mnemonic cannot afford a large distance: at two letters, a
        // distance of two means nothing at all was recognisable. The allowance
        // grows with the length of what was typed.
        const allowed = typed.length <= 3 ? 2 : 3;

        let best     = null;
        let bestCost = allowed;
        let bestTie  = -1;

        for (const candidate of this.handlers.keys()) {
            const cost = editDistance(typed, candidate, bestCost + 1);

            if (cost > bestCost) continue;

            // Among candidates the same distance away, prefer the one that
            // shares more of its opening letters. People mistype the end of a
            // word far more often than the start, so JCXZ is a better answer for
            // JCX than LOOPZ is, even when both score the same.
            const tie = sharedPrefix(typed, candidate);

            if (cost < bestCost || tie > bestTie) {
                bestCost = cost;
                bestTie  = tie;
                best     = candidate;
            }
        }

        // A suggestion that shares nothing with what was typed is noise. One
        // letter in common at the start is the minimum for it to read as a
        // correction rather than as a random instruction.
        if (best !== null && bestTie < 1) return null;

        return best;
    }

    /**
     * The whole explanation for an unrecognised mnemonic.
     *
     * Three different things can be wrong, and they need different answers:
     * a typing slip wants the nearest mnemonic, a real instruction from a later
     * processor wants to be told so and given the 8086 equivalent, and something
     * unrecognisable wants no guess at all.
     */
    explainUnknown(mnemonic) {
        const later = laterInstruction(mnemonic);

        if (later) {
            const opening = `"${String(mnemonic).toUpperCase()}" is a real instruction, ` +
                            `but it arrived with the ${later.processor} and the 8086 ` +
                            `has not got it.`;

            return later.instead === null
                ? `${opening} There is no equivalent, because ${later.because}.`
                : `${opening} Use ${later.instead}.`;
        }

        const nearest = this.nearestMnemonic(mnemonic);

        return `"${mnemonic}" is not a recognised 8086 instruction` +
               (nearest ? `. Did you mean ${nearest}?` : '.');
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
                this.explainUnknown(instruction.mnemonic),
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

            // PUSH SP is the one case where the 8086 and every later processor
            // disagree. An 8086 and an 8088 decrement SP first and then store
            // the decremented value, so the word written is two less than SP
            // was. The 80286 changed this to store the original value, and the
            // difference was used for years as a way to tell the two apart.
            //
            // This emulates an 8086, so the decremented value is what goes on
            // the stack. Reading the operand after the decrement is all it
            // takes, and it changes nothing for any other register.
            if (operands[0].kind === OPERAND.REGISTER && operands[0].name === 'SP') {
                const lowered = (cpu.registers.get('SP') - 2) & 0xFFFF;

                cpu.registers.set('SP', lowered);
                cpu.memory.writeWord(cpu.registers.get('SS'), lowered, lowered);
                return;
            }

            cpu.push(this.read(operands[0], 2));
        });

        this.define(['POP'], operands => {
            expect(operands, 1, 'POP');
            this.write(operands[0], cpu.pop(), 2);
        });

        this.define(['PUSHF'], () => cpu.push(flags.toWord()));
        this.define(['POPF'],  () => flags.fromWord(cpu.pop()));

        // LAHF and SAHF move the low byte of the flags word through AH. They
        // exist because the 8086 was meant to be source compatible with the
        // 8080, whose flags lived in exactly those five bits.
        this.define(['LAHF'], () => {
            cpu.registers.set('AH', flags.toWord() & 0xFF);
        });

        this.define(['SAHF'], () => {
            const high = flags.toWord() & 0xFF00;

            flags.fromWord(high | cpu.registers.get('AH'));
        });

        // LDS and LES load a far pointer: four bytes in memory, the offset
        // first and then the segment. This is how a program picks up a pointer
        // that reaches outside its own data segment.
        const loadPointer = (mnemonic, segment) => {
            this.define([mnemonic], (operands, instruction) => {
                expect(operands, 2, mnemonic);

                if (operands[0].kind !== OPERAND.REGISTER) {
                    throw new ExecutionError(
                        `${mnemonic} loads a pointer into a register, and the first ` +
                        `operand is not one`,
                        instruction.line
                    );
                }

                // The pointer may be written either as a bracketed address or
                // as the name of the four bytes that hold it.
                if (operands[1].kind !== OPERAND.MEMORY &&
                    operands[1].kind !== OPERAND.SYMBOL) {
                    throw new ExecutionError(
                        `${mnemonic} reads its pointer from memory, so the second ` +
                        `operand has to be an address or a data name`,
                        instruction.line
                    );
                }

                const address = this.addressOf(operands[1]);
                const base    = segmentBaseOf(operands[1]);

                this.write(operands[0], cpu.readMemory(address, 2, base, operands[1].override), 2);
                cpu.registers.set(segment,
                    cpu.readMemory((address + 2) & 0xFFFF, 2, base, operands[1].override));
            });
        };

        loadPointer('LDS', 'DS');
        loadPointer('LES', 'ES');

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

        // WAIT holds the processor until the coprocessor signals that it has
        // finished, and ESC hands an instruction to that coprocessor. There is
        // no 8087 here, so both are accepted and do nothing, which is exactly
        // what a machine without one does.
        this.define(['WAIT', 'FWAIT'], () => { /* no coprocessor to wait for */ });
        this.define(['ESC'],           () => { /* no coprocessor to escape to */ });

        // LOCK holds the bus for the next instruction. On one processor with
        // nothing to contend with, there is nothing to hold it against. The
        // lexer already treats it as a prefix; this covers it written alone.
        this.define(['LOCK'], () => { /* single processor, nothing to lock out */ });

        // INTO raises interrupt 4 when the last signed operation overflowed. It
        // is how a program checks for overflow without writing a branch.
        this.define(['INTO'], (operands, instruction) => {
            if (!flags.OF) return;

            throw new ExecutionError(
                'signed overflow trapped by INTO (interrupt 4). The last signed ' +
                'operation produced a result too large for its destination.',
                instruction.line
            );
        });

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

// -----------------------------------------------------------------------------
// EDIT DISTANCE
//
// How many single character changes turn one word into another. Used only to
// suggest what a misspelled mnemonic was meant to be.
// -----------------------------------------------------------------------------

/**
 * @param {string} from
 * @param {string} to
 * @param {number} ceiling  give up once every path costs at least this much
 * @returns {number} the distance, or the ceiling if it is at least that far
 */
/** How many opening letters two mnemonics share. */
function sharedPrefix(from, to) {
    let shared = 0;

    while (shared < from.length && shared < to.length && from[shared] === to[shared]) {
        shared++;
    }

    return shared;
}

export function editDistance(from, to, ceiling = Infinity) {
    // A difference in length is a lower bound on the distance, so most
    // candidates can be dismissed without any work at all.
    if (Math.abs(from.length - to.length) >= ceiling) return ceiling;

    // Two rows of history rather than one, because swapping two adjacent
    // letters is counted as a single mistake. It is much the commonest typing
    // slip, and plain Levenshtein charges two for it, which is enough to push
    // the right answer out of reach: MVO to MOV would score two, the same as
    // two unrelated substitutions.
    let older    = null;
    let previous = Array.from({ length: to.length + 1 }, (_, index) => index);

    for (let row = 1; row <= from.length; row++) {
        const current = [row];

        let rowBest = row;

        for (let column = 1; column <= to.length; column++) {
            const substitute = previous[column - 1] + (from[row - 1] === to[column - 1] ? 0 : 1);

            let cost = Math.min(substitute, previous[column] + 1, current[column - 1] + 1);

            // A transposition: this letter matches the previous one of the other
            // word, and the previous one matches this.
            if (row > 1 && column > 1 &&
                from[row - 1] === to[column - 2] &&
                from[row - 2] === to[column - 1]) {
                cost = Math.min(cost, older[column - 2] + 1);
            }

            current[column] = cost;
            rowBest = Math.min(rowBest, cost);
        }

        if (rowBest >= ceiling) return ceiling;   // no path can improve from here

        older    = previous;
        previous = current;
    }

    return previous[to.length];
}

// -----------------------------------------------------------------------------
// INSTRUCTIONS THAT ARE REAL BUT NOT 8086
//
// Suggesting the nearest 8086 mnemonic for one of these is worse than saying
// nothing: MOVZX is not a misspelling of MOVSX, and telling somebody it might be
// sends them looking for a typing mistake that is not there. The honest answer
// is that the instruction exists, arrived later, and here is what to write
// instead.
//
// Every entry names the processor that introduced it and gives the 8086
// equivalent where there is one.
// -----------------------------------------------------------------------------
const LATER_INSTRUCTIONS = {
    // ---- 80186 ----
    PUSHA:  ['80186', 'individual pushes for the registers you need'],
    POPA:   ['80186', 'individual pops, in the reverse order'],
    ENTER:  ['80186', 'PUSH BP then MOV BP, SP then SUB SP, size'],
    LEAVE:  ['80186', 'MOV SP, BP then POP BP'],
    BOUND:  ['80186', 'compare against both limits with CMP and branch'],
    INS:    ['80186', 'IN to AL then STOSB, in a loop'],
    OUTS:   ['80186', 'LODSB then OUT, in a loop'],

    // ---- 80286 ----
    PUSHAD: ['80386', 'individual pushes for the registers you need'],
    POPAD:  ['80386', 'individual pops, in the reverse order'],
    ARPL:   ['80286', null, 'it belongs to protected mode, which the 8086 has not got'],
    LGDT:   ['80286', null, 'the 8086 has no descriptor tables'],
    LIDT:   ['80286', null, 'the 8086 interrupt table is fixed at address zero'],
    SMSW:   ['80286', null, 'the 8086 has no machine status word'],

    // ---- 80386 ----
    MOVZX:  ['80386', 'XOR AH, AH then MOV AL, source for a byte to a word'],
    MOVSX:  ['80386', 'MOV AL, source then CBW, which sign extends AL into AX'],
    BSF:    ['80386', 'shift right in a loop, counting until the carry comes out set'],
    BSR:    ['80386', 'shift left in a loop, counting until the carry comes out set'],
    BT:     ['80386', 'TEST against a mask, or AND a copy'],
    BTS:    ['80386', 'OR with a mask'],
    BTR:    ['80386', 'AND with the complement of a mask'],
    BTC:    ['80386', 'XOR with a mask'],
    SETcc:  ['80386', 'branch on the condition and load the value on each path'],
    CDQ:    ['80386', 'CWD, which is the sixteen bit equivalent'],
    SHLD:   ['80386', 'shift both halves separately and combine them'],
    SHRD:   ['80386', 'shift both halves separately and combine them'],
    BSWAP:  ['80486', 'XCHG AL, AH for a word'],
    CMOVE:  ['Pentium Pro', 'branch on the condition and move on one path only'],
    CMOVZ:  ['Pentium Pro', 'branch on the condition and move on one path only'],
    CPUID:  ['Pentium', null, 'there is no way to identify an 8086 from software'],
    RDTSC:  ['Pentium', 'read the timer tick count with INT 1Ah service 00h']
};

/**
 * The conditional set and move instructions come in dozens of spellings, and
 * listing every one would be noise. Anything matching these shapes is treated as
 * the family it belongs to.
 */
const LATER_FAMILIES = [
    [/^SET[A-Z]{1,3}$/, '80386',
     'branch on the condition and load the value on each path'],
    [/^CMOV[A-Z]{1,3}$/, 'Pentium Pro',
     'branch on the condition and move on one path only'],
    [/^(FADD|FSUB|FMUL|FDIV|FLD|FST|FSTP|FCOM|FSQRT|FSIN|FCOS|FILD|FINIT)[A-Z]*$/,
     '8087 coprocessor',
     'integer arithmetic, because the 8086 on its own has no floating point at all']
];

/**
 * Recognise a mnemonic that is a real instruction from a later processor.
 *
 * @returns {{processor: string, instead: string}|null}
 */
export function laterInstruction(mnemonic) {
    const typed = String(mnemonic).toUpperCase();

    if (Object.hasOwn(LATER_INSTRUCTIONS, typed)) {
        const [processor, instead, because = null] = LATER_INSTRUCTIONS[typed];

        return { processor, instead, because };
    }

    for (const [shape, processor, instead] of LATER_FAMILIES) {
        if (shape.test(typed)) return { processor, instead, because: null };
    }

    return null;
}

export { NO_OPERAND };
