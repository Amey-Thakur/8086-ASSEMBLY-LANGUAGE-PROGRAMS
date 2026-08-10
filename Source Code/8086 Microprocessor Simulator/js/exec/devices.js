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

/** The stepper motor latch, and the bit a driver polls before each step.
 *  Reported as ready because there is no motor here that could be busy. */
const STEPPER_PORT  = 7;
const STEPPER_READY = 0x80;

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

    /**
     * IN reads a port. A port never written reads as zero.
     *
     * The stepper motor latch is the exception. A driver polls its top bit and
     * steps only when the motor reports itself ready, which is the correct way
     * to talk to one: pulsing faster than the rotor can turn makes it slip.
     *
     * There is no motor here to be busy, so the line would sit at zero for ever
     * and the driver would poll for ever without taking a single step. Reporting
     * ready is what the hardware does when it is idle, and it is what lets a
     * correctly written driver actually run.
     */
    read(port, width = 1) {
        const address = port & 0xFFFF;

        if (address === STEPPER_PORT) {
            return this.values[address] | STEPPER_READY;
        }

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
    INVALID_FUNCTION: 0x01,
    FILE_NOT_FOUND:   0x02,
    ACCESS_DENIED:    0x05,
    INVALID_HANDLE:   0x06
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

    /**
     * Service 42h: move the read and write position.
     *
     * The origin is 0 from the start, 1 from where it is now, and 2 from the
     * end. Seeking to the end with an offset of zero is how a program asks how
     * long a file is, which is the commonest use of the call by some distance.
     *
     * DOS allows a position past the end; writing there leaves a gap. The
     * position is returned so the caller can see where it landed.
     */
    seek(handle, offset, origin) {
        const entry = this.open.get(handle);

        if (!entry)          return { error: DOS_ERROR.INVALID_HANDLE };
        if (origin > 2)      return { error: DOS_ERROR.INVALID_FUNCTION };

        const file = this.files.get(entry.name);
        const from = origin === 0 ? 0
                   : origin === 1 ? entry.position
                   :                file.bytes.length;

        // The offset is signed, so a seek backwards from the end is possible.
        const position = from + offset;

        if (position < 0) return { error: DOS_ERROR.INVALID_FUNCTION };

        entry.position = position;
        return { position };
    }

    /**
     * Service 56h: rename a file.
     *
     * The file keeps its contents and any open handle keeps working, because a
     * handle records the name it was opened under and that name is updated too.
     */
    rename(from, to) {
        if (!this.files.has(from))  return { error: DOS_ERROR.FILE_NOT_FOUND };
        if (this.files.has(to))     return { error: DOS_ERROR.ACCESS_DENIED };

        const file = this.files.get(from);

        file.name = to;
        this.files.delete(from);
        this.files.set(to, file);

        for (const entry of this.open.values()) {
            if (entry.name === from) entry.name = to;
        }

        return {};
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
// PIXELS
//
// The BIOS can plot a single pixel and read one back, and a program in a
// graphics mode does nothing else. Without somewhere to keep them, a plot goes
// nowhere and a read returns whatever happened to be in AL, which looks like the
// program is wrong when it is not.
//
// One byte per pixel, which is exactly right for mode 13h and generous for the
// modes with fewer colours. The plane is allocated once at the largest size any
// supported mode needs rather than reallocated on every mode change.
// -----------------------------------------------------------------------------

/** The graphics modes, and how many pixels each one addresses. */
export const VIDEO_MODES = {
    0x04: { width: 320, height: 200, graphics: true  },
    0x05: { width: 320, height: 200, graphics: true  },
    0x06: { width: 640, height: 200, graphics: true  },
    0x0D: { width: 320, height: 200, graphics: true  },
    0x0E: { width: 640, height: 200, graphics: true  },
    0x10: { width: 640, height: 350, graphics: true  },
    0x12: { width: 640, height: 480, graphics: true  },
    0x13: { width: 320, height: 200, graphics: true  },

    0x00: { width: 40, height: 25, graphics: false },
    0x01: { width: 40, height: 25, graphics: false },
    0x02: { width: 80, height: 25, graphics: false },
    0x03: { width: 80, height: 25, graphics: false },
    0x07: { width: 80, height: 25, graphics: false }
};

const WIDEST  = 640;
const TALLEST = 480;

export class PixelPlane {

    constructor() {
        this.data = new Uint8Array(WIDEST * TALLEST);
        this.reset();
    }

    reset() {
        this.data.fill(0);

        this.mode    = 0x03;          // Eighty column colour text, as DOS leaves it
        this.width   = 80;
        this.height  = 25;
        this.written = 0;             // How many pixels the program has plotted
    }

    /**
     * Service 00h: set the video mode.
     *
     * Changing mode clears the screen on real hardware, so the plane is cleared
     * too. An unrecognised mode is accepted and treated as text, because
     * refusing it would stop a program that merely asked for something exotic.
     */
    setMode(mode) {
        const known = VIDEO_MODES[mode] ?? { width: 80, height: 25, graphics: false };

        this.mode    = mode;
        this.width   = known.width;
        this.height  = known.height;
        this.graphics = known.graphics === true;

        this.data.fill(0);
        this.written = 0;
    }

    /** True when the current mode can hold pixels at all. */
    get isGraphics() {
        return VIDEO_MODES[this.mode]?.graphics === true;
    }

    /**
     * Service 0Ch: write one pixel.
     *
     * A coordinate outside the mode is discarded rather than wrapped. Wrapping
     * would put a stray pixel somewhere unrelated and make a clipping mistake
     * very hard to see.
     */
    plot(column, row, colour) {
        if (column >= this.width || row >= this.height) return false;

        this.data[(row * WIDEST) + column] = colour & 0xFF;
        this.written++;
        return true;
    }

    /** Service 0Dh: read one pixel. Outside the mode reads as zero. */
    read(column, row) {
        if (column >= this.width || row >= this.height) return 0;

        return this.data[(row * WIDEST) + column];
    }

    /**
     * What the interface needs to draw the graphics panel: the bounding box of
     * everything plotted, so a small drawing is not shown as a speck in a corner
     * of an otherwise empty 320 by 200 field.
     */
    snapshot() {
        if (this.written === 0) return null;

        let left = this.width, right = -1, top = this.height, bottom = -1;

        for (let row = 0; row < this.height; row++) {
            for (let column = 0; column < this.width; column++) {
                if (this.data[(row * WIDEST) + column] === 0) continue;

                if (column < left)   left   = column;
                if (column > right)  right  = column;
                if (row    < top)    top    = row;
                if (row    > bottom) bottom = row;
            }
        }

        return {
            mode:   this.mode,
            width:  this.width,
            height: this.height,
            plotted: this.written,
            bounds: right < 0 ? null : { left, top, right, bottom }
        };
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
