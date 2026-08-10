// -----------------------------------------------------------------------------
// Script Name: operands.test.mjs
// Module:      Conformance Suite, operands
// Stack:       Node.js (ES modules), no test framework
// Description: Verifies operand classification, the legal 8086 addressing
//              combinations, rejection of the illegal ones, and effective
//              address computation against a live machine.
//
// Authors:     Amey Thakur
// Repository:  https://github.com/Amey-Thakur/8086-ASSEMBLY-LANGUAGE-PROGRAMS
// License:     CC BY 4.0
// -----------------------------------------------------------------------------

import { parseOperand, parseAddressExpression, effectiveAddress, segmentBaseOf, OPERAND }
    from '../asm/operands.js';
import { ExpressionContext } from '../asm/expressions.js';
import { SYMBOL } from '../asm/assembler.js';
import { CPU } from '../cpu/cpu.js';

let passed = 0;
let failed = 0;

function check(name, actual, expected) {
    const a = JSON.stringify(actual);
    const e = JSON.stringify(expected);

    if (a === e) { passed++; console.log(`  pass  ${name}`); }
    else         { failed++; console.log(`  FAIL  ${name}\n          got ${a}\n          want ${e}`); }
}

function rejects(name, thunk, fragment) {
    try {
        thunk();
        failed++;
        console.log(`  FAIL  ${name}\n          expected a rejection, none raised`);
    } catch (error) {
        if (fragment && !error.message.includes(fragment)) {
            failed++;
            console.log(`  FAIL  ${name}\n          message was "${error.message}"`);
        } else {
            passed++;
            console.log(`  pass  ${name}`);
        }
    }
}

const hex = v => v.toString(16).toUpperCase().padStart(4, '0');

// -----------------------------------------------------------------------------
console.log('\nCLASSIFICATION');
// -----------------------------------------------------------------------------
check('16-bit register', parseOperand('AX'), { kind: OPERAND.REGISTER, name: 'AX', width: 2 });
check('8-bit register',  parseOperand('bl'), { kind: OPERAND.REGISTER, name: 'BL', width: 1 });
check('segment register', parseOperand('DS'), { kind: OPERAND.REGISTER, name: 'DS', width: 2 });

check('decimal immediate', parseOperand('42'),    { kind: OPERAND.IMMEDIATE, value: 42, width: null });
check('hex immediate',     parseOperand('0FFh'),  { kind: OPERAND.IMMEDIATE, value: 255, width: null });
check('character immediate', parseOperand("'A'"), { kind: OPERAND.IMMEDIATE, value: 65, width: null });

check('bare symbol', parseOperand('COUNT'),
      { kind: OPERAND.SYMBOL, name: 'COUNT', width: null, override: null });

// -----------------------------------------------------------------------------
console.log('\nSIZE HINTS AND SEGMENT OVERRIDES');
// -----------------------------------------------------------------------------
{
    const byteHint = parseOperand('BYTE PTR [BX]');
    check('BYTE PTR sets width one', { kind: byteHint.kind, width: byteHint.width },
                                     { kind: OPERAND.MEMORY, width: 1 });

    const wordHint = parseOperand('WORD PTR [SI]');
    check('WORD PTR sets width two', wordHint.width, 2);

    const override = parseOperand('ES:[DI]');
    check('segment override captured',
          { override: override.override, index: override.index },
          { override: 'ES', index: 'DI' });

    const both = parseOperand('BYTE PTR ES:[BX+SI]');
    check('hint and override together',
          { width: both.width, override: both.override, base: both.base, index: both.index },
          { width: 1, override: 'ES', base: 'BX', index: 'SI' });
}

// -----------------------------------------------------------------------------
console.log('\nLEGAL ADDRESSING COMBINATIONS');
// -----------------------------------------------------------------------------
check('[BX]',        parseAddressExpression('BX'),
      { base: 'BX', index: null, displacement: 0, symbol: null });
check('[SI]',        parseAddressExpression('SI'),
      { base: null, index: 'SI', displacement: 0, symbol: null });
check('[BX+SI]',     parseAddressExpression('BX+SI'),
      { base: 'BX', index: 'SI', displacement: 0, symbol: null });
check('[BP+DI]',     parseAddressExpression('BP+DI'),
      { base: 'BP', index: 'DI', displacement: 0, symbol: null });
check('[BX+4]',      parseAddressExpression('BX+4'),
      { base: 'BX', index: null, displacement: 4, symbol: null });
check('[BX+SI+10h]', parseAddressExpression('BX+SI+10h'),
      { base: 'BX', index: 'SI', displacement: 16, symbol: null });
check('negative displacement', parseAddressExpression('BP-2'),
      { base: 'BP', index: null, displacement: -2, symbol: null });
check('direct address', parseAddressExpression('1234h'),
      { base: null, index: null, displacement: 0x1234, symbol: null });
check('symbol plus index', parseAddressExpression('ARRAY+SI'),
      { base: null, index: 'SI', displacement: 0, symbol: 'ARRAY' });

// -----------------------------------------------------------------------------
console.log('\nILLEGAL COMBINATIONS ARE REFUSED  (they would fail on real hardware)');
// -----------------------------------------------------------------------------
rejects('[AX] is not addressable', () => parseAddressExpression('AX'), 'cannot be used inside brackets');
rejects('[CX+DX] is not addressable', () => parseAddressExpression('CX+DX'), 'cannot be used inside brackets');
rejects('two base registers', () => parseAddressExpression('BX+BP'), 'two base registers');
rejects('two index registers', () => parseAddressExpression('SI+DI'), 'two index registers');
rejects('a register cannot be negated', () => parseAddressExpression('BX-SI'), 'cannot be negated');
rejects('empty brackets', () => parseOperand('[]'), 'empty address expression');

// -----------------------------------------------------------------------------
console.log('\nEFFECTIVE ADDRESS  (computed against a live machine)');
// -----------------------------------------------------------------------------
{
    const cpu = new CPU();

    cpu.registers.set('BX', 0x0100);
    cpu.registers.set('SI', 0x0020);
    cpu.registers.set('BP', 0x0200);

    check('[BX]',        hex(effectiveAddress(cpu, parseOperand('[BX]'))),        '0100');
    check('[BX+SI]',     hex(effectiveAddress(cpu, parseOperand('[BX+SI]'))),     '0120');
    check('[BX+SI+4]',   hex(effectiveAddress(cpu, parseOperand('[BX+SI+4]'))),   '0124');
    check('[BP-2]',      hex(effectiveAddress(cpu, parseOperand('[BP-2]'))),      '01FE');
    check('[1234h]',     hex(effectiveAddress(cpu, parseOperand('[1234h]'))),     '1234');

    const symbols = { ARRAY: { offset: 0x0050 } };
    check('[ARRAY+SI] resolves the symbol',
          hex(effectiveAddress(cpu, parseOperand('[ARRAY+SI]'), symbols)), '0070');

    // The adder wraps at sixteen bits, exactly as the hardware does.
    cpu.registers.set('BX', 0xFFFF);
    check('address arithmetic wraps at 16 bits',
          hex(effectiveAddress(cpu, parseOperand('[BX+2]'))), '0001');
}

// -----------------------------------------------------------------------------
console.log('\nCONSTANT EXPRESSIONS INSIDE BRACKETS');
//
// MASM allows a folded constant where a displacement is expected, so
// ARRAY[COUNT*2] addresses one past the end of a word array of COUNT entries.
// Splitting the brackets on + and - leaves each product intact, so precedence
// comes out right without the address parser having to know about it.
// -----------------------------------------------------------------------------
{
    const context = new ExpressionContext({
        COUNT: { kind: SYMBOL.CONSTANT, value: 6 },
        LEN:   { kind: SYMBOL.CONSTANT, value: 9 },
        ARRAY: { kind: SYMBOL.DATA, offset: 0x0050, width: 2, length: 4 }
    });

    check('COUNT*2 folds to a displacement',
          parseAddressExpression('COUNT * 2', null, context),
          { base: null, index: null, displacement: 12, symbol: null });

    check('a product adds to a register term',
          parseAddressExpression('BX + COUNT*2', null, context),
          { base: 'BX', index: null, displacement: 12, symbol: null });

    check('a negated product subtracts',
          parseAddressExpression('SI - COUNT*2', null, context),
          { base: null, index: 'SI', displacement: -12, symbol: null });

    check('division folds too',
          parseAddressExpression('(LEN+1)/2', null, context),
          { base: null, index: null, displacement: 5, symbol: null });

    check('ARRAY[COUNT*2] keeps the name and folds the brackets',
          parseOperand('ARRAY[COUNT*2]', null, context),
          { kind: OPERAND.MEMORY, base: null, index: null, displacement: 12,
            symbol: 'ARRAY', width: null, override: null });

    // Scaling an address is a 386 mode. Folding OFFSET ARRAY * 2 into a
    // displacement would produce a plausible but meaningless number, so the
    // assembler refuses and says what to do instead.
    rejects('a scaled label is refused',
            () => parseAddressExpression('ARRAY * 2', null, context),
            'the 8086 cannot do');

    // Without a symbol table there is nothing to fold against, and the older
    // message is still the right one.
    rejects('a product without a context is still rejected',
            () => parseAddressExpression('COUNT * 2'),
            'cannot parse');

    check('a grouped constant survives beside a register',
          parseAddressExpression('BX + (LEN+1)/2', null, context),
          { base: 'BX', index: null, displacement: 5, symbol: null });

    rejects('an unclosed group is reported',
            () => parseAddressExpression('BX + (LEN+1', null, context),
            'unbalanced "("');

    rejects('a surplus close is reported',
            () => parseAddressExpression('BX + LEN)', null, context),
            'unbalanced ")"');
}

// -----------------------------------------------------------------------------
console.log('\nDEFAULT SEGMENT SELECTION');
// -----------------------------------------------------------------------------
check('base wins over index', segmentBaseOf(parseOperand('[BP+SI]')), 'BP');
check('index used when no base', segmentBaseOf(parseOperand('[SI]')), 'SI');
check('direct address has neither', segmentBaseOf(parseOperand('[1000h]')), null);

// -----------------------------------------------------------------------------
console.log(`\n${passed} passed, ${failed} failed\n`);
process.exit(failed === 0 ? 0 : 1);
