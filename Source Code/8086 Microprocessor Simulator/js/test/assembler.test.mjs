// -----------------------------------------------------------------------------
// Script Name: assembler.test.mjs
// Module:      Conformance Suite, assembler
// Stack:       Node.js (ES modules), no test framework
// Description: Verifies two pass assembly: forward references, data layout in
//              little endian order, DUP reservations, EQU constants, and the
//              accumulation of diagnostics so one run reports every mistake.
//
// Authors:     Amey Thakur
// Repository:  https://github.com/Amey-Thakur/8086-ASSEMBLY-LANGUAGE-PROGRAMS
// License:     CC BY 4.0
// -----------------------------------------------------------------------------

import { Assembler, SYMBOL } from '../asm/assembler.js';

let passed = 0;
let failed = 0;

function check(name, actual, expected) {
    const a = JSON.stringify(actual);
    const e = JSON.stringify(expected);

    if (a === e) { passed++; console.log(`  pass  ${name}`); }
    else         { failed++; console.log(`  FAIL  ${name}\n          got ${a}\n          want ${e}`); }
}

const assemble = source => new Assembler().assemble(source);
const bytes    = image => Array.from(image);

// -----------------------------------------------------------------------------
console.log('\nINSTRUCTIONS AND LABELS');
// -----------------------------------------------------------------------------
{
    const result = assemble([
        '.CODE',
        'START:',
        '    MOV AX, 5',
        '    MOV BX, 3',
        '    ADD AX, BX',
        '    HLT',
        'END START'
    ].join('\n'));

    check('assembles without complaint', result.ok, true);
    check('four instructions emitted',   result.instructions.length, 4);
    check('START points at the first',   result.symbols.START, { kind: SYMBOL.CODE, index: 0 });
    check('END names the entry point',   result.entryPoint, 0);
    check('operands parsed in pass two', result.instructions[0].operands.length, 2);
    check('line numbers survive',        result.instructions[3].line, 6);
}

// -----------------------------------------------------------------------------
console.log('\nFORWARD REFERENCES  (the reason two passes exist)');
// -----------------------------------------------------------------------------
{
    const result = assemble([
        '    JMP FINISH',
        '    MOV AX, 99',
        'FINISH:',
        '    MOV AX, 1',
        '    HLT'
    ].join('\n'));

    check('a jump to a later label resolves', result.ok, true);
    check('FINISH points at instruction two', result.symbols.FINISH.index, 2);
}

// -----------------------------------------------------------------------------
console.log('\nDATA LAYOUT  (little endian, offsets assigned in order)');
// -----------------------------------------------------------------------------
{
    const result = assemble([
        '.DATA',
        "MSG   DB 'Hi$'",
        'NUM   DW 1234h',
        'SMALL DB 5',
        '.CODE',
        '    HLT'
    ].join('\n'));

    check('assembles cleanly', result.ok, true);
    // length is how many units the name covers, which is what LENGTH reports.
    check('MSG at offset zero',
          result.symbols.MSG, { kind: SYMBOL.DATA, offset: 0, width: 1, length: 3 });
    check('NUM follows the string',
          result.symbols.NUM, { kind: SYMBOL.DATA, offset: 3, width: 2, length: 1 });
    check('SMALL follows the word', result.symbols.SMALL.offset, 5);

    check('string laid out byte per character, word in little endian',
          bytes(result.data), [0x48, 0x69, 0x24, 0x34, 0x12, 0x05]);
}

// -----------------------------------------------------------------------------
console.log('\nDUP AND UNINITIALISED STORAGE');
// -----------------------------------------------------------------------------
{
    const result = assemble([
        '.DATA',
        'BUF   DB 5 DUP(0)',
        'WORDS DW 3 DUP(?)',
        'GAP   DB ?',
        '.CODE',
        '    HLT'
    ].join('\n'));

    check('DUP assembles', result.ok, true);
    check('five bytes reserved then six for three words',
          { total: result.data.length, wordsAt: result.symbols.WORDS.offset, gapAt: result.symbols.GAP.offset },
          { total: 12, wordsAt: 5, gapAt: 11 });
}

// -----------------------------------------------------------------------------
console.log('\nEQU CONSTANTS');
// -----------------------------------------------------------------------------
{
    const result = assemble([
        'COUNT EQU 10',
        'LIMIT EQU 0FFh',
        '.CODE',
        '    MOV CX, COUNT',
        '    HLT'
    ].join('\n'));

    check('constants recorded', result.symbols.COUNT, { kind: SYMBOL.CONSTANT, value: 10 });
    check('hex constant',       result.symbols.LIMIT.value, 255);
    check('a constant is not an instruction', result.instructions.length, 2);
    check('no diagnostics', result.diagnostics.map(String), []);
}

// -----------------------------------------------------------------------------
console.log('\nDIAGNOSTICS  (every mistake reported, not just the first)');
// -----------------------------------------------------------------------------
{
    const result = assemble([
        '.CODE',
        '    JMP NOWHERE',
        '    MOV AX, MISSING',
        '    MOV [AX], BX',
        '    HLT'
    ].join('\n'));

    check('assembly reported as failed', result.ok, false);
    check('three separate problems found', result.diagnostics.length, 3);
    check('unknown jump target named',  result.diagnostics[0].message.includes('NOWHERE'), true);
    check('unknown data symbol named',  result.diagnostics[1].message.includes('MISSING'), true);
    check('illegal addressing rejected',
          result.diagnostics[2].message.includes('cannot be used inside brackets'), true);
    check('each carries a line number',
          result.diagnostics.map(d => d.line), [2, 3, 4]);
}

// -----------------------------------------------------------------------------
console.log('\nDUPLICATE DEFINITIONS');
// -----------------------------------------------------------------------------
{
    const result = assemble([
        '.DATA',
        'VALUE DB 1',
        'VALUE DB 2',
        '.CODE',
        '    HLT'
    ].join('\n'));

    check('duplicate name refused', result.ok, false);
    check('message names the symbol',
          result.diagnostics[0].message.includes('defined more than once'), true);
}

// -----------------------------------------------------------------------------
console.log('\nA REALISTIC PROGRAM  (the shape the 161 programs actually take)');
// -----------------------------------------------------------------------------
{
    const result = assemble([
        '.MODEL SMALL',
        '.STACK 100H',
        '.DATA',
        "    MSG DB 'Hello, World!$'",
        '.CODE',
        'MAIN PROC',
        '    MOV AX, @DATA',
        '    MOV DS, AX',
        '    LEA DX, MSG',
        '    MOV AH, 09H',
        '    INT 21H',
        '    MOV AH, 4CH',
        '    INT 21H',
        'MAIN ENDP',
        'END MAIN'
    ].join('\n'));

    check('a complete DOS program assembles', result.ok, true);
    check('directives emitted no instructions', result.instructions.length, 7);
    check('the string is in the data image', result.data.length, 14);
    check('@DATA is accepted without definition',
          result.diagnostics.filter(d => d.message.includes('@DATA')).length, 0);
    check('first instruction is the MOV', result.instructions[0].mnemonic, 'MOV');
    check('INT survived parsing', result.instructions[4].mnemonic, 'INT');
}

// -----------------------------------------------------------------------------
console.log('\nREPT, THE ASSEMBLER REPEATING A BLOCK');
// -----------------------------------------------------------------------------
{
    const result = assemble(`
.MODEL SMALL
.DATA
    FOUR    DW 0
.CODE
START:
    REPT 4
    INC AX
    ENDM
    MOV BX, AX
    MOV AH, 4CH
    INT 21H
END START
`);

    check('REPT reported no errors', result.diagnostics.length, 0);
    check('four copies were written', result.instructions.filter(i => i.mnemonic === 'INC').length, 4);
    check('the line after the block survived', result.instructions[4].mnemonic, 'MOV');

    // A count that only the symbol table would know cannot be used, because the
    // repetition happens before the symbol table exists.
    const late = assemble(`
.MODEL SMALL
.DATA
    HOWMANY EQU 3
.CODE
START:
    REPT HOWMANY
    INC AX
    ENDM
    MOV AH, 4CH
    INT 21H
END START
`);

    check('a symbolic count is refused with a reason',
          late.diagnostics.some(d => d.message.includes('before the program is laid out')), true);

    // ENDM closes a REPT as well as a macro, so a macro containing one must not
    // be cut short at the inner ENDM.
    const nested = assemble(`
BAR MACRO HOWMANY
    REPT HOWMANY
    INC AX
    ENDM
    MOV BX, AX
ENDM

.MODEL SMALL
.CODE
START:
    BAR 3
    MOV AH, 4CH
    INT 21H
END START
`);

    check('a REPT inside a macro reported no errors', nested.diagnostics.length, 0);
    check('the macro repeated three times',
          nested.instructions.filter(i => i.mnemonic === 'INC').length, 3);
    check('the rest of the macro body survived the inner ENDM',
          nested.instructions.some(i => i.mnemonic === 'MOV'), true);
}

// -----------------------------------------------------------------------------
console.log('\nLABEL, A POSITION THAT RESERVES NOTHING');
// -----------------------------------------------------------------------------
{
    const result = assemble(`
.MODEL SMALL
.DATA
    TABLE     LABEL WORD
    DW 1, 2, 3, 4, 5
    TABLE_END LABEL WORD
    ROWS      EQU (TABLE_END - TABLE) / 2
.CODE
START:
    MOV AX, ROWS
    MOV BX, TABLE_END - TABLE
    MOV AH, 4CH
    INT 21H
END START
`);

    check('LABEL reported no errors', result.diagnostics.length, 0);
    check('the marker reserved no bytes', result.data.length, 10);
    check('both markers are data symbols',
          [result.symbols.TABLE.kind, result.symbols.TABLE_END.kind],
          [SYMBOL.DATA, SYMBOL.DATA]);
    check('they bracket the region exactly',
          result.symbols.TABLE_END.offset - result.symbols.TABLE.offset, 10);
    check('LABEL WORD declares a width of two', result.symbols.TABLE.width, 2);
    check('the measured row count folded to five', result.symbols.ROWS.value, 5);

    // The difference of two addresses is a count, not an address, so it has to
    // assemble as an immediate rather than as a memory read.
    check('a label difference is an immediate, not a memory read',
          result.instructions[1].operands[1].kind, 'immediate');
    check('and it carries the right number',
          result.instructions[1].operands[1].value, 10);
}

// -----------------------------------------------------------------------------
console.log('\nWHEN A DATA NAME MAKES AN EXPRESSION AN ADDRESS');
// -----------------------------------------------------------------------------
{
    const result = assemble(`
.MODEL SMALL
.DATA
    FIRST   DW 1, 2, 3
    SECOND  DW 9
.CODE
START:
    MOV AX, FIRST + 2
    MOV BX, OFFSET FIRST + 2
    MOV CX, SECOND - FIRST
    MOV DX, SECOND - FIRST + 1
    MOV AH, 4CH
    INT 21H
END START
`);

    check('no errors', result.diagnostics.length, 0);

    // One address left standing means a memory reference: the word two bytes
    // past FIRST, which is the second element.
    check('one address makes it a memory reference',
          result.instructions[0].operands[1].kind, 'memory');

    // OFFSET asks about the address instead of the contents, so the count is
    // suppressed and the result is a plain number.
    check('OFFSET suppresses it',
          result.instructions[1].operands[1].kind, 'immediate');

    // Two addresses that subtract cancel, leaving a length.
    check('two addresses cancel to a number',
          result.instructions[2].operands[1].kind, 'immediate');
    check('and the length is right', result.instructions[2].operands[1].value, 6);

    // Cancelling still holds with a constant added afterwards.
    check('a constant added after the cancellation keeps it a number',
          result.instructions[3].operands[1].kind, 'immediate');
    check('and the arithmetic is right', result.instructions[3].operands[1].value, 7);
}

// -----------------------------------------------------------------------------
console.log(`\n${passed} passed, ${failed} failed\n`);
process.exit(failed === 0 ? 0 : 1);
