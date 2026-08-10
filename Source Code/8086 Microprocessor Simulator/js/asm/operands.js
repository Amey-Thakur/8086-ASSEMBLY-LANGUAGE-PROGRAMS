// -----------------------------------------------------------------------------
// Script Name: operands.js
// Module:      Assembler, 4 of 5
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
import { evaluateExpression }           from './expressions.js';
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
export function parseOperand(text, line = null, context = null) {
    let token = String(text).trim();

    if (token === '') {
        throw new SyntaxError8086('empty operand', line);
    }

    // ---- explicit size hint: BYTE PTR [BX], WORD PTR value -------------------
    let width = null;

    // Adjacent bracket groups are the older way of writing one address:
    // [BX][SI] and [BX+SI] mean the same thing.
    token = token.replace(/\]\s*\[/g, '+');

    const sizeHint = token.match(/^(BYTE|WORD)\s+PTR\s*(.+)$/i);
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
        const memory = parseAddressExpression(inner, line, context);

        return { kind: OPERAND.MEMORY, ...memory, width, override };
    }

    // ---- indexed direct reference: ARR[SI], QUEUE_BUF[BX] --------------------
    // The name supplies the base address and the brackets the displacement, so
    // this means exactly the same thing as [ARR+SI] and is the form the
    // programs in this repository were written with.
    const indexed = token.match(/^([A-Za-z_@$?][A-Za-z0-9_@$?]*)\s*\[([^\]]+)\]$/);

    if (indexed) {
        const memory = parseAddressExpression(indexed[2], line, context);

        if (memory.symbol) {
            throw new SyntaxError8086(`two symbols in "${token}"`, line);
        }

        return { kind: OPERAND.MEMORY, ...memory, symbol: indexed[1], width, override };
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

    // ---- anything else is an expression: OFFSET MSG, LEN / 2, BUF + 1 --------
    // The assembler folds these to a number. A data name taking part without
    // OFFSET makes the result an address rather than a value, which is the
    // difference between "BUF+1" and "OFFSET BUF+1".
    if (context) {
        const { value, reference } = evaluateExpression(token, context);

        if (reference === null) {
            return { kind: OPERAND.IMMEDIATE, value: value & 0xFFFF, width };
        }

        const referenced = context.symbols?.[reference];

        return {
            kind:         OPERAND.MEMORY,
            base:         null,
            index:        null,
            displacement: value & 0xFFFF,
            symbol:       null,
            width:        width ?? referenced?.width ?? null,
            override
        };
    }

    // Without a symbol table only the shape can be checked, which is enough for
    // the parser's own tests but not for a real assembly.
    if (/^[^[\]]+[+-][^[\]]+$/.test(token)) {
        const expression = parseAddressExpression(token, line);

        if (expression.base || expression.index) {
            throw new SyntaxError8086(
                `a register can only form an address inside brackets, as in "[${token}]"`,
                line
            );
        }

        return expression.symbol
            ? { kind: OPERAND.MEMORY, ...expression, width, override }
            : { kind: OPERAND.IMMEDIATE, value: expression.displacement & 0xFFFF, width };
    }

    throw new SyntaxError8086(`cannot parse operand "${text}"`, line);
}

// -----------------------------------------------------------------------------
// ADDRESS EXPRESSIONS
//
// Handles the contents of the brackets: any of a base register, an index
// register, a symbol and a numeric displacement, combined with + or -.
// -----------------------------------------------------------------------------
export function parseAddressExpression(inner, line = null, context = null) {
    if (inner === '') {
        throw new SyntaxError8086('empty address expression "[]"', line);
    }

    // Split into signed terms while keeping each sign attached to its term.
    const terms = splitTerms(inner.replace(/\s+/g, ''), inner, line);

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
            // A name that is already known to be an EQU is a number, not an
            // address, so it belongs in the displacement. [SI+STRIDE] has one
            // symbol and a constant, not two symbols. The kind is compared as a
            // string rather than imported, because the assembler imports this
            // module and the cycle would not resolve.
            const known = context?.symbols?.[body.toUpperCase()];

            if (known?.kind === 'constant') {
                displacement += negative ? -known.value : known.value;
                continue;
            }

            if (symbol) throw new SyntaxError8086(`two symbols in "[${inner}]"`, line);
            symbol = body;
            continue;
        }

        // Anything left is a compound constant such as COUNT*2 or (LEN+1)/2.
        // Splitting on + and - above already respected precedence, because *
        // and / bind tighter, so whatever arrives here is a single product the
        // expression evaluator can fold to a number.
        if (context) {
            const folded = foldConstant(body, context, inner, line);

            displacement += negative ? -folded : folded;
            continue;
        }

        throw new SyntaxError8086(`cannot parse "${term}" inside "[${inner}]"`, line);
    }

    return { base, index, displacement, symbol };
}

/**
 * Breaks bracket contents into signed terms, each sign kept with its term.
 *
 * The split only happens outside parentheses, so "(LEN+1)/2" stays whole and
 * reaches the expression evaluator intact. A naive split on every + and - would
 * have cut it into "(LEN" and "1)/2" and lost the grouping.
 */
function splitTerms(text, inner, line) {
    const terms = [];

    let depth = 0;
    let start = 0;

    for (let at = 0; at < text.length; at++) {
        const character = text[at];

        if (character === '(') { depth++; continue; }

        if (character === ')') {
            if (--depth < 0) {
                throw new SyntaxError8086(`unbalanced ")" in "[${inner}]"`, line);
            }
            continue;
        }

        // A leading sign belongs to the first term, not between two of them.
        if (depth === 0 && (character === '+' || character === '-') && at > start) {
            terms.push(text.slice(start, at));
            start = character === '-' ? at : at + 1;
        }
    }

    if (depth !== 0) {
        throw new SyntaxError8086(`unbalanced "(" in "[${inner}]"`, line);
    }

    if (start < text.length) terms.push(text.slice(start));

    return terms.filter(term => term !== '' && term !== '+');
}

/**
 * Folds one compound bracket term to a constant.
 *
 * Scaling an address is meaningless on the 8086 -- there is no scaled index
 * mode until the 386 -- so a term that turns out to involve a label is refused
 * with an explanation rather than folded into a wrong number.
 */
function foldConstant(body, context, inner, line) {
    const { value, reference } = evaluateExpression(body, context);

    if (reference !== null) {
        throw new SyntaxError8086(
            `"${body}" inside "[${inner}]" scales the address of ${reference}, ` +
            `which the 8086 cannot do. Use OFFSET ${reference} in a register instead.`,
            line
        );
    }

    return value | 0;
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
