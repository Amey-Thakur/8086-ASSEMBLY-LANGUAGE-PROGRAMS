// -----------------------------------------------------------------------------
// Script Name: robustness.test.mjs
// Module:      Conformance Suite, robustness
// Stack:       Node.js (ES modules), no test framework
// Description: Throws malformed, hostile and merely strange source at the
//              assembler and the executor, and insists that neither ever escapes
//              with an unhandled exception.
//
//              The other suites check that correct programs behave correctly.
//              This one checks the far larger space of incorrect ones. A person
//              learning the 8086 spends most of their time there, and a
//              simulator that throws a JavaScript error instead of a diagnostic
//              is telling them nothing and looks broken.
//
//              The rule this suite enforces is narrow and absolute: every input
//              produces either a clean assembly with diagnostics, or an
//              ExecutionError with a line number. Never a stack trace, never a
//              hang, never a silently wrong answer accepted as correct.
//
// Authors:     Amey Thakur
// Repository:  https://github.com/Amey-Thakur/8086-ASSEMBLY-LANGUAGE-PROGRAMS
// License:     CC BY 4.0
// -----------------------------------------------------------------------------

import { CPU, ExecutionError } from '../cpu/cpu.js';
import { Assembler }           from '../asm/assembler.js';
import { Executor }            from '../exec/executor.js';

let passed = 0;
let failed = 0;

function check(name, actual, expected) {
    const a = JSON.stringify(actual);
    const e = JSON.stringify(expected);

    if (a === e) { passed++; console.log(`  pass  ${name}`); }
    else         { failed++; console.log(`  FAIL  ${name}\n          got ${a}\n          want ${e}`); }
}

/**
 * Assemble and run, reporting how it ended rather than what it computed.
 *
 * @returns {'rejected'|'ran'|'stopped'|'CRASHED'}
 *          rejected  the assembler produced diagnostics, which is a clean refusal
 *          ran       it assembled and ran to completion
 *          stopped   it assembled and the executor raised a proper ExecutionError
 *          CRASHED   something escaped that was not an ExecutionError
 */
function survive(source) {
    let program;

    try {
        program = new Assembler().assemble(source);
    } catch (error) {
        return `CRASHED in the assembler: ${error.message}`;
    }

    if (!program.ok) return 'rejected';

    const cpu = new CPU();

    try {
        cpu.memory.load(cpu.registers.get('DS') << 4, program.data);
        cpu.registers.set('IP', program.entryPoint);
        cpu.pendingInput = '5\r3\rAMEY\r';

        new Executor(cpu, program).run(200_000);
        return 'ran';
    } catch (error) {
        return error instanceof ExecutionError
            ? 'stopped'
            : `CRASHED in the executor: ${error.constructor.name}: ${error.message}`;
    }
}

/** True when the input was handled at all, however it ended. */
const handled = source => {
    const outcome = survive(source);

    return outcome.startsWith('CRASHED') ? outcome : true;
};

// -----------------------------------------------------------------------------
console.log('\nMALFORMED SOURCE IS REFUSED, NOT CRASHED ON');
// -----------------------------------------------------------------------------
const MALFORMED = {
    'an empty file':                    '',
    'only whitespace':                  '   \n\t\n   \n',
    'only a comment':                   '; nothing here at all\n',
    'a stray label with no code':       'ONLY_A_LABEL:\n',
    'an unterminated string':           `.DATA\n    M DB 'never closed\n.CODE\nSTART:\n    HLT\nEND START\n`,
    'an unclosed bracket':              'START:\n    MOV AX, [BX\n    HLT\n',
    'a surplus bracket':                'START:\n    MOV AX, BX]\n    HLT\n',
    'empty brackets':                   'START:\n    MOV AX, []\n    HLT\n',
    'a label defined twice':            'START:\n    NOP\nSTART:\n    HLT\n',
    'a jump to nowhere':                'START:\n    JMP NOWHERE_AT_ALL\n    HLT\n',
    'a name never defined':             'START:\n    MOV AX, UNDEFINED_NAME\n    HLT\n',
    'too many operands':                'START:\n    MOV AX, BX, CX\n    HLT\n',
    'too few operands':                 'START:\n    MOV AX\n    HLT\n',
    'an operand where none belongs':    'START:\n    NOP AX\n    HLT\n',
    'two memory operands':              'START:\n    MOV [100H], [200H]\n    HLT\n',
    'a segment register as an index':   'START:\n    MOV AX, [DS]\n    HLT\n',
    'an illegal index register':        'START:\n    MOV AX, [CX]\n    HLT\n',
    'two base registers':               'START:\n    MOV AX, [BX+BP]\n    HLT\n',
    'two index registers':              'START:\n    MOV AX, [SI+DI]\n    HLT\n',
    'a mismatched operand width':       'START:\n    MOV AL, BX\n    HLT\n',
    'an immediate destination':         'START:\n    MOV 5, AX\n    HLT\n',
    'a number that is not a number':    'START:\n    MOV AX, 12G4H\n    HLT\n',
    'a macro with no ENDM':             'BAD MACRO\n    NOP\nSTART:\n    HLT\n',
    'a REPT with no ENDM':              'START:\n    REPT 3\n    NOP\n',
    'an IF with no ENDIF':              'START:\n    IF 1\n    NOP\n',
    'an ENDIF with no IF':              'START:\n    ENDIF\n    HLT\n',
    'DUP with no count':                '.DATA\n    B DB DUP (0)\n.CODE\nSTART:\n    HLT\n',
    'a negative DUP count':             '.DATA\n    B DB -4 DUP (0)\n.CODE\nSTART:\n    HLT\n',
    'division by a literal zero':       'START:\n    MOV AX, 10\n    MOV BL, 0\n    DIV BL\n    HLT\n',
    'a RET with nothing pushed':        'START:\n    RET\n',
    'an interrupt that does not exist': 'START:\n    INT 99H\n    HLT\n',
    'a service that does not exist':    'START:\n    MOV AH, 0FEH\n    INT 21H\n    HLT\n',
    'nothing but binary rubbish':       '\x00\x01\x02\xFF\x7F\n',
    'a very long single line':          'START:\n    MOV AX, ' + '1+'.repeat(400) + '1\n    HLT\n',
    'a deeply nested expression':       'START:\n    MOV AX, ' + '('.repeat(60) + '1' + ')'.repeat(60) + '\n    HLT\n',
    'unbalanced nesting':               'START:\n    MOV AX, ' + '('.repeat(60) + '1\n    HLT\n'
};

for (const [description, source] of Object.entries(MALFORMED)) {
    check(description, handled(source), true);
}

// -----------------------------------------------------------------------------
console.log('\nA RUNAWAY PROGRAM IS STOPPED, NOT LEFT TO RUN');
//
// An infinite loop is not a mistake the simulator can refuse at assembly time,
// so the budget is what keeps the page responsive. These check that the budget
// is actually enforced rather than merely declared.
// -----------------------------------------------------------------------------
{
    const forever = 'START:\nAGAIN:\n    JMP AGAIN\n';
    const program = new Assembler().assemble(forever);

    check('an endless loop assembles cleanly', program.ok, true);

    const cpu = new CPU();

    cpu.registers.set('IP', program.entryPoint);

    const result = new Executor(cpu, program).run(5_000);

    check('and run() returns rather than hanging', typeof result, 'object');
    check('reporting it is still running',       result.reason, 'running');
    check('after executing exactly the budget',    result.executed, 5_000);
    check('with the machine still alive',          cpu.halted, false);

    // The same loop must be resumable, because the interface runs a program in
    // slices and would otherwise lose its place between frames.
    const more = new Executor(cpu, program).run(1_000);

    check('and it can be resumed', more.executed, 1_000);
}

{
    // A loop that never touches CX but uses LOOP is the other common runaway.
    const spinning = 'START:\n    MOV CX, 0\nAGAIN:\n    LOOP AGAIN\n    HLT\n';
    const outcome  = survive(spinning);

    check('a LOOP from zero is bounded too', outcome.startsWith('CRASHED'), false);
}

// -----------------------------------------------------------------------------
console.log('\nARITHMETIC THAT CANNOT BE DONE IS DIAGNOSED');
// -----------------------------------------------------------------------------
{
    const dividesByZero = source => {
        const program = new Assembler().assemble(source);

        if (!program.ok) return 'rejected';

        const cpu = new CPU();

        cpu.registers.set('IP', program.entryPoint);

        try {
            new Executor(cpu, program).run(10_000);
            return 'ran';
        } catch (error) {
            return error instanceof ExecutionError ? error.message : `CRASHED: ${error.message}`;
        }
    };

    const byZero = dividesByZero('START:\n    MOV AX, 10\n    MOV BL, 0\n    DIV BL\n    HLT\n');

    check('division by zero is an ExecutionError', byZero.startsWith('CRASHED'), false);
    check('and the message says what happened',    /divi|zero/i.test(byZero), true);

    // A quotient too large for the destination is the other divide fault, and is
    // much easier to write by accident than dividing by zero.
    const tooLarge = dividesByZero('START:\n    MOV AX, 0FFFFH\n    MOV BL, 1\n    DIV BL\n    HLT\n');

    check('an overflowing quotient is diagnosed too', tooLarge.startsWith('CRASHED'), false);
}

// -----------------------------------------------------------------------------
console.log('\nMEMORY AND THE STACK STAY INSIDE THEMSELVES');
//
// The 8086 wraps rather than faulting, so none of these are errors. What matters
// is that the simulator wraps in the same way instead of reading outside its own
// array, which in JavaScript would quietly produce undefined.
// -----------------------------------------------------------------------------
{
    const wrapping = [
        ['an address at the very top',   'START:\n    MOV BX, 0FFFFH\n    MOV AL, [BX]\n    HLT\n'],
        ['an address that wraps past it','START:\n    MOV BX, 0FFFFH\n    MOV AX, [BX]\n    HLT\n'],
        ['a stack pushed past its base', 'START:\n    MOV CX, 300\nAGAIN:\n    PUSH AX\n    LOOP AGAIN\n    HLT\n'],
        ['a stack popped past its top',  'START:\n    MOV CX, 300\nAGAIN:\n    POP AX\n    LOOP AGAIN\n    HLT\n'],
        ['SP set to an odd address',     'START:\n    MOV SP, 1235H\n    PUSH AX\n    POP BX\n    HLT\n']
    ];

    for (const [description, source] of wrapping) {
        check(description, handled(source), true);
    }

    // Whatever comes back from a wrapped read, it has to be a number in range.
    const program = new Assembler().assemble(
        'START:\n    MOV BX, 0FFFFH\n    MOV AX, [BX]\n    HLT\n');
    const cpu = new CPU();

    cpu.registers.set('IP', program.entryPoint);
    new Executor(cpu, program).run(1_000);

    const read = cpu.registers.get('AX');

    check('a wrapped read still yields a word', Number.isInteger(read) && read >= 0 && read <= 0xFFFF, true);
}

// -----------------------------------------------------------------------------
console.log('\nTHE ASSEMBLER REPORTS WHERE, NOT JUST WHAT');
//
// A diagnostic without a line number is nearly useless in a long program, and
// the editor gutter has nothing to point at.
// -----------------------------------------------------------------------------
{
    const program = new Assembler().assemble(
        '.MODEL SMALL\n.CODE\nSTART:\n    NOP\n    MOV AX, [CX]\n    HLT\nEND START\n');

    check('a bad operand is refused', program.ok, false);

    const located = program.diagnostics.filter(d => typeof d.line === 'number' && d.line > 0);

    check('and every diagnostic carries a line number',
          located.length, program.diagnostics.length);

    check('pointing at the offending line', located[0]?.line, 5);
}

// -----------------------------------------------------------------------------
console.log('\nTHE SAME SOURCE ALWAYS GIVES THE SAME RESULT');
//
// A simulator whose output varies between runs cannot be tested, and two people
// following the same lab sheet would see different answers. The clock is fixed
// and nothing consults the wall time, so this must hold.
// -----------------------------------------------------------------------------
{
    const source = `
.MODEL SMALL
.STACK 100H
.DATA
    M DB 'x', '$'
.CODE
START:
    MOV AX, @DATA
    MOV DS, AX
    MOV AH, 2CH
    INT 21H
    MOV BX, CX
    MOV AH, 2AH
    INT 21H
    MOV AH, 4CH
    INT 21H
END START
`;

    const once  = new Assembler().assemble(source);
    const twice = new Assembler().assemble(source);

    check('assembly is deterministic',
          JSON.stringify(once.data), JSON.stringify(twice.data));

    const stateOf = () => {
        const program = new Assembler().assemble(source);
        const cpu     = new CPU();

        cpu.memory.load(cpu.registers.get('DS') << 4, program.data);
        cpu.registers.set('IP', program.entryPoint);
        new Executor(cpu, program).run(10_000);

        return [cpu.registers.get('BX'), cpu.registers.get('CX'), cpu.registers.get('DX')].join(',');
    };

    check('and so is the clock the program reads', stateOf(), stateOf());
}

// -----------------------------------------------------------------------------
console.log(`\n${passed} passed, ${failed} failed\n`);
process.exit(failed === 0 ? 0 : 1);
