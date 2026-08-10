// -----------------------------------------------------------------------------
// Script Name: lexer.js
// Module:      Assembler, 1 of 3
// Stack:       JavaScript (ES2020), no dependencies
// Description: Turns assembly source text into a flat list of logical lines,
//              each already separated into its label, mnemonic and operands,
//              with the original line number preserved for error reporting.
//
//              The lexer deliberately understands very little. It knows how to
//              strip comments without breaking string literals, how to split
//              operands without breaking bracketed expressions, and how to
//              recognise a label. Everything else is left to the parser, which
//              keeps this file small enough to reason about.
//
//              Number formats accepted, because student code uses all of them:
//                  1234        decimal
//                  1234h  0x1234  $1234    hexadecimal
//                  1010b                   binary
//                  17o  17q                octal
//                  'A'                     character literal
//
// Authors:     Amey Thakur
// Repository:  https://github.com/Amey-Thakur/8086-ASSEMBLY-LANGUAGE-PROGRAMS
// License:     CC BY 4.0
// -----------------------------------------------------------------------------

'use strict';

/** Raised for anything the lexer cannot make sense of at all. */
export class SyntaxError8086 extends Error {
    constructor(message, line) {
        super(message);
        this.name = 'SyntaxError8086';
        this.line = line;
    }
}

// -----------------------------------------------------------------------------
// COMMENT REMOVAL
//
// A semicolon inside a string literal is data, not a comment. Walking the line
// character by character is the only reliable way to tell the difference.
// -----------------------------------------------------------------------------
export function stripComment(text) {
    let inSingle = false;
    let inDouble = false;

    for (let index = 0; index < text.length; index++) {
        const character = text[index];

        if (character === "'" && !inDouble) { inSingle = !inSingle; continue; }
        if (character === '"' && !inSingle) { inDouble = !inDouble; continue; }

        if (character === ';' && !inSingle && !inDouble) {
            return text.slice(0, index);
        }
    }

    return text;
}

// -----------------------------------------------------------------------------
// OPERAND SPLITTING
//
// Commas separate operands, except inside brackets or string literals. A naive
// split on ',' destroys DB 'a,b' and MOV AX, [BX+SI].
// -----------------------------------------------------------------------------
export function splitOperands(text) {
    const operands = [];

    let current  = '';
    let depth    = 0;
    let inSingle = false;
    let inDouble = false;

    for (const character of text) {
        if (character === "'" && !inDouble) { inSingle = !inSingle; current += character; continue; }
        if (character === '"' && !inSingle) { inDouble = !inDouble; current += character; continue; }

        if (!inSingle && !inDouble) {
            if (character === '[') depth++;
            if (character === ']') depth--;

            if (character === ',' && depth === 0) {
                operands.push(current.trim());
                current = '';
                continue;
            }
        }

        current += character;
    }

    if (current.trim() !== '') {
        operands.push(current.trim());
    }

    return operands;
}

// -----------------------------------------------------------------------------
// NUMBER PARSING
//
// Returns null rather than throwing, so callers can fall through to treating
// the text as a symbol.
// -----------------------------------------------------------------------------
export function parseNumber(text) {
    if (typeof text !== 'string') return null;

    const token = text.trim();
    if (token === '') return null;

    // Character literal. 'A' is 65, and '' is an escaped quote inside one.
    const character = token.match(/^'(\\.|[^'])'$/);
    if (character) {
        const value = character[1];

        if (value.startsWith('\\')) {
            const escapes = { '\\n': 10, '\\r': 13, '\\t': 9, '\\0': 0, "\\'": 39, '\\\\': 92 };
            return Object.hasOwn(escapes, value) ? escapes[value] : value.charCodeAt(1);
        }
        return value.charCodeAt(0);
    }

    let negative = false;
    let body     = token;

    if (body.startsWith('-')) { negative = true; body = body.slice(1).trim(); }
    else if (body.startsWith('+')) { body = body.slice(1).trim(); }

    let value = null;

    if (/^0x[0-9a-f]+$/i.test(body))        value = parseInt(body.slice(2), 16);
    else if (/^\$[0-9a-f]+$/i.test(body))   value = parseInt(body.slice(1), 16);
    else if (/^[0-9][0-9a-f]*h$/i.test(body)) value = parseInt(body.slice(0, -1), 16);
    else if (/^[01]+b$/i.test(body))        value = parseInt(body.slice(0, -1), 2);
    else if (/^[0-7]+[oq]$/i.test(body))    value = parseInt(body.slice(0, -1), 8);
    else if (/^[0-9]+d?$/i.test(body))      value = parseInt(body.replace(/d$/i, ''), 10);

    if (value === null || Number.isNaN(value)) return null;

    return negative ? -value : value;
}

// -----------------------------------------------------------------------------
// STRING LITERAL PARSING
//
// DB accepts quoted text, which becomes a byte per character. Used by the
// assembler when laying out the data segment.
// -----------------------------------------------------------------------------
export function parseStringLiteral(text) {
    const token = text.trim();
    const match = token.match(/^(['"])([\s\S]*)\1$/);

    if (!match) return null;

    const body  = match[2];
    const bytes = [];

    for (let index = 0; index < body.length; index++) {
        if (body[index] === '\\' && index + 1 < body.length) {
            const escapes = { n: 10, r: 13, t: 9, '0': 0, '\\': 92, "'": 39, '"': 34 };
            const next    = body[index + 1];

            if (Object.hasOwn(escapes, next)) { bytes.push(escapes[next]); index++; continue; }
        }
        bytes.push(body.charCodeAt(index) & 0xFF);
    }

    return bytes;
}

// -----------------------------------------------------------------------------
// LEXER
// -----------------------------------------------------------------------------

/** Directives that introduce a section rather than emit code or data. */
const SECTION_DIRECTIVES = new Set(['.MODEL', '.STACK', '.DATA', '.CODE', '.386', '.8086']);

/**
 * Break source into logical lines.
 *
 * A line may carry a label, a mnemonic and operands, in that order, and a label
 * may stand alone. Blank lines and pure comments are dropped, but the original
 * line number rides along so every later error can point at real source.
 */
export function tokenize(source) {
    const lines  = String(source).split(/\r?\n/);
    const output = [];

    lines.forEach((rawText, index) => {
        const lineNumber = index + 1;
        const text       = stripComment(rawText).trim();

        if (text === '') return;

        let remainder = text;
        let label     = null;

        // A leading "name:" is a label. Guard against a segment override such as
        // ES:[DI] being mistaken for one by requiring the colon to come before
        // any bracket or whitespace.
        const labelMatch = remainder.match(/^([A-Za-z_@$?][A-Za-z0-9_@$?]*)\s*:(?!:)/);

        if (labelMatch && !/^\s*(ES|CS|SS|DS)\s*:/i.test(remainder)) {
            label     = labelMatch[1];
            remainder = remainder.slice(labelMatch[0].length).trim();
        }

        if (remainder === '') {
            output.push({ line: lineNumber, label, mnemonic: null, operands: [], source: rawText });
            return;
        }

        // Mnemonic is the first whitespace-delimited word. Directives beginning
        // with a dot are kept whole.
        const spaceAt  = remainder.search(/\s/);
        const mnemonic = (spaceAt === -1 ? remainder : remainder.slice(0, spaceAt)).toUpperCase();
        const rest     = spaceAt === -1 ? '' : remainder.slice(spaceAt).trim();

        output.push({
            line:      lineNumber,
            label,
            mnemonic,
            operands:  rest === '' ? [] : splitOperands(rest),
            isSection: SECTION_DIRECTIVES.has(mnemonic),
            source:    rawText
        });
    });

    return output;
}
