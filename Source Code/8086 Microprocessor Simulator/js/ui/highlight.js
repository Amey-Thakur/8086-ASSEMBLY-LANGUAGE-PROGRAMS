// -----------------------------------------------------------------------------
// Script Name: highlight.js
// Module:      Interface, 1 of 6
// Stack:       JavaScript (ES2020), no dependencies
// Description: Colours 8086 assembly source for the editor.
//
//              The colour is doing work, not decoration. A register set apart
//              from a constant, and a comment set back from the code, is the
//              difference between reading a listing and decoding it. So the
//              categories are the ones that matter when reading assembly:
//
//                comment     stepped back, because it is not the program
//                directive   what the assembler is being told
//                mnemonic    what the processor is being told
//                register    where the value is
//                number      what the value is
//                string      text the program will print
//                label       a place the program can jump to
//
//              Seven colours, each with a job. Nothing is coloured merely to
//              break up the page.
//
//              The output is HTML, which means every piece of the source has to
//              be escaped on the way through. Nothing here trusts its input.
//
// Authors:     Amey Thakur
// Repository:  https://github.com/Amey-Thakur/8086-ASSEMBLY-LANGUAGE-PROGRAMS
// License:     CC BY 4.0
// -----------------------------------------------------------------------------

'use strict';

/** Every mnemonic the executor implements, so an unknown one stays plain and
 *  a typo is visible before the program is even assembled. */
const MNEMONICS = new Set([
    'MOV', 'XCHG', 'LEA', 'PUSH', 'POP', 'PUSHF', 'POPF', 'XLAT', 'XLATB',
    'ADD', 'ADC', 'SUB', 'SBB', 'CMP', 'INC', 'DEC', 'NEG',
    'MUL', 'IMUL', 'DIV', 'IDIV', 'CBW', 'CWD',
    'DAA', 'DAS', 'AAA', 'AAS', 'AAM', 'AAD',
    'AND', 'OR', 'XOR', 'NOT', 'TEST',
    'SHL', 'SAL', 'SHR', 'SAR', 'ROL', 'ROR', 'RCL', 'RCR',
    'JMP', 'CALL', 'RET', 'RETN', 'RETF', 'IRET',
    'JA', 'JAE', 'JB', 'JBE', 'JC', 'JE', 'JG', 'JGE', 'JL', 'JLE',
    'JNA', 'JNAE', 'JNB', 'JNBE', 'JNC', 'JNE', 'JNG', 'JNGE', 'JNL', 'JNLE',
    'JNO', 'JNP', 'JNS', 'JNZ', 'JO', 'JP', 'JPE', 'JPO', 'JS', 'JZ', 'JCXZ',
    'LOOP', 'LOOPE', 'LOOPZ', 'LOOPNE', 'LOOPNZ',
    'MOVSB', 'MOVSW', 'CMPSB', 'CMPSW', 'SCASB', 'SCASW',
    'LODSB', 'LODSW', 'STOSB', 'STOSW',
    'REP', 'REPE', 'REPZ', 'REPNE', 'REPNZ', 'LOCK',
    'IN', 'OUT', 'INT',
    'CLC', 'STC', 'CMC', 'CLD', 'STD', 'CLI', 'STI',
    'NOP', 'HLT'
]);

/** The registers, so that AX is coloured and a variable called AXIS is not. */
const REGISTERS = new Set([
    'AX', 'BX', 'CX', 'DX', 'AH', 'AL', 'BH', 'BL', 'CH', 'CL', 'DH', 'DL',
    'SI', 'DI', 'BP', 'SP', 'CS', 'DS', 'SS', 'ES', 'IP'
]);

/** Words that instruct the assembler rather than the processor. */
const DIRECTIVES = new Set([
    'DB', 'DW', 'DD', 'DUP', 'EQU', 'ORG', 'END', 'PROC', 'ENDP',
    'SEGMENT', 'ENDS', 'ASSUME', 'MACRO', 'ENDM', 'LOCAL',
    'IF', 'IFE', 'IFDEF', 'IFNDEF', 'ELSE', 'ELSEIF', 'ENDIF',
    'BYTE', 'WORD', 'PTR', 'OFFSET', 'SEG', 'TYPE', 'LENGTH', 'SIZE',
    'NAME', 'TITLE', 'PUBLIC', 'EXTRN', 'INCLUDE', 'MODEL', 'STACK', 'CODE', 'DATA',
    'SMALL', 'TINY', 'COMPACT', 'MEDIUM', 'LARGE', 'HUGE',
    'MOD', 'SHL', 'SHR', 'EQ', 'NE', 'LT', 'LE', 'GT', 'GE'
]);

/**
 * One pass over the source, in the order the pieces have to be recognised.
 *
 * Comments and strings come first because everything inside them is text, not
 * code, whatever it happens to spell.
 */
const PATTERNS = [
    { kind: 'comment',   pattern: /;[^\n]*/y },
    { kind: 'string',    pattern: /'(?:[^'\n])*'|"(?:[^"\n])*"/y },
    { kind: 'directive', pattern: /\.[A-Za-z][A-Za-z0-9_]*/y },   // .MODEL, .DATA
    { kind: 'number',    pattern: /\$?[0-9][0-9A-Fa-f_]*[HhBbDdOoQq]?\b/y },
    { kind: 'word',      pattern: /[A-Za-z_@?][A-Za-z0-9_@?]*/y },
    { kind: 'plain',     pattern: /\s+/y },
    { kind: 'plain',     pattern: /[^\s]/y }                      // anything else
];

/**
 * Turn source text into HTML with each piece wrapped in its category.
 *
 * @param {string} source
 * @returns {string} HTML safe to assign to innerHTML
 */
export function highlight(source) {
    const text  = String(source);
    const parts = [];

    let index = 0;

    while (index < text.length) {
        const piece = readPiece(text, index);

        parts.push(render(piece, text, index));
        index += piece.length;
    }

    // A trailing newline collapses in the layout unless something follows it,
    // which would put the highlighted layer half a line out of step with the
    // text area beneath it.
    return parts.join('') + '\n';
}

/** Read the next piece, and say what kind it is. */
function readPiece(text, index) {
    for (const { kind, pattern } of PATTERNS) {
        pattern.lastIndex = index;

        const match = pattern.exec(text);

        if (match && match.index === index && match[0].length > 0) {
            return { kind, length: match[0].length, value: match[0] };
        }
    }

    return { kind: 'plain', length: 1, value: text[index] };
}

/** Wrap a piece in the span its category calls for. */
function render(piece, text, index) {
    const escaped = escapeText(piece.value);

    if (piece.kind === 'plain') return escaped;

    if (piece.kind !== 'word') {
        return `<span class="tok tok--${piece.kind}">${escaped}</span>`;
    }

    // A bare word is only classified once it is known which list it is in, and
    // whether a colon follows it, which is what makes it a label.
    const upper = piece.value.toUpperCase();

    if (REGISTERS.has(upper))  return `<span class="tok tok--register">${escaped}</span>`;
    if (MNEMONICS.has(upper))  return `<span class="tok tok--mnemonic">${escaped}</span>`;
    if (DIRECTIVES.has(upper)) return `<span class="tok tok--directive">${escaped}</span>`;

    if (isLabelDefinition(text, index + piece.length)) {
        return `<span class="tok tok--label">${escaped}</span>`;
    }

    return escaped;
}

/** A name is a label when the next thing after it, past spaces, is a colon. */
function isLabelDefinition(text, from) {
    let index = from;

    while (index < text.length && (text[index] === ' ' || text[index] === '\t')) index++;

    return text[index] === ':' && text[index + 1] !== ':';
}

function escapeText(text) {
    return String(text).replace(/[&<>]/g, character => ({
        '&': '&amp;', '<': '&lt;', '>': '&gt;'
    })[character]);
}
