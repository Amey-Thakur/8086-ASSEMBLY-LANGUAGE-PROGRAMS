// -----------------------------------------------------------------------------
// Script Name: sync-counts.mjs
// Module:      Tooling, count synchronisation
// Stack:       Node.js (ES modules), no dependencies
// Description: Rewrites every published count in the repository from the one
//              place that actually knows it: the generated program index.
//
//              The README, the specification and the citation metadata each
//              quote how many programs there are. Every one of them was written
//              by hand, and every one of them went stale the first time a
//              program was added. A number a reader can check and find wrong
//              costs more trust than the number was worth.
//
//              So the numbers are derived here and written in. Running
//              "npm run counts" after adding programs is the whole maintenance
//              procedure, and library.test.mjs fails if it has not been done.
//
// Usage:       node js/tools/sync-counts.mjs           update the files
//              node js/tools/sync-counts.mjs --check   report without writing
//
// Authors:     Amey Thakur
// Repository:  https://github.com/Amey-Thakur/8086-ASSEMBLY-LANGUAGE-PROGRAMS
// License:     CC BY 4.0
// -----------------------------------------------------------------------------

'use strict';

import { readFileSync, writeFileSync, existsSync } from 'node:fs';
import { join, dirname }                           from 'node:path';
import { fileURLToPath }                           from 'node:url';

import { readCatalogue } from './index-programs.mjs';

const here          = dirname(fileURLToPath(import.meta.url));
const simulatorRoot = join(here, '..', '..');
const sourceRoot    = join(simulatorRoot, '..');
const repositoryRoot = join(sourceRoot, '..');

/**
 * Every number the repository publishes, worked out from the files themselves.
 */
export function currentCounts() {
    const catalogue = readCatalogue(sourceRoot);

    const programs   = Object.values(catalogue).reduce((sum, files) => sum + files.length, 0);
    const categories = Object.keys(catalogue).length;

    // The suites are whatever "npm test" runs, read from the script rather than
    // counted by hand so that adding one is picked up automatically.
    const packaged = JSON.parse(readFileSync(join(simulatorRoot, 'package.json'), 'utf8'));
    const suites   = (packaged.scripts?.test ?? '').match(/\.test\.mjs/g)?.length ?? 0;

    return { programs, categories, suites };
}

/**
 * The substitutions to make, as a pattern and what it should become.
 *
 * Each pattern captures the surrounding words so that only a count in the right
 * context is touched. A bare search for a number would rewrite version numbers,
 * years and instruction counts as well.
 */
function replacements({ programs, categories, suites }) {
    return [
        // "161 professionally documented 8086 Assembly programs"
        [/\b\d{2,4}(?= professionally documented)/g, String(programs)],

        // "161 Assembly programs", "161 assembly programs"
        // Never the architecture name. 8086 is not a count, and rewriting it
        // turns "8086 Assembly programs" into "525 Assembly programs".
        [/\b(?!8086\b)\d{2,4}(?= [Aa]ssembly programs)/g, String(programs)],

        // "all 161 programs", "containing all **161 programs**"
        [/\b\d{2,4}(?= programs\b)/g, String(programs)],

        // "8086 Assembly Programs (161 Files)"
        [/\(\d{2,4} Files\)/g, `(${programs} Files)`],

        // "609 tests across nine suites"
        [/\b\d{2,5}(?= tests\b)/g, '{{TESTS}}'],
        [/(?<=tests across )\w+(?= suites)/g, String(suites)],

        // "across 39 categories"
        [/\b\d{1,3}(?= categories\b)/g, String(categories)]
    ];
}

/**
 * The test total cannot be derived without running the suites, so it is passed
 * in. Leaving it out keeps whatever the file already says, which is better than
 * writing a number that might be wrong.
 */
function applyTo(text, counts, testTotal) {
    let updated = text;

    for (const [pattern, value] of replacements(counts)) {
        updated = updated.replace(pattern, value);
    }

    return updated.replace(/\{\{TESTS\}\}/g,
        testTotal === null ? String(counts.knownTests ?? '') : String(testTotal));
}

const FILES = [
    'README.md',
    'docs/SPECIFICATION.md',
    'codemeta.json',
    'CITATION.cff'
];

// -----------------------------------------------------------------------------
// COMMAND LINE
// -----------------------------------------------------------------------------
const checkOnly = process.argv.includes('--check');
const totalFlag = process.argv.find(argument => argument.startsWith('--tests='));
const testTotal = totalFlag ? Number(totalFlag.split('=')[1]) : null;

const counts = currentCounts();

console.log(`programs   ${counts.programs}`);
console.log(`categories ${counts.categories}`);
console.log(`suites     ${counts.suites}`);
if (testTotal !== null) console.log(`tests      ${testTotal}`);
console.log('');

let changed = 0;

for (const relative of FILES) {
    const path = join(repositoryRoot, relative);

    if (!existsSync(path)) { console.log(`skipped  ${relative} (not present)`); continue; }

    const before = readFileSync(path, 'utf8');
    const after  = applyTo(before, counts, testTotal);

    if (before === after) { console.log(`unchanged ${relative}`); continue; }

    changed++;

    if (checkOnly) {
        console.log(`STALE     ${relative}`);
        continue;
    }

    writeFileSync(path, after, 'utf8');
    console.log(`updated   ${relative}`);
}

console.log('');

if (checkOnly && changed > 0) {
    console.log(`${changed} file(s) quote a stale count. Run "npm run counts" to fix them.`);
    process.exit(1);
}

console.log(changed === 0 ? 'every published count already agrees' : `${changed} file(s) updated`);
