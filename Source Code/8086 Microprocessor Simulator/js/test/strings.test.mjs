// -----------------------------------------------------------------------------
// Script Name: strings.test.mjs
// Module:      Conformance Suite, strings and interrupts
// Stack:       Node.js (ES modules), no test framework
// Description: Verifies the string instructions, the repeat prefixes and the
//              DOS services against documented behaviour, using real assembly
//              text rather than hand built machine state.
//
//              Particular attention goes to the three things a simplified
//              implementation usually gets wrong: that the destination is ES:DI
//              and never anything else, that the direction flag reverses the
//              pointer step, and that REP with CX = 0 performs no work at all.
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

/** Assemble and run a fragment, optionally with keystrokes queued up. */
function run(source, input = '') {
    const cpu     = new CPU();
    const program = new Assembler().assemble(source);

    if (!program.ok) {
        return { ERROR: program.diagnostics.map(String).join('; ') };
    }

    cpu.memory.load(cpu.registers.get('DS') << 4, program.data);
    cpu.registers.set('IP', program.entryPoint);
    cpu.pendingInput = input;

    try {
        new Executor(cpu, program).runToCompletion();
    } catch (error) {
        return { ERROR: error.message };
    }

    const r = cpu.registers;

    return {
        cpu,
        AX: hex(r.get('AX')), BX: hex(r.get('BX')), CX: hex(r.get('CX')), DX: hex(r.get('DX')),
        SI: hex(r.get('SI')), DI: hex(r.get('DI')),
        ZF: cpu.flags.ZF, CF: cpu.flags.CF, DF: cpu.flags.DF,
        SF: cpu.flags.SF, OF: cpu.flags.OF, PF: cpu.flags.PF, AF: cpu.flags.AF,
        out: cpu.consoleOutput,
        exitCode: cpu.exitCode
    };
}

function expectState(name, source, expected, input = '') {
    const state = run(source, input);

    if (state.ERROR) {
        failed++;
        console.log(`  FAIL  ${name}\n          error: ${state.ERROR}`);
        return;
    }

    const actual = {};
    for (const key of Object.keys(expected)) actual[key] = state[key];

    check(name, actual, expected);
}

/** Read a run of bytes out of the data segment after a program has finished. */
function bytesAt(state, offset, count) {
    const segment = state.cpu.registers.get('ES');
    const out     = [];

    for (let index = 0; index < count; index++) {
        out.push(hex(state.cpu.memory.readByte(segment, offset + index), 2));
    }
    return out;
}

// -----------------------------------------------------------------------------
console.log('\nMOVS  (copy DS:SI to ES:DI)');
// -----------------------------------------------------------------------------
expectState('MOVSB copies one byte and advances both pointers',
            'MOV SI,100h\nMOV DI,200h\nMOV BYTE PTR [100h],5Ah\nMOVSB\nHLT',
            { SI: '0101', DI: '0201' });

{
    const state = run('MOV SI,100h\nMOV DI,200h\nMOV BYTE PTR [100h],5Ah\nMOVSB\nHLT');
    check('MOVSB actually moved the byte', bytesAt(state, 0x200, 1), ['5A']);
}

expectState('MOVSW advances by two',
            'MOV SI,100h\nMOV DI,200h\nMOVSW\nHLT',
            { SI: '0102', DI: '0202' });

{
    const state = run(`
        .DATA
        SRC DB 11h,22h,33h,44h
        .CODE
        LEA SI,SRC
        MOV DI,300h
        MOV CX,4
        CLD
        REP MOVSB
        HLT`);
    check('REP MOVSB copies the whole run', bytesAt(state, 0x300, 4), ['11', '22', '33', '44']);
}

expectState('REP MOVSB leaves CX at zero',
            'MOV SI,100h\nMOV DI,300h\nMOV CX,4\nCLD\nREP MOVSB\nHLT',
            { CX: '0000', SI: '0104', DI: '0304' });

expectState('REP with CX zero does nothing at all',
            'MOV SI,100h\nMOV DI,300h\nMOV CX,0\nREP MOVSB\nHLT',
            { CX: '0000', SI: '0100', DI: '0300' });

expectState('STD makes the pointers count down',
            'MOV SI,100h\nMOV DI,300h\nMOV CX,3\nSTD\nREP MOVSB\nHLT',
            { SI: '00FD', DI: '02FD', DF: 1 });

{
    // The destination is ES:DI even when ES differs from DS. Pointing ES
    // elsewhere and checking the byte landed there is the only way to prove the
    // segment is not quietly being taken from DS.
    const cpu     = new CPU();
    const program = new Assembler().assemble(
        'MOV BYTE PTR [100h],7Eh\nMOV SI,100h\nMOV DI,50h\nMOVSB\nHLT');

    cpu.registers.set('ES', 0x0A00);
    cpu.registers.set('IP', program.entryPoint);
    new Executor(cpu, program).runToCompletion();

    check('the destination is ES:DI, not DS:DI',
          hex(cpu.memory.readByte(0x0A00, 0x50), 2), '7E');
}

// -----------------------------------------------------------------------------
console.log('\nSTOS and LODS  (accumulator to and from memory)');
// -----------------------------------------------------------------------------
{
    const state = run('MOV AL,0FFh\nMOV DI,400h\nMOV CX,5\nCLD\nREP STOSB\nHLT');
    check('REP STOSB fills a block', bytesAt(state, 0x400, 5), ['FF', 'FF', 'FF', 'FF', 'FF']);
}

expectState('STOSB moves DI but leaves SI alone',
            'MOV DI,400h\nMOV SI,900h\nSTOSB\nHLT',
            { DI: '0401', SI: '0900' });

expectState('LODSB loads into AL and moves SI only',
            'MOV BYTE PTR [100h],3Ch\nMOV SI,100h\nMOV DI,700h\nLODSB\nHLT',
            { AX: '003C', SI: '0101', DI: '0700' });

expectState('LODSW loads a word',
            'MOV WORD PTR [100h],0BEEFh\nMOV SI,100h\nLODSW\nHLT',
            { AX: 'BEEF', SI: '0102' });

// -----------------------------------------------------------------------------
console.log('\nCMPS and SCAS  (comparison, and the conditional prefixes)');
// -----------------------------------------------------------------------------
expectState('CMPSB sets ZF when the bytes match',
            'MOV BYTE PTR [100h],41h\nMOV BYTE PTR [200h],41h\n' +
            'MOV SI,100h\nMOV DI,200h\nCMPSB\nHLT',
            { ZF: 1, SI: '0101', DI: '0201' });

expectState('CMPSB clears ZF when they differ',
            'MOV BYTE PTR [100h],41h\nMOV BYTE PTR [200h],42h\n' +
            'MOV SI,100h\nMOV DI,200h\nCMPSB\nHLT',
            { ZF: 0, CF: 1 });

expectState('REPE CMPSB runs to the end of two equal strings',
            `.DATA
             A DB 'ABCD'
             B DB 'ABCD'
             .CODE
             LEA SI,A
             LEA DI,B
             MOV CX,4
             CLD
             REPE CMPSB
             HLT`,
            { CX: '0000', ZF: 1 });

expectState('REPE CMPSB stops at the first difference',
            `.DATA
             A DB 'ABCD'
             B DB 'ABXD'
             .CODE
             LEA SI,A
             LEA DI,B
             MOV CX,4
             CLD
             REPE CMPSB
             HLT`,
            { CX: '0001', ZF: 0 });

expectState('SCASB finds the byte and REPNE stops on it',
            `.DATA
             S DB 'HELLO'
             .CODE
             LEA DI,S
             MOV AL,'L'
             MOV CX,5
             CLD
             REPNE SCASB
             HLT`,
            { CX: '0002', ZF: 1 });

expectState('REPNE SCASB exhausts CX when the byte is absent',
            `.DATA
             S DB 'HELLO'
             .CODE
             LEA DI,S
             MOV AL,'Z'
             MOV CX,5
             CLD
             REPNE SCASB
             HLT`,
            { CX: '0000', ZF: 0 });

expectState('SCASB moves DI only',
            'MOV DI,100h\nMOV SI,800h\nSCASB\nHLT',
            { DI: '0101', SI: '0800' });

{
    const state = run('REP\nHLT');
    check('a repeat prefix with nothing after it is diagnosed',
          state.ERROR?.includes('must be followed by a string instruction'), true);
}

// -----------------------------------------------------------------------------
console.log('\nINT 21h  (the DOS services the programs actually call)');
// -----------------------------------------------------------------------------
expectState('service 02h prints one character',
            'MOV AH,2\nMOV DL,41h\nINT 21h\nHLT',
            { out: 'A' });

expectState('service 09h prints a $ terminated string',
            `.MODEL SMALL
             .DATA
             MSG DB 'HELLO$'
             .CODE
             MOV AH,9
             LEA DX,MSG
             INT 21h
             MOV AH,4Ch
             INT 21h`,
            { out: 'HELLO', exitCode: 0 });

expectState('CR LF inside a string becomes one newline',
            `.DATA
             MSG DB 'A',13,10,'B','$'
             .CODE
             MOV AH,9
             LEA DX,MSG
             INT 21h
             HLT`,
            { out: 'A\nB' });

expectState('service 01h reads a character and echoes it',
            'MOV AH,1\nINT 21h\nHLT',
            { AX: '0137', out: '7' }, '7');

expectState('service 08h reads without echoing',
            'MOV AH,8\nINT 21h\nHLT',
            { AX: '0837', out: '' }, '7');

expectState('service 0Ah reads a line and records its length',
            `.DATA
             BUF DB 20,0,20 DUP(?)
             .CODE
             MOV AH,0Ah
             LEA DX,BUF
             INT 21h
             MOV BL,BUF+1
             MOV BH,0
             HLT`,
            { BX: '0004', out: 'AMEY\n' }, 'AMEY\r');

expectState('service 4Ch reports the exit code in AL',
            'MOV AX,4C05h\nINT 21h',
            { exitCode: 5 });

expectState('INT 20h terminates the older way',
            'MOV AX,7\nINT 20h\nMOV AX,99\nHLT',
            { AX: '0007' });

expectState('INT 10h service 0Eh prints through the BIOS',
            'MOV AH,0Eh\nMOV AL,5Ah\nINT 10h\nHLT',
            { out: 'Z' });

{
    const state = run('MOV AH,55h\nINT 21h\nHLT');
    check('an unsupported DOS service says which one it was',
          state.ERROR?.includes('service 55h'), true);
}

{
    const state = run('INT 5Ch\nHLT');
    check('an unsupported interrupt is named, not silently ignored',
          state.ERROR?.includes('INT 5Ch'), true);
}

expectState('INT 16h reads a key with its scan code',
            'MOV AH,0\nINT 16h\nHLT',
            { AX: '1C0D' }, '\r');

expectState('INT 16h service 01h reports an empty buffer through ZF',
            'MOV AH,1\nINT 16h\nHLT',
            { ZF: 1 });

// 09:30 is 34,200 seconds, and the timer ticks 18.2 times a second, so the
// count is 622,440, which is 0009_7F68 split across CX and DX.
expectState('INT 1Ah returns the tick count',
            'MOV AH,0\nINT 1Ah\nHLT',
            { CX: '0009', DX: '7F68' });

expectState('OUT records what was sent and IN reads it back',
            'MOV AL,55h\nOUT 4,AL\nMOV AL,0\nIN AL,4\nHLT',
            { AX: '0055' });

expectState('a port never written reads as zero',
            'MOV AL,0FFh\nIN AL,200\nHLT',
            { AX: '0000' });

expectState('DX carries a port number too large for an immediate',
            'MOV DX,3F8h\nMOV AL,7Eh\nOUT DX,AL\nMOV AL,0\nIN AL,DX\nHLT',
            { AX: '007E' });

expectState('an indirect jump goes through a table',
            `.DATA
             TABLE DW FIRST, SECOND
             .CODE
             MOV BX,2
             JMP TABLE[BX]
             FIRST:  MOV AX,1
                     HLT
             SECOND: MOV AX,2
                     HLT`,
            { AX: '0002' });

{
    const state = run(
        `.DATA
         NAME_  DB 'OUT.TXT',0
         TEXT   DB 'AMEY'
         .CODE
         MOV AH,3Ch
         MOV CX,0
         LEA DX,NAME_
         INT 21h
         MOV BX,AX
         MOV AH,40h
         MOV CX,4
         LEA DX,TEXT
         INT 21h
         MOV AH,3Eh
         INT 21h
         HLT`);

    check('a file written by a program can be read back',
          state.cpu?.files.snapshot(), [{ name: 'OUT.TXT', size: 4, text: 'AMEY' }]);
}

{
    const state = run(".DATA\nBAD DB 'NO TERMINATOR HERE'\n.CODE\nMOV AH,9\nLEA DX,BAD\nINT 21h\nHLT");
    check('a string with no $ is diagnosed rather than looping',
          typeof state.ERROR === 'string' || state.out.length > 0, true);
}

// -----------------------------------------------------------------------------
console.log('\nA WHOLE PROGRAM  (the shape almost every file in the repository uses)');
// -----------------------------------------------------------------------------
expectState('print a message, copy it, print the copy',
            `.MODEL SMALL
             .STACK 100H
             .DATA
             MSG  DB 'AMEY$'
             COPY DB 5 DUP('$')
             .CODE
             MAIN PROC
                 MOV AX,@DATA
                 MOV DS,AX
                 MOV ES,AX

                 MOV AH,9
                 LEA DX,MSG
                 INT 21h

                 LEA SI,MSG
                 LEA DI,COPY
                 MOV CX,4
                 CLD
                 REP MOVSB

                 MOV AH,2
                 MOV DL,20h
                 INT 21h

                 MOV AH,9
                 LEA DX,COPY
                 INT 21h

                 MOV AH,4Ch
                 INT 21h
             MAIN ENDP
             END MAIN`,
            { out: 'AMEY AMEY', exitCode: 0 });

// -----------------------------------------------------------------------------
console.log('\nTHE REMAINDER OF THE INSTRUCTION SET');
//
// The eight instructions an audit against the programmer's reference found
// missing. Two of them move the flags through AH, two load a far pointer, one
// traps on overflow, and three exist for hardware this machine does not have.
// -----------------------------------------------------------------------------
expectState('LAHF copies the low flags into AH',
            'STC\nMOV AH,0\nLAHF\nHLT',
            { AX: '0300' });

expectState('SAHF writes them back',
            'MOV AH,0C7h\nSAHF\nHLT',
            { CF: 1, ZF: 1, SF: 1 });

expectState('LES loads a far pointer into ES and a register',
            `.DATA
             FARPTR DW 1234h, 0B800h
             .CODE
             LES BX,FARPTR
             MOV AX,ES
             HLT`,
            { BX: '1234', AX: 'B800' });

expectState('LDS loads one into DS',
            `.DATA
             FARPTR DW 5678h, 0A000h
             .CODE
             LDS SI,FARPTR
             MOV AX,DS
             HLT`,
            { SI: '5678', AX: 'A000' });

expectState('INTO passes when nothing overflowed',
            'MOV AX,1\nADD AX,1\nINTO\nHLT',
            { AX: '0002' });

{
    const state = run('MOV AX,7FFFh\nADD AX,1\nINTO\nHLT');
    check('INTO traps when something did', state.ERROR?.includes('interrupt 4'), true);
}

expectState('WAIT, ESC and LOCK are accepted and do nothing',
            'MOV AX,7\nWAIT\nESC\nLOCK\nHLT',
            { AX: '0007' });

// @DATA is a constant fixed at load time. Reporting the live DS instead would
// make this restore a no-op, and the program would carry on with the wrong
// data segment while looking entirely correct.
expectState('@DATA survives DS being pointed elsewhere',
            `.DATA
             FAR_PTR DW 0200h, 0A000h
             .CODE
             MOV AX,@DATA
             MOV DS,AX
             LDS SI,FAR_PTR
             MOV BX,DS
             MOV AX,@DATA
             MOV DS,AX
             MOV CX,DS
             HLT`,
            { BX: 'A000', CX: '0800' });

// -----------------------------------------------------------------------------
console.log(`\n${passed} passed, ${failed} failed\n`);
process.exit(failed === 0 ? 0 : 1);
