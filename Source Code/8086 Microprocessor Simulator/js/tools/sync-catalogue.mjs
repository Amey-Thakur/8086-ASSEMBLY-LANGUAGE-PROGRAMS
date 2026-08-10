// -----------------------------------------------------------------------------
// Script Name: sync-catalogue.mjs
// Module:      Tooling, program catalogue synchronisation
// Stack:       Node.js (ES modules), no dependencies
// Description: Regenerates the "Program Details" section of README.md from the
//              programs themselves.
//
//              That section lists every program with its title, a description
//              and a link to the source. It was maintained by hand, so it
//              drifted the moment anything was added: it announced one program
//              in a category holding twelve, and omitted whole categories.
//
//              Nothing here is invented. The title and the description are read
//              out of each file's own header, which every program in this
//              repository carries and which library.test.mjs enforces. If a
//              description is wrong, the fix belongs in the program, not here.
//
// Usage:       node js/tools/sync-catalogue.mjs           rewrite the section
//              node js/tools/sync-catalogue.mjs --check   report without writing
//
// Authors:     Amey Thakur
// Repository:  https://github.com/Amey-Thakur/8086-ASSEMBLY-LANGUAGE-PROGRAMS
// License:     CC BY 4.0
// -----------------------------------------------------------------------------

'use strict';

import { readFileSync, writeFileSync, readdirSync, statSync } from 'node:fs';
import { join, dirname }                                      from 'node:path';
import { fileURLToPath }                                       from 'node:url';

const here           = dirname(fileURLToPath(import.meta.url));
const simulatorRoot  = join(here, '..', '..');
const sourceRoot     = join(simulatorRoot, '..');
const repositoryRoot = join(sourceRoot, '..');

const SIMULATOR = '8086 Microprocessor Simulator';

/**
 * Read the title and description out of a program's header.
 *
 * A description may run over several lines, indented under the first. They are
 * joined back into one sentence, because a table cell cannot hold a line break.
 */
function headerOf(text) {
    const lines = text.split(/\r?\n/);

    let title = '';
    const description = [];

    for (let at = 0; at < lines.length; at++) {
        const titleMatch = lines[at].match(/^;\s*TITLE:\s*(.+?)\s*$/i);

        if (titleMatch) { title = titleMatch[1]; continue; }

        const first = lines[at].match(/^;\s*DESCRIPTION:\s*(.+?)\s*$/i);

        if (!first) continue;

        description.push(first[1]);

        // Continuation lines are comment lines indented past the keyword, and
        // stop at the next keyword or at the end of the header block.
        for (let next = at + 1; next < lines.length; next++) {
            const more = lines[next].match(/^;\s{4,}(\S.*?)\s*$/);

            if (!more) break;
            if (/^[A-Z ]+:/.test(more[1])) break;

            description.push(more[1]);
        }

        break;
    }

    return {
        title: title || '(untitled)',
        description: description.join(' ').replace(/\s+/g, ' ').trim() || '(no description)'
    };
}

/** A table cell must not contain a bar, or it splits the row in two. */
const cell = text => text.replace(/\|/g, '\\|');

/** Percent encode each path segment, leaving the separators alone. */
const link = (...parts) => parts.map(encodeURIComponent).join('/');

function buildCatalogue() {
    const categories = readdirSync(sourceRoot)
        .filter(name => name !== SIMULATOR)
        .filter(name => statSync(join(sourceRoot, name)).isDirectory())
        .sort((a, b) => a.localeCompare(b));

    const blocks = [];

    let total = 0;

    for (const category of categories) {
        const files = readdirSync(join(sourceRoot, category))
            .filter(name => name.endsWith('.asm'))
            .sort((a, b) => a.localeCompare(b));

        if (files.length === 0) continue;

        total += files.length;

        const rows = files.map(file => {
            const { title, description } = headerOf(
                readFileSync(join(sourceRoot, category, file), 'utf8'));

            const href = link('Source Code', category, file);

            return `| \`${file}\` | ${cell(title)} | ${cell(description)} | [View](${href}) |`;
        });

        blocks.push(`<details>
<summary><strong>${category} (${files.length} ${files.length === 1 ? 'Program' : 'Programs'})</strong></summary>

| Program | Title | Description | Code |
|:---|:---|:---|:-:|
${rows.join('\n')}

</details>`);
    }

    return { text: `## Program Details

> [!IMPORTANT]
> Click on each section below to expand and view all programs with direct links to source code.

> [!NOTE]
> This section is generated from the programs themselves by \`npm run catalogue\`. The title and description of each row are read out of that file's own header, so the list cannot fall behind the repository.

**${total} programs across ${blocks.length} categories.**

${blocks.join('\n\n')}

---

`, total, categories: blocks.length };
}

// -----------------------------------------------------------------------------
// REWRITE THE SECTION
// -----------------------------------------------------------------------------
const checkOnly = process.argv.includes('--check');
const readme    = join(repositoryRoot, 'README.md');

const text  = readFileSync(readme, 'utf8');
const start = text.indexOf('## Program Details');

if (start < 0) {
    console.error('README.md has no "## Program Details" heading');
    process.exit(1);
}

// The section ends where the next top level heading begins.
const after = text.indexOf('\n## ', start + 1);

if (after < 0) {
    console.error('no heading follows "## Program Details"');
    process.exit(1);
}

const built   = buildCatalogue();
const updated = text.slice(0, start) + built.text + text.slice(after + 1);

if (updated === text) {
    console.log('the program catalogue already matches the repository');
    process.exit(0);
}

if (checkOnly) {
    console.log('README.md program catalogue is out of date. Run "npm run catalogue".');
    process.exit(1);
}

writeFileSync(readme, updated, 'utf8');
console.log(`catalogue rewritten: ${built.total} programs across ${built.categories} categories`);
