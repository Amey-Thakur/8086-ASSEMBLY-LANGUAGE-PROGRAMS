// -----------------------------------------------------------------------------
// Script Name: registers.js
// Module:      CPU Core, 2 of 6
// Stack:       JavaScript (ES2020), no dependencies
// Description: The 8086 register file. Holds the four general purpose registers,
//              the pointer and index registers, the four segment registers and
//              the instruction pointer.
//
//              The important behaviour here is aliasing. AL and AH are not
//              separate storage, they are the low and high halves of AX. Writing
//              AL must leave AH untouched and must be visible through AX
//              immediately. The same holds for BX, CX and DX.
//
// Authors:     Amey Thakur
// Repository:  https://github.com/Amey-Thakur/8086-ASSEMBLY-LANGUAGE-PROGRAMS
// License:     CC BY 4.0
// -----------------------------------------------------------------------------

'use strict';

// -----------------------------------------------------------------------------
// REGISTER TABLES
// -----------------------------------------------------------------------------

/** The four general purpose registers, each splittable into two 8-bit halves. */
export const GENERAL_REGISTERS = ['AX', 'BX', 'CX', 'DX'];

/** Pointer and index registers. These are 16-bit only, they have no halves. */
export const INDEX_REGISTERS = ['SI', 'DI', 'BP', 'SP'];

/** Segment registers. CS:IP is the instruction stream, SS:SP the stack. */
export const SEGMENT_REGISTERS = ['CS', 'DS', 'ES', 'SS'];

/** Every addressable 16-bit register name. */
export const WORD_REGISTERS = [
    ...GENERAL_REGISTERS,
    ...INDEX_REGISTERS,
    ...SEGMENT_REGISTERS,
    'IP'
];

/** Maps each 8-bit register to its parent and which half it occupies. */
export const BYTE_REGISTERS = {
    AL: { parent: 'AX', half: 'low'  },
    AH: { parent: 'AX', half: 'high' },
    BL: { parent: 'BX', half: 'low'  },
    BH: { parent: 'BX', half: 'high' },
    CL: { parent: 'CX', half: 'low'  },
    CH: { parent: 'CX', half: 'high' },
    DL: { parent: 'DX', half: 'low'  },
    DH: { parent: 'DX', half: 'high' }
};

/** Power-on stack pointer. Chosen so the first PUSH lands at SS:FFFC. */
export const INITIAL_SP = 0xFFFE;

// -----------------------------------------------------------------------------
// REGISTER FILE
// -----------------------------------------------------------------------------
export class RegisterFile {

    constructor() {
        this.reset();
    }

    reset() {
        this.values = {
            AX: 0x0000, BX: 0x0000, CX: 0x0000, DX: 0x0000,
            SI: 0x0000, DI: 0x0000, BP: 0x0000, SP: INITIAL_SP,
            CS: 0x0000, DS: 0x0000, ES: 0x0000, SS: 0x0000,
            IP: 0x0000
        };

        // Names touched since the interface last asked, so it can highlight
        // exactly what an instruction changed instead of flashing everything.
        this.dirty = new Set();
    }

    // -------------------------------------------------------------------------
    // IDENTIFICATION
    // -------------------------------------------------------------------------

    /** True if the name is any addressable register, 8-bit or 16-bit. */
    static exists(name) {
        const upper = String(name).toUpperCase();

        return WORD_REGISTERS.includes(upper)
            || Object.hasOwn(BYTE_REGISTERS, upper);
    }

    /** Width of a register in bytes: 1 for AL and friends, 2 for the rest. */
    static widthOf(name) {
        return Object.hasOwn(BYTE_REGISTERS, String(name).toUpperCase()) ? 1 : 2;
    }

    /** True for CS, DS, ES and SS. Several instructions treat these specially. */
    static isSegment(name) {
        return SEGMENT_REGISTERS.includes(String(name).toUpperCase());
    }

    // -------------------------------------------------------------------------
    // READ
    // -------------------------------------------------------------------------

    get(name) {
        const upper = String(name).toUpperCase();
        const byte  = BYTE_REGISTERS[upper];

        if (byte) {
            const parent = this.values[byte.parent];

            return byte.half === 'low'
                ? (parent & 0x00FF)
                : ((parent >> 8) & 0x00FF);
        }

        return this.values[upper] & 0xFFFF;
    }

    // -------------------------------------------------------------------------
    // WRITE
    //
    // Writing a half must preserve the other half. Getting this wrong is what
    // makes MOV AL, 0FFh silently destroy AH, and it is a very common emulator
    // defect because the naive implementation just assigns the whole register.
    // -------------------------------------------------------------------------

    set(name, value) {
        const upper = String(name).toUpperCase();
        const byte  = BYTE_REGISTERS[upper];

        if (byte) {
            const parent  = this.values[byte.parent];
            const written = value & 0x00FF;

            this.values[byte.parent] = byte.half === 'low'
                ? ((parent & 0xFF00) | written)
                : ((parent & 0x00FF) | (written << 8));

            this.dirty.add(byte.parent);
            return;
        }

        this.values[upper] = value & 0xFFFF;
        this.dirty.add(upper);
    }

    // -------------------------------------------------------------------------
    // CONVENIENCE ACCESSORS
    //
    // These read better at the call site than get('AX') scattered through the
    // executor, and they keep the hot path free of string comparisons.
    // -------------------------------------------------------------------------

    get AX() { return this.values.AX; }  set AX(v) { this.set('AX', v); }
    get BX() { return this.values.BX; }  set BX(v) { this.set('BX', v); }
    get CX() { return this.values.CX; }  set CX(v) { this.set('CX', v); }
    get DX() { return this.values.DX; }  set DX(v) { this.set('DX', v); }
    get SI() { return this.values.SI; }  set SI(v) { this.set('SI', v); }
    get DI() { return this.values.DI; }  set DI(v) { this.set('DI', v); }
    get BP() { return this.values.BP; }  set BP(v) { this.set('BP', v); }
    get SP() { return this.values.SP; }  set SP(v) { this.set('SP', v); }
    get CS() { return this.values.CS; }  set CS(v) { this.set('CS', v); }
    get DS() { return this.values.DS; }  set DS(v) { this.set('DS', v); }
    get ES() { return this.values.ES; }  set ES(v) { this.set('ES', v); }
    get SS() { return this.values.SS; }  set SS(v) { this.set('SS', v); }
    get IP() { return this.values.IP; }  set IP(v) { this.set('IP', v); }

    // -------------------------------------------------------------------------
    // INSPECTION
    // -------------------------------------------------------------------------

    /** Snapshot for the interface. Plain object, safe to keep or diff. */
    snapshot() {
        return { ...this.values };
    }

    /** Names changed since the last call, then clear the journal. */
    takeDirty() {
        const changed = Array.from(this.dirty);

        this.dirty.clear();
        return changed;
    }
}
