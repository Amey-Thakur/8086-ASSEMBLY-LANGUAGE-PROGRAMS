// -----------------------------------------------------------------------------
// Script Name: executor.test.mjs
// Module:      Conformance Suite, executor
// Stack:       Node.js (ES modules), no test framework
// Description: End to end verification. Each case is real assembly text that is
//              assembled and executed, then the resulting machine state is
//              compared against documented 8086 behaviour.
//
//              The first section is the exact battery that was run against the
//              previous emulator, where thirteen of thirty three cases failed.
//              Keeping the same cases here means the fix is demonstrable rather
//              than asserted.
//
// Authors:     Amey Thakur
// Repository:  https://github.com/Amey-Thakur/8086-ASSEMBLY-LANGUAGE-PROGRAMS
// License:     CC BY 4.0
// -----------------------------------------------------------------------------

import { CPU }       from '../cpu/cpu.js';
import { Assembler } from '../asm/assembler.js';
import { Executor, editDistance } from '../exec/executor.js';

let passed = 0;
let failed = 0;

function check(name, actual, expected) {
    const a = JSON.stringify(actual);
    const e = JSON.stringify(expected);

    if (a === e) { passed++; console.log(`  pass  ${name}`); }
    else         { failed++; console.log(`  FAIL  ${name}\n          got ${a}\n          want ${e}`); }
}

const hex = (v, w = 4) => v.toString(16).toUpperCase().padStart(w, '0');

/**
 * Assemble and run a fragment, then return the observable machine state in the
 * same shape the browser test used, so the two are directly comparable.
 */
function run(source) {
    const cpu     = new CPU();
    const program = new Assembler().assemble(source);

    if (!program.ok) {
        return { ERROR: program.diagnostics.map(String).join('; ') };
    }

    cpu.memory.load(cpu.registers.get('DS') << 4, program.data);
    cpu.registers.set('IP', program.entryPoint);

    const executor = new Executor(cpu, program);

    try {
        executor.runToCompletion();
    } catch (error) {
        return { ERROR: error.message };
    }

    const r = cpu.registers;
    const f = cpu.flags;

    return {
        AX: hex(r.get('AX')), BX: hex(r.get('BX')), CX: hex(r.get('CX')), DX: hex(r.get('DX')),
        SI: hex(r.get('SI')), DI: hex(r.get('DI')), SP: hex(r.get('SP')),
        CF: f.CF, ZF: f.ZF, SF: f.SF, OF: f.OF, PF: f.PF, AF: f.AF,
        out: cpu.consoleOutput
    };
}

/** Compare only the fields a case cares about. */
function expectState(name, source, expected) {
    const state = run(source);

    if (state.ERROR) {
        failed++;
        console.log(`  FAIL  ${name}\n          error: ${state.ERROR}`);
        return;
    }

    const actual = {};
    for (const key of Object.keys(expected)) actual[key] = state[key];

    check(name, actual, expected);
}

// -----------------------------------------------------------------------------
console.log('\nTHE THIRTEEN THAT FAILED BEFORE');
// -----------------------------------------------------------------------------
expectState('unsigned wrap sets AF',   'MOV AX,0FFFFh\nADD AX,1\nHLT',
            { AX: '0000', CF: 1, ZF: 1, AF: 1, OF: 0, SF: 0 });

expectState('signed overflow sets OF', 'MOV AX,7FFFh\nADD AX,1\nHLT',
            { AX: '8000', OF: 1, SF: 1, CF: 0, ZF: 0 });

expectState('auxiliary carry',         'MOV AL,0Fh\nADD AL,1\nHLT',
            { AX: '0010', AF: 1 });

expectState('INC preserves CF',        'MOV AX,1\nSTC\nINC AX\nHLT',
            { AX: '0002', CF: 1 });

expectState('DEC preserves CF',        'MOV AX,5\nSTC\nDEC AX\nHLT',
            { AX: '0004', CF: 1 });

expectState('SHL sets carry out',      'MOV AL,80h\nSHL AL,1\nHLT',
            { AX: '0000', CF: 1 });

expectState('SHR sets carry out',      'MOV AL,81h\nSHR AL,1\nHLT',
            { AX: '0040', CF: 1 });

expectState('SAR replicates the sign', 'MOV AL,80h\nSAR AL,1\nHLT',
            { AX: '00C0' });

expectState('ROL rotates, does not lose', 'MOV AL,80h\nROL AL,1\nHLT',
            { AX: '0001', CF: 1 });

expectState('ROR rotates, does not lose', 'MOV AL,1\nROR AL,1\nHLT',
            { AX: '0080', CF: 1 });

expectState('RCL through carry',       'MOV AL,80h\nCLC\nRCL AL,1\nHLT',
            { AX: '0000', CF: 1 });

expectState('RCR through carry',       'MOV AL,1\nCLC\nRCR AL,1\nHLT',
            { AX: '0000', CF: 1 });

expectState('NEG sets carry',          'MOV AX,1\nNEG AX\nHLT',
            { AX: 'FFFF', CF: 1 });

expectState('memory actually retains', 'MOV AX,1234h\nMOV [100h],AX\nMOV BX,[100h]\nHLT',
            { BX: '1234' });

// -----------------------------------------------------------------------------
console.log('\nTHE TWENTY THAT ALREADY PASSED  (guard against regression)');
// -----------------------------------------------------------------------------
expectState('borrow',            'MOV AX,0\nSUB AX,1\nHLT',                 { AX: 'FFFF', CF: 1, SF: 1 });
expectState('MUL byte',          'MOV AL,10\nMOV BL,3\nMUL BL\nHLT',        { AX: '001E' });
expectState('MUL word into DX',  'MOV AX,1000h\nMOV BX,10h\nMUL BX\nHLT',   { AX: '0000', DX: '0001' });
expectState('DIV byte',          'MOV AX,100\nMOV BL,7\nDIV BL\nHLT',       { AX: '020E' });
expectState('PUSH and POP',      'MOV AX,1234h\nPUSH AX\nPOP BX\nHLT',      { BX: '1234', SP: 'FFFE' });
expectState('LOOP counts down',  'MOV CX,5\nMOV AX,0\nL1: INC AX\nLOOP L1\nHLT', { AX: '0005', CX: '0000' });
expectState('XCHG',              'MOV AX,1\nMOV BX,2\nXCHG AX,BX\nHLT',     { AX: '0002', BX: '0001' });
expectState('CMP then JZ',       'MOV AX,5\nCMP AX,5\nJZ D\nMOV AX,99\nD: HLT', { AX: '0005', ZF: 1 });
expectState('8-bit alias AL',    'MOV AX,1234h\nMOV AL,0FFh\nHLT',          { AX: '12FF' });
expectState('8-bit alias AH',    'MOV AX,1234h\nMOV AH,0ABh\nHLT',          { AX: 'AB34' });
expectState('AND clears CF/OF',  'MOV AX,0FFFFh\nSTC\nAND AX,0F0Fh\nHLT',   { AX: '0F0F', CF: 0, OF: 0 });
expectState('OR sets ZF and PF', 'MOV AX,0\nOR AX,0\nHLT',                  { AX: '0000', ZF: 1, PF: 1 });
expectState('XOR self clears',   'MOV AX,1234h\nXOR AX,AX\nHLT',            { AX: '0000', ZF: 1 });
expectState('NOT',               'MOV AX,0F0Fh\nNOT AX\nHLT',               { AX: 'F0F0' });
expectState('TEST does not write','MOV AX,0F0h\nTEST AX,0Fh\nHLT',          { AX: '00F0', ZF: 1 });
expectState('ADC adds the carry','MOV AX,1\nSTC\nADC AX,1\nHLT',            { AX: '0003' });
expectState('SBB subtracts it',  'MOV AX,5\nSTC\nSBB AX,1\nHLT',            { AX: '0003' });
expectState('JMP forward',       'JMP S\nMOV AX,99\nS: MOV AX,7\nHLT',      { AX: '0007' });
expectState('JC taken',          'STC\nJC T\nMOV AX,99\nT: MOV AX,1\nHLT',  { AX: '0001' });

// -----------------------------------------------------------------------------
console.log('\nBEYOND THE ORIGINAL BATTERY');
// -----------------------------------------------------------------------------
expectState('CALL and RET',
            'CALL SUB1\nMOV BX,7\nHLT\nSUB1: MOV AX,3\nRET',
            { AX: '0003', BX: '0007', SP: 'FFFE' });

expectState('nested calls unwind',
            'CALL A\nHLT\nA: CALL B\nRET\nB: MOV AX,9\nRET',
            { AX: '0009', SP: 'FFFE' });

expectState('signed comparison uses SF and OF',
            'MOV AX,-5\nCMP AX,3\nJL LESS\nMOV BX,0\nHLT\nLESS: MOV BX,1\nHLT',
            { BX: '0001' });

expectState('unsigned comparison uses CF',
            'MOV AX,0FFFFh\nCMP AX,3\nJA ABOVE\nMOV BX,0\nHLT\nABOVE: MOV BX,1\nHLT',
            { BX: '0001' });

expectState('LOOPNE stops on equality',
            'MOV CX,5\nMOV AX,0\nL: INC AX\nCMP AX,3\nLOOPNE L\nHLT',
            { AX: '0003' });

expectState('memory addressed through BX',
            'MOV BX,200h\nMOV AX,0ABCDh\nMOV [BX],AX\nMOV CX,[BX]\nHLT',
            { CX: 'ABCD' });

expectState('byte and word writes do not collide',
            'MOV BYTE PTR [300h],0FFh\nMOV AL,[300h]\nHLT',
            { AX: '00FF' });

expectState('indexed addressing',
            'MOV BX,100h\nMOV SI,4\nMOV AX,5555h\nMOV [BX+SI],AX\nMOV DX,[104h]\nHLT',
            { DX: '5555' });

expectState('LEA takes an address, not a value',
            '.DATA\nVAL DW 1234h\n.CODE\nLEA BX,VAL\nMOV AX,[BX]\nHLT',
            { BX: '0000', AX: '1234' });

expectState('data symbol reads its contents',
            '.DATA\nNUM DW 4321h\n.CODE\nMOV AX,NUM\nHLT',
            { AX: '4321' });

expectState('PUSHF and POPF round trip',
            'STC\nPUSHF\nCLC\nPOPF\nHLT',
            { CF: 1 });

expectState('XLAT indexes a table',
            '.DATA\nTBL DB 10h,20h,30h,40h\n.CODE\nMOV BX,0\nMOV AL,2\nXLAT\nHLT',
            { AX: '0030' });

expectState('CBW then IDIV handles negatives',
            'MOV AL,-15\nCBW\nMOV BL,3\nIDIV BL\nHLT',
            { AX: '00FB' });

// The three cases below are expected to FAIL to run, so they are checked
// through run() directly rather than expectState(), which assumes success.
{
    const state = run('FOOBAR AX,1\nHLT');
    check('unknown mnemonic reports clearly',
          state.ERROR?.includes('not a recognised 8086 instruction'), true);
}

// A misspelling should be named, because the message a reader gets is the
// difference between a two second fix and a puzzled minute.
{
    const state = run('MOVV AX,1\nHLT');
    check('a one letter slip is diagnosed', state.ERROR?.includes('Did you mean MOV?'), true);
}

{
    const state = run('PSUH AX\nHLT');
    check('two transposed letters are diagnosed',
          state.ERROR?.includes('Did you mean PUSH?'), true);
}

{
    // Nothing within two edits of this, so guessing would be worse than silence.
    const state = run('FLUGELHORN AX,1\nHLT');
    check('a word that resembles nothing gets no guess',
          state.ERROR?.includes('Did you mean'), false);
}

{
    const state = run('MOV AX,10\nMOV BL,0\nDIV BL\nHLT');
    check('divide by zero surfaces as interrupt 0',
          state.ERROR?.includes('interrupt 0'), true);
}

{
    const state = run('L: JMP L');
    check('an infinite loop is stopped, not hung',
          state.ERROR?.includes('never terminates'), true);
}

// -----------------------------------------------------------------------------
console.log('\nWHERE AN 8086 DIFFERS FROM EVERYTHING AFTER IT');
//
// These are the behaviours a later processor changed. Getting one of them wrong
// is invisible until somebody runs real period code against the emulator, and
// then it is very wrong indeed. Each is pinned here because an emulator claiming
// to be an 8086 has to be an 8086 and not a 386 with the new instructions taken
// out.
// -----------------------------------------------------------------------------

// PUSH SP stores the value SP holds AFTER the decrement. The 80286 changed this
// to store the original, and the difference was used for years to tell an 8086
// from a 286 at run time.
expectState('PUSH SP pushes the decremented value',
            'MOV SP,1000h\nPUSH SP\nPOP BX\nHLT',
            { BX: '0FFE', SP: '1000' });

expectState('but PUSH of anything else is unaffected',
            'MOV SP,1000h\nMOV AX,1234h\nPUSH AX\nPOP BX\nHLT',
            { BX: '1234', SP: '1000' });

// An 8086 does not mask the shift count. The 80186 onwards take it modulo 32, so
// a count of 33 shifts once there and thirty-three times here.
expectState('a shift count is not masked to five bits',
            'MOV AL,0FFh\nMOV CL,33\nSHL AL,CL\nHLT',
            { AX: '0000' });

// A count of zero must leave every flag exactly as it found them.
expectState('a shift of zero touches no flag',
            'STC\nMOV AL,0FFh\nMOV CL,0\nSHL AL,CL\nHLT',
            { AX: '00FF', CF: 1 });

// NOT is the one logical instruction that sets no flags at all.
expectState('NOT alters no flags',
            'STC\nMOV AX,0\nNOT AX\nHLT',
            { AX: 'FFFF', CF: 1, ZF: 0 });

// LOOP decrements before testing, so entering with zero goes all the way round.
expectState('LOOP entered with CX zero runs the full 65536 times',
            'MOV CX,0\nXOR AX,AX\nAGAIN: INC AX\nLOOP AGAIN\nHLT',
            { AX: '0000', CX: '0000' });

// Parity is taken from the low eight bits even when the operation was on a word.
expectState('parity comes from the low byte of a word result',
            'MOV AX,0FF00h\nOR AX,AX\nHLT',
            { PF: 1 });

expectState('and an odd low byte clears it',
            'MOV AX,0FF01h\nOR AX,AX\nHLT',
            { PF: 0 });

// A word at the very top of a segment wraps to offset zero for its high byte.
expectState('a word read at offset FFFFh wraps inside the segment',
            'MOV BX,0FFFFh\nMOV BYTE PTR [BX],0AAh\nMOV BYTE PTR [0],0BBh\nMOV AX,[BX]\nHLT',
            { AX: 'BBAA' });

// INC and DEC set every flag except the carry, which they leave alone. That is
// what makes them usable inside a multiple precision loop.
expectState('INC leaves the carry flag alone and sets the rest',
            'STC\nMOV AX,7FFFh\nINC AX\nHLT',
            { AX: '8000', CF: 1, OF: 1, SF: 1, ZF: 0 });

// AAM and AAD take an operand, and it does not have to be ten. Assemblers write
// ten when none is given, which hides the fact that the byte is there at all.
expectState('AAM works in a base other than ten',
            'MOV AL,0FFh\nAAM 16\nHLT',
            { AX: '0F0F' });

expectState('AAD works in a base other than ten',
            'MOV AX,0104h\nAAD 16\nHLT',
            { AX: '0014' });

// -----------------------------------------------------------------------------
console.log('\nDIAGNOSING AN UNRECOGNISED MNEMONIC');
//
// Three different things can be wrong and they need three different answers. A
// typing slip wants the nearest mnemonic. A real instruction from a later
// processor wants to be told so, because suggesting the nearest 8086 mnemonic
// for MOVZX sends somebody hunting for a typing mistake that is not there.
// Something unrecognisable wants no guess at all.
// -----------------------------------------------------------------------------
{
    const complain = mnemonic => run(`
.MODEL SMALL
.STACK 100H
.CODE
START:
    ${mnemonic}
    MOV AH, 4CH
    INT 21H
END START
`).ERROR ?? '';

    // ---- typing slips -------------------------------------------------------
    check('a substitution is diagnosed',   complain('MVO').includes('Did you mean MOV?'),   true);
    check('a transposition is diagnosed',  complain('PSUH').includes('Did you mean PUSH?'), true);
    check('an inserted letter is diagnosed', complain('XCHNG').includes('Did you mean XCHG?'), true);
    check('a doubled letter is diagnosed', complain('ADDD').includes('Did you mean ADD?'),  true);

    // Transposition is the commonest slip of all, and plain Levenshtein charges
    // two for it. Counting it as one is what lets MVO reach MOV before anything
    // else does.
    check('a transposition costs one, not two', editDistance('MVO', 'MOV'), 1);
    check('and an unrelated pair still costs two', editDistance('MVO', 'XOR') >= 2, true);

    // ---- instructions from later processors ---------------------------------
    const movzx = complain('MOVZX');

    check('a 386 instruction is named as such', movzx.includes('80386'), true);
    check('and is not passed off as a typing slip', movzx.includes('Did you mean'), false);
    check('and says what to write instead', movzx.includes('CBW') || movzx.includes('XOR AH'), true);

    check('a 186 instruction is recognised', complain('PUSHA').includes('80186'), true);
    check('the whole SETcc family is recognised', complain('SETNE').includes('80386'), true);
    check('the whole CMOVcc family is recognised', complain('CMOVGE').includes('Pentium Pro'), true);
    check('coprocessor instructions are recognised', complain('FSQRT').includes('8087'), true);

    // Some have no 8086 equivalent at all, and saying "use nothing" would be
    // worse than saying so plainly.
    check('an instruction with no equivalent says so',
          complain('CPUID').includes('no equivalent'), true);

    // ---- nothing worth guessing --------------------------------------------
    check('gibberish gets no suggestion', complain('ZZZZZ').includes('Did you mean'), false);
    check('and a suggestion sharing no opening letter is withheld',
          complain('QQ').includes('Did you mean'), false);
}

// -----------------------------------------------------------------------------
console.log('\nFILE SEEK AND RENAME  (INT 21h, 42h and 56h)');
// -----------------------------------------------------------------------------
{
    // Origin 2 with a zero offset is how a program asks how long a file is,
    // which is the commonest use of the call by some way.
    const measured = run(`
.MODEL SMALL
.STACK 100H
.DATA
    NAME_A  DB 'M.TXT', 0
    TEXT_W  DB '0123456789'
.CODE
START:
    MOV AX, @DATA
    MOV DS, AX
    LEA DX, NAME_A
    XOR CX, CX
    MOV AH, 3CH
    INT 21H
    MOV BX, AX
    LEA DX, TEXT_W
    MOV CX, 10
    MOV AH, 40H
    INT 21H
    MOV AX, 4202H
    XOR CX, CX
    XOR DX, DX
    INT 21H
    MOV SI, AX
    MOV DI, DX
    MOV AH, 4CH
    INT 21H
END START
`);

    check('seeking to the end returns the length', measured.SI, '000A');
    check('the high word of the position is zero', measured.DI, '0000');

    // Origin 1 is relative to where the position already is, which is what a
    // program skipping a record header uses.
    const relative = run(`
.MODEL SMALL
.STACK 100H
.DATA
    NAME_A  DB 'R.TXT', 0
    TEXT_W  DB 'ABCDEFGHIJ'
    BUF     DB 4 DUP (0)
.CODE
START:
    MOV AX, @DATA
    MOV DS, AX
    LEA DX, NAME_A
    XOR CX, CX
    MOV AH, 3CH
    INT 21H
    MOV BX, AX
    LEA DX, TEXT_W
    MOV CX, 10
    MOV AH, 40H
    INT 21H
    MOV AX, 4200H
    XOR CX, CX
    MOV DX, 2
    INT 21H
    MOV AX, 4201H
    XOR CX, CX
    MOV DX, 3
    INT 21H
    MOV SI, AX
    LEA DX, BUF
    MOV CX, 2
    MOV AH, 3FH
    INT 21H
    MOV DI, AX
    MOV AH, 4CH
    INT 21H
END START
`);

    check('a relative seek adds to the position', relative.SI, '0005');
    check('and the read that follows starts there', relative.DI, '0002');

    // A seek backwards past the start is refused rather than wrapping, and a
    // seek on a handle that was never opened is an invalid handle.
    const refused = run(`
.MODEL SMALL
.STACK 100H
.DATA
    NAME_A  DB 'B.TXT', 0
.CODE
START:
    MOV AX, @DATA
    MOV DS, AX
    LEA DX, NAME_A
    XOR CX, CX
    MOV AH, 3CH
    INT 21H
    MOV BX, AX
    MOV AX, 4200H
    MOV CX, 0FFFFH
    MOV DX, 0FFF0H
    INT 21H
    MOV SI, 0
    JNC NOT_REFUSED
    MOV SI, AX
NOT_REFUSED:
    MOV BX, 77
    MOV AX, 4200H
    XOR CX, CX
    XOR DX, DX
    INT 21H
    MOV DI, 0
    JNC NOT_BAD
    MOV DI, AX
NOT_BAD:
    MOV AH, 4CH
    INT 21H
END START
`);

    check('a seek before the start is refused', refused.SI, '0001');
    check('a seek on an unopened handle is an invalid handle', refused.DI, '0006');

    // A rename moves the file: the old name must stop working and the contents
    // must survive under the new one.
    const renamed = run(`
.MODEL SMALL
.STACK 100H
.DATA
    OLD_N   DB 'OLD.TXT', 0
    NEW_N   DB 'NEW.TXT', 0
    TEXT_W  DB 'KEEP'
    BUF     DB 4 DUP (0)
.CODE
START:
    MOV AX, @DATA
    MOV DS, AX
    MOV ES, AX
    LEA DX, OLD_N
    XOR CX, CX
    MOV AH, 3CH
    INT 21H
    MOV BX, AX
    LEA DX, TEXT_W
    MOV CX, 4
    MOV AH, 40H
    INT 21H
    MOV AH, 3EH
    INT 21H
    LEA DX, OLD_N
    LEA DI, NEW_N
    MOV AH, 56H
    INT 21H
    MOV AX, 3D00H
    LEA DX, OLD_N
    INT 21H
    MOV SI, 0
    JNC OLD_OPENED
    MOV SI, AX
OLD_OPENED:
    MOV AX, 3D00H
    LEA DX, NEW_N
    INT 21H
    MOV BX, AX
    LEA DX, BUF
    MOV CX, 4
    MOV AH, 3FH
    INT 21H
    MOV DI, AX
    MOV AH, 4CH
    INT 21H
END START
`);

    check('the old name no longer opens', renamed.SI, '0002');
    check('the contents survive under the new name', renamed.DI, '0004');

    // Renaming onto a name already in use is refused, so the other file cannot
    // be destroyed by accident.
    const clash = run(`
.MODEL SMALL
.STACK 100H
.DATA
    ONE_N   DB 'ONE.TXT', 0
    TWO_N   DB 'TWO.TXT', 0
.CODE
START:
    MOV AX, @DATA
    MOV DS, AX
    MOV ES, AX
    LEA DX, ONE_N
    XOR CX, CX
    MOV AH, 3CH
    INT 21H
    MOV BX, AX
    MOV AH, 3EH
    INT 21H
    LEA DX, TWO_N
    XOR CX, CX
    MOV AH, 3CH
    INT 21H
    MOV BX, AX
    MOV AH, 3EH
    INT 21H
    LEA DX, ONE_N
    LEA DI, TWO_N
    MOV AH, 56H
    INT 21H
    MOV SI, 0
    JNC NO_CLASH
    MOV SI, AX
NO_CLASH:
    LEA DX, ONE_N
    LEA DI, ONE_N
    MOV AH, 56H
    INT 21H
    MOV AH, 4CH
    INT 21H
END START
`);

    check('renaming onto an existing name is access denied', clash.SI, '0005');
}

// -----------------------------------------------------------------------------
console.log(`\n${passed} passed, ${failed} failed\n`);
process.exit(failed === 0 ? 0 : 1);
