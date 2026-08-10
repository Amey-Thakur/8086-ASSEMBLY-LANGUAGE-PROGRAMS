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
import { Executor }  from '../exec/executor.js';

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
console.log(`\n${passed} passed, ${failed} failed\n`);
process.exit(failed === 0 ? 0 : 1);
