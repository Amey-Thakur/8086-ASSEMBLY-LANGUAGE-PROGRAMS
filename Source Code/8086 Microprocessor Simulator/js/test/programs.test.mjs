// -----------------------------------------------------------------------------
// Script Name: programs.test.mjs
// Module:      Conformance Suite, program library
// Stack:       Node.js (ES modules), no test framework
// Description: Assembles and runs every .asm file in this repository.
//
//              The other suites test the simulator against the manual. This one
//              tests it against the work itself: if a program in this
//              repository does not assemble, or stops with an error, that is a
//              defect in the simulator or in the program, and either way it
//              should be visible without anyone having to click through the
//              library by hand.
//
//              Eight programs are expected NOT to finish, and are listed below.
//              Seven of them are embedded controllers, and a traffic light
//              sequencer that stopped on its own would be the broken one. The
//              eighth is a calibrated delay loop that takes about thirty five
//              million instructions to complete, more than a test should spend.
//
// Authors:     Amey Thakur
// Repository:  https://github.com/Amey-Thakur/8086-ASSEMBLY-LANGUAGE-PROGRAMS
// License:     CC BY 4.0
// -----------------------------------------------------------------------------

import { readFileSync, readdirSync, statSync } from 'node:fs';
import { join, dirname, relative, sep }        from 'node:path';
import { fileURLToPath }                       from 'node:url';

import { CPU }       from '../cpu/cpu.js';
import { Assembler } from '../asm/assembler.js';
import { Executor }  from '../exec/executor.js';

/** Programs that are meant to run until the power is cut, and one that is
 *  simply long. Anything else still running at the end of its budget is a bug. */
const CONTINUOUS = new Set([
    'External Devices/keyboard.asm',
    'External Devices/led_display_test.asm',
    'External Devices/robot.asm',
    'External Devices/stepper_motor.asm',
    'External Devices/thermometer.asm',
    'External Devices/traffic_lights.asm',
    'External Devices/traffic_lights_advanced.asm',
    'Utilities/delay_timer.asm'
]);

/** Instructions each program is given before the run is called unfinished. */
const BUDGET = 3_000_000;

/** Keystrokes offered to any program that asks for input, so that a program
 *  waiting on the keyboard still reaches its end rather than stalling. */
const INPUT = '5\r3\rAMEY\r' + 'A'.repeat(40) + '\r';

let passed = 0;
let failed = 0;

function check(name, actual, expected) {
    if (JSON.stringify(actual) === JSON.stringify(expected)) { passed++; return; }

    failed++;
    console.log(`  FAIL  ${name}\n          got ${JSON.stringify(actual)}`);
}

// -----------------------------------------------------------------------------
// FINDING THE PROGRAMS
// -----------------------------------------------------------------------------
const here        = dirname(fileURLToPath(import.meta.url));
const sourceRoot  = join(here, '..', '..', '..');    // js/test -> simulator -> Source Code

function walk(directory, found = []) {
    for (const entry of readdirSync(directory)) {
        const full = join(directory, entry);

        if (statSync(full).isDirectory()) walk(full, found);
        else if (entry.toLowerCase().endsWith('.asm')) found.push(full);
    }
    return found;
}

const files = walk(sourceRoot).sort();

if (files.length === 0) {
    console.log('\nno .asm files found; nothing to check\n');
    process.exit(0);
}

// -----------------------------------------------------------------------------
// RUNNING THEM
// -----------------------------------------------------------------------------
console.log(`\nASSEMBLING AND RUNNING ${files.length} PROGRAMS`);

const stillRunning = [];

for (const file of files) {
    const name   = relative(sourceRoot, file).split(sep).join('/');
    const source = readFileSync(file, 'utf8');

    // ---- it must assemble with no complaints --------------------------------
    const program = new Assembler().assemble(source);

    if (!program.ok) {
        check(`${name} assembles`, program.diagnostics.map(String), []);
        continue;
    }
    passed++;

    // ---- and it must run without stopping on an error -----------------------
    const cpu = new CPU();

    cpu.memory.load(cpu.registers.get('DS') << 4, program.data);
    cpu.registers.set('IP', program.entryPoint);
    cpu.pendingInput = INPUT;

    let outcome;

    try {
        outcome = new Executor(cpu, program).run(BUDGET);
    } catch (error) {
        check(`${name} runs`, error.message, 'no error');
        continue;
    }

    if (outcome.reason === 'running') {
        stillRunning.push(name);
        continue;
    }
    passed++;
}

// -----------------------------------------------------------------------------
// A PROGRAM THAT NEVER STOPS IS ONLY CORRECT IF IT WAS MEANT TO
// -----------------------------------------------------------------------------
console.log('\nPROGRAMS THAT RUN CONTINUOUSLY');

const unexpected = stillRunning.filter(name => !CONTINUOUS.has(name));
const missing    = [...CONTINUOUS].filter(name => !stillRunning.includes(name));

check('only the controllers and the delay loop keep running', unexpected, []);
check('every listed continuous program is still continuous',  missing, []);

for (const name of stillRunning) console.log(`  ${name}`);

// -----------------------------------------------------------------------------
console.log(`\n${passed} passed, ${failed} failed\n`);
process.exit(failed === 0 ? 0 : 1);
