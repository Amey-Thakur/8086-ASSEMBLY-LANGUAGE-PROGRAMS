// -----------------------------------------------------------------------------
// Script Name: check-links.mjs
// Module:      Tooling, link verification
// Stack:       Node.js (ES modules), no dependencies
// Description: Checks every relative link in the repository's markdown against
//              the filesystem.
// Usage:       node js/tools/check-links.mjs
//
// Authors:     Amey Thakur
// Repository:  https://github.com/Amey-Thakur/8086-ASSEMBLY-LANGUAGE-PROGRAMS
// License:     CC BY 4.0
// -----------------------------------------------------------------------------
//
// A link that used to work and quietly stopped is the commonest rot in a long
// README, and nothing in a normal test suite would notice. Anchors are checked
// against the headings actually present, and file links against the files
// actually there, with percent encoding undone first.

import { readFileSync, existsSync, readdirSync, statSync } from 'node:fs';
import { join, dirname, resolve } from 'node:path';
import { fileURLToPath } from 'node:url';

// The repository root, four levels up from js/tools.
const ROOT = resolve(dirname(fileURLToPath(import.meta.url)), '..', '..', '..', '..');

/** Every markdown file in the repository, ignoring anything vendored. */
function markdownFiles(dir, found = []) {
    for (const name of readdirSync(dir)) {
        if (name === '.git' || name === 'node_modules') continue;

        const path = join(dir, name);

        if (statSync(path).isDirectory()) markdownFiles(path, found);
        else if (name.endsWith('.md')) found.push(path);
    }

    return found;
}

/**
 * GitHub's anchor rule: lower case, punctuation dropped, each space a hyphen.
 *
 * Each space individually, not each run of them. "Debugging & Error Analysis"
 * loses the ampersand and keeps both surrounding spaces, so the anchor is
 * "debugging--error-analysis" with two hyphens. Collapsing the run gives one
 * and reports a working anchor as broken.
 */
const slug = heading => heading
    .toLowerCase()
    .replace(/[^\w\s-]/g, '')
    .trim()
    .replace(/ /g, '-');

let checked = 0;
const broken = [];

for (const file of markdownFiles(ROOT)) {
    const text = readFileSync(file, 'utf8');
    const base = dirname(file);

    const anchors = new Set(
        [...text.matchAll(/^ {0,3}#{1,6}\s+(.+?)\s*$/gm)].map(m => slug(m[1])));

    // Markdown links and bare HTML hrefs both count.
    const targets = [
        ...[...text.matchAll(/\[[^\]]*\]\(([^)\s]+)(?:\s+"[^"]*")?\)/g)].map(m => m[1]),
        ...[...text.matchAll(/href="([^"]+)"/g)].map(m => m[1])
    ];

    for (const raw of targets) {
        if (/^(https?:|mailto:|#!)/i.test(raw)) continue;   // external, not ours to check

        checked++;

        // An anchor on its own points inside this same document.
        if (raw.startsWith('#')) {
            if (!anchors.has(raw.slice(1).toLowerCase())) {
                broken.push(`${file}  ->  ${raw}   (no such heading)`);
            }
            continue;
        }

        const [pathPart, anchor] = raw.split('#');
        const decoded = decodeURIComponent(pathPart);
        const target  = resolve(base, decoded);

        if (!existsSync(target)) {
            broken.push(`${file}  ->  ${raw}   (no such file)`);
            continue;
        }

        // A link into another document has to name a heading that is there.
        if (anchor && target.endsWith('.md')) {
            const theirs = new Set(
                [...readFileSync(target, 'utf8').matchAll(/^ {0,3}#{1,6}\s+(.+?)\s*$/gm)]
                    .map(m => slug(m[1])));

            if (!theirs.has(anchor.toLowerCase())) {
                broken.push(`${file}  ->  ${raw}   (no such heading in that file)`);
            }
        }
    }
}

console.log(`checked ${checked} relative link(s) across the markdown`);

if (broken.length === 0) {
    console.log('every one of them resolves');
    process.exit(0);
}

console.log(`\n${broken.length} broken:`);
for (const line of broken) console.log(`  ${line}`);
process.exit(1);
