// -----------------------------------------------------------------------------
// Script Name: interrupts.js
// Module:      Execution, 4 of 4
// Stack:       JavaScript (ES2020), depends on the CPU core
// Description: The software interrupt services an 8086 program written for DOS
//              actually uses. Nearly every one of the 161 programs in this
//              repository prints something, and printing means INT 21h, so
//              without this file the simulator can assemble a program and then
//              produce no visible result.
//
//              Implemented services, chosen by the value in AH:
//
//                INT 21h / 01h   read one character, echoed, returned in AL
//                INT 21h / 02h   print the character in DL
//                INT 21h / 06h   direct console input or output
//                INT 21h / 07h   read one character, no echo
//                INT 21h / 08h   read one character, no echo, checks Ctrl-C
//                INT 21h / 09h   print the $ terminated string at DS:DX
//                INT 21h / 0Ah   read a buffered line into DS:DX
//                INT 21h / 4Ch   terminate, with the exit code in AL
//                INT 20h         terminate, the older calling convention
//
//              Input is supplied ahead of time rather than read from a live
//              keyboard, so a program is deterministic and can be tested from a
//              terminal with no browser present. When the buffer runs dry the
//              read returns a carriage return rather than blocking forever.
//
// Authors:     Amey Thakur
// Repository:  https://github.com/Amey-Thakur/8086-ASSEMBLY-LANGUAGE-PROGRAMS
// License:     CC BY 4.0
// -----------------------------------------------------------------------------

'use strict';

import { ExecutionError } from '../cpu/cpu.js';

/** Marks the end of a string for service 09h. */
export const STRING_TERMINATOR = 0x24;   // '$'

/** How many characters a single buffered read will accept before giving up.
 *  Guards against a malformed buffer descriptor looping forever. */
const MAX_LINE_LENGTH = 254;

// -----------------------------------------------------------------------------
// CONSOLE INPUT
// -----------------------------------------------------------------------------

/**
 * Take the next character from the pending input buffer.
 *
 * Returns a carriage return when the buffer is empty. A real machine would
 * block on the keyboard, but blocking is not available to us and hanging is
 * worse than terminating a read early.
 */
function nextInputCharacter(cpu) {
    if (cpu.pendingInput.length === 0) {
        return 0x0D;
    }

    const character = cpu.pendingInput.charCodeAt(0);

    cpu.pendingInput = cpu.pendingInput.slice(1);
    return character & 0xFF;
}

// -----------------------------------------------------------------------------
// DOS SERVICES  (INT 21h)
// -----------------------------------------------------------------------------
const DOS_SERVICES = {

    // ---- 01h  read a character with echo ------------------------------------
    0x01(cpu) {
        const character = nextInputCharacter(cpu);

        cpu.registers.set('AL', character);
        cpu.writeCharacter(character);          // echoed, as the real service does
    },

    // ---- 02h  print the character in DL --------------------------------------
    0x02(cpu) {
        cpu.writeCharacter(cpu.registers.get('DL'));
    },

    // ---- 06h  direct console input or output ---------------------------------
    // DL = FFh means read, anything else means write that character.
    0x06(cpu) {
        const request = cpu.registers.get('DL');

        if (request === 0xFF) {
            const character = cpu.pendingInput.length ? nextInputCharacter(cpu) : 0;

            cpu.registers.set('AL', character);
            cpu.flags.ZF = character === 0 ? 1 : 0;
            return;
        }

        cpu.writeCharacter(request);
    },

    // ---- 07h and 08h  read a character without echo --------------------------
    0x07(cpu) { cpu.registers.set('AL', nextInputCharacter(cpu)); },
    0x08(cpu) { cpu.registers.set('AL', nextInputCharacter(cpu)); },

    // ---- 09h  print the $ terminated string at DS:DX -------------------------
    // This is the service almost every program in the repository uses.
    0x09(cpu) {
        let offset = cpu.registers.get('DX');
        let guard  = 0;

        for (;;) {
            const byte = cpu.memory.readByte(cpu.registers.get('DS'), offset);

            if (byte === STRING_TERMINATOR) break;

            cpu.writeCharacter(byte);

            offset = (offset + 1) & 0xFFFF;

            if (++guard > 0xFFFF) {
                throw new ExecutionError(
                    'INT 21h service 09h ran past the end of memory without finding a "$". ' +
                    'The string is probably missing its terminator.'
                );
            }
        }
    },

    // ---- 0Ah  buffered line input --------------------------------------------
    // DS:DX points at a descriptor: byte 0 is the capacity the program is
    // offering, byte 1 receives the count actually read, and the text follows.
    0x0A(cpu) {
        const segment  = cpu.registers.get('DS');
        const base     = cpu.registers.get('DX');
        const capacity = cpu.memory.readByte(segment, base);

        let written = 0;

        while (written < Math.min(capacity, MAX_LINE_LENGTH)) {
            const character = nextInputCharacter(cpu);

            if (character === 0x0D) break;      // Enter ends the line

            cpu.memory.writeByte(segment, (base + 2 + written) & 0xFFFF, character);
            cpu.writeCharacter(character);      // buffered input is echoed
            written++;
        }

        cpu.memory.writeByte(segment, (base + 1) & 0xFFFF, written);
        cpu.memory.writeByte(segment, (base + 2 + written) & 0xFFFF, 0x0D);
        cpu.writeCharacter(0x0A);
    },

    // ---- 2Ah  read the date --------------------------------------------------
    // CX year, DH month, DL day, AL day of the week.
    0x2A(cpu) {
        cpu.registers.set('CX', cpu.clock.year);
        cpu.registers.set('DH', cpu.clock.month);
        cpu.registers.set('DL', cpu.clock.day);
        cpu.registers.set('AL', cpu.clock.weekday);
    },

    // ---- 2Ch  read the time --------------------------------------------------
    // CH hour, CL minute, DH second, DL hundredths.
    0x2C(cpu) {
        cpu.registers.set('CH', cpu.clock.hour);
        cpu.registers.set('CL', cpu.clock.minute);
        cpu.registers.set('DH', cpu.clock.second);
        cpu.registers.set('DL', cpu.clock.hundredths);
    },

    // ---- 3Ch  create a file --------------------------------------------------
    // DS:DX names the file, and the new handle comes back in AX.
    0x3C(cpu) {
        finishFileCall(cpu, cpu.files.create(readFileName(cpu)));
    },

    // ---- 3Dh  open an existing file ------------------------------------------
    // AL holds the access wanted: 0 read, 1 write, 2 both.
    0x3D(cpu) {
        const writable = (cpu.registers.get('AL') & 0x03) !== 0;

        finishFileCall(cpu, cpu.files.openForAccess(readFileName(cpu), writable));
    },

    // ---- 3Eh  close a handle -------------------------------------------------
    0x3E(cpu) {
        finishFileCall(cpu, cpu.files.close(cpu.registers.get('BX')));
    },

    // ---- 3Fh  read from a handle ---------------------------------------------
    // BX handle, CX how many bytes, DS:DX where to put them. AX returns how
    // many were actually read, which is fewer at the end of the file.
    0x3F(cpu) {
        const result = cpu.files.read(cpu.registers.get('BX'), cpu.registers.get('CX'));

        if (result.error !== undefined) { failFileCall(cpu, result.error); return; }

        const segment = cpu.registers.get('DS');
        const base    = cpu.registers.get('DX');

        result.bytes.forEach((byte, index) => {
            cpu.memory.writeByte(segment, (base + index) & 0xFFFF, byte);
        });

        succeedFileCall(cpu, result.bytes.length);
    },

    // ---- 40h  write to a handle ----------------------------------------------
    // Handle 1 is the screen, which is how a program prints without service 09h.
    0x40(cpu) {
        const handle  = cpu.registers.get('BX');
        const count   = cpu.registers.get('CX');
        const segment = cpu.registers.get('DS');
        const base    = cpu.registers.get('DX');
        const bytes   = [];

        for (let index = 0; index < count; index++) {
            bytes.push(cpu.memory.readByte(segment, (base + index) & 0xFFFF));
        }

        if (handle === 1 || handle === 2) {
            bytes.forEach(byte => cpu.writeCharacter(byte));
            succeedFileCall(cpu, bytes.length);
            return;
        }

        const result = cpu.files.write(handle, bytes);

        if (result.error !== undefined) { failFileCall(cpu, result.error); return; }

        succeedFileCall(cpu, result.written);
    },

    // ---- 41h  delete a file --------------------------------------------------
    0x41(cpu) {
        finishFileCall(cpu, cpu.files.remove(readFileName(cpu)));
    },

    // ---- 4Ch  terminate with an exit code ------------------------------------
    0x4C(cpu) {
        cpu.exitCode = cpu.registers.get('AL');
        cpu.halted   = true;
    }
};

// -----------------------------------------------------------------------------
// FILE SERVICE HELPERS
//
// DOS reports a file call the same way every time: the carry flag clear and the
// result in AX, or the carry flag set and an error code in AX.
// -----------------------------------------------------------------------------

/** Read the ASCIIZ name at DS:DX that every file service takes. */
function readFileName(cpu) {
    const segment = cpu.registers.get('DS');
    const base    = cpu.registers.get('DX');
    const letters = [];

    for (let index = 0; index < 128; index++) {
        const byte = cpu.memory.readByte(segment, (base + index) & 0xFFFF);

        if (byte === 0) break;
        letters.push(String.fromCharCode(byte));
    }

    return letters.join('');
}

function succeedFileCall(cpu, value) {
    cpu.registers.set('AX', value & 0xFFFF);
    cpu.flags.CF = 0;
}

function failFileCall(cpu, code) {
    cpu.registers.set('AX', code & 0xFFFF);
    cpu.flags.CF = 1;
}

/** Report a call whose only result is success or an error code. */
function finishFileCall(cpu, result) {
    if (result.error !== undefined) failFileCall(cpu, result.error);
    else                            succeedFileCall(cpu, result.handle ?? 0);
}

// -----------------------------------------------------------------------------
// VIDEO SERVICES  (INT 10h)
//
// Only the handful a text mode program is likely to call. Anything graphical is
// accepted and ignored rather than refused, so a program that sets a video mode
// still runs to completion.
// -----------------------------------------------------------------------------
const VIDEO_SERVICES = {

    // 0Eh  teletype output: print AL and advance the cursor
    0x0E(cpu) { cpu.writeCharacter(cpu.registers.get('AL')); },

    // 02h  set cursor position. There is no addressable screen here, so this is
    // recorded for the interface to show and otherwise has no effect.
    0x02(cpu) {
        cpu.cursor = { row: cpu.registers.get('DH'), column: cpu.registers.get('DL') };
    },

    // 00h  set video mode. Accepted and ignored.
    0x00() { /* text only */ },

    // 06h  scroll a window. Used to clear the screen, which is honoured by
    // starting the transcript again rather than by moving anything.
    0x06(cpu) {
        if (cpu.registers.get('AL') === 0) cpu.consoleOutput = '';
    },

    // 09h and 0Ah  write a character at the cursor, with or without an
    // attribute. The count in CX says how many times.
    0x09(cpu) { repeatCharacter(cpu); },
    0x0A(cpu) { repeatCharacter(cpu); },

    // 03h  report the cursor position.
    0x03(cpu) {
        cpu.registers.set('DH', cpu.cursor.row);
        cpu.registers.set('DL', cpu.cursor.column);
        cpu.registers.set('CX', 0x0607);      // an ordinary underline cursor
    },

    // 0Fh  report the video mode: eighty column colour text, page zero.
    0x0F(cpu) {
        cpu.registers.set('AL', 0x03);
        cpu.registers.set('AH', 80);
        cpu.registers.set('BH', 0);
    }
};

/** Services 09h and 0Ah both write AL to the screen CX times. */
function repeatCharacter(cpu) {
    const character = cpu.registers.get('AL');
    const count     = Math.max(1, cpu.registers.get('CX'));

    for (let written = 0; written < count; written++) cpu.writeCharacter(character);
}

// -----------------------------------------------------------------------------
// KEYBOARD SERVICES  (INT 16h)
//
// The BIOS keyboard is a lower level route to the same keystrokes DOS offers.
// A key is reported as a pair: the ASCII value in AL and the scan code in AH.
// -----------------------------------------------------------------------------
const KEYBOARD_SERVICES = {

    // 00h and 10h  wait for a key and return it.
    0x00(cpu) { returnKey(cpu, nextInputCharacter(cpu)); },
    0x10(cpu) { returnKey(cpu, nextInputCharacter(cpu)); },

    // 01h and 11h  report whether a key is waiting, without taking it.
    // The zero flag is set when the buffer is empty.
    0x01(cpu) { peekKey(cpu); },
    0x11(cpu) { peekKey(cpu); },

    // 02h  report the shift key state. Nothing is held down here.
    0x02(cpu) { cpu.registers.set('AL', 0); }
};

/** Scan codes for the keys a program is likely to test for by name. */
const SCAN_CODES = { 13: 0x1C, 27: 0x01, 8: 0x0E, 9: 0x0F, 32: 0x39 };

function returnKey(cpu, character) {
    cpu.registers.set('AL', character);
    cpu.registers.set('AH', SCAN_CODES[character] ?? 0);
}

function peekKey(cpu) {
    if (cpu.pendingInput.length === 0) {
        cpu.flags.ZF = 1;
        return;
    }

    cpu.flags.ZF = 0;
    returnKey(cpu, cpu.pendingInput.charCodeAt(0) & 0xFF);   // left in the buffer
}

// -----------------------------------------------------------------------------
// REGISTRATION
// -----------------------------------------------------------------------------

/** Add INT and IRET to an executor's dispatch table. */
export function registerInterruptHandlers(executor) {
    const cpu = executor.cpu;

    executor.define(['INT'], (operands, instruction) => {
        if (operands.length !== 1) {
            throw new ExecutionError('INT needs an interrupt number', instruction.line);
        }

        const vector = executor.read(operands[0], 1) & 0xFF;

        switch (vector) {

            case 0x21: {
                const service = cpu.registers.get('AH');
                const handler = DOS_SERVICES[service];

                if (!handler) {
                    throw new ExecutionError(
                        `INT 21h service ${service.toString(16).toUpperCase().padStart(2, '0')}h ` +
                        `is not implemented. Supported: 01h, 02h, 06h, 07h, 08h, 09h, 0Ah, 4Ch.`,
                        instruction.line
                    );
                }

                handler(cpu);
                return;
            }

            case 0x10: {
                const handler = VIDEO_SERVICES[cpu.registers.get('AH')];

                if (handler) handler(cpu);
                return;                       // unknown video calls are ignored
            }

            case 0x16: {
                const handler = KEYBOARD_SERVICES[cpu.registers.get('AH')];

                if (handler) handler(cpu);
                return;
            }

            // ---- 1Ah  the BIOS clock ------------------------------------------
            case 0x1A: {
                if (cpu.registers.get('AH') !== 0x00) return;

                const ticks = cpu.clock.ticks();

                cpu.registers.set('CX', (ticks >> 16) & 0xFFFF);
                cpu.registers.set('DX', ticks & 0xFFFF);
                cpu.registers.set('AL', 0);          // midnight has not passed
                return;
            }

            // ---- 15h  miscellaneous system services ---------------------------
            // Service 86h waits for the microseconds in CX:DX. Waiting here
            // would only freeze the page, so the call returns at once with the
            // carry flag clear to say it succeeded.
            case 0x15:
                cpu.flags.CF = 0;
                return;

            // ---- 33h  the mouse -----------------------------------------------
            // There is no mouse. Service 00h reports that honestly by returning
            // zero in AX, which is what a program checks before using it.
            case 0x33:
                if (cpu.registers.get('AX') === 0) {
                    cpu.registers.set('AX', 0);      // no driver installed
                    cpu.registers.set('BX', 0);
                }
                return;

            case 0x20:                        // the older terminate convention
                cpu.halted = true;
                return;

            // ---- 19h  restart the machine -------------------------------------
            // A reboot ends everything that was running, which here means the
            // program stops. There is nothing to restart into.
            case 0x19:
                cpu.halted = true;
                return;

            case 0x03:                        // breakpoint
            case 0x01:                        // single step
                return;

            default:
                throw new ExecutionError(
                    `INT ${vector.toString(16).toUpperCase()}h is not implemented. ` +
                    `This simulator supports INT 21h and INT 20h for DOS, and ` +
                    `INT 10h, 16h, 1Ah, 15h and 33h for the BIOS.`,
                    instruction.line
                );
        }
    });

    // IRET restores what an interrupt pushed. Nothing here pushes a frame, so
    // it behaves as a return that also restores the flags if one is present.
    executor.define(['IRET'], () => {
        if (cpu.registers.get('SP') === 0xFFFE) { cpu.halted = true; return; }

        const address = cpu.pop();

        cpu.pop();                            // discard the saved CS
        cpu.flags.fromWord(cpu.pop());
        cpu.jumpTo(address);
    });
}

export { DOS_SERVICES, VIDEO_SERVICES, KEYBOARD_SERVICES };
