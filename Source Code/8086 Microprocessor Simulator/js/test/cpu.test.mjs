// -----------------------------------------------------------------------------
// Script Name: cpu.test.mjs
// Module:      Conformance Suite, machine
// Stack:       Node.js (ES modules), no test framework
// Description: Verifies the assembled machine: stack discipline, segment
//              selection, control transfer and the execution budget. These are
//              whole-machine behaviours that none of the individual core
//              modules can be tested for on their own.
//
// Authors:     Amey Thakur
// Repository:  https://github.com/Amey-Thakur/8086-ASSEMBLY-LANGUAGE-PROGRAMS
// License:     CC BY 4.0
// -----------------------------------------------------------------------------

import { CPU, ExecutionError } from '../cpu/cpu.js';

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
console.log('\nSTACK  (full descending: push decrements first, pop reads first)');
// -----------------------------------------------------------------------------
{
    const cpu = new CPU();

    check('SP powers on at FFFE', hex(cpu.registers.get('SP')), 'FFFE');

    cpu.push(0x1234);
    check('PUSH decrements SP by two', hex(cpu.registers.get('SP')), 'FFFC');
    check('PUSH writes at the new SP',
          hex(cpu.memory.readWord(cpu.registers.get('SS'), 0xFFFC)), '1234');

    cpu.push(0xABCD);
    check('second PUSH', hex(cpu.registers.get('SP')), 'FFFA');

    check('POP returns last in first out', hex(cpu.pop()), 'ABCD');
    check('POP restores SP',               hex(cpu.registers.get('SP')), 'FFFC');
    check('POP again',                     hex(cpu.pop()), '1234');
    check('stack is balanced again',       hex(cpu.registers.get('SP')), 'FFFE');
}

// -----------------------------------------------------------------------------
console.log('\nSEGMENT SELECTION  (BP and SP imply the stack segment)');
// -----------------------------------------------------------------------------
{
    const cpu = new CPU();

    cpu.registers.set('DS', 0x1000);
    cpu.registers.set('SS', 0x2000);
    cpu.registers.set('ES', 0x3000);

    check('BX addressing uses DS', hex(cpu.resolveSegment('BX')), '1000');
    check('SI addressing uses DS', hex(cpu.resolveSegment('SI')), '1000');
    check('BP addressing uses SS', hex(cpu.resolveSegment('BP')), '2000');
    check('SP addressing uses SS', hex(cpu.resolveSegment('SP')), '2000');
    check('an explicit override wins', hex(cpu.resolveSegment('BX', 'ES')), '3000');
    check('override applies to BP too', hex(cpu.resolveSegment('BP', 'DS')), '1000');
}

// -----------------------------------------------------------------------------
console.log('\nMEMORY PORTS  (the data written is the data read back)');
// -----------------------------------------------------------------------------
{
    const cpu = new CPU();

    cpu.writeMemory(0x0100, 0xBEEF, 2, 'BX');
    check('word through the DS port', hex(cpu.readMemory(0x0100, 2, 'BX')), 'BEEF');

    cpu.writeMemory(0x0200, 0x7F, 1, 'BX');
    check('byte through the DS port', hex(cpu.readMemory(0x0200, 1, 'BX'), 2), '7F');

    // A BP-relative write must land in SS, so a DS-relative read must miss it.
    cpu.registers.set('DS', 0x1000);
    cpu.registers.set('SS', 0x2000);
    cpu.writeMemory(0x0050, 0x1111, 2, 'BP');
    check('BP writes land in the stack segment',
          hex(cpu.memory.readWord(0x2000, 0x0050)), '1111');
    check('and are not visible through DS',
          hex(cpu.memory.readWord(0x1000, 0x0050)), '0000');

    // String destinations ignore DS entirely.
    cpu.writeExtraSegment(0x0010, 0x2222, 2);
    check('ES port writes to the extra segment',
          hex(cpu.readExtraSegment(0x0010, 2)), '2222');
}

// -----------------------------------------------------------------------------
console.log('\nCONTROL TRANSFER  (CALL pushes a return address, RET pops it)');
// -----------------------------------------------------------------------------
{
    const cpu = new CPU();

    cpu.jumpTo(0x0040);
    check('JMP sets IP', hex(cpu.registers.get('IP')), '0040');

    cpu.callTo(0x0100, 'subroutine');
    check('CALL transfers control',   hex(cpu.registers.get('IP')), '0100');
    check('CALL pushed the return',   hex(cpu.registers.get('SP')), 'FFFC');
    check('call trace records depth', cpu.callTrace.length, 1);

    cpu.returnFromCall();
    check('RET restores IP',        hex(cpu.registers.get('IP')), '0040');
    check('RET balances the stack', hex(cpu.registers.get('SP')), 'FFFE');
    check('call trace unwound',     cpu.callTrace.length, 0);

    // RET with an immediate discards caller arguments as well.
    cpu.registers.set('IP', 0x0080);
    cpu.callTo(0x0200);
    cpu.push(0xAAAA);
    cpu.push(0xBBBB);
    cpu.registers.set('SP', (cpu.registers.get('SP') + 4) & 0xFFFF);  // callee drops its locals
    cpu.returnFromCall(4);
    check('RET n also discards arguments', hex(cpu.registers.get('SP')), '0002');
}

// -----------------------------------------------------------------------------
console.log('\nCONSOLE AND BUDGET');
// -----------------------------------------------------------------------------
{
    const cpu = new CPU();

    cpu.writeCharacter(0x48);   // H
    cpu.writeCharacter(0x69);   // i
    cpu.writeCharacter(0x0D);   // carriage return, swallowed
    cpu.writeCharacter(0x0A);   // line feed, becomes the newline
    check('CR LF collapses to one newline', JSON.stringify(cpu.consoleOutput), '"Hi\\n"');

    cpu.reset();
    check('reset clears the console', cpu.consoleOutput, '');
    check('reset restores SP',        hex(cpu.registers.get('SP')), 'FFFE');
    check('reset re-seeds segments',  hex(cpu.registers.get('CS')), '0700');

    // Counting is all the processor does. Deciding when a run has gone on long
    // enough belongs to the executor, because a program that never ends is not
    // necessarily a program that is wrong.
    cpu.instructionCount = 5_000_000;
    cpu.countInstruction();
    check('counting has no ceiling of its own', cpu.instructionCount, 5_000_001);
}

// -----------------------------------------------------------------------------
console.log(`\n${passed} passed, ${failed} failed\n`);
process.exit(failed === 0 ? 0 : 1);
