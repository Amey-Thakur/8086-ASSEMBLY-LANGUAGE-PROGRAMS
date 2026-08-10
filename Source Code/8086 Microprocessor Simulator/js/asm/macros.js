// -----------------------------------------------------------------------------
// Script Name: macros.js
// Module:      Assembler, 2 of 5
// Stack:       JavaScript (ES2020), no dependencies
// Description: Expands MACRO definitions before the source reaches the lexer.
//
//              A macro is a named block of source text with parameters, written
//              once and pasted in wherever it is called:
//
//                  PRINT_CHAR MACRO CHAR
//                      MOV DL, CHAR
//                      MOV AH, 02H
//                      INT 21H
//                  ENDM
//
//              Expansion happens on the text, before anything is parsed, which
//              is what the assembler manuals describe and what makes a macro
//              able to contain any construct at all rather than only complete
//              instructions.
//
//              Two details matter. LOCAL renames the labels it lists on every
//              expansion, without which a macro used twice defines the same
//              label twice. And a macro may call another macro, so expansion
//              repeats until nothing changes, with a depth limit in case a macro
//              ends up calling itself.
//
//              Every produced line keeps the line number of the source it came
//              from, so an error inside an expansion still points at the call.
//
// Authors:     Amey Thakur
// Repository:  https://github.com/Amey-Thakur/8086-ASSEMBLY-LANGUAGE-PROGRAMS
// License:     CC BY 4.0
// -----------------------------------------------------------------------------

'use strict';

import { ExpressionContext, evaluateExpression } from './expressions.js';

/** How many times an expansion may itself expand before it is called a loop. */
const MAX_EXPANSION_DEPTH = 32;

/**
 * How many copies one REPT may produce.
 *
 * High enough for any honest unrolling and low enough that a mistyped count
 * fails with a message instead of filling memory.
 */
const MAX_REPEAT_COUNT = 4096;

/**
 * Lines that open a block closed by ENDM.
 *
 * ENDM serves both a macro definition and a REPT, so the two have to be counted
 * together to know which one a given ENDM belongs to.
 */
const OPENS_A_BLOCK = /^(REPT\b|[A-Za-z_@$?][A-Za-z0-9_@$?]*\s+MACRO\b)/i;

/** Result of expansion: source lines carrying their original line numbers. */
export class SourceLine {
    constructor(text, line) {
        this.text = text;
        this.line = line;
    }
}

// -----------------------------------------------------------------------------
// ENTRY POINT
// -----------------------------------------------------------------------------

/**
 * Expand every macro in the source.
 *
 * @param {string} source
 * @returns {{lines: SourceLine[], macros: object, diagnostics: Array}}
 */
export function expandMacros(source) {
    const diagnostics = [];
    const raw         = String(source).split(/\r?\n/)
                                      .map((text, index) => new SourceLine(text, index + 1));

    const { macros, body } = collectDefinitions(raw, diagnostics);

    // The pass runs even when nothing was defined, because REPT is expanded here
    // too and a file may use one without defining a single macro.
    const counter = { value: 0 };
    const lines   = expand(body, macros, diagnostics, counter, 0);

    return { lines, macros, diagnostics };
}

// -----------------------------------------------------------------------------
// COLLECTING DEFINITIONS
// -----------------------------------------------------------------------------

/** Pull every "NAME MACRO ... ENDM" block out, returning the rest of the source. */
function collectDefinitions(lines, diagnostics) {
    const macros = Object.create(null);
    const body   = [];

    let current = null;

    for (const line of lines) {
        const bare = withoutComment(line.text).trim();

        if (current === null) {
            const header = bare.match(/^([A-Za-z_@$?][A-Za-z0-9_@$?]*)\s+MACRO\b\s*(.*)$/i);

            if (header) {
                current = {
                    name:       header[1].toUpperCase(),
                    parameters: splitList(header[2]),
                    body:       [],
                    depth:      0,
                    line:       line.line
                };
                continue;
            }

            body.push(line);
            continue;
        }

        // ENDM closes a REPT block as well as a macro, so the nesting has to be
        // counted. Without this a macro whose body contains a REPT would appear
        // to finish at the REPT's own ENDM, and the rest of it would be treated
        // as ordinary source.
        if (OPENS_A_BLOCK.test(bare)) {
            current.depth++;
            current.body.push(line);
            continue;
        }

        if (/^ENDM\b/i.test(bare)) {
            if (current.depth > 0) {
                current.depth--;
                current.body.push(line);
                continue;
            }

            macros[current.name] = current;
            current = null;
            continue;
        }

        current.body.push(line);
    }

    if (current) {
        diagnostics.push({ message: `macro "${current.name}" has no ENDM`, line: current.line });
        macros[current.name] = current;
    }

    return { macros, body };
}

// -----------------------------------------------------------------------------
// EXPANSION
// -----------------------------------------------------------------------------

/** Replace every macro call in a run of lines, recursively. */
function expand(lines, macros, diagnostics, counter, depth) {
    if (depth > MAX_EXPANSION_DEPTH) {
        diagnostics.push({
            message: 'macro expansion went more than ' + MAX_EXPANSION_DEPTH +
                     ' levels deep, which usually means a macro calls itself',
            line: lines[0]?.line ?? null
        });
        return lines;
    }

    const output = [];

    for (let at = 0; at < lines.length; at++) {
        const line = lines[at];

        // ---- REPT: the assembler writes the body out N times ----------------
        // This is handled here rather than in a pass of its own so that a
        // repeated body may contain macro calls, and a macro body may contain a
        // REPT, in either order.
        const repeat = withoutComment(line.text).trim().match(/^REPT\s+(.+)$/i);

        if (repeat) {
            const block = takeBlock(lines, at, diagnostics);
            const times = countOf(repeat[1], line.line, diagnostics);

            for (let round = 0; round < times; round++) {
                output.push(...expand(block.body, macros, diagnostics, counter, depth + 1));
            }

            at = block.end;
            continue;
        }

        const call = matchCall(line.text, macros);

        if (!call) { output.push(line); continue; }

        // A label written in front of the call has to survive it, so it is
        // emitted on its own line ahead of the expansion.
        if (call.label) {
            output.push(new SourceLine(`${call.label}:`, line.line));
        }

        const macro = macros[call.name];
        const bound = substitute(macro, call.arguments, counter, line.line);

        output.push(...expand(bound, macros, diagnostics, counter, depth + 1));
    }

    return output;
}

/**
 * Collects the body of a REPT block, from the line after the REPT to the ENDM
 * that closes it, counting any nested blocks on the way.
 *
 * @returns {{body: SourceLine[], end: number}} end is the index of the ENDM.
 */
function takeBlock(lines, start, diagnostics) {
    const body = [];

    let depth = 0;

    for (let at = start + 1; at < lines.length; at++) {
        const bare = withoutComment(lines[at].text).trim();

        if (OPENS_A_BLOCK.test(bare)) depth++;

        if (/^ENDM\b/i.test(bare)) {
            if (depth === 0) return { body, end: at };
            depth--;
        }

        body.push(lines[at]);
    }

    diagnostics.push({
        message: 'REPT has no ENDM to close it',
        line: lines[start].line
    });

    return { body, end: lines.length - 1 };
}

/**
 * Works out how many times a REPT should repeat.
 *
 * The count is needed before the symbol table exists, so it has to be a number
 * or a small sum of numbers. A macro argument that arrived as a literal counts,
 * which is the usual way a REPT gets its length. Anything else is refused with
 * an explanation rather than guessed at.
 */
function countOf(text, line, diagnostics) {
    const trimmed = text.trim();

    if (!/^[0-9A-Fa-fHhOoQqBbDd\s()+\-*/]+$/.test(trimmed)) {
        diagnostics.push({
            message: `REPT needs a count the assembler can work out before the ` +
                     `program is laid out, and "${trimmed}" is not one. A number ` +
                     `or a macro argument holding a number will do.`,
            line
        });
        return 0;
    }

    const value = evaluateLiteralArithmetic(trimmed);

    if (value === null || value < 0 || value > MAX_REPEAT_COUNT) {
        diagnostics.push({
            message: `REPT count "${trimmed}" is not a whole number between 0 ` +
                     `and ${MAX_REPEAT_COUNT}`,
            line
        });
        return 0;
    }

    return value;
}

/**
 * Folds a sum or product of plain numbers, with no symbols involved.
 *
 * The assembler's own expression evaluator does the work, against an empty
 * symbol table so that a name cannot creep in. That keeps REPT 2*4 and
 * REPT (3+1) reading exactly as they do everywhere else in the source.
 */
function evaluateLiteralArithmetic(text) {
    try {
        const { value, reference } = evaluateExpression(text, new ExpressionContext({}));

        return reference === null ? value : null;
    } catch {
        return null;
    }
}

/** Recognise a line that calls a macro, allowing a label in front of it. */
function matchCall(text, macros) {
    let bare = withoutComment(text).trim();

    if (bare === '') return null;

    let label = null;

    const labelled = bare.match(/^([A-Za-z_@$?][A-Za-z0-9_@$?]*)\s*:(?!:)\s*(.*)$/);

    if (labelled) { label = labelled[1]; bare = labelled[2].trim(); }
    if (bare === '') return null;

    const spaceAt = bare.search(/\s/);
    const head    = (spaceAt === -1 ? bare : bare.slice(0, spaceAt)).toUpperCase();

    if (!Object.hasOwn(macros, head)) return null;

    return {
        name:      head,
        label,
        arguments: splitList(spaceAt === -1 ? '' : bare.slice(spaceAt))
    };
}

/**
 * Produce one expansion of a macro with its arguments bound.
 *
 * LOCAL names are renamed first, so a parameter that happens to share a name
 * with a local is still substituted correctly afterwards.
 */
function substitute(macro, callArguments, counter, callLine) {
    const serial  = ++counter.value;
    const locals  = new Map();
    const output  = [];

    // ---- first sweep: find the LOCAL declarations ---------------------------
    for (const line of macro.body) {
        const local = withoutComment(line.text).trim().match(/^LOCAL\b\s*(.*)$/i);

        if (!local) continue;

        for (const name of splitList(local[1])) {
            locals.set(name.toUpperCase(), `${name}__M${serial}`);
        }
    }

    // ---- second sweep: emit the body with everything replaced ---------------
    for (const line of macro.body) {
        const bare = withoutComment(line.text).trim();

        if (/^LOCAL\b/i.test(bare)) continue;      // consumed above

        let text = line.text;

        macro.parameters.forEach((parameter, index) => {
            text = replaceWord(text, parameter, callArguments[index] ?? '');
        });

        for (const [name, unique] of locals) {
            text = replaceWord(text, name, unique);
        }

        output.push(new SourceLine(text, callLine));
    }

    return output;
}

// -----------------------------------------------------------------------------
// TEXT HELPERS
// -----------------------------------------------------------------------------

/** Split a comma separated list, dropping empties and the MASM <> brackets. */
function splitList(text) {
    return String(text)
        .split(',')
        .map(item => item.trim().replace(/^<([\s\S]*)>$/, '$1').trim())
        .filter(item => item !== '');
}

/** Remove a trailing comment without being fooled by a semicolon in a string. */
function withoutComment(text) {
    let inSingle = false;
    let inDouble = false;

    for (let index = 0; index < text.length; index++) {
        const character = text[index];

        if (character === "'" && !inDouble) { inSingle = !inSingle; continue; }
        if (character === '"' && !inSingle) { inDouble = !inDouble; continue; }
        if (character === ';' && !inSingle && !inDouble) return text.slice(0, index);
    }
    return text;
}

/**
 * Replace whole occurrences of a name, leaving quoted text alone.
 *
 * A macro parameter called CHAR must not rewrite the letters of a message that
 * happens to contain the word, so string literals are copied through untouched.
 */
function replaceWord(text, name, replacement) {
    const pattern = new RegExp(`(^|[^A-Za-z0-9_@$?])${escapeForRegExp(name)}(?![A-Za-z0-9_@$?])`, 'gi');
    const pieces  = splitOnLiterals(text);

    return pieces
        .map(piece => piece.quoted ? piece.text
                                   : piece.text.replace(pattern, (_, before) => before + replacement))
        .join('');
}

/** Break text into alternating plain and quoted runs. */
function splitOnLiterals(text) {
    const pieces = [];

    let buffer = '';
    let quote  = null;

    for (const character of text) {
        if (quote) {
            buffer += character;

            if (character === quote) { pieces.push({ text: buffer, quoted: true }); buffer = ''; quote = null; }
            continue;
        }

        if (character === "'" || character === '"') {
            if (buffer !== '') pieces.push({ text: buffer, quoted: false });
            buffer = character;
            quote  = character;
            continue;
        }

        buffer += character;
    }

    if (buffer !== '') pieces.push({ text: buffer, quoted: quote !== null });

    return pieces;
}

function escapeForRegExp(text) {
    return String(text).replace(/[.*+?^${}()|[\]\\]/g, '\\$&');
}
