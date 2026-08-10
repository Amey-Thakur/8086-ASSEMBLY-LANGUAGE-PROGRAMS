// -----------------------------------------------------------------------------
// Script Name: output.test.mjs
// Module:      Conformance Suite, program output
// Stack:       Node.js (ES modules), no test framework
// Description: Checks that every program still prints what it printed when it
//              was written.
//
//              programs.test.mjs proves that a program runs. That is not the
//              same as proving it is right. A bit reversal routine that quietly
//              copies its input runs perfectly and produces the wrong answer,
//              and nothing about the run says so.
//
//              So the exact output of every program is recorded in
//              expected-output.json, checked once by hand against what the
//              program is supposed to compute, and compared on every run
//              afterwards. Any change to the simulator or to a program that
//              alters a single character of output fails here and names the
//              file.
//
//              To record the output of newly added programs, or to accept a
//              change that is intended:
//
//                  node js/test/output.test.mjs --update
//
//              The update is deliberately a separate step. Regenerating on
//              every run would make the file agree with whatever the code
//              currently does, which is no check at all.
//
// Authors:     Amey Thakur
// Repository:  https://github.com/Amey-Thakur/8086-ASSEMBLY-LANGUAGE-PROGRAMS
// License:     CC BY 4.0
// -----------------------------------------------------------------------------

import { readFileSync, readdirSync, statSync, writeFileSync, existsSync } from 'node:fs';
import { join, dirname, relative, sep }                                  from 'node:path';
import { fileURLToPath }                                                 from 'node:url';

import { CPU }       from '../cpu/cpu.js';
import { Assembler } from '../asm/assembler.js';
import { Executor }  from '../exec/executor.js';

/** Keystrokes offered to any program that reads, so a run is reproducible. */
const INPUT = '5\r3\rAMEY\r' + 'A'.repeat(40) + '\r';

/** Instructions a program is given before its output is taken as final. */
const BUDGET = 3_000_000;

const here       = dirname(fileURLToPath(import.meta.url));
const sourceRoot = join(here, '..', '..', '..');
const goldenPath = join(here, 'expected-output.json');
const updating   = process.argv.includes('--update');

let passed = 0;
let failed = 0;

// -----------------------------------------------------------------------------
// RUNNING
// -----------------------------------------------------------------------------

function walk(directory, found = []) {
    for (const entry of readdirSync(directory)) {
        const full = join(directory, entry);

        if (statSync(full).isDirectory()) walk(full, found);
        else if (entry.toLowerCase().endsWith('.asm')) found.push(full);
    }
    return found;
}

/** Assemble and run one program, and return whatever it printed. */
function outputOf(file) {
    const program = new Assembler().assemble(readFileSync(file, 'utf8'));

    if (!program.ok) {
        return { error: 'did not assemble: ' + program.diagnostics.map(String)[0] };
    }

    const cpu = new CPU();

    cpu.memory.load(cpu.registers.get('DS') << 4, program.data);
    cpu.registers.set('IP', program.entryPoint);
    cpu.pendingInput = INPUT;

    try {
        const outcome = new Executor(cpu, program).run(BUDGET);

        return { output: cpu.consoleOutput, finished: outcome.reason === 'halted' };
    } catch (error) {
        return { error: error.message };
    }
}

// -----------------------------------------------------------------------------
// THE CHECK
// -----------------------------------------------------------------------------
const files   = walk(sourceRoot).sort();
const results = {};

for (const file of files) {
    const name = relative(sourceRoot, file).split(sep).join('/');

    results[name] = outputOf(file);
}

// ---- recording ---------------------------------------------------------------
if (updating) {
    writeFileSync(goldenPath, JSON.stringify(results, null, 2) + '\n', 'utf8');

    console.log(`\nrecorded the output of ${Object.keys(results).length} programs`);
    console.log('review the diff before committing it\n');
    process.exit(0);
}

// ---- comparing ---------------------------------------------------------------
if (!existsSync(goldenPath)) {
    console.log('\nno recorded output to compare against.');
    console.log('run "node js/test/output.test.mjs --update" first\n');
    process.exit(1);
}

const golden = JSON.parse(readFileSync(goldenPath, 'utf8'));

console.log(`\nCOMPARING THE OUTPUT OF ${files.length} PROGRAMS`);

function check(name, actual, expected) {
    if (JSON.stringify(actual) === JSON.stringify(expected)) { passed++; return; }

    failed++;
    console.log(`  FAIL  ${name}`);
    console.log(`          expected ${JSON.stringify(expected)}`);
    console.log(`          got      ${JSON.stringify(actual)}`);
}

for (const [name, result] of Object.entries(results)) {
    if (!Object.hasOwn(golden, name)) {
        failed++;
        console.log(`  FAIL  ${name}`);
        console.log(`          no recorded output. Run with --update to record it.`);
        continue;
    }

    check(name, result, golden[name]);
}

// A program that was removed leaves its recording behind, which should be
// noticed rather than quietly ignored.
for (const name of Object.keys(golden)) {
    if (Object.hasOwn(results, name)) continue;

    failed++;
    console.log(`  FAIL  ${name}`);
    console.log(`          recorded but no longer present. Run with --update.`);
}

// -----------------------------------------------------------------------------
console.log(`\n${passed} passed, ${failed} failed\n`);
process.exit(failed === 0 ? 0 : 1);
