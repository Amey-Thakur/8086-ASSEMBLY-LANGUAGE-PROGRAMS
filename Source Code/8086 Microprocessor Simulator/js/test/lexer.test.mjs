// -----------------------------------------------------------------------------
// Script Name: lexer.test.mjs
// Module:      Conformance Suite, lexer
// Stack:       Node.js (ES modules), no test framework
// Description: Verifies comment stripping, operand splitting and number parsing
//              against the forms that appear in real student assembly, notably
//              semicolons inside strings and commas inside bracketed operands.
//
// Authors:     Amey Thakur
// Repository:  https://github.com/Amey-Thakur/8086-ASSEMBLY-LANGUAGE-PROGRAMS
// License:     CC BY 4.0
// -----------------------------------------------------------------------------

import { stripComment, splitOperands, parseNumber, parseStringLiteral, tokenize }
    from '../asm/lexer.js';

let passed = 0;
let failed = 0;

function check(name, actual, expected) {
    const a = JSON.stringify(actual);
    const e = JSON.stringify(expected);

    if (a === e) { passed++; console.log(`  pass  ${name}`); }
    else         { failed++; console.log(`  FAIL  ${name}\n          got ${a}\n          want ${e}`); }
}

// -----------------------------------------------------------------------------
console.log('\nCOMMENTS  (a semicolon inside a string is data, not a comment)');
// -----------------------------------------------------------------------------
check('trailing comment removed', stripComment('MOV AX, 5   ; load five').trim(), 'MOV AX, 5');
check('whole-line comment',       stripComment('; nothing here').trim(), '');
check('semicolon inside quotes survives',
      stripComment("MSG DB 'a;b$'").trim(), "MSG DB 'a;b$'");
check('comment after a string still goes',
      stripComment("MSG DB 'hi$'  ; greeting").trim(), "MSG DB 'hi$'");
check('no comment at all', stripComment('HLT'), 'HLT');

// -----------------------------------------------------------------------------
console.log('\nOPERAND SPLITTING  (brackets and quotes protect their commas)');
// -----------------------------------------------------------------------------
check('two plain operands',       splitOperands('AX, BX'), ['AX', 'BX']);
check('bracketed sum stays whole', splitOperands('AX, [BX+SI]'), ['AX', '[BX+SI]']);
check('displacement inside brackets',
      splitOperands('[BX+SI+4], AL'), ['[BX+SI+4]', 'AL']);
check('comma inside a string literal',
      splitOperands("MSG, 'a,b'"), ['MSG', "'a,b'"]);
check('single operand', splitOperands('AX'), ['AX']);
check('no operands',    splitOperands(''), []);
check('segment override kept intact',
      splitOperands('AL, ES:[DI]'), ['AL', 'ES:[DI]']);

// -----------------------------------------------------------------------------
console.log('\nNUMBER FORMATS  (student code uses every one of these)');
// -----------------------------------------------------------------------------
check('decimal',              parseNumber('1234'), 1234);
check('hex with h suffix',    parseNumber('1234h'), 0x1234);
check('hex needing a leading zero', parseNumber('0FFh'), 0xFF);
check('hex with 0x prefix',   parseNumber('0x1F'), 0x1F);
check('hex with dollar sign', parseNumber('$FF'), 0xFF);
check('binary',               parseNumber('1010b'), 0b1010);
check('octal with q',         parseNumber('17q'), 15);
check('character literal',    parseNumber("'A'"), 65);
check('escaped newline',      parseNumber("'\\n'"), 10);
check('negative decimal',     parseNumber('-5'), -5);
check('a symbol is not a number', parseNumber('COUNT'), null);
check('empty string',         parseNumber(''), null);

// -----------------------------------------------------------------------------
console.log('\nSTRING LITERALS  (DB lays these out byte by byte)');
// -----------------------------------------------------------------------------
check('simple string', parseStringLiteral("'Hi$'"), [72, 105, 36]);
check('double quotes accepted', parseStringLiteral('"AB"'), [65, 66]);
check('escape sequences', parseStringLiteral("'a\\nb'"), [97, 10, 98]);
check('not a string', parseStringLiteral('COUNT'), null);

// -----------------------------------------------------------------------------
console.log('\nTOKENIZER  (labels, mnemonics, blank and comment-only lines)');
// -----------------------------------------------------------------------------
{
    const program = [
        '; a small program',
        '.DATA',
        "MSG DB 'Hello$'",
        '',
        '.CODE',
        'START:',
        '    MOV AX, @DATA   ; set up',
        '    MOV DS, AX',
        'LOOP1: DEC CX',
        '    JNZ LOOP1',
        '    HLT'
    ].join('\n');

    const tokens = tokenize(program);

    check('blank and comment lines dropped', tokens.length, 9);
    check('directive recognised',
          { m: tokens[0].mnemonic, section: tokens[0].isSection }, { m: '.DATA', section: true });
    check('data definition',
          { label: tokens[1].label, m: tokens[1].mnemonic, ops: tokens[1].operands },
          { label: null, m: 'MSG', ops: ["DB 'Hello$'"] });
    check('standalone label',
          { label: tokens[3].label, m: tokens[3].mnemonic }, { label: 'START', m: null });
    check('label and instruction on one line',
          { label: tokens[6].label, m: tokens[6].mnemonic, ops: tokens[6].operands },
          { label: 'LOOP1', m: 'DEC', ops: ['CX'] });
    check('line numbers survive', tokens[6].line, 9);
    check('mnemonic is upper cased', tokens[4].mnemonic, 'MOV');
    check('operands keep their case', tokens[4].operands, ['AX', '@DATA']);
}

// -----------------------------------------------------------------------------
console.log('\nSEGMENT OVERRIDE  (ES:[DI] must not read as a label)');
// -----------------------------------------------------------------------------
{
    const tokens = tokenize('MOV AL, ES:[DI]');

    check('no false label detected', tokens[0].label, null);
    check('mnemonic still found',    tokens[0].mnemonic, 'MOV');
    check('override kept in operand', tokens[0].operands, ['AL', 'ES:[DI]']);
}

// -----------------------------------------------------------------------------
console.log(`\n${passed} passed, ${failed} failed\n`);
process.exit(failed === 0 ? 0 : 1);
