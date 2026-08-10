// -----------------------------------------------------------------------------
// Script Name: devices.js
// Module:      Execution, 2 of 4
// Stack:       JavaScript (ES2020), no dependencies
// Description: The world outside the processor: input and output ports, a small
//              file store, and a clock.
//
//              A program that drives traffic lights or a stepper motor talks to
//              hardware through IN and OUT rather than through memory, and one
//              that opens a file talks to the operating system. Neither exists
//              in a browser, so both are modelled here.
//
//              Everything is deterministic. A port that has never been written
//              reads as zero, the clock returns whatever the host set rather
//              than the wall time, and files live in memory only. A program
//              therefore behaves the same way on every run, which is what makes
//              it possible to test the simulator at all.
//
//              Every write to a port is kept in a short journal so the interface
//              can show what a program sent to which device, which is the only
//              visible result a motor or a lamp has here.
//
// Authors:     Amey Thakur
// Repository:  https://github.com/Amey-Thakur/8086-ASSEMBLY-LANGUAGE-PROGRAMS
// License:     CC BY 4.0
// -----------------------------------------------------------------------------

'use strict';

/** The 8086 addresses 65,536 ports through a sixteen bit port number. */
const PORT_COUNT = 0x10000;

/** How many port writes to remember for display. Older ones are discarded. */
const JOURNAL_LIMIT = 256;

/**
 * Ports the example programs drive, named so the interface can label them.
 * These follow the assignments emu8086 uses, which is what the programs in
 * this repository were written against.
 */
export const KNOWN_PORTS = {
    4:   'Traffic lights',
    5:   'Traffic lights, upper byte',
    7:   'Stepper motor',
    9:   'Robot arm',
    125: 'Thermometer',
    127: 'Heater and cooler',
    199: 'Numeric display'
};

// -----------------------------------------------------------------------------
// PORTS
// -----------------------------------------------------------------------------
export class PortSpace {

    constructor() {
        this.reset();
    }

    reset() {
        this.values  = new Uint8Array(PORT_COUNT);
        this.journal = [];
    }

    /** IN reads a port. A port never written reads as zero. */
    read(port, width = 1) {
        const address = port & 0xFFFF;

        return width === 1
            ? this.values[address]
            : this.values[address] | (this.values[(address + 1) & 0xFFFF] << 8);
    }

    /** OUT writes a port and records what was sent, for the interface to show. */
    write(port, value, width = 1) {
        const address = port & 0xFFFF;

        this.values[address] = value & 0xFF;

        if (width === 2) {
            this.values[(address + 1) & 0xFFFF] = (value >> 8) & 0xFF;
        }

        this.journal.push({
            port:   address,
            value:  width === 1 ? (value & 0xFF) : (value & 0xFFFF),
            width,
            device: KNOWN_PORTS[address] ?? null
        });

        if (this.journal.length > JOURNAL_LIMIT) this.journal.shift();
    }

    /** What the interface needs to render the device panel. */
    snapshot() {
        return this.journal.slice(-16);
    }
}

// -----------------------------------------------------------------------------
// FILES
//
// DOS identifies an open file by a handle, a small number the program passes
// back on every later call. Handles 0 to 4 belong to the console and the
// printer, so allocation starts above them.
// -----------------------------------------------------------------------------
const FIRST_HANDLE = 5;

/** DOS error codes the services below can return in AX. */
export const DOS_ERROR = {
    FILE_NOT_FOUND: 0x02,
    ACCESS_DENIED:  0x05,
    INVALID_HANDLE: 0x06
};

export class FileStore {

    constructor() {
        this.reset();
    }

    reset() {
        this.files  = new Map();   // name  -> { name, bytes: number[] }
        this.open   = new Map();   // handle -> { name, position, writable }
        this.next   = FIRST_HANDLE;
    }

    /** Service 3Ch: create a file, replacing any file of the same name. */
    create(name) {
        this.files.set(name, { name, bytes: [] });
        return this.openExisting(name, true);
    }

    /** Service 3Dh: open a file that must already exist. */
    openForAccess(name, writable) {
        if (!this.files.has(name)) return { error: DOS_ERROR.FILE_NOT_FOUND };

        return this.openExisting(name, writable);
    }

    openExisting(name, writable) {
        const handle = this.next++;

        this.open.set(handle, { name, position: 0, writable });
        return { handle };
    }

    /** Service 3Eh: close a handle. */
    close(handle) {
        return this.open.delete(handle) ? {} : { error: DOS_ERROR.INVALID_HANDLE };
    }

    /** Service 3Fh: read up to count bytes from the current position. */
    read(handle, count) {
        const entry = this.open.get(handle);

        if (!entry) return { error: DOS_ERROR.INVALID_HANDLE };

        const file  = this.files.get(entry.name);
        const bytes = file.bytes.slice(entry.position, entry.position + count);

        entry.position += bytes.length;
        return { bytes };
    }

    /** Service 40h: write bytes at the current position. */
    write(handle, bytes) {
        const entry = this.open.get(handle);

        if (!entry)          return { error: DOS_ERROR.INVALID_HANDLE };
        if (!entry.writable) return { error: DOS_ERROR.ACCESS_DENIED };

        const file = this.files.get(entry.name);

        for (const byte of bytes) file.bytes[entry.position++] = byte;

        return { written: bytes.length };
    }

    /** Service 41h: delete a file. */
    remove(name) {
        return this.files.delete(name) ? {} : { error: DOS_ERROR.FILE_NOT_FOUND };
    }

    /** What the interface needs to list the files a program produced. */
    snapshot() {
        return [...this.files.values()].map(file => ({
            name: file.name,
            size: file.bytes.length,
            text: file.bytes.map(byte => String.fromCharCode(byte)).join('')
        }));
    }
}

// -----------------------------------------------------------------------------
// CLOCK
//
// Fixed rather than live. A program that prints the time should print the same
// time on every run, otherwise the simulator cannot be tested and two people
// following the same lab sheet see different output.
// -----------------------------------------------------------------------------
export class Clock {

    constructor() {
        this.reset();
    }

    reset() {
        // The date the first version of this simulator was written.
        this.year    = 2021;
        this.month   = 6;
        this.day     = 14;
        this.weekday = 1;      // Monday

        this.hour       = 9;
        this.minute     = 30;
        this.second     = 0;
        this.hundredths = 0;
    }

    /** Set the clock from a host date, for when a live reading is wanted. */
    setFrom(date) {
        this.year    = date.getFullYear();
        this.month   = date.getMonth() + 1;
        this.day     = date.getDate();
        this.weekday = date.getDay();

        this.hour       = date.getHours();
        this.minute     = date.getMinutes();
        this.second     = date.getSeconds();
        this.hundredths = Math.floor(date.getMilliseconds() / 10);
    }

    /**
     * The BIOS tick count, as INT 1Ah service 00h reports it.
     *
     * The timer runs at 18.2 ticks a second and is reset at midnight, so the
     * count is the time of day expressed in those ticks.
     */
    ticks() {
        const seconds = this.hour * 3600 + this.minute * 60 + this.second;

        return Math.floor(seconds * 18.2) & 0xFFFFFF;
    }
}
