// -----------------------------------------------------------------------------
// Script Name: alu.test.mjs
// Module:      Conformance Suite, arithmetic unit
// Stack:       Node.js (ES modules), no test framework
// Description: Verifies multiplication, division, negation, sign extension and
//              the binary coded decimal adjustments against documented 8086
//              behaviour, including the implicit AX and DX:AX destinations and
//              the interrupt 0 conditions.
//
// Authors:     Amey Thakur
// Repository:  https://github.com/Amey-Thakur/8086-ASSEMBLY-LANGUAGE-PROGRAMS
// License:     CC BY 4.0
// -----------------------------------------------------------------------------

import { RegisterFile }    from '../cpu/registers.js';
import { Flags }           from '../cpu/flags.js';
import { ALU, DivideError } from '../cpu/alu.js';

let passed = 0;
let failed = 0;

function check(name, actual, expected) {
    const a = JSON.stringify(actual);
    const e = JSON.stringify(expected);

    if (a === e) { passed++; console.log(`  pass  ${name}`); }
    else         { failed++; console.log(`  FAIL  ${name}\n          got ${a}\n          want ${e}`); }
}

const hex = (v, w = 4) => (v & (w === 2 ? 0xFF : 0xFFFF)).toString(16).toUpperCase().padStart(w, '0');

/** Fresh machine for each case, so no test can be polluted by the last. */
function machine(setup = {}) {
    const registers = new RegisterFile();
    const flags     = new Flags();

    for (const [name, value] of Object.entries(setup)) {
        registers.set(name, value);
    }
    return { registers, flags };
}

// -----------------------------------------------------------------------------
console.log('\nMULTIPLICATION  (implicit destinations AX and DX:AX)');
// -----------------------------------------------------------------------------
{
    let { registers, flags } = machine({ AL: 10 });
    ALU.multiply(registers, flags, 3, 1);
    check('MUL byte 10*3', { AX: hex(registers.get('AX')), CF: flags.CF }, { AX: '001E', CF: 0 });

    ({ registers, flags } = machine({ AL: 0xFF }));
    ALU.multiply(registers, flags, 0xFF, 1);
    check('MUL byte overflows into AH',
          { AX: hex(registers.get('AX')), CF: flags.CF, OF: flags.OF },
          { AX: 'FE01', CF: 1, OF: 1 });

    ({ registers, flags } = machine({ AX: 0x1000 }));
    ALU.multiply(registers, flags, 0x10, 2);
    check('MUL word spills into DX',
          { DX: hex(registers.get('DX')), AX: hex(registers.get('AX')), CF: flags.CF },
          { DX: '0001', AX: '0000', CF: 1 });

    ({ registers, flags } = machine({ AL: 0xFF }));           // -1
    ALU.multiplySigned(registers, flags, 0xFF, 1);            // -1 * -1
    check('IMUL byte -1 * -1',
          { AX: hex(registers.get('AX')), CF: flags.CF },
          { AX: '0001', CF: 0 });

    ({ registers, flags } = machine({ AL: 0xFB }));           // -5
    ALU.multiplySigned(registers, flags, 3, 1);               // -5 * 3
    check('IMUL byte -5 * 3', hex(registers.get('AX')), 'FFF1');   // -15
}

// -----------------------------------------------------------------------------
console.log('\nDIVISION  (quotient and remainder placement, interrupt 0 cases)');
// -----------------------------------------------------------------------------
{
    let { registers, flags } = machine({ AX: 100 });
    ALU.divide(registers, flags, 7, 1);
    check('DIV byte 100/7', { AL: hex(registers.get('AL'), 2), AH: hex(registers.get('AH'), 2) },
                            { AL: '0E', AH: '02' });

    ({ registers, flags } = machine({ DX: 0x0001, AX: 0x0000 }));   // 65536
    ALU.divide(registers, flags, 0x10, 2);
    check('DIV word 65536/16', { AX: hex(registers.get('AX')), DX: hex(registers.get('DX')) },
                               { AX: '1000', DX: '0000' });

    ({ registers, flags } = machine({ AX: 0xFFF1 }));               // -15
    ALU.divideSigned(registers, flags, 3, 1);
    check('IDIV byte -15/3', hex(registers.get('AL'), 2), 'FB');    // -5

    ({ registers, flags } = machine({ AX: 0xFFF9 }));               // -7
    ALU.divideSigned(registers, flags, 2, 1);
    check('IDIV truncates toward zero, remainder takes dividend sign',
          { AL: hex(registers.get('AL'), 2), AH: hex(registers.get('AH'), 2) },
          { AL: 'FD', AH: 'FF' });                                   // -3 remainder -1

    ({ registers, flags } = machine({ AX: 10 }));
    let raised = null;
    try { ALU.divide(registers, flags, 0, 1); } catch (error) { raised = error; }
    check('divide by zero raises interrupt 0',
          { name: raised && raised.name, vector: raised && raised.vector },
          { name: 'DivideError', vector: 0 });

    ({ registers, flags } = machine({ AX: 0xFFFF }));
    raised = null;
    try { ALU.divide(registers, flags, 1, 1); } catch (error) { raised = error; }
    check('quotient overflow raises interrupt 0', raised && raised.name, 'DivideError');
}

// -----------------------------------------------------------------------------
console.log('\nNEGATION AND SIGN EXTENSION');
// -----------------------------------------------------------------------------
{
    let { flags } = machine();
    let result = ALU.negate(flags, 1, 2);
    check('NEG 1 sets carry', { AX: hex(result), CF: flags.CF }, { AX: 'FFFF', CF: 1 });

    ({ flags } = machine());
    result = ALU.negate(flags, 0, 2);
    check('NEG 0 clears carry', { AX: hex(result), CF: flags.CF, ZF: flags.ZF }, { AX: '0000', CF: 0, ZF: 1 });

    ({ flags } = machine());
    result = ALU.negate(flags, 0x8000, 2);
    check('NEG of the most negative value overflows',
          { AX: hex(result), OF: flags.OF }, { AX: '8000', OF: 1 });

    let { registers } = machine({ AL: 0x80 });
    ALU.convertByteToWord(registers);
    check('CBW sign extends a negative AL', hex(registers.get('AX')), 'FF80');

    ({ registers } = machine({ AL: 0x7F }));
    ALU.convertByteToWord(registers);
    check('CBW leaves a positive AL alone', hex(registers.get('AX')), '007F');

    ({ registers } = machine({ AX: 0x8000 }));
    ALU.convertWordToDouble(registers);
    check('CWD sign extends into DX', hex(registers.get('DX')), 'FFFF');
}

// -----------------------------------------------------------------------------
console.log('\nBCD ADJUSTMENTS  (could not work before, AF was never set)');
// -----------------------------------------------------------------------------
{
    // 19 + 28 in packed BCD. Raw add gives 41h with AF set; DAA corrects to 47h.
    let { registers, flags } = machine({ AL: 0x19 });
    let sum = flags.applyAddition(0x19, 0x28, 0, 1);
    registers.set('AL', sum);
    ALU.decimalAdjustAfterAddition(registers, flags);
    check('DAA corrects 19h + 28h to 47h', hex(registers.get('AL'), 2), '47');

    // 55 + 55 = AAh raw, DAA gives 10 with a carry out of the hundreds
    ({ registers, flags } = machine());
    sum = flags.applyAddition(0x55, 0x55, 0, 1);
    registers.set('AL', sum);
    ALU.decimalAdjustAfterAddition(registers, flags);
    check('DAA carries past 99', { AL: hex(registers.get('AL'), 2), CF: flags.CF }, { AL: '10', CF: 1 });

    // 42 - 17 in packed BCD
    ({ registers, flags } = machine());
    const difference = flags.applySubtraction(0x42, 0x17, 0, 1);
    registers.set('AL', difference);
    ALU.decimalAdjustAfterSubtraction(registers, flags);
    check('DAS corrects 42h - 17h to 25h', hex(registers.get('AL'), 2), '25');

    // AAA after adding two ASCII digits: 9 + 8 leaves 11h, AAA gives AH=1 AL=7
    ({ registers, flags } = machine());
    const digits = flags.applyAddition(0x09, 0x08, 0, 1);
    registers.set('AL', digits);
    registers.set('AH', 0);
    ALU.asciiAdjustAfterAddition(registers, flags);
    check('AAA splits the carry into AH',
          { AH: hex(registers.get('AH'), 2), AL: hex(registers.get('AL'), 2), CF: flags.CF },
          { AH: '01', AL: '07', CF: 1 });

    ({ registers, flags } = machine({ AL: 37 }));
    ALU.asciiAdjustAfterMultiply(registers, flags);
    check('AAM splits 37 into 3 and 7',
          { AH: hex(registers.get('AH'), 2), AL: hex(registers.get('AL'), 2) },
          { AH: '03', AL: '07' });

    ({ registers, flags } = machine({ AH: 3, AL: 7 }));
    ALU.asciiAdjustBeforeDivide(registers, flags);
    check('AAD folds 3 and 7 back into 37',
          { AH: hex(registers.get('AH'), 2), AL: hex(registers.get('AL'), 2) },
          { AH: '00', AL: '25' });   // 37 decimal is 25h
}

// -----------------------------------------------------------------------------
console.log(`\n${passed} passed, ${failed} failed\n`);
process.exit(failed === 0 ? 0 : 1);
