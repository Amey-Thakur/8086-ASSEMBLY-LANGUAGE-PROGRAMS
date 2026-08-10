// -----------------------------------------------------------------------------
// Script Name: sync-structure.mjs
// Module:      Tooling, project structure synchronisation
// Stack:       Node.js (ES modules), no dependencies
// Description: Regenerates the project tree in README.md from the repository
//              itself.
//
//              The tree was written by hand, and by the time anybody noticed it
//              listed twenty-eight categories out of thirty-nine and quoted
//              counts that had been wrong for months. A structure diagram that
//              disagrees with the structure is worse than none at all, because a
//              reader trusts it before they trust the folder listing.
//
//              So it is generated. The one thing kept by hand is the short
//              description beside each category, because no tool can infer what
//              a folder is for. A category with no description still appears,
//              with its name alone, and the check below names it so the gap can
//              be filled.
//
// Usage:       node js/tools/sync-structure.mjs           rewrite the block
//              node js/tools/sync-structure.mjs --check   report without writing
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

/** What each category is for. Written by hand, because a tool cannot know. */
const ABOUT = {
    'Addressing Modes':    'Every way the 8086 can name an operand',
    'Arithmetic':          'Add, subtract, multiply, divide, and BCD',
    'Array Operations':    'Sum, min and max, insert, delete, rotate, search',
    'BIOS Services':       'INT 10h, 16h and 1Ah: video, keyboard, clock',
    'Bit Manipulation':    'Counting, isolating, reversing and rounding bits',
    'Bitwise Operations':  'AND, OR, XOR, NOT, shifts, rotates, masks',
    'Conditional Jumps':   'The signed and unsigned branch families',
    'Control Flow':        'Loops, guards, jump tables, state machines',
    'Conversion':          'Hex, BCD, binary, octal, ASCII, seven segment',
    'DOS Services':        'INT 21h: console, buffered input, files, clock',
    'Data Structures':     'Stack, queue, deque, list, tree, hash, heap',
    'Data Transfer':       'MOV, XCHG, LEA, LDS, LES, XLAT, PUSH, POP',
    'Expression':          'Factorial, Fibonacci, GCD, power, quadratic',
    'External Devices':    'Traffic lights, stepper motor, relays, sensors',
    'File Operations':     'Create, open, read, write, seek, rename, delete',
    'Flags':               'All nine flags, and what each one answers',
    'Graphics':            'Text mode drawing, VGA pixels, Bresenham, sprites',
    'Input Output':        'Reading and printing decimal, hex, binary, strings',
    'Interrupts':          'The vector table, service conventions, BIOS and DOS',
    'Introduction':        'Hello World, the syntax, the first instructions',
    'Loops':               'LOOP, LOOPE, LOOPNE, and loops built by hand',
    'Macros':              'MACRO, LOCAL, REPT, conditional assembly',
    'Mathematics':         'Roots, powers, averages, 32-bit arithmetic',
    'Matrix':              'Addition, transpose, multiplication, determinant',
    'Memory Operations':   'Block move, fill, compare, scan, checksum, dump',
    'Number Theory':       'Primes, divisors, Collatz, modular arithmetic',
    'Patterns':            'Pyramids, diamonds, triangles, geometric figures',
    'Port Programming':    'IN and OUT against a port space',
    'Procedures':          'Calls, arguments, frames, recursion, dispatch',
    'Recursion':           'Factorial, Fibonacci, Hanoi, and the frames beneath',
    'Searching':           'Linear, binary, jump, exponential, ternary, rotated',
    'Shift and Rotate':    'SHL, SHR, SAR, ROL, ROR, RCL, RCR',
    'Signed Arithmetic':   'Two’s complement, IMUL, IDIV, CBW, CWD',
    'Simulation':          'Traffic lights, lifts, sensors, machines, displays',
    'Sorting':             'Bubble, selection, insertion, quick, heap, radix',
    'Stack Operations':    'The pointer, frames, flags, and stack discipline',
    'String Instructions': 'MOVS, LODS, STOS, CMPS, SCAS, and REP',
    'String Operations':   'Length, reverse, palindrome, case, search, encode',
    'Utilities':           'Delays, passwords, sound, clearing, calendars'
};

/** The categories on disk, with how many programs each holds. */
function categories() {
    return readdirSync(sourceRoot)
        .filter(name => name !== SIMULATOR)
        .filter(name => statSync(join(sourceRoot, name)).isDirectory())
        .map(name => ({
            name,
            count: readdirSync(join(sourceRoot, name)).filter(f => f.endsWith('.asm')).length
        }))
        .filter(entry => entry.count > 0)
        .sort((a, b) => a.name.localeCompare(b.name));
}

/** How many files sit in one of the simulator's own directories. */
const countIn = (...parts) => readdirSync(join(simulatorRoot, ...parts)).length;

function buildTree() {
    const list  = categories();
    const total = list.reduce((sum, entry) => sum + entry.count, 0);

    // Every comment starts in the same column as the ones outside this block,
    // so the whole tree reads as one aligned diagram rather than two.
    const COLUMN = 42;
    const pad    = text => text + ' '.repeat(Math.max(1, COLUMN - text.length));

    const rows = list.map(entry => {
        const label = `│   ├── ${entry.name}/`;
        const about = ABOUT[entry.name] ?? entry.name;

        return `${pad(label)}# ${about} (${entry.count})`;
    });

    return `\`\`\`python
8086-ASSEMBLY-LANGUAGE-PROGRAMS/
│
├── docs/                                    # Formal documentation
│   └── SPECIFICATION.md                     # Technical architecture and specification
│
├── Source Code/                             # 8086 assembly programs (${total} files, ${list.length} categories)
${rows.join('\n')}
│   │
│   └── ${SIMULATOR}/       # Browser simulator, no dependencies and no build step
│       ├── css/                             # Tokens, layout, components (${countIn('css')})
│       ├── js/
│       │   ├── cpu/                         # Memory, registers, flags, shifter, ALU, CPU (${countIn('js', 'cpu')})
│       │   ├── asm/                         # Lexer, macros, expressions, operands, assembler (${countIn('js', 'asm')})
│       │   ├── exec/                        # Executor, devices, strings, interrupts (${countIn('js', 'exec')})
│       │   ├── ui/                          # Editor, inspector, library, console, panels, app (${countIn('js', 'ui')})
│       │   ├── tools/                       # Index and count generators (${countIn('js', 'tools')})
│       │   └── test/                        # Conformance suites (${countIn('js', 'test')})
│       ├── index.html                       # Simulator entry point
│       ├── package.json                     # Test runner configuration
│       └── programs.js                      # Generated program index
│
├── .gitattributes                           # Git configuration
├── .gitignore                               # Git ignore rules
├── 404.html                                 # Personalised not-found page
├── CITATION.cff                             # Citation metadata
├── codemeta.json                            # Project metadata (JSON-LD)
├── LICENSE                                  # MIT License
├── README.md                                # Main documentation
└── SECURITY.md                              # Security policy and posture
\`\`\``;
}

// -----------------------------------------------------------------------------
// REWRITE THE BLOCK BETWEEN THE HEADING AND THE NEXT ONE
// -----------------------------------------------------------------------------
const checkOnly = process.argv.includes('--check');
const readme    = join(repositoryRoot, 'README.md');

const text  = readFileSync(readme, 'utf8');
const start = text.indexOf('## Project Structure');

if (start < 0) {
    console.error('README.md has no "## Project Structure" heading');
    process.exit(1);
}

const open  = text.indexOf('```python', start);
const close = text.indexOf('```', open + 9);

if (open < 0 || close < 0) {
    console.error('the project structure block is not a fenced python block');
    process.exit(1);
}

const before  = text.slice(0, open);
const after   = text.slice(close + 3);
const updated = before + buildTree() + after;

const missing = categories()
    .map(entry => entry.name)
    .filter(name => !Object.hasOwn(ABOUT, name));

if (missing.length) {
    console.log(`no description written for: ${missing.join(', ')}`);
}

if (updated === text) { console.log('the project structure already matches the repository'); process.exit(0); }

if (checkOnly) {
    console.log('README.md project structure is out of date. Run "npm run structure".');
    process.exit(1);
}

writeFileSync(readme, updated, 'utf8');
console.log(`project structure rewritten: ${categories().length} categories`);
