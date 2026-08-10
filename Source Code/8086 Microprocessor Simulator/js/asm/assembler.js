// -----------------------------------------------------------------------------
// Script Name: assembler.js
// Module:      Assembler, 5 of 5
// Stack:       JavaScript (ES2020), depends on lexer.js and operands.js
// Description: Two pass assembler. Turns tokenized source into an executable
//              program: a list of instructions, a symbol table and a data
//              image ready to be loaded into the data segment.
//
//              Two passes are necessary because assembly allows forward
//              references. A jump may name a label defined fifty lines later,
//              so the first pass records where everything lives and the second
//              resolves the names once every address is known.
//
//              Pass one   assigns an address to each instruction, lays out the
//                         data segment, and records every label and constant.
//              Pass two   parses operands and resolves symbols, reporting every
//                         unresolved name rather than stopping at the first.
//
//              Errors accumulate. A student with four mistakes should see four
//              messages, not have to fix and re-run four times.
//
// Authors:     Amey Thakur
// Repository:  https://github.com/Amey-Thakur/8086-ASSEMBLY-LANGUAGE-PROGRAMS
// License:     CC BY 4.0
// -----------------------------------------------------------------------------

'use strict';

import { tokenize, parseNumber, parseStringLiteral, splitOperands } from './lexer.js';
import { parseOperand, OPERAND }                                    from './operands.js';
import { expandMacros }                                             from './macros.js';
import { evaluateExpression, ExpressionContext }                    from './expressions.js';

/** Directives that reserve or initialise storage, and how wide each unit is. */
const DATA_DIRECTIVES = { DB: 1, DW: 2, DD: 4 };

/** The widths a "NAME LABEL type" marker can declare. */
const MARKER_WIDTHS = { BYTE: 1, WORD: 2, DWORD: 4 };

/** Directives consumed by the assembler that emit nothing by themselves. */
const IGNORED_DIRECTIVES = new Set([
    '.MODEL', '.STACK', '.386', '.8086', '.486', '.586',
    'ASSUME', 'PROC', 'ENDP', 'SEGMENT', 'ENDS', 'PUBLIC', 'EXTRN', 'INCLUDE',
    'NAME', 'TITLE', 'SUBTTL', 'PAGE', 'COMMENT', 'ALIGN', 'EVEN', 'LOCAL'
]);

/** Directives that begin a run of data rather than of code. */
const DATA_SECTIONS = new Set(['.DATA', '.DATA?', '.CONST', '.FARDATA', '.FARDATA?']);

/** Conditional assembly. These decide whether the lines they enclose are
 *  assembled at all, so they are handled before anything else on the line. */
const CONDITIONAL_DIRECTIVES = new Set(['IF', 'IFE', 'IFDEF', 'IFNDEF', 'ELSE', 'ELSEIF', 'ENDIF']);

/** How a symbol was defined, which decides how it resolves in an operand. */
export const SYMBOL = {
    CODE:     'code',      // a jump target: resolves to an instruction index
    DATA:     'data',      // a variable: resolves to an offset in the data segment
    CONSTANT: 'constant'   // an EQU: resolves to a literal value
};

/** Collected diagnostics. Carries a line number so the editor can point at it. */
export class AssemblyDiagnostic {
    constructor(message, line, severity = 'error') {
        this.message  = message;
        this.line     = line;
        this.severity = severity;
    }

    toString() {
        return this.line ? `line ${this.line}: ${this.message}` : this.message;
    }
}

// -----------------------------------------------------------------------------
// ASSEMBLER
// -----------------------------------------------------------------------------
export class Assembler {

    constructor() {
        this.reset();
    }

    reset() {
        this.instructions = [];
        this.symbols      = Object.create(null);
        this.dataBytes    = [];
        this.diagnostics  = [];
        this.entryPoint   = 0;

        // Data words that name a code label cannot be filled in during the
        // first pass, because the label may be defined further down. Their
        // positions are recorded here and patched once every address is known.
        this.fixups = [];

        // Nesting state for IF / ELSE / ENDIF.
        this.conditionals = [];
    }

    /** Record a problem and keep going, so one run reports everything. */
    report(message, line) {
        this.diagnostics.push(new AssemblyDiagnostic(message, line));
    }

    // -------------------------------------------------------------------------
    // ENTRY POINT
    // -------------------------------------------------------------------------

    /**
     * Assemble source text.
     *
     * @returns {object} { instructions, symbols, data, diagnostics, entryPoint, ok }
     */
    assemble(source) {
        this.reset();

        // Macros are pasted in before anything is parsed, so the rest of the
        // assembler never has to know they existed.
        const expansion = expandMacros(source);

        for (const problem of expansion.diagnostics) {
            this.report(problem.message, problem.line);
        }

        const lines = tokenize(expansion.lines);

        this.firstPass(lines);
        this.applyFixups();
        this.secondPass();

        return {
            instructions: this.instructions,
            symbols:      this.symbols,
            data:         Uint8Array.from(this.dataBytes),
            diagnostics:  this.diagnostics,
            entryPoint:   this.entryPoint,
            ok:           this.diagnostics.length === 0
        };
    }

    // -------------------------------------------------------------------------
    // PASS ONE
    //
    // Walk every line, decide whether it is data, a directive or an instruction,
    // and record where each label points. Operands are kept as raw text here;
    // they cannot be resolved until every label is known.
    // -------------------------------------------------------------------------
    firstPass(lines) {
        let section = 'code';   // programs without .DATA are all code

        for (const line of lines) {
            // ---- conditional assembly ----------------------------------------
            // Handled before anything else, because a line inside a branch that
            // was not taken must not define labels or emit anything at all.
            if (line.mnemonic && CONDITIONAL_DIRECTIVES.has(line.mnemonic)) {
                this.applyConditional(line);
                continue;
            }

            if (!this.assembling()) continue;

            // ---- section directives ------------------------------------------
            if (line.mnemonic && DATA_SECTIONS.has(line.mnemonic)) {
                section = 'data';
                this.defineLabel(line);
                continue;
            }
            if (line.mnemonic === '.CODE')  { section = 'code'; this.defineLabel(line); continue; }

            if (line.mnemonic && IGNORED_DIRECTIVES.has(line.mnemonic)) {
                this.defineLabel(line);
                continue;
            }

            if (line.mnemonic === 'END') {
                // "END START" names the entry point.
                if (line.operands.length > 0) {
                    this.pendingEntryLabel = line.operands[0].trim();
                }
                continue;
            }

            // ---- ORG moves the data pointer ----------------------------------
            if (line.mnemonic === 'ORG') {
                const target = parseNumber(line.operands[0] ?? '');

                if (target === null) {
                    this.report('ORG needs a numeric address', line.line);
                } else {
                    while (this.dataBytes.length < target) this.dataBytes.push(0);
                }
                continue;
            }

            // ---- named directives --------------------------------------------
            // "MAIN PROC", "DATA SEGMENT" and "NAME EQU 10" all put the NAME
            // first, so the lexer reads the name as the mnemonic and the real
            // directive as the first operand. These have to be recognised by
            // looking at the operand, not the mnemonic.
            const namedDirective = (line.operands[0] ?? '').split(/\s+/)[0].toUpperCase();

            if (namedDirective === 'EQU') {
                this.defineConstant(line);
                continue;
            }

            if (namedDirective === 'PROC' || namedDirective === 'SEGMENT') {
                // The procedure name is a jump target pointing at whatever
                // instruction comes next, which is what "END MAIN" relies on.
                this.defineNamedLabel(line.mnemonic, line.line);
                continue;
            }

            if (namedDirective === 'ENDP' || namedDirective === 'ENDS') {
                continue;   // closes a block, emits nothing
            }
            if (line.mnemonic === 'EQU' && line.label) {
                const value = parseNumber(line.operands[0] ?? '');

                if (value === null) this.report(`EQU needs a constant value`, line.line);
                else this.symbols[line.label.toUpperCase()] = { kind: SYMBOL.CONSTANT, value };
                continue;
            }

            // ---- data definitions --------------------------------------------
            // "MSG DB 'Hi$'" reaches the lexer as mnemonic MSG, operand "DB 'Hi$'".
            const asData = this.matchDataDefinition(line);
            if (asData) { this.emitData(asData, line); continue; }

            // ---- "NAME LABEL WORD" -------------------------------------------
            // Names the current position without reserving anything. Two of them
            // around a region measure it exactly, which is how a table declares
            // its own length instead of carrying a hand written count.
            const asMarker = this.matchPositionMarker(line);
            if (asMarker) { this.definePosition(asMarker, line); continue; }

            if (line.mnemonic && Object.hasOwn(DATA_DIRECTIVES, line.mnemonic)) {
                this.emitData({ name: line.label, directive: line.mnemonic, items: line.operands }, line);
                continue;
            }

            // ---- a label with nothing after it -------------------------------
            if (!line.mnemonic) { this.defineLabel(line); continue; }

            // ---- an instruction ----------------------------------------------
            if (section === 'data') {
                // Anything unrecognised inside .DATA is almost certainly a
                // malformed declaration; say so rather than trying to execute it.
                this.report(`"${line.mnemonic}" is not a data declaration`, line.line);
                continue;
            }

            this.defineLabel(line, this.instructions.length);

            this.instructions.push({
                index:       this.instructions.length,
                line:        line.line,
                mnemonic:    line.mnemonic,
                prefix:      line.prefix ?? null,
                rawOperands: line.operands,
                operands:    null,          // filled in by pass two
                source:      line.source
            });
        }

        // Resolve the entry point named by END, if there was one.
        if (this.pendingEntryLabel) {
            const target = this.symbols[this.pendingEntryLabel.toUpperCase()];

            if (target && target.kind === SYMBOL.CODE) this.entryPoint = target.index;
            this.pendingEntryLabel = null;
        }
    }

    // -------------------------------------------------------------------------
    // CONDITIONAL ASSEMBLY
    //
    // IF, ELSE and ENDIF decide which lines exist at all. The state is a stack
    // so that conditionals may nest, and a branch inside a branch that was not
    // taken stays untaken however its own test comes out.
    // -------------------------------------------------------------------------

    /** True when the line currently being read is inside a taken branch. */
    assembling() {
        return this.conditionals.every(frame => frame.active);
    }

    applyConditional(line) {
        const argument = (line.operands[0] ?? '').trim();

        switch (line.mnemonic) {

            case 'IF':
            case 'IFE': {
                const enclosing = this.assembling();
                const holds     = enclosing ? this.testCondition(argument, line) : false;

                this.conditionals.push({
                    active:  line.mnemonic === 'IF' ? holds : !holds && enclosing,
                    taken:   line.mnemonic === 'IF' ? holds : !holds && enclosing,
                    enclosing
                });
                return;
            }

            case 'IFDEF':
            case 'IFNDEF': {
                const enclosing = this.assembling();
                const defined   = Object.hasOwn(this.symbols, argument.toUpperCase());
                const holds     = enclosing && (line.mnemonic === 'IFDEF' ? defined : !defined);

                this.conditionals.push({ active: holds, taken: holds, enclosing });
                return;
            }

            case 'ELSEIF': {
                const frame = this.conditionals[this.conditionals.length - 1];

                if (!frame) { this.report('ELSEIF without IF', line.line); return; }

                const holds  = frame.enclosing && !frame.taken && this.testCondition(argument, line);
                frame.active = holds;
                frame.taken  = frame.taken || holds;
                return;
            }

            case 'ELSE': {
                const frame = this.conditionals[this.conditionals.length - 1];

                if (!frame) { this.report('ELSE without IF', line.line); return; }

                frame.active = frame.enclosing && !frame.taken;
                frame.taken  = true;
                return;
            }

            default:                                  // ENDIF
                if (this.conditionals.pop() === undefined) {
                    this.report('ENDIF without IF', line.line);
                }
        }
    }

    /** Evaluate the test on an IF, reporting rather than throwing if it fails. */
    testCondition(text, line) {
        if (text === '') { this.report('IF needs a condition', line.line); return false; }

        try {
            return this.evaluate(text) !== 0;
        } catch (error) {
            this.report(error.message, line.line);
            return false;
        }
    }

    // -------------------------------------------------------------------------
    // EXPRESSIONS
    // -------------------------------------------------------------------------

    /** Evaluate a constant expression against the symbols known so far. */
    evaluate(text) {
        return evaluateExpression(text, this.context()).value;
    }

    /** The symbol table and location counter an expression is read against. */
    context() {
        return new ExpressionContext(this.symbols, this.dataBytes.length, 0);
    }

    /** Record a label, either as a jump target or as a bare marker. */
    defineLabel(line, instructionIndex = null) {
        if (!line.label) return;

        const name = line.label.toUpperCase();

        if (Object.hasOwn(this.symbols, name)) {
            this.report(`"${line.label}" is defined more than once`, line.line);
            return;
        }

        this.symbols[name] = instructionIndex === null
            ? { kind: SYMBOL.CODE, index: this.instructions.length }
            : { kind: SYMBOL.CODE, index: instructionIndex };
    }

    /** Define a code label by name, pointing at the next instruction to be
     *  emitted. Used by PROC and SEGMENT, where the name precedes the keyword. */
    defineNamedLabel(rawName, line) {
        if (!rawName) return;

        const name = rawName.toUpperCase();

        if (Object.hasOwn(this.symbols, name)) {
            this.report(`"${rawName}" is defined more than once`, line);
            return;
        }

        this.symbols[name] = { kind: SYMBOL.CODE, index: this.instructions.length };
    }

    /**
     * "NAME EQU 10" arrives with NAME as the mnemonic and "EQU 10" as operand.
     *
     * The value may be any constant expression, which is what makes the usual
     * "MSG_LEN EQU $ - MSG" work: $ is the current end of the data laid down so
     * far, so subtracting the start of the message gives its length.
     */
    defineConstant(line) {
        const body = [line.operands[0].replace(/^\s*EQU\b/i, ''), ...line.operands.slice(1)]
                        .join(',')
                        .trim();
        const name = (line.label ?? line.mnemonic ?? '').toUpperCase();

        if (!name) { this.report('EQU without a name', line.line); return; }

        try {
            this.symbols[name] = { kind: SYMBOL.CONSTANT, value: this.evaluate(body) };
        } catch (error) {
            this.report(`EQU "${name}" needs a constant value: ${error.message}`, line.line);
        }
    }

    /**
     * Recognise "NAME DB ..." where the lexer has read NAME as the mnemonic.
     * Returns { name, directive, items } or null.
     */
    matchDataDefinition(line) {
        if (!line.mnemonic || line.operands.length === 0) return null;

        const first = line.operands[0];
        const match = first.match(/^(DB|DW|DD)\s+([\s\S]+)$/i);

        if (!match) return null;
        if (Object.hasOwn(DATA_DIRECTIVES, line.mnemonic)) return null;   // bare DB, handled elsewhere

        // The first operand carried the directive and its first item; any
        // remaining operands are further items of the same declaration.
        const items = [match[2].trim(), ...line.operands.slice(1)];

        return { name: line.mnemonic, directive: match[1].toUpperCase(), items };
    }

    /**
     * Recognise "NAME LABEL WORD", which marks a position and reserves nothing.
     *
     * It reaches the lexer the same way a data definition does: the name arrives
     * as the mnemonic and "LABEL WORD" as the single operand.
     */
    matchPositionMarker(line) {
        if (!line.mnemonic || line.operands.length !== 1) return null;
        if (Object.hasOwn(DATA_DIRECTIVES, line.mnemonic)) return null;

        const match = line.operands[0].match(/^LABEL\s+(BYTE|WORD|DWORD)$/i);

        if (!match) return null;

        return { name: line.mnemonic, type: match[1].toUpperCase() };
    }

    /** Record a position marker as a data symbol occupying no bytes. */
    definePosition(marker, line) {
        const name  = marker.name.toUpperCase();
        const width = MARKER_WIDTHS[marker.type];

        if (Object.hasOwn(this.symbols, name)) {
            this.report(`"${marker.name}" is defined more than once`, line.line);
            return;
        }

        this.symbols[name] = {
            kind:   SYMBOL.DATA,
            offset: this.dataBytes.length,
            width,
            length: 0
        };
    }

    /** Lay bytes into the data image and record where the name points. */
    emitData(definition, line) {
        const width  = DATA_DIRECTIVES[definition.directive];
        const offset = this.dataBytes.length;

        if (definition.name) {
            const name = definition.name.toUpperCase();

            if (Object.hasOwn(this.symbols, name)) {
                this.report(`"${definition.name}" is defined more than once`, line.line);
            } else {
                this.symbols[name] = { kind: SYMBOL.DATA, offset, width, length: 0 };
            }
        }

        for (const rawItem of definition.items) {
            const item = rawItem.trim();
            if (item === '') continue;

            // "DUP" reserves repeated storage: 10 DUP(0)
            const duplicate = item.match(/^([\s\S]+?)\s+DUP\s*\(\s*([\s\S]*)\s*\)$/i);
            if (duplicate) {
                const filler = duplicate[2].trim();

                let count;
                try { count = this.evaluate(duplicate[1]); }
                catch { this.report('DUP needs a count', line.line); continue; }

                // The filler may itself be a string, as in 5 DUP('$').
                const text = filler === '?' ? null : parseStringLiteral(filler);
                const fill = filler === '?' ? 0 : (text ? text[0] : this.readValue(filler, line));

                for (let n = 0; n < count; n++) this.pushValue(fill ?? 0, width);
                continue;
            }

            // A quoted string becomes one byte per character.
            const text = parseStringLiteral(item);
            if (text) { text.forEach(byte => this.dataBytes.push(byte)); continue; }

            // "?" means reserved but uninitialised.
            if (item === '?') { this.pushValue(0, width); continue; }

            // A name that is not defined yet is almost always a code label used
            // to build a jump table. Reserve the space and fill it in later.
            if (/^[A-Za-z_@$?][A-Za-z0-9_@$?]*$/.test(item) &&
                !Object.hasOwn(this.symbols, item.toUpperCase())) {

                this.fixups.push({ offset: this.dataBytes.length, name: item, width, line: line.line });
                this.pushValue(0, width);
                continue;
            }

            const value = this.readValue(item, line);
            if (value === null) continue;

            this.pushValue(value, width);
        }

        // Record how many units the name covers, so LENGTH and SIZE can answer.
        if (definition.name) {
            const symbol = this.symbols[definition.name.toUpperCase()];

            if (symbol && symbol.kind === SYMBOL.DATA) {
                symbol.length = Math.max(1, Math.floor((this.dataBytes.length - offset) / width));
            }
        }
    }

    /** Read one data item as a constant expression, reporting if it will not. */
    readValue(item, line) {
        try {
            return this.evaluate(item);
        } catch {
            this.report(`cannot read data value "${item}"`, line.line);
            return null;
        }
    }

    // -------------------------------------------------------------------------
    // FIXUPS
    //
    // A jump table written as "TABLE DW CASE_1, CASE_2" names labels that the
    // first pass had not reached yet. Now that every address is known, the
    // reserved words can be filled in.
    // -------------------------------------------------------------------------
    applyFixups() {
        for (const fixup of this.fixups) {
            const symbol = this.symbols[fixup.name.toUpperCase()];

            if (!symbol) {
                this.report(`"${fixup.name}" is not defined`, fixup.line);
                continue;
            }

            const value = symbol.kind === SYMBOL.DATA     ? symbol.offset
                        : symbol.kind === SYMBOL.CONSTANT ? symbol.value
                        :                                   symbol.index;

            for (let byte = 0; byte < fixup.width; byte++) {
                this.dataBytes[fixup.offset + byte] = (value >> (byte * 8)) & 0xFF;
            }
        }
    }

    /** Append one value in little endian order. */
    pushValue(value, width) {
        for (let byte = 0; byte < width; byte++) {
            this.dataBytes.push((value >> (byte * 8)) & 0xFF);
        }
    }

    // -------------------------------------------------------------------------
    // PASS TWO
    //
    // Every address is now known, so operands can be parsed and each symbol
    // checked. Unknown names are reported individually.
    // -------------------------------------------------------------------------
    secondPass() {
        for (const instruction of this.instructions) {
            const parsed = [];

            for (const rawOperand of instruction.rawOperands) {
                try {
                    const operand = parseOperand(rawOperand, instruction.line, this.context());

                    this.checkSymbol(operand, instruction.line);
                    parsed.push(operand);
                } catch (error) {
                    this.report(error.message, error.line ?? instruction.line);
                    parsed.push({ kind: OPERAND.IMMEDIATE, value: 0, width: null, invalid: true });
                }
            }

            instruction.operands = parsed;
        }
    }

    /** Confirm that any name an operand mentions was actually defined. */
    checkSymbol(operand, line) {
        const named = operand.kind === OPERAND.SYMBOL ? operand.name : operand.symbol;

        if (!named) return;

        const name = named.toUpperCase();

        // @DATA is supplied by the loader, not by the program.
        if (name === '@DATA' || name === '@CODE' || name === '@STACK') return;

        if (!Object.hasOwn(this.symbols, name)) {
            this.report(`"${named}" is not defined`, line);
        }
    }
}
