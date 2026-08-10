// -----------------------------------------------------------------------------
// Script Name: interrupts.js
// Module:      Execution, 3 of 3
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

    // ---- 4Ch  terminate with an exit code ------------------------------------
    0x4C(cpu) {
        cpu.exitCode = cpu.registers.get('AL');
        cpu.halted   = true;
    }
};

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
    0x00() { /* text only */ }
};

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
                const service = cpu.registers.get('AH');
                const handler = VIDEO_SERVICES[service];

                if (handler) handler(cpu);
                return;                       // unknown video calls are ignored
            }

            case 0x20:                        // the older terminate convention
                cpu.halted = true;
                return;

            case 0x03:                        // breakpoint
            case 0x01:                        // single step
                return;

            default:
                throw new ExecutionError(
                    `INT ${vector.toString(16).toUpperCase()}h is not implemented. ` +
                    `This simulator supports INT 21h, INT 20h and INT 10h.`,
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

export { DOS_SERVICES, VIDEO_SERVICES };
