// -----------------------------------------------------------------------------
// Script Name: shifter.js
// Module:      CPU Core, 4 of 6
// Stack:       JavaScript (ES2020), depends on flags.js
// Description: The 8086 shift and rotate unit. Implements SHL, SAL, SHR, SAR,
//              ROL, ROR, RCL and RCR.
//
//              This unit is worth its own module because the rules are subtle
//              and the previous emulator got every one of them wrong, losing
//              the shifted bit entirely rather than rotating it. The rules the
//              hardware actually follows:
//
//                - a count of zero performs no work and changes NO flag
//                - the count is taken modulo the operand width for ROL and ROR,
//                  and modulo width + 1 for RCL and RCR because the carry flag
//                  is part of the ring
//                - CF always receives the last bit moved out
//                - OF is defined ONLY when the count is exactly 1; for longer
//                  counts the hardware leaves it in an undefined state, so we
//                  leave it untouched rather than inventing a value
//                - shifts update ZF, SF and PF; rotates do not touch them
//                - SAR replicates the sign bit, it does not shift in zeroes
//
// Authors:     Amey Thakur
// Repository:  https://github.com/Amey-Thakur/8086-ASSEMBLY-LANGUAGE-PROGRAMS
// License:     CC BY 4.0
// -----------------------------------------------------------------------------

'use strict';

import { hasEvenParity } from './flags.js';

// -----------------------------------------------------------------------------
// WIDTH CONSTANTS
// -----------------------------------------------------------------------------
const BITS     = { 1: 8,      2: 16     };
const MASK     = { 1: 0x00FF, 2: 0xFFFF };
const SIGN_BIT = { 1: 0x0080, 2: 0x8000 };

/** The operations this unit understands. */
export const SHIFT_OPERATIONS = ['SHL', 'SAL', 'SHR', 'SAR', 'ROL', 'ROR', 'RCL', 'RCR'];

/** Shifts write ZF, SF and PF. Rotates deliberately do not. */
const UPDATES_RESULT_FLAGS = new Set(['SHL', 'SAL', 'SHR', 'SAR']);

// -----------------------------------------------------------------------------
// SHIFTER
// -----------------------------------------------------------------------------
export class Shifter {

    /**
     * Perform one shift or rotate.
     *
     * @param {Flags}  flags     live flag register, read for CF and written in place
     * @param {string} operation one of SHIFT_OPERATIONS
     * @param {number} value     the operand
     * @param {number} count     shift count, already masked to 8 bits by the caller
     * @param {number} width     1 for byte, 2 for word
     * @returns {number} the result, masked to the operand width
     */
    static execute(flags, operation, value, count, width) {
        const op = String(operation).toUpperCase();

        if (!SHIFT_OPERATIONS.includes(op)) {
            throw new RangeError(`shifter: unsupported operation "${operation}"`);
        }

        const mask    = MASK[width];
        const bits    = BITS[width];
        const signBit = SIGN_BIT[width];

        const original = value & mask;
        const shifts   = count & 0xFF;

        // A count of zero is a genuine no-operation. Not even the flags move.
        if (shifts === 0) {
            return original;
        }

        let result = original;
        let carry  = flags.CF;

        switch (op) {

            // -----------------------------------------------------------------
            // ROTATE LEFT
            // Bits leaving the top re-enter at the bottom. CF ends up holding a
            // copy of the bit that wrapped around, which is the new low bit.
            // -----------------------------------------------------------------
            case 'ROL': {
                const steps = shifts % bits;

                if (steps !== 0) {
                    result = ((result << steps) | (result >>> (bits - steps))) & mask;
                }
                carry = result & 1;
                break;
            }

            // -----------------------------------------------------------------
            // ROTATE RIGHT
            // Mirror of ROL. CF holds the bit that wrapped to the top.
            // -----------------------------------------------------------------
            case 'ROR': {
                const steps = shifts % bits;

                if (steps !== 0) {
                    result = ((result >>> steps) | (result << (bits - steps))) & mask;
                }
                carry = (result & signBit) ? 1 : 0;
                break;
            }

            // -----------------------------------------------------------------
            // ROTATE LEFT THROUGH CARRY
            // The carry flag is a genuine extra bit in the ring, so the period
            // is width + 1, not width. Stepping one bit at a time keeps that
            // exact and is far clearer than a closed form.
            // -----------------------------------------------------------------
            case 'RCL': {
                const steps = shifts % (bits + 1);

                for (let step = 0; step < steps; step++) {
                    const departing = (result & signBit) ? 1 : 0;

                    result = ((result << 1) | carry) & mask;
                    carry  = departing;
                }
                break;
            }

            // -----------------------------------------------------------------
            // ROTATE RIGHT THROUGH CARRY
            // -----------------------------------------------------------------
            case 'RCR': {
                const steps = shifts % (bits + 1);

                for (let step = 0; step < steps; step++) {
                    const departing = result & 1;

                    result = ((result >>> 1) | (carry ? signBit : 0)) & mask;
                    carry  = departing;
                }
                break;
            }

            // -----------------------------------------------------------------
            // SHIFT LEFT
            // SHL and SAL are the same instruction on the 8086. Zeroes enter at
            // the bottom and the departing top bit lands in CF.
            // -----------------------------------------------------------------
            case 'SHL':
            case 'SAL': {
                for (let step = 0; step < shifts; step++) {
                    carry  = (result & signBit) ? 1 : 0;
                    result = (result << 1) & mask;
                }
                break;
            }

            // -----------------------------------------------------------------
            // SHIFT RIGHT LOGICAL
            // Zeroes enter at the top. Used for unsigned division by powers of 2.
            // -----------------------------------------------------------------
            case 'SHR': {
                for (let step = 0; step < shifts; step++) {
                    carry  = result & 1;
                    result = (result >>> 1) & mask;
                }
                break;
            }

            // -----------------------------------------------------------------
            // SHIFT RIGHT ARITHMETIC
            // The sign bit is replicated rather than cleared, so the value keeps
            // its sign. This is what makes SAR a signed divide by two, and it is
            // the difference the old emulator missed: 80h SAR 1 is C0h, not 40h.
            // -----------------------------------------------------------------
            case 'SAR': {
                for (let step = 0; step < shifts; step++) {
                    carry  = result & 1;
                    result = ((result >>> 1) | (result & signBit)) & mask;
                }
                break;
            }
        }

        flags.CF = carry ? 1 : 0;

        Shifter.#applyOverflow(flags, op, original, result, shifts, width);

        if (UPDATES_RESULT_FLAGS.has(op)) {
            flags.ZF = (result === 0) ? 1 : 0;
            flags.SF = (result & signBit) ? 1 : 0;
            flags.PF = hasEvenParity(result) ? 1 : 0;
        }

        return result;
    }

    // -------------------------------------------------------------------------
    // OVERFLOW
    //
    // OF is architecturally defined only for a single-bit shift. For any longer
    // count the hardware result is undefined, so the honest thing is to leave
    // the flag exactly as it was rather than fabricate a value that some
    // program might come to depend on.
    // -------------------------------------------------------------------------
    static #applyOverflow(flags, operation, original, result, shifts, width) {
        if (shifts !== 1) {
            return;
        }

        const signBit  = SIGN_BIT[width];
        const bits     = BITS[width];
        const topBit   = (result & signBit) ? 1 : 0;

        switch (operation) {

            // Left shifts and left rotates: set when the sign changed as the
            // bit moved out, i.e. the new top bit disagrees with the carry.
            case 'SHL':
            case 'SAL':
            case 'ROL':
            case 'RCL':
                flags.OF = (topBit ^ flags.CF) ? 1 : 0;
                break;

            // Right rotates: set when the top two bits of the result differ.
            case 'ROR':
            case 'RCR': {
                const nextBit = (result >> (bits - 2)) & 1;

                flags.OF = (topBit ^ nextBit) ? 1 : 0;
                break;
            }

            // SHR always clears the sign, so overflow is the old sign bit.
            case 'SHR':
                flags.OF = (original & signBit) ? 1 : 0;
                break;

            // SAR preserves the sign by construction, so it can never overflow.
            case 'SAR':
                flags.OF = 0;
                break;
        }
    }
}
