// -----------------------------------------------------------------------------
// Script Name: flags.js
// Module:      CPU Core, 3 of 6
// Stack:       JavaScript (ES2020), no dependencies
// Description: The 8086 status and control flags, and the rules that set them.
//
//              Flags are where emulators quietly go wrong, so each rule below
//              is written out separately rather than funnelled through one
//              shared helper. The cases that are most often implemented
//              incorrectly, and which are handled explicitly here, are:
//
//                - INC and DEC must NOT disturb the carry flag
//                - AF is a real carry out of bit 3, for byte and word alike
//                - PF is computed on the LOW BYTE only, even for word results
//                - OF is signed overflow, which is not the same as CF
//                - logical operations always clear CF and OF
//
// Authors:     Amey Thakur
// Repository:  https://github.com/Amey-Thakur/8086-ASSEMBLY-LANGUAGE-PROGRAMS
// License:     CC BY 4.0
// -----------------------------------------------------------------------------

'use strict';

// -----------------------------------------------------------------------------
// BIT POSITIONS IN THE FLAGS WORD
//
// Bits 1, 3, 5, 12, 13, 14 and 15 are not implemented on the 8086 and read back
// as a fixed pattern. PUSHF must reproduce that pattern or programs that save
// and compare the flags word will disagree with real hardware.
// -----------------------------------------------------------------------------
export const FLAG_BIT = {
    CF:  0,   // carry        unsigned overflow, and the bit shifted out
    PF:  2,   // parity       even parity of the low byte
    AF:  4,   // auxiliary    carry out of bit 3, used by the BCD adjusts
    ZF:  6,   // zero
    SF:  7,   // sign         copy of the most significant bit
    TF:  8,   // trap         single step
    IF:  9,   // interrupt    enable
    DF: 10,   // direction    string operations count down when set
    OF: 11    // overflow     signed overflow
};

/** Bits that always read as 1 on the 8086. */
export const RESERVED_HIGH = 0xF002;

/** Width helpers, so callers pass 1 or 2 rather than magic masks. */
const MASK      = { 1: 0x00FF, 2: 0xFFFF };
const SIGN_BIT  = { 1: 0x0080, 2: 0x8000 };

// -----------------------------------------------------------------------------
// PARITY
//
// The 8086 sets PF when the low eight bits of the result contain an EVEN number
// of set bits. Note this is the low byte even when the operation was 16-bit.
// -----------------------------------------------------------------------------
export function hasEvenParity(value) {
    let bits  = value & 0xFF;
    let ones  = 0;

    while (bits) {
        ones ^= bits & 1;
        bits >>= 1;
    }

    return ones === 0;
}

// -----------------------------------------------------------------------------
// FLAG REGISTER
// -----------------------------------------------------------------------------
export class Flags {

    constructor() {
        this.reset();
    }

    reset() {
        this.CF = 0;
        this.PF = 0;
        this.AF = 0;
        this.ZF = 0;
        this.SF = 0;
        this.TF = 0;
        this.IF = 1;   // interrupts enabled out of reset
        this.DF = 0;   // strings count upward by default
        this.OF = 0;

        this.dirty = new Set();
    }

    // -------------------------------------------------------------------------
    // SHARED RESULT FLAGS
    //
    // Zero, sign and parity depend only on the result, never on the operands,
    // so every arithmetic and logical rule ends by calling this.
    // -------------------------------------------------------------------------
    applyResultFlags(result, width) {
        this.ZF = (result === 0) ? 1 : 0;
        this.SF = (result & SIGN_BIT[width]) ? 1 : 0;
        this.PF = hasEvenParity(result) ? 1 : 0;
    }

    // -------------------------------------------------------------------------
    // ADDITION
    //
    // CF is the carry out of the most significant bit.
    // AF is the carry out of bit 3.
    // OF is set when both operands share a sign and the result contradicts it.
    // -------------------------------------------------------------------------
    applyAddition(left, right, carryIn, width) {
        const mask     = MASK[width];
        const signBit  = SIGN_BIT[width];
        const extended = left + right + carryIn;
        const result   = extended & mask;

        this.CF = (extended > mask) ? 1 : 0;
        this.AF = (((left & 0x0F) + (right & 0x0F) + carryIn) > 0x0F) ? 1 : 0;
        this.OF = ((~(left ^ right) & (left ^ result)) & signBit) ? 1 : 0;

        this.applyResultFlags(result, width);
        return result;
    }

    // -------------------------------------------------------------------------
    // SUBTRACTION
    //
    // CF here means BORROW, which is why the test is on the signed difference
    // going below zero rather than on any bit of the result.
    // -------------------------------------------------------------------------
    applySubtraction(left, right, borrowIn, width) {
        const mask     = MASK[width];
        const signBit  = SIGN_BIT[width];
        const extended = left - right - borrowIn;
        const result   = extended & mask;

        this.CF = (extended < 0) ? 1 : 0;
        this.AF = (((left & 0x0F) - (right & 0x0F) - borrowIn) < 0) ? 1 : 0;
        this.OF = (((left ^ right) & (left ^ result)) & signBit) ? 1 : 0;

        this.applyResultFlags(result, width);
        return result;
    }

    // -------------------------------------------------------------------------
    // INCREMENT AND DECREMENT
    //
    // Identical to add-one and subtract-one in every respect EXCEPT that the
    // carry flag is preserved. This is architectural, not an accident: it lets
    // a multi-word counter be incremented without destroying a carry that the
    // surrounding code is still using.
    // -------------------------------------------------------------------------
    applyIncrement(value, width) {
        const preservedCarry = this.CF;
        const result         = this.applyAddition(value, 1, 0, width);

        this.CF = preservedCarry;
        return result;
    }

    applyDecrement(value, width) {
        const preservedCarry = this.CF;
        const result         = this.applySubtraction(value, 1, 0, width);

        this.CF = preservedCarry;
        return result;
    }

    // -------------------------------------------------------------------------
    // LOGICAL OPERATIONS
    //
    // AND, OR, XOR and TEST always clear both CF and OF. AF is documented as
    // undefined; hardware leaves it clear, and so do we, so behaviour is at
    // least deterministic.
    // -------------------------------------------------------------------------
    applyLogical(result, width) {
        const masked = result & MASK[width];

        this.CF = 0;
        this.OF = 0;
        this.AF = 0;

        this.applyResultFlags(masked, width);
        return masked;
    }

    // -------------------------------------------------------------------------
    // FLAGS WORD, FOR PUSHF AND POPF
    // -------------------------------------------------------------------------

    toWord() {
        return RESERVED_HIGH
            | (this.CF << FLAG_BIT.CF)
            | (this.PF << FLAG_BIT.PF)
            | (this.AF << FLAG_BIT.AF)
            | (this.ZF << FLAG_BIT.ZF)
            | (this.SF << FLAG_BIT.SF)
            | (this.TF << FLAG_BIT.TF)
            | (this.IF << FLAG_BIT.IF)
            | (this.DF << FLAG_BIT.DF)
            | (this.OF << FLAG_BIT.OF);
    }

    fromWord(word) {
        this.CF = (word >> FLAG_BIT.CF) & 1;
        this.PF = (word >> FLAG_BIT.PF) & 1;
        this.AF = (word >> FLAG_BIT.AF) & 1;
        this.ZF = (word >> FLAG_BIT.ZF) & 1;
        this.SF = (word >> FLAG_BIT.SF) & 1;
        this.TF = (word >> FLAG_BIT.TF) & 1;
        this.IF = (word >> FLAG_BIT.IF) & 1;
        this.DF = (word >> FLAG_BIT.DF) & 1;
        this.OF = (word >> FLAG_BIT.OF) & 1;
    }

    // -------------------------------------------------------------------------
    // INSPECTION
    // -------------------------------------------------------------------------

    snapshot() {
        return {
            CF: this.CF, PF: this.PF, AF: this.AF,
            ZF: this.ZF, SF: this.SF, TF: this.TF,
            IF: this.IF, DF: this.DF, OF: this.OF
        };
    }
}
