// -----------------------------------------------------------------------------
// Script Name: operands.js
// Module:      Assembler, 2 of 3
// Stack:       JavaScript (ES2020), depends on lexer.js and registers.js
// Description: Parses a single operand into a structured descriptor the
//              executor can act on without re-reading text, and resolves memory
//              operands to an effective address at run time.
//
//              The 8086 does not permit arbitrary register arithmetic inside
//              brackets. Only these combinations are legal:
//
//                  base        BX or BP
//                  index       SI or DI
//                  either      base, index, base+index, any of those + disp
//
//              So [BX+SI] is valid and [AX+BX] is not. Accepting the illegal
//              forms would let a program assemble here and fail on real
//              hardware, which is worse than refusing it, so they are rejected
//              with a message naming the legal set.
//
// Authors:     Amey Thakur
// Repository:  https://github.com/Amey-Thakur/8086-ASSEMBLY-LANGUAGE-PROGRAMS
// License:     CC BY 4.0
// -----------------------------------------------------------------------------

'use strict';

import { parseNumber, SyntaxError8086 } from './lexer.js';
import { RegisterFile }                 from '../cpu/registers.js';

/** Operand kinds produced by this module. */
export const OPERAND = {
    REGISTER:  'register',
    IMMEDIATE: 'immediate',
    MEMORY:    'memory',
    SYMBOL:    'symbol'      // an unresolved name: a jump target or a data label
};

/** Registers legal as a base inside brackets. */
const BASE_REGISTERS  = new Set(['BX', 'BP']);

/** Registers legal as an index inside brackets. */
const INDEX_REGISTERS = new Set(['SI', 'DI']);

/** Segment registers usable as an override prefix. */
const OVERRIDE_SEGMENTS = new Set(['CS', 'DS', 'ES', 'SS']);

// -----------------------------------------------------------------------------
// PARSING
// -----------------------------------------------------------------------------

/**
 * Parse one operand.
 *
 * @param {string} text  the operand as written
 * @param {number} line  source line, for error messages
 * @returns {object} a descriptor: { kind, ... }
 */
export function parseOperand(text, line = null) {
    let token = String(text).trim();

    if (token === '') {
        throw new SyntaxError8086('empty operand', line);
    }

    // ---- explicit size hint: BYTE PTR [BX], WORD PTR value -------------------
    let width = null;

    const sizeHint = token.match(/^(BYTE|WORD)\s+PTR\s+(.+)$/i);
    if (sizeHint) {
        width = sizeHint[1].toUpperCase() === 'BYTE' ? 1 : 2;
        token = sizeHint[2].trim();
    }

    // ---- segment override: ES:[DI], DS:VALUE ---------------------------------
    let override = null;

    const overrideMatch = token.match(/^([A-Za-z]{2})\s*:\s*(.+)$/);
    if (overrideMatch && OVERRIDE_SEGMENTS.has(overrideMatch[1].toUpperCase())) {
        override = overrideMatch[1].toUpperCase();
        token    = overrideMatch[2].trim();
    }

    // ---- register ------------------------------------------------------------
    if (RegisterFile.exists(token)) {
        return {
            kind:  OPERAND.REGISTER,
            name:  token.toUpperCase(),
            width: RegisterFile.widthOf(token)
        };
    }

    // ---- bracketed memory reference -----------------------------------------
    if (token.startsWith('[') && token.endsWith(']')) {
        const inner  = token.slice(1, -1).trim();
        const memory = parseAddressExpression(inner, line);

        return { kind: OPERAND.MEMORY, ...memory, width, override };
    }

    // ---- immediate -----------------------------------------------------------
    const immediate = parseNumber(token);
    if (immediate !== null) {
        return { kind: OPERAND.IMMEDIATE, value: immediate, width };
    }

    // ---- a name: a label, a data symbol, or something like @DATA -------------
    if (/^[A-Za-z_@$?][A-Za-z0-9_@$?]*$/.test(token)) {
        return { kind: OPERAND.SYMBOL, name: token, width, override };
    }

    throw new SyntaxError8086(`cannot parse operand "${text}"`, line);
}

// -----------------------------------------------------------------------------
// ADDRESS EXPRESSIONS
//
// Handles the contents of the brackets: any of a base register, an index
// register, a symbol and a numeric displacement, combined with + or -.
// -----------------------------------------------------------------------------
export function parseAddressExpression(inner, line = null) {
    if (inner === '') {
        throw new SyntaxError8086('empty address expression "[]"', line);
    }

    // Split into signed terms while keeping each sign attached to its term.
    const terms = inner
        .replace(/\s+/g, '')
        .replace(/-/g, '+-')
        .split('+')
        .filter(term => term !== '');

    let base         = null;
    let index        = null;
    let displacement = 0;
    let symbol       = null;

    for (const term of terms) {
        const negative = term.startsWith('-');
        const body     = negative ? term.slice(1) : term;
        const upper    = body.toUpperCase();

        if (BASE_REGISTERS.has(upper)) {
            if (base) throw new SyntaxError8086(`two base registers in "[${inner}]"`, line);
            if (negative) throw new SyntaxError8086(`a register cannot be negated in "[${inner}]"`, line);
            base = upper;
            continue;
        }

        if (INDEX_REGISTERS.has(upper)) {
            if (index) throw new SyntaxError8086(`two index registers in "[${inner}]"`, line);
            if (negative) throw new SyntaxError8086(`a register cannot be negated in "[${inner}]"`, line);
            index = upper;
            continue;
        }

        // Any other register is rejected outright rather than silently accepted.
        if (RegisterFile.exists(upper)) {
            throw new SyntaxError8086(
                `${upper} cannot be used inside brackets on the 8086. ` +
                `Only BX or BP as a base, and SI or DI as an index.`,
                line
            );
        }

        const numeric = parseNumber(body);
        if (numeric !== null) {
            displacement += negative ? -numeric : numeric;
            continue;
        }

        if (/^[A-Za-z_@$?][A-Za-z0-9_@$?]*$/.test(body)) {
            if (symbol) throw new SyntaxError8086(`two symbols in "[${inner}]"`, line);
            symbol = body;
            continue;
        }

        throw new SyntaxError8086(`cannot parse "${term}" inside "[${inner}]"`, line);
    }

    return { base, index, displacement, symbol };
}

// -----------------------------------------------------------------------------
// EFFECTIVE ADDRESS
//
// Computes the offset a memory operand refers to, given the live machine. The
// sum wraps at sixteen bits, exactly as the address adder does in hardware.
// -----------------------------------------------------------------------------
export function effectiveAddress(cpu, operand, symbols = {}) {
    let offset = operand.displacement | 0;

    if (operand.symbol) {
        if (!Object.hasOwn(symbols, operand.symbol)) {
            throw new SyntaxError8086(`unknown symbol "${operand.symbol}"`);
        }
        offset += symbols[operand.symbol].offset;
    }

    if (operand.base)  offset += cpu.registers.get(operand.base);
    if (operand.index) offset += cpu.registers.get(operand.index);

    return offset & 0xFFFF;
}

/**
 * Which register decides the default segment for this operand.
 *
 * The base register wins when present, because [BP+SI] is a stack reference
 * even though SI is a data-segment register on its own.
 */
export function segmentBaseOf(operand) {
    return operand.base ?? operand.index ?? null;
}
