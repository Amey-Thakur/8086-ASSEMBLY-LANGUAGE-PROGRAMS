// -----------------------------------------------------------------------------
// Script Name: alu.js
// Module:      CPU Core, 5 of 6
// Stack:       JavaScript (ES2020), depends on flags.js and registers.js
// Description: The 8086 arithmetic unit beyond simple add and subtract.
//              Covers multiplication, division, negation, sign extension and
//              the binary coded decimal adjustments.
//
//              Two areas need care. First, MUL and DIV are implicit-operand
//              instructions: the destination is always AX or DX:AX, never
//              whatever the programmer names. Second, the BCD adjustments read
//              the auxiliary carry, which the previous emulator never set, so
//              DAA, DAS, AAA and AAS could not have worked at all.
//
//              Division by zero and quotient overflow raise interrupt 0 on real
//              hardware. Both are surfaced here as DivideError so the executor
//              can vector correctly rather than silently producing a wrong
//              answer.
//
// Authors:     Amey Thakur
// Repository:  https://github.com/Amey-Thakur/8086-ASSEMBLY-LANGUAGE-PROGRAMS
// License:     CC BY 4.0
// -----------------------------------------------------------------------------

'use strict';

import { hasEvenParity } from './flags.js';

// -----------------------------------------------------------------------------
// HELPERS
// -----------------------------------------------------------------------------
const toSigned8  = value => (value & 0x80)   ? (value & 0xFF)   - 0x100   : (value & 0xFF);
const toSigned16 = value => (value & 0x8000) ? (value & 0xFFFF) - 0x10000 : (value & 0xFFFF);

/** Raised for divide by zero and for a quotient too large for the destination.
 *  Both conditions vector through interrupt 0 on the real part. */
export class DivideError extends Error {
    constructor(message) {
        super(message);
        this.name   = 'DivideError';
        this.vector = 0;
    }
}

// -----------------------------------------------------------------------------
// ARITHMETIC LOGIC UNIT
// -----------------------------------------------------------------------------
export class ALU {

    // -------------------------------------------------------------------------
    // UNSIGNED MULTIPLICATION
    //
    // Byte form: AX      = AL * source
    // Word form: DX:AX   = AX * source
    //
    // CF and OF are set together when the upper half of the product is non
    // zero, which is the processor telling you the result did not fit in the
    // lower half. They are the only flags MUL defines.
    // -------------------------------------------------------------------------
    static multiply(registers, flags, source, width) {
        if (width === 1) {
            const product = registers.get('AL') * (source & 0xFF);

            registers.set('AX', product & 0xFFFF);

            const overflowed = ((product >> 8) & 0xFF) !== 0;
            flags.CF = overflowed ? 1 : 0;
            flags.OF = overflowed ? 1 : 0;
            return product & 0xFFFF;
        }

        const product = registers.get('AX') * (source & 0xFFFF);
        const high    = (product / 0x10000) | 0;

        registers.set('AX', product & 0xFFFF);
        registers.set('DX', high & 0xFFFF);

        const overflowed = high !== 0;
        flags.CF = overflowed ? 1 : 0;
        flags.OF = overflowed ? 1 : 0;
        return product;
    }

    // -------------------------------------------------------------------------
    // SIGNED MULTIPLICATION
    //
    // Same destinations as MUL. CF and OF are set when the upper half is not
    // merely a sign extension of the lower half, which is the signed equivalent
    // of "the result did not fit".
    // -------------------------------------------------------------------------
    static multiplySigned(registers, flags, source, width) {
        if (width === 1) {
            const product = toSigned8(registers.get('AL')) * toSigned8(source);
            const stored  = product & 0xFFFF;

            registers.set('AX', stored);

            const notSignExtended = toSigned16(stored) !== product;
            flags.CF = notSignExtended ? 1 : 0;
            flags.OF = notSignExtended ? 1 : 0;
            return stored;
        }

        const product = toSigned16(registers.get('AX')) * toSigned16(source);
        const low     = product & 0xFFFF;
        const high    = Math.floor(product / 0x10000) & 0xFFFF;

        registers.set('AX', low);
        registers.set('DX', high);

        // Fits when the high word is pure sign extension of the low word.
        const expectedHigh    = (low & 0x8000) ? 0xFFFF : 0x0000;
        const notSignExtended = high !== expectedHigh;

        flags.CF = notSignExtended ? 1 : 0;
        flags.OF = notSignExtended ? 1 : 0;
        return product;
    }

    // -------------------------------------------------------------------------
    // UNSIGNED DIVISION
    //
    // Byte form: AL = AX / source,      AH = AX % source
    // Word form: AX = DX:AX / source,   DX = DX:AX % source
    //
    // All arithmetic flags are left undefined by the processor, so nothing is
    // written here. Inventing flag values would be worse than leaving them.
    // -------------------------------------------------------------------------
    static divide(registers, flags, source, width) {
        const divisor = width === 1 ? (source & 0xFF) : (source & 0xFFFF);

        if (divisor === 0) {
            throw new DivideError('division by zero');
        }

        if (width === 1) {
            const dividend  = registers.get('AX');
            const quotient  = Math.floor(dividend / divisor);
            const remainder = dividend % divisor;

            if (quotient > 0xFF) {
                throw new DivideError('quotient too large for AL');
            }

            registers.set('AL', quotient);
            registers.set('AH', remainder);
            return { quotient, remainder };
        }

        const dividend  = (registers.get('DX') * 0x10000) + registers.get('AX');
        const quotient  = Math.floor(dividend / divisor);
        const remainder = dividend % divisor;

        if (quotient > 0xFFFF) {
            throw new DivideError('quotient too large for AX');
        }

        registers.set('AX', quotient);
        registers.set('DX', remainder);
        return { quotient, remainder };
    }

    // -------------------------------------------------------------------------
    // SIGNED DIVISION
    //
    // The remainder takes the sign of the dividend, which is truncation toward
    // zero rather than flooring. JavaScript's trunc matches the hardware here.
    // -------------------------------------------------------------------------
    static divideSigned(registers, flags, source, width) {
        const divisor = width === 1 ? toSigned8(source) : toSigned16(source);

        if (divisor === 0) {
            throw new DivideError('division by zero');
        }

        if (width === 1) {
            const dividend  = toSigned16(registers.get('AX'));
            const quotient  = Math.trunc(dividend / divisor);
            const remainder = dividend % divisor;

            if (quotient < -128 || quotient > 127) {
                throw new DivideError('signed quotient out of range for AL');
            }

            registers.set('AL', quotient & 0xFF);
            registers.set('AH', remainder & 0xFF);
            return { quotient, remainder };
        }

        const unsigned  = (registers.get('DX') * 0x10000) + registers.get('AX');
        const dividend  = unsigned >= 0x80000000 ? unsigned - 0x100000000 : unsigned;
        const quotient  = Math.trunc(dividend / divisor);
        const remainder = dividend % divisor;

        if (quotient < -32768 || quotient > 32767) {
            throw new DivideError('signed quotient out of range for AX');
        }

        registers.set('AX', quotient & 0xFFFF);
        registers.set('DX', remainder & 0xFFFF);
        return { quotient, remainder };
    }

    // -------------------------------------------------------------------------
    // NEGATION
    //
    // NEG is subtract-from-zero, so it borrows for every operand except zero.
    // That is why CF ends up set for any non-zero input, a detail the previous
    // emulator omitted entirely.
    // -------------------------------------------------------------------------
    static negate(flags, value, width) {
        const mask    = width === 1 ? 0xFF : 0xFFFF;
        const signBit = width === 1 ? 0x80 : 0x8000;
        const operand = value & mask;

        const result = flags.applySubtraction(0, operand, 0, width);

        // Subtracting from zero borrows unless the operand was already zero.
        flags.CF = (operand !== 0) ? 1 : 0;

        // The most negative value has no positive counterpart, so it overflows.
        flags.OF = (operand === signBit) ? 1 : 0;

        return result;
    }

    // -------------------------------------------------------------------------
    // SIGN EXTENSION
    //
    // CBW widens AL into AX, CWD widens AX into DX:AX. Neither touches a flag.
    // -------------------------------------------------------------------------
    static convertByteToWord(registers) {
        registers.set('AH', (registers.get('AL') & 0x80) ? 0xFF : 0x00);
    }

    static convertWordToDouble(registers) {
        registers.set('DX', (registers.get('AX') & 0x8000) ? 0xFFFF : 0x0000);
    }

    // -------------------------------------------------------------------------
    // PACKED BCD ADJUSTMENTS
    //
    // DAA and DAS repair AL after adding or subtracting two packed BCD bytes.
    // Both depend on the auxiliary carry, so neither could work until AF was
    // implemented correctly.
    // -------------------------------------------------------------------------
    static decimalAdjustAfterAddition(registers, flags) {
        const initialAL = registers.get('AL');
        const initialCF = flags.CF;

        let al = initialAL;
        let cf = 0;

        if (((al & 0x0F) > 9) || flags.AF === 1) {
            al += 6;
            cf = initialCF | (al > 0xFF ? 1 : 0);
            flags.AF = 1;
        } else {
            flags.AF = 0;
        }

        if ((initialAL > 0x99) || initialCF === 1) {
            al += 0x60;
            cf = 1;
        }

        al &= 0xFF;
        registers.set('AL', al);

        flags.CF = cf;
        flags.ZF = (al === 0) ? 1 : 0;
        flags.SF = (al & 0x80) ? 1 : 0;
        flags.PF = hasEvenParity(al) ? 1 : 0;
    }

    static decimalAdjustAfterSubtraction(registers, flags) {
        const initialAL = registers.get('AL');
        const initialCF = flags.CF;

        let al = initialAL;
        let cf = 0;

        if (((al & 0x0F) > 9) || flags.AF === 1) {
            al -= 6;
            cf = initialCF | (al < 0 ? 1 : 0);
            flags.AF = 1;
        } else {
            flags.AF = 0;
        }

        if ((initialAL > 0x99) || initialCF === 1) {
            al -= 0x60;
            cf = 1;
        }

        al &= 0xFF;
        registers.set('AL', al);

        flags.CF = cf;
        flags.ZF = (al === 0) ? 1 : 0;
        flags.SF = (al & 0x80) ? 1 : 0;
        flags.PF = hasEvenParity(al) ? 1 : 0;
    }

    // -------------------------------------------------------------------------
    // UNPACKED BCD ADJUSTMENTS
    //
    // AAA and AAS repair AL after arithmetic on ASCII digits, carrying into AH.
    // -------------------------------------------------------------------------
    static asciiAdjustAfterAddition(registers, flags) {
        let al = registers.get('AL');
        let ah = registers.get('AH');

        if (((al & 0x0F) > 9) || flags.AF === 1) {
            al = (al + 6) & 0xFF;
            ah = (ah + 1) & 0xFF;
            flags.AF = 1;
            flags.CF = 1;
        } else {
            flags.AF = 0;
            flags.CF = 0;
        }

        registers.set('AL', al & 0x0F);
        registers.set('AH', ah);
    }

    static asciiAdjustAfterSubtraction(registers, flags) {
        let al = registers.get('AL');
        let ah = registers.get('AH');

        if (((al & 0x0F) > 9) || flags.AF === 1) {
            al = (al - 6) & 0xFF;
            ah = (ah - 1) & 0xFF;
            flags.AF = 1;
            flags.CF = 1;
        } else {
            flags.AF = 0;
            flags.CF = 0;
        }

        registers.set('AL', al & 0x0F);
        registers.set('AH', ah);
    }

    /** AAM splits AL into two unpacked decimal digits. The base is an operand
     *  on real hardware and defaults to ten. */
    static asciiAdjustAfterMultiply(registers, flags, base = 10) {
        if (base === 0) {
            throw new DivideError('AAM with a base of zero');
        }

        const al = registers.get('AL');

        registers.set('AH', Math.floor(al / base));
        registers.set('AL', al % base);

        const result = registers.get('AL');
        flags.ZF = (result === 0) ? 1 : 0;
        flags.SF = (result & 0x80) ? 1 : 0;
        flags.PF = hasEvenParity(result) ? 1 : 0;
    }

    /** AAD folds two unpacked digits back into AL before a divide. */
    static asciiAdjustBeforeDivide(registers, flags, base = 10) {
        const combined = ((registers.get('AH') * base) + registers.get('AL')) & 0xFF;

        registers.set('AL', combined);
        registers.set('AH', 0);

        flags.ZF = (combined === 0) ? 1 : 0;
        flags.SF = (combined & 0x80) ? 1 : 0;
        flags.PF = hasEvenParity(combined) ? 1 : 0;
    }
}
