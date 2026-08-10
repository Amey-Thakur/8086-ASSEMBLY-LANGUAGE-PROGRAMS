// -----------------------------------------------------------------------------
// Script Name: expressions.js
// Module:      Assembler, 3 of 5
// Stack:       JavaScript (ES2020), depends on lexer.js
// Description: Evaluates the constant expressions assembly source is allowed to
//              write wherever a number is expected. Three places need this and
//              all three used to accept only a bare literal:
//
//                MSG_LEN EQU $ - MSG          the length of the string above
//                MOV CX, LEN / 2              half the count, folded at assembly
//                LEA SI, OFFSET ARRAY         the address rather than the value
//
//              An expression is resolved entirely by the assembler; nothing here
//              survives into execution. The only thing the caller needs back
//              besides the number is whether a data name took part in it without
//              OFFSET, because "BUF+1" means the byte at that address while
//              "OFFSET BUF+1" means the number itself.
//
//              Operator precedence follows MASM: unary operators bind tightest,
//              then multiplication and the shifts, then addition.
//
// Authors:     Amey Thakur
// Repository:  https://github.com/Amey-Thakur/8086-ASSEMBLY-LANGUAGE-PROGRAMS
// License:     CC BY 4.0
// -----------------------------------------------------------------------------

'use strict';

import { parseNumber, SyntaxError8086 } from './lexer.js';

/** Operators recognised as words rather than punctuation. */
const WORD_OPERATORS = new Set([
    'MOD', 'SHL', 'SHR', 'AND', 'OR', 'XOR', 'NOT',
    'EQ', 'NE', 'LT', 'LE', 'GT', 'GE'
]);

/** What a comparison yields when it holds. Every bit set, as the manuals give
 *  it, so that a result can be combined with AND and OR and still make sense. */
const TRUE  = -1;
const FALSE =  0;

/** Unary operators that take a name and return a number about it. */
const ADDRESS_OPERATORS = new Set(['OFFSET', 'SEG', 'TYPE', 'LENGTH', 'LENGTHOF', 'SIZE', 'SIZEOF']);

/** Everything the evaluator may need to look a name up. */
export class ExpressionContext {
    /**
     * @param {object} symbols   the assembler symbol table
     * @param {number} location  the value of "$", the current location counter
     * @param {number} segment   the segment a data name belongs to, for SEG
     */
    constructor(symbols = {}, location = 0, segment = 0) {
        this.symbols  = symbols;
        this.location = location;
        this.segment  = segment;
    }
}

// -----------------------------------------------------------------------------
// TOKENIZING
// -----------------------------------------------------------------------------

/**
 * Break an expression into tokens.
 *
 * Character literals are taken whole so that 'A'+1 works, and a leading $ is
 * distinguished from the $ that may appear inside a name.
 */
export function tokenizeExpression(text) {
    const tokens = [];
    const source = String(text);

    let index = 0;

    while (index < source.length) {
        const character = source[index];

        if (/\s/.test(character)) { index++; continue; }

        // ---- character literal ------------------------------------------------
        if (character === "'" || character === '"') {
            const closing = source.indexOf(character, index + 1);

            if (closing === -1) throw new SyntaxError8086(`unterminated literal in "${text}"`);

            tokens.push({ type: 'literal', text: source.slice(index, closing + 1) });
            index = closing + 1;
            continue;
        }

        // ---- punctuation ------------------------------------------------------
        if ('+-*/()'.includes(character)) {
            tokens.push({ type: 'operator', text: character });
            index++;
            continue;
        }

        // ---- $ standing alone is the location counter -------------------------
        if (character === '$' && !/[A-Za-z0-9_]/.test(source[index + 1] ?? '')) {
            tokens.push({ type: 'here', text: '$' });
            index++;
            continue;
        }

        // ---- a number, a name, or a word operator -----------------------------
        const word = source.slice(index).match(/^[A-Za-z0-9_@$?.]+/);

        if (!word) throw new SyntaxError8086(`cannot read "${character}" in "${text}"`);

        const upper = word[0].toUpperCase();

        tokens.push(WORD_OPERATORS.has(upper) || ADDRESS_OPERATORS.has(upper)
            ? { type: 'operator', text: upper }
            : { type: 'word', text: word[0] });

        index += word[0].length;
    }

    return tokens;
}

// -----------------------------------------------------------------------------
// EVALUATION
// -----------------------------------------------------------------------------

/**
 * Evaluate an expression.
 *
 * @returns {{value:number, reference:string|null}}
 *          value     the number the expression comes to
 *          reference the data name it is relative to, if the expression names
 *                    one without OFFSET; null for a pure constant
 */
export function evaluateExpression(text, context = new ExpressionContext()) {
    const tokens = tokenizeExpression(text);

    if (tokens.length === 0) throw new SyntaxError8086('empty expression');

    const state = { tokens, position: 0, reference: null, context };
    const value = parseComparison(state);

    if (state.position < tokens.length) {
        throw new SyntaxError8086(`unexpected "${tokens[state.position].text}" in "${text}"`);
    }

    return { value: value | 0, reference: state.reference };
}

/** True when the text can be evaluated with the names currently known. */
export function isEvaluable(text, context) {
    try { evaluateExpression(text, context); return true; }
    catch { return false; }
}

// ---- grammar ----------------------------------------------------------------

function peek(state)    { return state.tokens[state.position]; }
function consume(state) { return state.tokens[state.position++]; }

function accept(state, ...texts) {
    const token = peek(state);

    if (token && token.type === 'operator' && texts.includes(token.text)) {
        state.position++;
        return token.text;
    }
    return null;
}

/** comparison := sum ((EQ | NE | LT | LE | GT | GE) sum)?
 *
 *  Comparisons bind loosest, so "TYPE X EQ 1" reads as "(TYPE X) EQ 1" without
 *  needing the parentheses. They exist for the IF directive. */
function parseComparison(state) {
    const left     = parseSum(state);
    const operator = accept(state, 'EQ', 'NE', 'LT', 'LE', 'GT', 'GE');

    if (!operator) return left;

    const right = parseSum(state);

    switch (operator) {
        case 'EQ': return left === right ? TRUE : FALSE;
        case 'NE': return left !== right ? TRUE : FALSE;
        case 'LT': return left <   right ? TRUE : FALSE;
        case 'LE': return left <=  right ? TRUE : FALSE;
        case 'GT': return left >   right ? TRUE : FALSE;
        default:   return left >=  right ? TRUE : FALSE;
    }
}

/** sum := product (('+' | '-' | OR | XOR) product)* */
function parseSum(state) {
    let value = parseProduct(state);

    for (;;) {
        const operator = accept(state, '+', '-', 'OR', 'XOR');
        if (!operator) return value;

        const right = parseProduct(state);

        if (operator === '+')       value += right;
        else if (operator === '-')  value -= right;
        else if (operator === 'OR') value |= right;
        else                        value ^= right;
    }
}

/** product := unary (('*' | '/' | MOD | SHL | SHR | AND) unary)* */
function parseProduct(state) {
    let value = parseUnary(state);

    for (;;) {
        const operator = accept(state, '*', '/', 'MOD', 'SHL', 'SHR', 'AND');
        if (!operator) return value;

        const right = parseUnary(state);

        switch (operator) {
            case '*':   value = value * right; break;
            case '/':   if (right === 0) throw new SyntaxError8086('division by zero in an expression');
                        value = Math.trunc(value / right); break;
            case 'MOD': if (right === 0) throw new SyntaxError8086('division by zero in an expression');
                        value = value % right; break;
            case 'SHL': value = value << right; break;
            case 'SHR': value = value >>> right; break;
            default:    value = value & right;
        }
    }
}

/** unary := ('-' | '+' | NOT | OFFSET | SEG | TYPE | LENGTH | SIZE)? primary */
function parseUnary(state) {
    if (accept(state, '-')) return -parseUnary(state);
    if (accept(state, '+')) return  parseUnary(state);
    if (accept(state, 'NOT')) return (~parseUnary(state)) & 0xFFFF;

    // OFFSET and SEG suppress the reference, because they ask about the address
    // rather than about what is stored there.
    if (accept(state, 'OFFSET')) {
        const saved = state.reference;
        const value = parseUnary(state);

        state.reference = saved;
        return value;
    }

    if (accept(state, 'SEG')) {
        const saved = state.reference;

        parseUnary(state);
        state.reference = saved;
        return state.context.segment;
    }

    if (accept(state, 'TYPE')) {
        const token = consume(state);

        return widthOfName(state, token?.text) ?? 1;
    }

    if (accept(state, 'LENGTH', 'LENGTHOF', 'SIZE', 'SIZEOF')) {
        const token  = consume(state);
        const symbol = lookUp(state, token?.text);

        return symbol?.length ?? 1;
    }

    return parsePrimary(state);
}

/** primary := number | literal | '$' | name | '(' sum ')' */
function parsePrimary(state) {
    const token = consume(state);

    if (!token) throw new SyntaxError8086('expression ends early');

    if (token.type === 'operator' && token.text === '(') {
        const value = parseComparison(state);

        if (!accept(state, ')')) throw new SyntaxError8086('missing ")" in an expression');
        return value;
    }

    if (token.type === 'here')    return state.context.location;
    if (token.type === 'literal') return readLiteral(token.text);

    if (token.type !== 'word') {
        throw new SyntaxError8086(`"${token.text}" cannot start a value`);
    }

    const numeric = parseNumber(token.text);
    if (numeric !== null) return numeric;

    return readName(state, token.text);
}

/** A quoted literal in an expression is its character value, 'AB' being two. */
function readLiteral(text) {
    const body = text.slice(1, -1);

    if (body.length === 0) return 0;
    if (body.length === 1) return body.charCodeAt(0);

    return ((body.charCodeAt(0) << 8) | body.charCodeAt(1)) & 0xFFFF;
}

function lookUp(state, name) {
    if (!name) return null;

    const key = name.toUpperCase();

    return Object.hasOwn(state.context.symbols, key) ? state.context.symbols[key] : null;
}

function widthOfName(state, name) {
    return lookUp(state, name)?.width ?? null;
}

/** Resolve a name to a number, noting when it makes the expression an address. */
function readName(state, name) {
    const symbol = lookUp(state, name);

    if (!symbol) throw new SyntaxError8086(`"${name}" is not defined`);

    if (symbol.kind === 'constant') return symbol.value;

    if (symbol.kind === 'data') {
        // A data name used bare means "what is stored here", so the caller has
        // to treat the whole expression as an address.
        state.reference ??= name.toUpperCase();
        return symbol.offset;
    }

    return symbol.index ?? 0;   // a code label: its instruction number
}
