// -----------------------------------------------------------------------------
// Script Name: core.test.mjs
// Module:      Conformance Suite, core
// Stack:       Node.js (ES modules), no test framework
// Description: Verifies the CPU core modules against documented 8086 behaviour.
//              Every case here corresponds to a defect measured on the previous
//              emulator, so a pass is evidence the defect is closed rather than
//              a general claim of correctness.
//
// Authors:     Amey Thakur
// Repository:  https://github.com/Amey-Thakur/8086-ASSEMBLY-LANGUAGE-PROGRAMS
// License:     CC BY 4.0
// -----------------------------------------------------------------------------

import { Memory }       from '../cpu/memory.js';
import { RegisterFile } from '../cpu/registers.js';
import { Flags }        from '../cpu/flags.js';
import { Shifter }      from '../cpu/shifter.js';

let passed = 0;
let failed = 0;

function check(name, actual, expected) {
    const a = JSON.stringify(actual);
    const e = JSON.stringify(expected);

    if (a === e) { passed++; console.log(`  pass  ${name}`); }
    else         { failed++; console.log(`  FAIL  ${name}\n          got ${a}\n          want ${e}`); }
}

const hex = (v, w = 4) => v.toString(16).toUpperCase().padStart(w, '0');

// -----------------------------------------------------------------------------
console.log('\nMEMORY  (previously: writes never persisted)');
// -----------------------------------------------------------------------------
{
    const mem = new Memory();

    mem.writeWord(0x0000, 0x0100, 0x1234);
    check('word round trip', hex(mem.readWord(0x0000, 0x0100)), '1234');

    check('little endian low byte',  hex(mem.readByte(0x0000, 0x0100), 2), '34');
    check('little endian high byte', hex(mem.readByte(0x0000, 0x0101), 2), '12');

    // seg:off must collapse to the same physical cell
    mem.writeByte(0x1000, 0x0000, 0xAB);
    check('segment aliasing 1000:0000 == 0000:0000+10000h',
          hex(mem.readByte(0x0FFF, 0x0010), 2), 'AB');

    check('dirty journal records writes', mem.takeDirty().length > 0, true);
}

// -----------------------------------------------------------------------------
console.log('\nREGISTERS  (8-bit halves must alias, not overwrite)');
// -----------------------------------------------------------------------------
{
    const r = new RegisterFile();

    r.set('AX', 0x1234);
    r.set('AL', 0xFF);
    check('writing AL preserves AH', hex(r.get('AX')), '12FF');

    r.set('AX', 0x1234);
    r.set('AH', 0xAB);
    check('writing AH preserves AL', hex(r.get('AX')), 'AB34');

    check('AL reads low half',  hex(r.get('AL'), 2), '34');
    check('AH reads high half', hex(r.get('AH'), 2), 'AB');

    check('SP powers on at FFFE', hex(r.get('SP')), 'FFFE');
}

// -----------------------------------------------------------------------------
console.log('\nFLAGS  (previously: AF and OF never set, INC/DEC clobbered CF)');
// -----------------------------------------------------------------------------
{
    const f = new Flags();

    // FFFF + 1 wraps to zero, carrying out of both bit 3 and bit 15
    let result = f.applyAddition(0xFFFF, 1, 0, 2);
    check('FFFF+1 result', hex(result), '0000');
    check('FFFF+1 flags',
          { CF: f.CF, ZF: f.ZF, AF: f.AF, OF: f.OF, SF: f.SF },
          { CF: 1,    ZF: 1,    AF: 1,    OF: 0,    SF: 0 });

    // 7FFF + 1 is the classic signed overflow: no carry out, but the sign flips
    f.reset();
    result = f.applyAddition(0x7FFF, 1, 0, 2);
    check('7FFF+1 signed overflow',
          { AX: hex(result), OF: f.OF, SF: f.SF, CF: f.CF },
          { AX: '8000',      OF: 1,    SF: 1,    CF: 0 });

    // 0Fh + 1 crosses the nibble boundary, which is exactly what AF reports
    f.reset();
    result = f.applyAddition(0x0F, 1, 0, 1);
    check('0Fh+1 auxiliary carry', { AL: hex(result, 2), AF: f.AF }, { AL: '10', AF: 1 });

    // subtraction sets CF as a borrow
    f.reset();
    result = f.applySubtraction(0x0000, 1, 0, 2);
    check('0-1 borrow', { AX: hex(result), CF: f.CF, SF: f.SF }, { AX: 'FFFF', CF: 1, SF: 1 });

    // the rule the old emulator broke
    f.reset();
    f.CF = 1;
    result = f.applyIncrement(0x0001, 2);
    check('INC preserves CF', { AX: hex(result), CF: f.CF }, { AX: '0002', CF: 1 });

    f.CF = 1;
    result = f.applyDecrement(0x0005, 2);
    check('DEC preserves CF', { AX: hex(result), CF: f.CF }, { AX: '0004', CF: 1 });

    // logical operations always clear CF and OF
    f.reset();
    f.CF = 1; f.OF = 1;
    result = f.applyLogical(0xFFFF & 0x0F0F, 2);
    check('AND clears CF and OF', { AX: hex(result), CF: f.CF, OF: f.OF }, { AX: '0F0F', CF: 0, OF: 0 });

    // parity is the low byte only, even for a word result
    f.reset();
    f.applyLogical(0xFF00, 2);
    check('PF ignores the high byte', f.PF, 1);

    // PUSHF / POPF round trip, including the fixed reserved bits
    f.reset();
    f.CF = 1; f.ZF = 1; f.DF = 1;
    const word = f.toWord();
    const g = new Flags();
    g.fromWord(word);
    check('flags word round trip', { CF: g.CF, ZF: g.ZF, DF: g.DF }, { CF: 1, ZF: 1, DF: 1 });
}

// -----------------------------------------------------------------------------
console.log('\nSHIFTER  (previously: rotates lost the bit entirely)');
// -----------------------------------------------------------------------------
{
    const f = new Flags();
    const run = (op, val, cnt, width) => {
        f.reset();
        const out = Shifter.execute(f, op, val, cnt, width);
        return { v: hex(out, width === 1 ? 2 : 4), CF: f.CF };
    };

    check('ROL 80h,1 wraps to 01h', run('ROL', 0x80, 1, 1), { v: '01', CF: 1 });
    check('ROR 01h,1 wraps to 80h', run('ROR', 0x01, 1, 1), { v: '80', CF: 1 });
    check('SHL 80h,1 shifts out',   run('SHL', 0x80, 1, 1), { v: '00', CF: 1 });
    check('SHR 81h,1',              run('SHR', 0x81, 1, 1), { v: '40', CF: 1 });
    check('SAR 80h,1 keeps sign',   run('SAR', 0x80, 1, 1), { v: 'C0', CF: 0 });

    // RCL and RCR move through the carry flag, so the ring is nine bits wide
    f.reset(); f.CF = 0;
    check('RCL 80h,1 with CF clear', { v: hex(Shifter.execute(f, 'RCL', 0x80, 1, 1), 2), CF: f.CF },
                                     { v: '00', CF: 1 });

    f.reset(); f.CF = 0;
    check('RCR 01h,1 with CF clear', { v: hex(Shifter.execute(f, 'RCR', 0x01, 1, 1), 2), CF: f.CF },
                                     { v: '00', CF: 1 });

    // a count of zero must not touch a single flag
    f.reset(); f.CF = 1; f.ZF = 1;
    const untouched = Shifter.execute(f, 'SHL', 0x55, 0, 1);
    check('count 0 is a true no-op', { v: hex(untouched, 2), CF: f.CF, ZF: f.ZF },
                                     { v: '55', CF: 1, ZF: 1 });

    // rotating by the full width returns the original value
    check('ROL by 8 is identity', run('ROL', 0x3C, 8, 1).v, '3C');
    check('ROR by 16 is identity', run('ROR', 0xBEEF, 16, 2).v, 'BEEF');
}

// -----------------------------------------------------------------------------
console.log(`\n${passed} passed, ${failed} failed\n`);
process.exit(failed === 0 ? 0 : 1);
