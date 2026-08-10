// -----------------------------------------------------------------------------
// Script Name: assembler.js
// Module:      Assembler, 3 of 3
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

/** Directives that reserve or initialise storage, and how wide each unit is. */
const DATA_DIRECTIVES = { DB: 1, DW: 2, DD: 4 };

/** Directives consumed by the assembler that emit nothing by themselves. */
const IGNORED_DIRECTIVES = new Set([
    '.MODEL', '.STACK', '.386', '.8086', '.486', '.586',
    'ASSUME', 'PROC', 'ENDP', 'SEGMENT', 'ENDS', 'PUBLIC', 'EXTRN', 'INCLUDE'
]);

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

        const lines = tokenize(source);

        this.firstPass(lines);
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
            // ---- section directives ------------------------------------------
            if (line.mnemonic === '.DATA')  { section = 'data'; this.defineLabel(line); continue; }
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

    /** "NAME EQU 10" arrives with NAME as the mnemonic and "EQU 10" as operand. */
    defineConstant(line) {
        const parts = line.operands[0].split(/\s+/);
        const value = parseNumber(parts.slice(1).join(' '));
        const name  = (line.label ?? line.mnemonic ?? '').toUpperCase();

        if (!name)          { this.report('EQU without a name', line.line); return; }
        if (value === null) { this.report(`EQU "${name}" needs a constant value`, line.line); return; }

        this.symbols[name] = { kind: SYMBOL.CONSTANT, value };
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

    /** Lay bytes into the data image and record where the name points. */
    emitData(definition, line) {
        const width  = DATA_DIRECTIVES[definition.directive];
        const offset = this.dataBytes.length;

        if (definition.name) {
            const name = definition.name.toUpperCase();

            if (Object.hasOwn(this.symbols, name)) {
                this.report(`"${definition.name}" is defined more than once`, line.line);
            } else {
                this.symbols[name] = { kind: SYMBOL.DATA, offset, width };
            }
        }

        for (const rawItem of definition.items) {
            const item = rawItem.trim();
            if (item === '') continue;

            // "DUP" reserves repeated storage: 10 DUP(0)
            const duplicate = item.match(/^(\S+)\s+DUP\s*\(\s*([^)]*)\s*\)$/i);
            if (duplicate) {
                const count = parseNumber(duplicate[1]);
                const fill  = duplicate[2].trim() === '?' ? 0 : (parseNumber(duplicate[2]) ?? 0);

                if (count === null) { this.report(`DUP needs a count`, line.line); continue; }

                for (let n = 0; n < count; n++) this.pushValue(fill, width);
                continue;
            }

            // A quoted string becomes one byte per character.
            const text = parseStringLiteral(item);
            if (text) { text.forEach(byte => this.dataBytes.push(byte)); continue; }

            // "?" means reserved but uninitialised.
            if (item === '?') { this.pushValue(0, width); continue; }

            const value = parseNumber(item);
            if (value === null) {
                this.report(`cannot read data value "${item}"`, line.line);
                continue;
            }

            this.pushValue(value, width);
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
                    const operand = parseOperand(rawOperand, instruction.line);

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
