// -----------------------------------------------------------------------------
// Script Name: strings.js
// Module:      Execution, 3 of 4
// Stack:       JavaScript (ES2020), depends on the CPU core
// Description: The 8086 string instructions: MOVS, CMPS, SCAS, LODS and STOS,
//              together with the REP, REPE and REPNE prefixes.
//
//              Three rules govern all of them and are easy to get wrong:
//
//                - the SOURCE is DS:SI and may be overridden, but the
//                  DESTINATION is always ES:DI and may not be. This asymmetry
//                  is architectural, not a simplification.
//
//                - after each element SI and DI move by the operand size, and
//                  the DIRECTION FLAG decides the sign. DF clear counts up,
//                  DF set counts down, which is what makes a backwards copy of
//                  overlapping memory possible.
//
//                - REP tests CX BEFORE each iteration, so a count of zero
//                  executes the instruction zero times rather than once. The
//                  conditional forms also test ZF AFTER each iteration.
//
// Authors:     Amey Thakur
// Repository:  https://github.com/Amey-Thakur/8086-ASSEMBLY-LANGUAGE-PROGRAMS
// License:     CC BY 4.0
// -----------------------------------------------------------------------------

'use strict';

import { ExecutionError } from '../cpu/cpu.js';

/** The string operations, and how wide each element is. */
export const STRING_OPERATIONS = {
    MOVSB: { operation: 'MOVS', width: 1 },  MOVSW: { operation: 'MOVS', width: 2 },
    CMPSB: { operation: 'CMPS', width: 1 },  CMPSW: { operation: 'CMPS', width: 2 },
    SCASB: { operation: 'SCAS', width: 1 },  SCASW: { operation: 'SCAS', width: 2 },
    LODSB: { operation: 'LODS', width: 1 },  LODSW: { operation: 'LODS', width: 2 },
    STOSB: { operation: 'STOS', width: 1 },  STOSW: { operation: 'STOS', width: 2 }
};

/** Repeat prefixes and the extra condition each one applies after an element. */
export const REPEAT_PREFIXES = {
    REP:    null,                 // repeat while CX is non zero
    REPE:   flags => flags.ZF === 1,
    REPZ:   flags => flags.ZF === 1,
    REPNE:  flags => flags.ZF === 0,
    REPNZ:  flags => flags.ZF === 0
};

// -----------------------------------------------------------------------------
// ONE ELEMENT
// -----------------------------------------------------------------------------

/**
 * Perform a single string element, then advance SI and DI as the direction
 * flag dictates.
 */
export function executeStringElement(cpu, operation, width, sourceOverride = null) {
    const step = cpu.flags.DF ? -width : width;

    switch (operation) {

        // Copy DS:SI to ES:DI. Both pointers move.
        case 'MOVS': {
            const value = cpu.readMemory(cpu.registers.get('SI'), width, 'SI', sourceOverride);

            cpu.writeExtraSegment(cpu.registers.get('DI'), value, width);
            advance(cpu, ['SI', 'DI'], step);
            return;
        }

        // Compare DS:SI against ES:DI and set the flags as SUB would, without
        // storing anything. Both pointers move.
        case 'CMPS': {
            const left  = cpu.readMemory(cpu.registers.get('SI'), width, 'SI', sourceOverride);
            const right = cpu.readExtraSegment(cpu.registers.get('DI'), width);

            cpu.flags.applySubtraction(left, right, 0, width);
            advance(cpu, ['SI', 'DI'], step);
            return;
        }

        // Compare the accumulator against ES:DI. Only DI moves.
        case 'SCAS': {
            const accumulator = width === 1 ? cpu.registers.get('AL') : cpu.registers.get('AX');
            const value       = cpu.readExtraSegment(cpu.registers.get('DI'), width);

            cpu.flags.applySubtraction(accumulator, value, 0, width);
            advance(cpu, ['DI'], step);
            return;
        }

        // Load DS:SI into the accumulator. Only SI moves.
        case 'LODS': {
            const value = cpu.readMemory(cpu.registers.get('SI'), width, 'SI', sourceOverride);

            cpu.registers.set(width === 1 ? 'AL' : 'AX', value);
            advance(cpu, ['SI'], step);
            return;
        }

        // Store the accumulator at ES:DI. Only DI moves.
        case 'STOS': {
            const accumulator = width === 1 ? cpu.registers.get('AL') : cpu.registers.get('AX');

            cpu.writeExtraSegment(cpu.registers.get('DI'), accumulator, width);
            advance(cpu, ['DI'], step);
            return;
        }

        default:
            throw new ExecutionError(`unknown string operation "${operation}"`);
    }
}

/** Move the named pointers by step, wrapping at sixteen bits. */
function advance(cpu, registers, step) {
    for (const name of registers) {
        cpu.registers.set(name, (cpu.registers.get(name) + step) & 0xFFFF);
    }
}

// -----------------------------------------------------------------------------
// REPEATED EXECUTION
// -----------------------------------------------------------------------------

/**
 * Run a string operation under a repeat prefix.
 *
 * CX is tested first, so REP with CX = 0 performs no work at all. For the
 * conditional prefixes the ZF test happens after each element, which is what
 * lets REPNE SCASB stop on the element it found rather than one past it.
 */
export function executeRepeated(cpu, prefix, operation, width, sourceOverride = null) {
    const condition = REPEAT_PREFIXES[prefix];

    if (condition === undefined) {
        throw new ExecutionError(`unknown repeat prefix "${prefix}"`);
    }

    while (cpu.registers.get('CX') !== 0) {
        executeStringElement(cpu, operation, width, sourceOverride);

        cpu.registers.set('CX', (cpu.registers.get('CX') - 1) & 0xFFFF);
        cpu.countInstruction();

        if (condition && !condition(cpu.flags)) break;
    }
}

// -----------------------------------------------------------------------------
// REGISTRATION
// -----------------------------------------------------------------------------

/**
 * Add the string instructions to an executor's dispatch table.
 *
 * The lexer has already lifted any REP off the front of the line and recorded
 * it as instruction.prefix, so each handler covers both the bare form and the
 * repeated one.
 */
export function registerStringHandlers(executor) {
    const cpu = executor.cpu;

    for (const [mnemonic, spec] of Object.entries(STRING_OPERATIONS)) {
        executor.define([mnemonic], (operands, instruction) => {
            const prefix = instruction?.prefix;

            if (!prefix) {
                executeStringElement(cpu, spec.operation, spec.width);
                return;
            }

            executeRepeated(cpu, prefix, spec.operation, spec.width);
        });
    }

    // A repeat prefix with nothing to repeat reaches the dispatcher as an
    // instruction in its own right. Say what is wrong rather than reporting it
    // as an unrecognised mnemonic.
    for (const prefix of Object.keys(REPEAT_PREFIXES)) {
        executor.define([prefix], (operands, instruction) => {
            throw new ExecutionError(
                `${prefix} must be followed by a string instruction such as MOVSB or SCASB`,
                instruction?.line
            );
        });
    }
}
