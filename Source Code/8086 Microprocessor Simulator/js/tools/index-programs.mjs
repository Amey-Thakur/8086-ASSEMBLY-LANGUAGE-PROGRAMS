// -----------------------------------------------------------------------------
// Script Name: index-programs.mjs
// Module:      Tools, 1 of 1
// Stack:       Node.js (ES modules), no dependencies
// Description: Rebuilds programs.js from what is actually on disk.
//
//              The library the simulator shows is driven by programs.js. If a
//              program exists in a folder but is missing from that file, it is
//              in the repository and unreachable from the interface, which is
//              the worst of both: the work is there and nobody can run it.
//
//              Maintaining the list by hand guarantees that happens eventually.
//              So it is generated, and library.test.mjs fails the build if the
//              generated file and the folders ever disagree.
//
//                  npm run index
//
// Authors:     Amey Thakur
// Repository:  https://github.com/Amey-Thakur/8086-ASSEMBLY-LANGUAGE-PROGRAMS
// License:     CC BY 4.0
// -----------------------------------------------------------------------------

import { readdirSync, statSync, writeFileSync } from 'node:fs';
import { join, dirname }                        from 'node:path';
import { fileURLToPath }                        from 'node:url';

const here       = dirname(fileURLToPath(import.meta.url));
const simulator  = join(here, '..', '..');          // js/tools -> js -> simulator
const sourceRoot = join(simulator, '..');           // simulator -> Source Code
const target     = join(simulator, 'programs.js');

/**
 * Read the catalogue from the folders beside the simulator.
 *
 * The simulator's own directory is skipped: it holds the engine, not programs.
 */
export function readCatalogue(root) {
    const catalogue = {};

    for (const entry of readdirSync(root).sort()) {
        const full = join(root, entry);

        if (!statSync(full).isDirectory()) continue;
        if (entry === '8086 Microprocessor Simulator') continue;

        const programs = readdirSync(full)
            .filter(name => name.toLowerCase().endsWith('.asm'))
            .sort();

        if (programs.length > 0) catalogue[entry] = programs;
    }

    return catalogue;
}

/** Render the catalogue as the module the interface imports. */
function render(catalogue) {
    const total = Object.values(catalogue).reduce((sum, list) => sum + list.length, 0);
    const lines = Object.entries(catalogue).map(([category, programs]) => {
        const quoted = programs.map(name => `'${name}'`).join(', ');

        return `    '${category}': [${quoted}]`;
    });

    return `// -----------------------------------------------------------------------------
// Script Name: programs.js
// Module:      Program Library
// Stack:       JavaScript (ES2020), no dependencies
// Description: The catalogue of every assembly program in this repository,
//              grouped by the folder it lives in.
//
//              GENERATED. Do not edit by hand: run "npm run index" after adding
//              or removing a program, and library.test.mjs will fail the build
//              if this file and the folders ever disagree.
//
//              This is an index, not a copy. The interface fetches the real
//              .asm file from the folder beside this one, so what the simulator
//              runs is what the repository actually holds.
//
//              ${total} programs across ${Object.keys(catalogue).length} categories.
//
// Authors:     Amey Thakur
// Repository:  https://github.com/Amey-Thakur/8086-ASSEMBLY-LANGUAGE-PROGRAMS
// License:     CC BY 4.0
// -----------------------------------------------------------------------------

'use strict';

/** Category name to the files it contains, in the order they appear on disk. */
export const PROGRAMS = {
${lines.join(',\n')}
};

/** How many programs the library holds. Written out so that anything quoting
 *  the number reads it from here rather than repeating it. */
export const PROGRAM_COUNT = ${total};

/** How many categories they are grouped into. */
export const CATEGORY_COUNT = ${Object.keys(catalogue).length};
`;
}

// Running directly rewrites the file; importing only exposes readCatalogue.
if (process.argv[1] && process.argv[1].endsWith('index-programs.mjs')) {
    const catalogue = readCatalogue(sourceRoot);
    const total     = Object.values(catalogue).reduce((sum, list) => sum + list.length, 0);

    writeFileSync(target, render(catalogue), 'utf8');

    console.log(`\nindexed ${total} programs across ${Object.keys(catalogue).length} categories`);

    for (const [category, programs] of Object.entries(catalogue)) {
        console.log(`  ${String(programs.length).padStart(3)}  ${category}`);
    }
    console.log();
}
