// -----------------------------------------------------------------------------
// Script Name: memory.js
// Module:      CPU Core, 1 of 6
// Stack:       JavaScript (ES2020), no dependencies
// Description: Physical memory for the 8086. Provides a flat 1 MiB address
//              space addressed the way the real part does, by forming a
//              20-bit physical address from a segment and an offset:
//
//                  physical = (segment << 4) + offset
//
//              Also owns the read and write ports used by every other module,
//              and a change journal so the interface can highlight exactly
//              which bytes an instruction touched.
//
// Authors:     Amey Thakur
// Repository:  https://github.com/Amey-Thakur/8086-ASSEMBLY-LANGUAGE-PROGRAMS
// License:     CC BY 4.0
// -----------------------------------------------------------------------------

'use strict';

// The 8086 has 20 address lines, giving exactly 1 MiB of addressable memory.
export const ADDRESS_LINES = 20;
export const MEMORY_SIZE   = 1 << ADDRESS_LINES;   // 1 048 576 bytes
export const ADDRESS_MASK  = MEMORY_SIZE - 1;      // 0xFFFFF

// -----------------------------------------------------------------------------
// MEMORY
// -----------------------------------------------------------------------------
export class Memory {

    constructor() {
        this.bytes = new Uint8Array(MEMORY_SIZE);

        // Every write is recorded here until the interface consumes it. This is
        // what lets the memory view highlight the byte an instruction just
        // changed, rather than re-rendering 1 MiB on every step.
        this.dirty = new Set();
    }

    // -------------------------------------------------------------------------
    // ADDRESSING
    // -------------------------------------------------------------------------

    /**
     * Form a physical address from a segment and an offset.
     *
     * The addition is deliberately allowed to wrap at 20 bits. On real hardware
     * FFFF:0010 wraps to 0x00000, and programs of the era relied on it.
     */
    static physical(segment, offset) {
        return (((segment & 0xFFFF) << 4) + (offset & 0xFFFF)) & ADDRESS_MASK;
    }

    // -------------------------------------------------------------------------
    // BYTE ACCESS
    // -------------------------------------------------------------------------

    readByte(segment, offset) {
        return this.bytes[Memory.physical(segment, offset)];
    }

    writeByte(segment, offset, value) {
        const address = Memory.physical(segment, offset);

        this.bytes[address] = value & 0xFF;
        this.dirty.add(address);
    }

    // -------------------------------------------------------------------------
    // WORD ACCESS
    //
    // The 8086 is little endian: the low byte occupies the lower address. A word
    // access at offset FFFF wraps its high byte around to offset 0000 within the
    // same segment, which is why the offset is masked rather than the address.
    // -------------------------------------------------------------------------

    readWord(segment, offset) {
        const low  = this.readByte(segment, offset);
        const high = this.readByte(segment, (offset + 1) & 0xFFFF);

        return low | (high << 8);
    }

    writeWord(segment, offset, value) {
        this.writeByte(segment, offset, value & 0xFF);
        this.writeByte(segment, (offset + 1) & 0xFFFF, (value >> 8) & 0xFF);
    }

    // -------------------------------------------------------------------------
    // BULK HELPERS
    // -------------------------------------------------------------------------

    /** Load a byte sequence at a physical address. Used by the assembler to
     *  place the data segment before execution begins. */
    load(address, source) {
        const base = address & ADDRESS_MASK;

        for (let i = 0; i < source.length; i++) {
            const target = (base + i) & ADDRESS_MASK;

            this.bytes[target] = source[i] & 0xFF;
            this.dirty.add(target);
        }
    }

    /** Read a window of memory for display, without disturbing the journal. */
    slice(address, length) {
        const base = address & ADDRESS_MASK;
        const out  = new Uint8Array(length);

        for (let i = 0; i < length; i++) {
            out[i] = this.bytes[(base + i) & ADDRESS_MASK];
        }
        return out;
    }

    /** Hand the interface the set of addresses written since it last asked. */
    takeDirty() {
        const changed = Array.from(this.dirty);

        this.dirty.clear();
        return changed;
    }

    // -------------------------------------------------------------------------
    // LIFECYCLE
    // -------------------------------------------------------------------------

    /** Clear all memory. Called on reset, never during execution. */
    clear() {
        this.bytes.fill(0);
        this.dirty.clear();
    }
}
