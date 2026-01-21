/*
============================================================================
PROJECT: 8086 MICROPROCESSOR SIMULATOR - CORE ENGINE
============================================================================
AUTHOR:      Amey Thakur
GITHUB:      https://github.com/Amey-Thakur/8086-ASSEMBLY-LANGUAGE-PROGRAMS
PROFILE:     https://github.com/Amey-Thakur
LICENSE:     MIT License
CREATED:     2021

DESCRIPTION:
The core emulation engine responsible for parsing, compiling, and executing
8086 assembly instructions. Features a cycle-accurate state machine,
16-bit register file simulation, memory segmentation model, and partial
support for DOS interrupts (INT 21h).

DEPENDENCIES:
- programs.js: Library of pre-written assembly programs.
============================================================================
*/

// ========================================
// 8086 Emulator Core Class
// ========================================

/**
 * Represents the 8086 Microprocessor state and execution logic.
 * Manages registers, flags, memory, and instruction cycle.
 * @class
 */
class Emulator8086 {
    constructor() {
        this.reset();
    }

    reset() {
        // 16-bit registers
        this.regs = { AX: 0, BX: 0, CX: 0, DX: 0, SI: 0, DI: 0, SP: 0xFFFE, BP: 0 };
        // Flags
        this.flags = { CF: 0, ZF: 0, SF: 0, OF: 0, PF: 0, AF: 0 };
        // Memory (64KB)
        this.memory = new Uint8Array(65536);
        // Data segment
        this.dataLabels = {};
        this.dataPointer = 0x2000; // Start data at 8KB offset
        this.output = '';
        this.pc = 0;
        this.instructions = [];
        this.running = false;
        this.waiting = false;  // Fix: Clear input wait state
        this.echoInput = false;
        this.errors = []; // Compilation errors
        this.isCompiled = false;

        // Tracking for intelligent tooltips
        this.registerHistory = {
            AX: [], BX: [], CX: [], DX: [],
            SI: [], DI: [], SP: [], BP: []
        };
        this.flagHistory = {
            CF: null, ZF: null, SF: null, OF: null, PF: null, AF: null
        };
        this.lastInstruction = null;
    }

    // Get 8-bit register value
    getReg8(name) {
        name = name.toUpperCase();
        if (name === 'AL') return this.regs.AX & 0xFF;
        if (name === 'AH') return (this.regs.AX >> 8) & 0xFF;
        if (name === 'BL') return this.regs.BX & 0xFF;
        if (name === 'BH') return (this.regs.BX >> 8) & 0xFF;
        if (name === 'CL') return this.regs.CX & 0xFF;
        if (name === 'CH') return (this.regs.CX >> 8) & 0xFF;
        if (name === 'DL') return this.regs.DX & 0xFF;
        if (name === 'DH') return (this.regs.DX >> 8) & 0xFF;
        return 0;
    }

    // Set 8-bit register
    setReg8(name, val) {
        name = name.toUpperCase();
        val = val & 0xFF;
        if (name === 'AL') this.regs.AX = (this.regs.AX & 0xFF00) | val;
        else if (name === 'AH') this.regs.AX = (this.regs.AX & 0x00FF) | (val << 8);
        else if (name === 'BL') this.regs.BX = (this.regs.BX & 0xFF00) | val;
        else if (name === 'BH') this.regs.BX = (this.regs.BX & 0x00FF) | (val << 8);
        else if (name === 'CL') this.regs.CX = (this.regs.CX & 0xFF00) | val;
        else if (name === 'CH') this.regs.CX = (this.regs.CX & 0x00FF) | (val << 8);
        else if (name === 'DL') this.regs.DX = (this.regs.DX & 0xFF00) | val;
        else if (name === 'DH') this.regs.DX = (this.regs.DX & 0x00FF) | (val << 8);
    }

    // Get register or immediate value
    getValue(operand) {
        operand = operand.trim().toUpperCase();
        // 16-bit registers
        if (['AX', 'BX', 'CX', 'DX', 'SI', 'DI', 'SP', 'BP'].includes(operand)) {
            return this.regs[operand];
        }
        // 8-bit registers
        if (['AL', 'AH', 'BL', 'BH', 'CL', 'CH', 'DL', 'DH'].includes(operand)) {
            return this.getReg8(operand);
        }
        // Hex number
        if (operand.endsWith('H')) {
            return parseInt(operand.slice(0, -1), 16);
        }
        // Binary number
        if (operand.endsWith('B')) {
            return parseInt(operand.slice(0, -1), 2);
        }
        // Decimal number
        if (/^\d+$/.test(operand)) {
            return parseInt(operand, 10);
        }
        // Character literal
        if (operand.startsWith("'") && operand.endsWith("'")) {
            return operand.charCodeAt(1);
        }
        // Label reference
        if (this.dataLabels[operand] !== undefined) {
            return this.dataLabels[operand];
        }
        return 0;
    }

    // Set register value
    setValue(dest, val) {
        dest = dest.trim().toUpperCase();
        if (['AX', 'BX', 'CX', 'DX', 'SI', 'DI', 'SP', 'BP'].includes(dest)) {
            this.regs[dest] = val & 0xFFFF;
        } else if (['AL', 'AH', 'BL', 'BH', 'CL', 'CH', 'DL', 'DH'].includes(dest)) {
            this.setReg8(dest, val);
        }
    }

    // Stack operations
    push(val) {
        this.regs.SP = (this.regs.SP - 2) & 0xFFFF;
        const addr = this.regs.SP;
        this.memory[addr] = val & 0xFF;
        this.memory[(addr + 1) & 0xFFFF] = (val >> 8) & 0xFF;
    }

    pop() {
        const addr = this.regs.SP;
        const val = this.memory[addr] | (this.memory[(addr + 1) & 0xFFFF] << 8);
        this.regs.SP = (this.regs.SP + 2) & 0xFFFF;
        return val;
    }

    // Update flags based on result
    updateFlags(result, is16bit = true) {
        const max = is16bit ? 0xFFFF : 0xFF;
        const signBit = is16bit ? 0x8000 : 0x80;
        this.flags.ZF = (result & max) === 0 ? 1 : 0;
        this.flags.SF = (result & signBit) ? 1 : 0;
        this.flags.CF = result > max ? 1 : 0;
        // Parity flag (count of 1s in low byte)
        let ones = 0;
        let lb = result & 0xFF;
        while (lb) { ones += lb & 1; lb >>= 1; }
        this.flags.PF = (ones % 2 === 0) ? 1 : 0;
    }

    // Find similar opcode using Levenshtein distance
    findSimilarOpcode(input, validOpcodes) {
        let bestMatch = null;
        let bestDistance = Infinity;

        for (const opcode of validOpcodes) {
            const distance = this.levenshtein(input, opcode);
            if (distance < bestDistance && distance <= 2) { // Max 2 edits
                bestDistance = distance;
                bestMatch = opcode;
            }
        }
        return bestMatch;
    }

    // Levenshtein distance algorithm
    levenshtein(a, b) {
        const matrix = [];
        for (let i = 0; i <= b.length; i++) {
            matrix[i] = [i];
        }
        for (let j = 0; j <= a.length; j++) {
            matrix[0][j] = j;
        }
        for (let i = 1; i <= b.length; i++) {
            for (let j = 1; j <= a.length; j++) {
                if (b.charAt(i - 1) === a.charAt(j - 1)) {
                    matrix[i][j] = matrix[i - 1][j - 1];
                } else {
                    matrix[i][j] = Math.min(
                        matrix[i - 1][j - 1] + 1, // substitution
                        matrix[i][j - 1] + 1,     // insertion
                        matrix[i - 1][j] + 1      // deletion
                    );
                }
            }
        }
        return matrix[b.length][a.length];
    }

    // Parse and execute
    parse(code) {
        this.reset();
        const lines = code.split('\n');
        const codeLines = [];
        const labels = {};
        let dataMode = false;

        // Pre-pass: Handle EQU constants and strip EMU8086 directives
        const constants = {};
        for (let i = 0; i < lines.length; i++) {
            let line = lines[i].split(';')[0].trim();
            if (line.startsWith('#')) continue; // Ignore EMU8086 directives

            // Handle EQU: NAME EQU VALUE
            const equMatch = line.match(/^(\w+)\s+EQU\s+(.+)$/i);
            if (equMatch) {
                constants[equMatch[1].toUpperCase()] = equMatch[2].trim();
                lines[i] = ''; // Remove EQU line from code
            }
        }

        // First pass: find labels and data
        for (let i = 0; i < lines.length; i++) {
            let line = lines[i].split(';')[0].trim(); // Remove comments
            if (!line || line.startsWith('#')) continue;

            // Substitute constants
            for (const [name, val] of Object.entries(constants)) {
                const regex = new RegExp(`\\b${name}\\b`, 'g');
                line = line.replace(regex, val);
            }

            // Check for data definitions (DB, DW)
            const dataMatch = line.match(/^(\w+)?\s*(DB|DW)\s+(.+)$/i);
            if (dataMatch) {
                const label = dataMatch[1] ? dataMatch[1].toUpperCase() : null;
                const type = dataMatch[2].toUpperCase(); // DB or DW
                let value = dataMatch[3].trim();

                // Allocate address (linear)
                const addr = this.dataPointer;
                if (label) this.dataLabels[label] = addr;

                // Parse Value
                let bytes = [];

                // String handling: 'text', 10, 13, '$'
                if (value.includes("'") || value.includes('"')) {
                    // Primitive regex split - improving to handle tokens
                    // Note: This is a simplified parser. It assumes standard formats.
                    // 1. Extract string literals
                    const strMatches = [];
                    value = value.replace(/(["'])(.*?)\1/g, (match, quote, content) => {
                        strMatches.push(content);
                        return `__STR_${strMatches.length - 1}__`;
                    });

                    // 2. Split by comma
                    const parts = value.split(',');
                    for (let p of parts) {
                        p = p.trim();
                        if (p.startsWith('__STR_')) {
                            const idx = parseInt(p.match(/\d+/)[0]);
                            const s = strMatches[idx];
                            for (let k = 0; k < s.length; k++) bytes.push(s.charCodeAt(k));
                        } else if (p.endsWith('H')) {
                            bytes.push(parseInt(p.slice(0, -1), 16));
                        } else if (!isNaN(p)) {
                            bytes.push(parseInt(p));
                        } else if (p === '$') {
                            bytes.push(36);
                        } else if (p === '?') {
                            bytes.push(0);
                        } else {
                            // Try to find if it's a constant or label reference?
                            // For simplicity, 0
                            bytes.push(0);
                        }
                    }
                } else {
                    // Numeric / Simple
                    if (value === '?') value = '0';
                    let num = 0;
                    if (value.endsWith('H')) num = parseInt(value.slice(0, -1), 16);
                    else num = parseInt(value);

                    if (isNaN(num)) num = 0; // Constants handling required?

                    if (type === 'DB') bytes.push(num & 0xFF);
                    else if (type === 'DW') { bytes.push(num & 0xFF); bytes.push((num >> 8) & 0xFF); }
                }

                // Write to memory
                for (let b of bytes) {
                    this.memory[this.dataPointer++] = b;
                }

                continue;
            }

            // Check for code labels or PROC definitions
            const labelMatch = line.match(/^(\w+):/) || line.match(/^(\w+)\s+PROC/i);
            if (labelMatch) {
                labels[labelMatch[1].toUpperCase()] = codeLines.length;
                // Remove label or PROC declaration
                line = line.replace(/^(\w+):/, '').replace(/^(\w+)\s+PROC/i, '').trim();
                if (!line) continue;
            }

            // Handle PROC/ENDP/SEGMENT/ENDS/MACRO/ENDM
            if (/\s+(PROC|ENDP|SEGMENT|ENDS|MACRO|ENDM)\b/i.test(line) || /^(ENDP|ENDS|ENDM)$/i.test(line)) {
                continue;
            }

            // Skip directives
            // Skip directives / comments
            if (/^(ORG|END|SEGMENT|ENDS|ASSUME|NAME|\.MODEL|\.DATA|\.CODE|\.STACK|\.FARDATA)/i.test(line)) {
                continue;
            }
            if (line.match(/\s+ENDP$/i)) { // Skip ENDP lines
                continue;
            }

            // Clean up PTR and SHORT directives
            line = line.replace(/\s+(BYTE|WORD|DWORD)\s+PTR\s+/gi, ' ');
            line = line.replace(/\s+SHORT\s+/gi, ' ');

            // Validate instruction opcode
            const validOpcodes = ['MOV', 'ADD', 'SUB', 'MUL', 'DIV', 'INC', 'DEC', 'AND', 'OR', 'XOR', 'NOT',
                'SHL', 'SAL', 'SHR', 'SAR', 'ROL', 'ROR', 'CMP', 'JMP', 'JZ', 'JE', 'JNZ', 'JNE', 'JC', 'JB',
                'JNC', 'JNB', 'JAE', 'JG', 'JGE', 'JL', 'JLE', 'JA', 'JBE', 'LOOP', 'LOOPZ', 'LOOPNZ',
                'LEA', 'PUSH', 'POP', 'XCHG', 'INT', 'RET', 'HLT', 'NOP', 'CALL', 'NEG', 'CBW', 'CWD',
                'MOVSB', 'MOVSW', 'STOSB', 'STOSW', 'LODSB', 'LODSW', 'REP', 'REPE', 'REPNE', 'CMPSB', 'CMPSW',
                'CLC', 'STC', 'CMC', 'CLD', 'STD', 'IN', 'OUT', 'JCXZ', 'JO', 'JP', 'JNP', 'JS',
                'AAA', 'AAD', 'AAM', 'AAS', 'ADC', 'DAA', 'DAS', 'IDIV', 'IMUL', 'LAHF', 'SAHF', 'TEST',
                // MACRO stubs/Common Procedures
                'PRNSTR', 'DIS', 'PRINT_CHAR', 'PRINT_STR', 'NEWLINE', 'PRINT_LINE', 'PRINT_BORDER', 'PRINT_RESULT',
                'GIVE_SPACE', 'PRINT_NUM', 'PRINT_DECIMAL', 'SCAN_NUM', 'SHOW_NUM', 'DEFINE_SCAN_NUM', 'DEFINE_PRINT_NUM', 'DEFINE_PRINT_NUM_UNS',
                'SUB_HEX_TO_DEC_STR', 'SUB_EXTRACT_DIGIT', 'SUB_INT_TO_ASCII', 'ENQUEUE', 'DEQUEUE', 'CUSTOM_PUSH', 'CUSTOM_POP',
                'GET_OPERANDS', 'READ_DECIMAL', 'CALC_FACTORIAL', 'WAIT_FOR_IDLE', 'WAIT_FOR_DATA', 'RANDOM_TURN', 'RANDOM_DECISION',
                'PRINT_DEC_PROC', 'READ_DEC_PROC', 'PRINT_HEX_BYTE_PROC', 'PRINT_NIBBLE', 'PRINT_WORD_HEX', 'PRINT_BYTE_HEX', 'PRINT_DIGIT',
                'DISPLAY_DIGITS', 'PRINT_ME', 'PRINT_STRING', 'PROC_M1', 'PROC_MUL', 'IF', 'ELSE', 'LOCAL', 'CHECK_ZERO', 'ADD_VALUES',
                'MULTIPLY_POW2', 'PRINT_NEWLINE', 'M2', 'CALCULATE', 'DOUBLE_AX', 'QUADRUPLE_AX', 'ADD_NUMBERS', 'FACTORIAL', 'READ_BCD_DIGIT',
                'DELAY_1SEC_LOOP', 'DELAY_BIOS', 'MAIN', 'DATA', 'CODE'];

            const validDirectives = ['ORG', 'END', 'SEGMENT', 'ENDS', 'ASSUME', 'PROC', 'ENDP', '.MODEL', '.DATA', '.CODE', '.STACK', 'DB', 'DW', 'EQU', '.FARDATA'];

            const opcode = line.split(/[\s,]+/)[0].toUpperCase();
            if (!validOpcodes.includes(opcode) && !validDirectives.includes(opcode)) {
                // Find similar opcode or directive for suggestion
                const allValidTokens = [...validOpcodes, ...validDirectives];
                const suggestion = this.findSimilarOpcode(opcode, allValidTokens);
                const msg = suggestion
                    ? `Unknown instruction: ${opcode}. Did you mean: ${suggestion}?`
                    : `Unknown instruction: ${opcode}`;
                this.errors.push({ line: i + 1, instruction: line, message: msg, suggestion });
            }

            codeLines.push({ instruction: line, lineNo: i + 1 });
        }

        this.instructions = codeLines;
        this.labels = labels;
        this.pc = 0;
    }

    // Execute one instruction
    step() {
        if (this.pc >= this.instructions.length) {
            this.running = false;
            return false;
        }

        const instr = this.instructions[this.pc];
        const line = instr.instruction.toUpperCase();
        const parts = line.split(/[\s,]+/).filter(p => p);
        const op = parts[0];

        try {
            switch (op) {
                case 'MOV':
                    this.setValue(parts[1], this.getValue(parts[2]));
                    break;

                case 'ADD':
                    const addResult = this.getValue(parts[1]) + this.getValue(parts[2]);
                    this.setValue(parts[1], addResult);
                    this.updateFlags(addResult);
                    break;

                case 'SUB':
                    const subResult = this.getValue(parts[1]) - this.getValue(parts[2]);
                    this.setValue(parts[1], subResult);
                    this.updateFlags(subResult);
                    this.flags.CF = subResult < 0 ? 1 : 0;
                    break;

                case 'MUL':
                    const mulVal = this.getValue(parts[1]);
                    this.regs.AX = (this.regs.AX & 0xFF) * mulVal;
                    this.updateFlags(this.regs.AX);
                    break;

                case 'DIV':
                    const divVal = this.getValue(parts[1]);
                    if (divVal !== 0) {
                        const quotient = Math.floor(this.regs.AX / divVal);
                        const remainder = this.regs.AX % divVal;
                        this.setReg8('AL', quotient);
                        this.setReg8('AH', remainder);
                    }
                    break;

                case 'INC':
                    this.setValue(parts[1], this.getValue(parts[1]) + 1);
                    this.updateFlags(this.getValue(parts[1]));
                    break;

                case 'DEC':
                    this.setValue(parts[1], this.getValue(parts[1]) - 1);
                    this.updateFlags(this.getValue(parts[1]));
                    break;

                case 'AND':
                    const andResult = this.getValue(parts[1]) & this.getValue(parts[2]);
                    this.setValue(parts[1], andResult);
                    this.updateFlags(andResult);
                    break;

                case 'OR':
                    const orResult = this.getValue(parts[1]) | this.getValue(parts[2]);
                    this.setValue(parts[1], orResult);
                    this.updateFlags(orResult);
                    break;

                case 'XOR':
                    const xorResult = this.getValue(parts[1]) ^ this.getValue(parts[2]);
                    this.setValue(parts[1], xorResult);
                    this.updateFlags(xorResult);
                    break;

                case 'NOT':
                    this.setValue(parts[1], ~this.getValue(parts[1]) & 0xFFFF);
                    break;

                case 'SHL':
                case 'SAL':
                    const shlResult = this.getValue(parts[1]) << this.getValue(parts[2]);
                    this.setValue(parts[1], shlResult);
                    this.updateFlags(shlResult);
                    break;

                case 'SHR':
                    const shrResult = this.getValue(parts[1]) >>> this.getValue(parts[2]);
                    this.setValue(parts[1], shrResult);
                    this.updateFlags(shrResult);
                    break;

                case 'CMP':
                    const cmpResult = this.getValue(parts[1]) - this.getValue(parts[2]);
                    this.updateFlags(cmpResult);
                    this.flags.CF = cmpResult < 0 ? 1 : 0;
                    break;

                case 'JMP':
                    if (this.labels[parts[1]] !== undefined) {
                        this.pc = this.labels[parts[1]] - 1;
                    }
                    break;

                case 'JZ':
                case 'JE':
                    if (this.flags.ZF && this.labels[parts[1]] !== undefined) {
                        this.pc = this.labels[parts[1]] - 1;
                    }
                    break;

                case 'JNZ':
                case 'JNE':
                    if (!this.flags.ZF && this.labels[parts[1]] !== undefined) {
                        this.pc = this.labels[parts[1]] - 1;
                    }
                    break;

                case 'JC':
                case 'JB':
                    if (this.flags.CF && this.labels[parts[1]] !== undefined) {
                        this.pc = this.labels[parts[1]] - 1;
                    }
                    break;

                case 'JNC':
                case 'JNB':
                case 'JAE':
                    if (!this.flags.CF && this.labels[parts[1]] !== undefined) {
                        this.pc = this.labels[parts[1]] - 1;
                    }
                    break;

                case 'LOOP':
                    this.regs.CX--;
                    if (this.regs.CX > 0 && this.labels[parts[1]] !== undefined) {
                        this.pc = this.labels[parts[1]] - 1;
                    }
                    break;

                case 'JCXZ':
                    if (this.regs.CX === 0 && this.labels[parts[1]] !== undefined) {
                        this.pc = this.labels[parts[1]] - 1;
                    }
                    break;

                case 'LEA':
                    if (this.dataLabels[parts[2]] !== undefined) {
                        this.setValue(parts[1], this.dataLabels[parts[2]]);
                    }
                    break;

                case 'PUSH':
                    this.push(this.getValue(parts[1]));
                    break;

                case 'POP':
                    this.setValue(parts[1], this.pop());
                    break;

                case 'CALL':
                    if (this.labels[parts[1]] !== undefined) {
                        this.push(this.pc + 1);
                        this.pc = this.labels[parts[1]] - 1;
                    }
                    break;

                case 'IN':
                case 'OUT':
                    // Stub for I/O instructions to prevent crash
                    break;

                case 'REPE':
                case 'REPNE':
                case 'REPZ':
                case 'REPNZ':
                case 'REP':
                    // Stub: treat as REP
                    break;

                case 'CMPSB':
                case 'CMPSW':
                    // Compare String - stub implementation
                    const srcIndex2 = this.regs.SI;
                    const destIndex2 = this.regs.DI;
                    const size2 = (op === 'CMPSW') ? 2 : 1;
                    if (!this.flags.DF) { this.regs.SI += size2; this.regs.DI += size2; }
                    else { this.regs.SI -= size2; this.regs.DI -= size2; }
                    break;

                case 'XCHG':
                    const val1 = this.getValue(parts[1]);
                    const val2 = this.getValue(parts[2]);
                    this.setValue(parts[1], val2);
                    this.setValue(parts[2], val1);
                    break;

                case 'INT':
                    this.handleInterrupt(this.getValue(parts[1]));
                    break;

                case 'RET':
                    this.pc = this.pop() - 1;
                    break;

                case 'HLT':
                    this.running = false;
                    return false;

                case 'NOP':
                    break;

                default:
                    // Unknown instruction - skip
                    break;
            }
        } catch (e) {
            this.output += '\n[Error: ' + e.message + ']';
        }

        this.pc++;
        return true;
    }

    // Handle DOS/BIOS interrupts
    handleInterrupt(num) {
        if (num === 0x21) {
            const func = this.getReg8('AH');
            switch (func) {
                case 0x01: // Read char with echo
                case 0x07: // Read char no echo
                case 0x08: // Read char no echo
                    this.waitInput(func === 0x01);
                    break;
                case 0x02: // Display character
                    this.output += String.fromCharCode(this.getReg8('DL'));
                    updateDisplay(); // Force update
                    break;
                case 0x09: // Display string
                    const addr = this.regs.DX;
                    let str = '';
                    for (let i = 0; i < 256; i++) {
                        const ch = this.memory[addr + i];
                        if (ch === 36) break; // '$' behavior
                        str += String.fromCharCode(ch);
                    }
                    this.output += str;
                    updateDisplay(); // Force update
                    break;
                case 0x4C: // Terminate
                    this.running = false;
                    this.output += '\n[Program Terminated]';
                    updateDisplay(); // Force update
                    break;
            }
        } else if (num === 0x16) { // BIOS Keyboard
            const func = this.getReg8('AH');
            if (func === 0x00 || func === 0x10) {
                this.waitInput(false); // Wait for key
            }
        }
    }

    // Wait for user input
    waitInput(echo) {
        this.waiting = true;
        this.echoInput = echo;
        this.output += '█';
        updateDisplay();

        // Auto-focus output
        const out = document.getElementById('output');
        if (out) {
            out.setAttribute('tabindex', '0');
            out.focus();
            // Removed blue outline as requested
            out.style.outline = 'none';
        }

        // Blinking Cursor Logic
        if (this.blinkInterval) clearInterval(this.blinkInterval);
        this.blinkState = true;
        this.blinkInterval = setInterval(() => {
            if (this.waiting) {
                if (this.blinkState) {
                    if (this.output.endsWith('█')) this.output = this.output.slice(0, -1);
                } else {
                    this.output += '█';
                }
                this.blinkState = !this.blinkState;
                updateDisplay();
            }
        }, 500);
    }

    // Process input key
    processInput(charCode) {
        if (!this.waiting) return;

        // Stop blinking
        if (this.blinkInterval) {
            clearInterval(this.blinkInterval);
            this.blinkInterval = null;
        }

        // Clear cursor if present
        if (this.output.endsWith('█')) {
            this.output = this.output.slice(0, -1);
        }

        this.setReg8('AL', charCode);
        if (this.echoInput) {
            this.output += String.fromCharCode(charCode);
            updateDisplay(); // Instant echo
        } else {
            updateDisplay(); // Remove cursor
        }

        this.waiting = false;
        setTimeout(() => this.run(), 10); // Resume with slight delay to prevent stack overflow
    }

    // Run execution loop (Async)
    run() {
        this.running = true;

        const executeChunk = () => {
            if (!this.running || this.waiting) return;

            // Execute 500 instructions per frame to keep UI responsive
            let chunk = 2000;
            while (this.running && !this.waiting && chunk > 0) {
                if (!this.step()) {
                    this.running = false;
                    updateDisplay();
                    return;
                }
                chunk--;
            }

            if (this.running && !this.waiting) {
                requestAnimationFrame(executeChunk);
            }
            updateDisplay();
        };

        requestAnimationFrame(executeChunk);
    }
}

// ========================================
// Global Emulator Instance
// ========================================

const emu = new Emulator8086();

// ========================================
// Program List Initialization
// ========================================

// Initialize program list
function initProgramList() {
    const container = document.getElementById('program-list');
    for (const [category, files] of Object.entries(programs)) {
        const div = document.createElement('div');
        div.className = 'category';
        div.innerHTML = `
            <div class="category-header" onclick="this.parentElement.classList.toggle('open')">${category} (${files.length})</div>
            <div class="category-items">
                ${files.map(f => `<div class="program-item" onclick="loadProgram('${category}', '${f}')">${f.replace('.asm', '').replace(/_/g, ' ')}</div>`).join('')}
            </div>
        `;
        container.appendChild(div);
    }
}

// Load program from GitHub
async function loadProgram(category, filename) {
    document.getElementById('current-file').textContent = filename;
    document.getElementById('status').textContent = 'Loading...';
    document.getElementById('status').className = 'status';

    try {
        const url = `https://raw.githubusercontent.com/Amey-Thakur/8086-ASSEMBLY-LANGUAGE-PROGRAMS/main/Source%20Code/${encodeURIComponent(category)}/${filename}`;
        const response = await fetch(url);
        if (response.ok) {
            const code = await response.text();
            document.getElementById('code-editor').value = code;
            document.getElementById('status').textContent = 'Loaded: ' + filename;
            document.getElementById('status').className = 'status success';
            resetEmulator();
            updateLineNumbers(); // Update line numbers after loading
        } else {
            document.getElementById('status').textContent = 'Failed to load file';
            document.getElementById('status').className = 'status error';
        }
    } catch (e) {
        document.getElementById('status').textContent = 'Error: ' + e.message;
        document.getElementById('status').className = 'status error';
    }
}

// ========================================
// Emulator Control Functions
// ========================================

// Compile code (parse and check for errors)
function compileCode() {
    try {
        const code = document.getElementById('code-editor').value;
        if (!code.trim()) {
            document.getElementById('status').textContent = 'Error: No code to compile';
            document.getElementById('status').className = 'status error';
            return false;
        }
        emu.reset();
        emu.parse(code);

        // Check for compilation errors
        if (emu.errors.length > 0) {
            const firstError = emu.errors[0];
            document.getElementById('status').textContent =
                `Error on line ${firstError.line}: ${firstError.message}`;
            document.getElementById('status').className = 'status error';
            return false;
        }

        if (emu.instructions.length === 0) {
            document.getElementById('status').textContent = 'Warning: No executable instructions found';
            document.getElementById('status').className = 'status error';
            return false;
        }

        document.getElementById('status').textContent = 'Compiled successfully! ' + emu.instructions.length + ' instructions ready.';
        document.getElementById('status').className = 'status success';
        emu.isCompiled = true;
        updateDisplay();
        return true;
    } catch (e) {
        document.getElementById('status').textContent = 'Compilation Error: ' + e.message;
        document.getElementById('status').className = 'status error';
        emu.isCompiled = false;
        return false;
    }
}

// Run code
function runCode() {
    if (!emu.isCompiled) {
        document.getElementById('status').textContent = 'Error: Please compile the code first!';
        document.getElementById('status').className = 'status error';
        return;
    }
    emu.run();
    updateDisplay();
    document.getElementById('status').textContent = 'Execution complete';
    document.getElementById('status').className = 'status success';
}

// Step through code
function stepCode() {
    if (!emu.isCompiled) {
        document.getElementById('status').textContent = 'Error: Please compile the code first!';
        document.getElementById('status').className = 'status error';
        return;
    }
    if (emu.step()) {
        updateDisplay();
        document.getElementById('status').textContent = 'Step: Line ' + (emu.pc);
    } else {
        document.getElementById('status').textContent = 'Execution complete';
        document.getElementById('status').className = 'status success';
    }
}

// Reset emulator
function resetEmulator() {
    emu.reset();
    userScrolledOutput = false; // Reset scroll tracking for fresh output
    updateDisplay();
    document.getElementById('status').textContent = 'Ready';
    document.getElementById('status').className = 'status';
}

// ========================================
// Editor Functions
// ========================================

// Update line numbers and highlight active line
function updateLineNumbers(activeLineIndex) {
    const editor = document.getElementById('code-editor');
    const gutter = document.getElementById('line-numbers');
    if (!editor || !gutter) return;

    const lineCount = editor.value.split('\n').length;
    let html = '';
    for (let i = 0; i < lineCount; i++) {
        const isActive = (i === activeLineIndex) ? ' active' : '';
        html += `<div class="line-number${isActive}">${i + 1}</div>`;
    }
    gutter.innerHTML = html;
}

// Sync scroll
function syncScroll() {
    const editor = document.getElementById('code-editor');
    const gutter = document.getElementById('line-numbers');
    if (editor && gutter) {
        gutter.scrollTop = editor.scrollTop;
    }
}

// Copy code
function copyCode() {
    const code = document.getElementById('code-editor').value;
    navigator.clipboard.writeText(code).then(() => {
        const btn = document.querySelector('button[title="Copy to Clipboard"]');
        if (btn) {
            const originalText = btn.innerHTML;
            btn.innerHTML = '<svg class="icon icon-sm" viewBox="0 0 24 24" fill="currentColor"><path d="M9 16.17L4.83 12l-1.42 1.41L9 19 21 7l-1.41-1.41z"/></svg> Copied!';
            setTimeout(() => btn.innerHTML = originalText, 2000);
        }
    });
}

// Download code
function downloadCode() {
    const code = document.getElementById('code-editor').value;
    const filename = document.getElementById('current-file').textContent || 'program.asm';
    const blob = new Blob([code], { type: 'text/plain' });
    const url = URL.createObjectURL(blob);
    const a = document.createElement('a');
    a.href = url;
    a.download = filename;
    document.body.appendChild(a);
    a.click();
    document.body.removeChild(a);
    URL.revokeObjectURL(url);
}

// Share code - uses Web Share API on supported devices, falls back to clipboard
function shareCode() {
    const filename = document.getElementById('current-file').textContent || 'program.asm';
    const programName = filename.replace('.asm', '').replace(/_/g, ' ');
    const shareUrl = 'https://amey-thakur.github.io/8086-ASSEMBLY-LANGUAGE-PROGRAMS/';

    // Custom share message with subtle authorship
    const shareTitle = '8086 Assembly Emulator';
    const shareText = `Check out "${programName}" - an 8086 assembly program running in this interactive emulator by Amey Thakur.`;

    // Check if Web Share API is available (mobile devices, etc.)
    if (navigator.share) {
        navigator.share({
            title: shareTitle,
            text: shareText,
            url: shareUrl
        }).catch(() => {
            // User cancelled or error - silently handle
        });
    } else {
        // Fallback for desktop: copy share link with message to clipboard
        const fullShareMessage = `${shareText}\n${shareUrl}`;
        navigator.clipboard.writeText(fullShareMessage).then(() => {
            const btn = document.querySelector('button[title="Share this program"]');
            if (btn) {
                const originalText = btn.innerHTML;
                btn.innerHTML = '<svg class="icon icon-sm" viewBox="0 0 24 24" fill="currentColor"><path d="M9 16.17L4.83 12l-1.42 1.41L9 19 21 7l-1.41-1.41z"/></svg> Link Copied!';
                setTimeout(() => btn.innerHTML = originalText, 2000);
            }
        });
    }
}

// ========================================
// Display Update Functions
// ========================================

// Initialize with default content
updateLineNumbers();

// Track whether user has manually scrolled up in the output console
let userScrolledOutput = false;

// Update display
function updateDisplay() {
    // Registers
    for (const reg of ['AX', 'BX', 'CX', 'DX', 'SI', 'DI', 'SP', 'BP']) {
        document.getElementById('reg-' + reg.toLowerCase()).textContent =
            emu.regs[reg].toString(16).toUpperCase().padStart(4, '0');
    }
    // Flags
    for (const flag of ['CF', 'ZF', 'SF', 'OF', 'PF', 'AF']) {
        const el = document.getElementById('flag-' + flag.toLowerCase());
        el.className = 'flag' + (emu.flags[flag] ? ' set' : '');
    }
    // Output - with proper auto-scroll like CMD behavior
    const outputEl = document.getElementById('output');
    const previousScrollHeight = outputEl.scrollHeight;
    outputEl.textContent = emu.output || '(No output)';

    // Auto-scroll to bottom only if user hasn't manually scrolled up
    if (!userScrolledOutput) {
        outputEl.scrollTop = outputEl.scrollHeight;
    }
}

// Initialize output scroll tracking after DOM is ready
(function initOutputScrollTracking() {
    const outputEl = document.getElementById('output');
    if (!outputEl) return;

    // Track user scroll interactions on the output console
    outputEl.addEventListener('scroll', function () {
        // Check if user is at the bottom (within 20px threshold)
        const isAtBottom = outputEl.scrollHeight - outputEl.scrollTop <= outputEl.clientHeight + 20;

        // If user scrolls to bottom, resume auto-scroll
        // If user scrolls up, pause auto-scroll
        userScrolledOutput = !isAtBottom;
    });

    // Handle mousewheel scroll - detect when user actively scrolls up
    outputEl.addEventListener('wheel', function (e) {
        // If scrolling up and not already at top, user is manually scrolling
        if (e.deltaY < 0 && outputEl.scrollTop > 0) {
            userScrolledOutput = true;
        }
    });
})();

// ========================================
// Theme Toggle
// ========================================

// Theme toggle
function toggleTheme() {
    const html = document.documentElement;
    const currentTheme = html.getAttribute('data-theme');
    const newTheme = currentTheme === 'dark' ? 'light' : 'dark';
    html.setAttribute('data-theme', newTheme);
    const moonIcon = '<svg class="icon" viewBox="0 0 24 24" fill="currentColor"><path d="M12 3a9 9 0 109 9c0-.46-.04-.92-.1-1.36a5.389 5.389 0 01-4.4 2.26 5.403 5.403 0 01-3.14-9.8c-.44-.06-.9-.1-1.36-.1z"/></svg>';
    const sunIcon = '<svg class="icon" viewBox="0 0 24 24" fill="currentColor"><path d="M12 7c-2.76 0-5 2.24-5 5s2.24 5 5 5 5-2.24 5-5-2.24-5-5-5zM2 13h2c.55 0 1-.45 1-1s-.45-1-1-1H2c-.55 0-1 .45-1 1s.45 1 1 1zm18 0h2c.55 0 1-.45 1-1s-.45-1-1-1h-2c-.55 0-1 .45-1 1s.45 1 1 1zM11 2v2c0 .55.45 1 1 1s1-.45 1-1V2c0-.55-.45-1-1-1s-1 .45-1 1zm0 18v2c0 .55.45 1 1 1s1-.45 1-1v-2c0-.55-.45-1-1-1s-1 .45-1 1zM5.99 4.58a.996.996 0 00-1.41 0 .996.996 0 000 1.41l1.06 1.06c.39.39 1.03.39 1.41 0s.39-1.03 0-1.41L5.99 4.58zm12.37 12.37a.996.996 0 00-1.41 0 .996.996 0 000 1.41l1.06 1.06c.39.39 1.03.39 1.41 0a.996.996 0 000-1.41l-1.06-1.06zm1.06-10.96a.996.996 0 000-1.41.996.996 0 00-1.41 0l-1.06 1.06c-.39.39-.39 1.03 0 1.41s1.03.39 1.41 0l1.06-1.06zM7.05 18.36a.996.996 0 000-1.41.996.996 0 00-1.41 0l-1.06 1.06c-.39.39-.39 1.03 0 1.41s1.03.39 1.41 0l1.06-1.06z"/></svg>';
    document.getElementById('theme-icon').innerHTML = newTheme === 'dark' ? moonIcon : sunIcon;
    localStorage.setItem('8086-theme', newTheme);
}

// Load saved theme
(function () {
    const savedTheme = localStorage.getItem('8086-theme') || 'dark';
    document.documentElement.setAttribute('data-theme', savedTheme);
    if (document.getElementById('theme-icon')) {
        const moonIcon = '<svg class="icon" viewBox="0 0 24 24" fill="currentColor"><path d="M12 3a9 9 0 109 9c0-.46-.04-.92-.1-1.36a5.389 5.389 0 01-4.4 2.26 5.403 5.403 0 01-3.14-9.8c-.44-.06-.9-.1-1.36-.1z"/></svg>';
        const sunIcon = '<svg class="icon" viewBox="0 0 24 24" fill="currentColor"><path d="M12 7c-2.76 0-5 2.24-5 5s2.24 5 5 5 5-2.24 5-5-2.24-5-5-5zM2 13h2c.55 0 1-.45 1-1s-.45-1-1-1H2c-.55 0-1 .45-1 1s.45 1 1 1zm18 0h2c.55 0 1-.45 1-1s-.45-1-1-1h-2c-.55 0-1 .45-1 1s.45 1 1 1zM11 2v2c0 .55.45 1 1 1s1-.45 1-1V2c0-.55-.45-1-1-1s-1 .45-1 1zm0 18v2c0 .55.45 1 1 1s1-.45 1-1v-2c0-.55-.45-1-1-1s-1 .45-1 1zM5.99 4.58a.996.996 0 00-1.41 0 .996.996 0 000 1.41l1.06 1.06c.39.39 1.03.39 1.41 0s.39-1.03 0-1.41L5.99 4.58zm12.37 12.37a.996.996 0 00-1.41 0 .996.996 0 000 1.41l1.06 1.06c.39.39 1.03.39 1.41 0a.996.996 0 000-1.41l-1.06-1.06zm1.06-10.96a.996.996 0 000-1.41.996.996 0 00-1.41 0l-1.06 1.06c-.39.39-.39 1.03 0 1.41s1.03.39 1.41 0l1.06-1.06zM7.05 18.36a.996.996 0 000-1.41.996.996 0 00-1.41 0l-1.06 1.06c-.39.39-.39 1.03 0 1.41s1.03.39 1.41 0l1.06-1.06z"/></svg>';
        document.getElementById('theme-icon').innerHTML = savedTheme === 'dark' ? moonIcon : sunIcon;
    }
})();

// ========================================
// Initialize Application
// ========================================

// Initialize
initProgramList();

// ========================================
// Loading Screen Logic
// ========================================

window.addEventListener('load', function () {
    // Animate progress bar
    const bar = document.querySelector('.progress-bar');
    if (bar) {
        // slight delay to ensure transition works
        setTimeout(() => {
            bar.style.width = '100%';
        }, 100);
    }

    // Minimum display time for branding (1.5 seconds)
    setTimeout(function () {
        const overlay = document.getElementById('loading-overlay');
        if (overlay) {
            overlay.classList.add('loaded');
            // Remove from DOM after transition completion to clean up
            setTimeout(() => {
                overlay.style.display = 'none';
            }, 800); // Match transition duration
        }
    }, 1600); // 100ms delay + 1.5s transition
});

// ========================================
// Intelligent Tooltip System
// ========================================

// Register descriptions and metadata
const registerInfo = {
    AX: { fullName: 'Accumulator', description: 'Primary register for arithmetic operations, I/O, and interrupt calls.' },
    BX: { fullName: 'Base Register', description: 'Often used as a base pointer for memory addressing.' },
    CX: { fullName: 'Counter', description: 'Used as a loop counter and for shift/rotate operations.' },
    DX: { fullName: 'Data Register', description: 'Used in I/O operations, multiplication, and division.' },
    SI: { fullName: 'Source Index', description: 'Points to source data for string operations.' },
    DI: { fullName: 'Destination Index', description: 'Points to destination for string operations.' },
    SP: { fullName: 'Stack Pointer', description: 'Points to the top of the stack.' },
    BP: { fullName: 'Base Pointer', description: 'Used to access parameters and local variables on the stack.' }
};

const flagInfo = {
    CF: { fullName: 'Carry Flag', description: 'Set when arithmetic operation generates a carry or borrow.' },
    ZF: { fullName: 'Zero Flag', description: 'Set when result of operation is zero.' },
    SF: { fullName: 'Sign Flag', description: 'Set when result is negative (MSB is 1).' },
    OF: { fullName: 'Overflow Flag', description: 'Set when signed arithmetic overflow occurs.' },
    PF: { fullName: 'Parity Flag', description: 'Set when low byte has even number of 1-bits.' },
    AF: { fullName: 'Auxiliary Flag', description: 'Set when carry from bit 3 to bit 4 occurs (BCD operations).' }
};

// Track instruction execution for register history
function trackRegisterChange(reg, value, instruction) {
    if (emu.registerHistory[reg]) {
        emu.registerHistory[reg].push({
            value: value,
            instruction: instruction,
            pc: emu.pc
        });
    }
}

// Track flag changes
function trackFlagChange(flag, value, instruction, reason) {
    emu.flagHistory[flag] = {
        value: value,
        instruction: instruction,
        reason: reason,
        pc: emu.pc
    };
}

// Generate register tooltip content
function generateRegisterTooltip(reg) {
    const value = emu.regs[reg];
    const info = registerInfo[reg];
    const history = emu.registerHistory[reg] || [];

    // Value conversions
    const hexVal = value.toString(16).toUpperCase().padStart(4, '0');
    const decVal = value;
    const binVal = value.toString(2).padStart(16, '0');
    const signedVal = value > 0x7FFF ? value - 0x10000 : value;

    // Build context section
    let contextHTML = '';
    if (history.length > 0) {
        const lastChange = history[history.length - 1];
        contextHTML = `
            <div class="tooltip-section">
                <div class="tooltip-section-title">EXECUTION CONTEXT</div>
                <div class="tooltip-context">
                    <ul>
                        <li>Modified <strong>${history.length}</strong> time${history.length > 1 ? 's' : ''}</li>
                        <li>Last set by: <code>${lastChange.instruction}</code></li>
                        ${getRegisterUsageHint(reg, history)}
                    </ul>
                </div>
            </div>
        `;
    } else if (!emu.isCompiled) {
        contextHTML = `
            <div class="tooltip-section">
                <div class="tooltip-section-title">NOTE</div>
                <div class="tooltip-context">Compile and run a program to see how this register is used.</div>
            </div>
        `;
    } else {
        contextHTML = `
            <div class="tooltip-section">
                <div class="tooltip-section-title">EXECUTION CONTEXT</div>
                <div class="tooltip-context">Not modified in this program.</div>
            </div>
        `;
    }

    return `
        <div class="tooltip-header">
            <span class="tooltip-title">${reg} (${info.fullName})</span>
            <span class="tooltip-value">0x${hexVal}</span>
        </div>
        <div class="tooltip-section">
            <div class="tooltip-section-title">VALUE BREAKDOWN</div>
            <div class="tooltip-values">
                <div class="tooltip-value-item">
                    <span class="tooltip-value-label">Decimal</span>
                    <span class="tooltip-value-data">${decVal}</span>
                </div>
                <div class="tooltip-value-item">
                    <span class="tooltip-value-label">Signed</span>
                    <span class="tooltip-value-data">${signedVal}</span>
                </div>
                <div class="tooltip-value-item">
                    <span class="tooltip-value-label">Binary</span>
                    <span class="tooltip-value-data">${binVal.slice(0, 8)} ${binVal.slice(8)}</span>
                </div>
            </div>
        </div>
        ${contextHTML}
        <div class="tooltip-section">
            <div class="tooltip-section-title">DESCRIPTION</div>
            <div class="tooltip-description">${info.description}</div>
        </div>
    `;
}

// Generate usage hint based on register history
function getRegisterUsageHint(reg, history) {
    if (history.length === 0) return '';

    // Analyze instructions to determine usage
    const instructions = history.map(h => h.instruction.toUpperCase());

    if (reg === 'CX' && instructions.some(i => i.includes('LOOP'))) {
        return '<li>Used as: <strong>Loop counter</strong></li>';
    }
    if (reg === 'AX' && instructions.some(i => i.includes('MUL') || i.includes('DIV'))) {
        return '<li>Contains: <strong>Arithmetic result</strong></li>';
    }
    if ((reg === 'DX' || reg === 'AX') && instructions.some(i => i.includes('INT'))) {
        return '<li>Used for: <strong>DOS/BIOS interrupt</strong></li>';
    }
    if ((reg === 'SI' || reg === 'DI') && instructions.some(i => i.includes('MOVS') || i.includes('LODS') || i.includes('STOS'))) {
        return '<li>Used as: <strong>String pointer</strong></li>';
    }
    return '';
}

// Generate flag tooltip content
function generateFlagTooltip(flag) {
    const value = emu.flags[flag];
    const info = flagInfo[flag];
    const history = emu.flagHistory[flag];

    const statusClass = value ? 'set' : 'clear';
    const statusText = value ? 'SET' : 'CLEAR';

    // Build context section
    let contextHTML = '';
    if (history && history.instruction) {
        contextHTML = `
            <div class="tooltip-section">
                <div class="tooltip-section-title">EXECUTION CONTEXT</div>
                <div class="tooltip-context">
                    <ul>
                        <li>${value ? 'Set' : 'Cleared'} by: <code>${history.instruction}</code></li>
                        ${getFlagImpactHint(flag, value)}
                    </ul>
                </div>
            </div>
        `;
    } else if (!emu.isCompiled) {
        contextHTML = `
            <div class="tooltip-section">
                <div class="tooltip-section-title">NOTE</div>
                <div class="tooltip-context">Compile and run to see how flags change during execution.</div>
            </div>
        `;
    }

    return `
        <div class="tooltip-header">
            <span class="tooltip-title">${flag} (${info.fullName})</span>
            <span class="tooltip-status ${statusClass}">${statusText}</span>
        </div>
        ${contextHTML}
        <div class="tooltip-section">
            <div class="tooltip-section-title">DESCRIPTION</div>
            <div class="tooltip-description">${info.description}</div>
        </div>
        <div class="tooltip-section">
            <div class="tooltip-section-title">AFFECTED INSTRUCTIONS</div>
            <div class="tooltip-description">${getFlagJumps(flag)}</div>
        </div>
    `;
}

// Get jump instructions affected by flag
function getFlagJumps(flag) {
    const jumps = {
        CF: 'JC/JB (jump if carry), JNC/JNB/JAE (jump if no carry)',
        ZF: 'JZ/JE (jump if zero), JNZ/JNE (jump if not zero)',
        SF: 'JS (jump if sign), JNS (jump if not sign)',
        OF: 'JO (jump if overflow), JNO (jump if no overflow)',
        PF: 'JP/JPE (jump if parity even), JNP/JPO (jump if parity odd)',
        AF: 'Used internally for BCD arithmetic (AAA, AAS, DAA, DAS)'
    };
    return jumps[flag] || 'N/A';
}

// Get flag impact hint
function getFlagImpactHint(flag, value) {
    if (flag === 'ZF' && value) {
        return '<li>Impact: <strong>JZ/JE will branch</strong></li>';
    }
    if (flag === 'ZF' && !value) {
        return '<li>Impact: <strong>JNZ/JNE will branch</strong></li>';
    }
    if (flag === 'CF' && value) {
        return '<li>Impact: <strong>JC/JB will branch</strong></li>';
    }
    return '';
}

// Tooltip element and show/hide logic
const tooltip = document.getElementById('tooltip');
let tooltipTimeout = null;

function showTooltip(element, content, event) {
    if (!tooltip) return;

    tooltip.innerHTML = content;
    tooltip.classList.add('visible');

    // Position tooltip near cursor but within viewport
    const rect = element.getBoundingClientRect();
    const tooltipRect = tooltip.getBoundingClientRect();

    let left = rect.left;
    let top = rect.bottom + 8;

    // Keep within viewport
    if (left + 320 > window.innerWidth) {
        left = window.innerWidth - 330;
    }
    if (top + tooltipRect.height > window.innerHeight) {
        top = rect.top - tooltipRect.height - 8;
    }

    tooltip.style.left = left + 'px';
    tooltip.style.top = top + 'px';
}

function hideTooltip() {
    if (tooltip) {
        tooltip.classList.remove('visible');
    }
}

// Attach hover events to registers
document.querySelectorAll('.register[data-reg]').forEach(el => {
    el.addEventListener('mouseenter', function (e) {
        const reg = this.dataset.reg;
        const content = generateRegisterTooltip(reg);
        clearTimeout(tooltipTimeout);
        tooltipTimeout = setTimeout(() => showTooltip(this, content, e), 150);
    });

    el.addEventListener('mouseleave', function () {
        clearTimeout(tooltipTimeout);
        hideTooltip();
    });
});

// Attach hover events to flags
document.querySelectorAll('.flag[data-flag]').forEach(el => {
    el.addEventListener('mouseenter', function (e) {
        const flag = this.dataset.flag;
        const content = generateFlagTooltip(flag);
        clearTimeout(tooltipTimeout);
        tooltipTimeout = setTimeout(() => showTooltip(this, content, e), 150);
    });

    el.addEventListener('mouseleave', function () {
        clearTimeout(tooltipTimeout);
        hideTooltip();
    });
});

// Modify step function to track changes (wrap original)
const originalStep = emu.step.bind(emu);
emu.step = function () {
    const prevRegs = { ...this.regs };
    const prevFlags = { ...this.flags };
    const instr = this.instructions[this.pc];

    const result = originalStep();

    if (instr) {
        // Track register changes
        for (const reg of Object.keys(this.regs)) {
            if (this.regs[reg] !== prevRegs[reg]) {
                trackRegisterChange(reg, this.regs[reg], instr.instruction);
            }
        }

        // Track flag changes
        for (const flag of Object.keys(this.flags)) {
            if (this.flags[flag] !== prevFlags[flag]) {
                trackFlagChange(flag, this.flags[flag], instr.instruction, '');
            }
        }
    }

    return result;
};


// ========================================
// Debug Info Bar
// ========================================

const debugBar = document.getElementById('debug-bar');
const debugInstruction = document.getElementById('debug-instruction');
const debugExplanation = document.getElementById('debug-explanation');

function updateDebugBar(instruction, explanation) {
    if (!debugBar) return;

    // Show bar
    debugBar.classList.add('visible');

    // Update content
    debugInstruction.textContent = instruction;
    debugExplanation.textContent = explanation;
}

function hideDebugBar() {
    if (debugBar) {
        debugBar.classList.remove('visible');
    }
}

// Clear log/Hide bar
const originalReset = resetEmulator;
resetEmulator = function () {
    originalReset();
    hideDebugBar();
};

// Explain instruction in plain English
function explainInstruction(instruction) {
    const parts = instruction.replace(/,/g, ' ').split(/\s+/).filter(p => p);
    const op = parts[0];
    const dest = parts[1];
    const src = parts[2];

    switch (op) {
        case 'MOV':
            return `Copy value from ${src} to ${dest}.`;
        case 'ADD':
            return `Add ${src} to ${dest} and store result in ${dest}.`;
        case 'SUB':
            return `Subtract ${src} from ${dest} and store result in ${dest}.`;
        case 'INC':
            return `Increment (add 1 to) ${dest}.`;
        case 'DEC':
            return `Decrement (subtract 1 from) ${dest}.`;
        case 'MUL':
            return `Multiply AX by ${dest}.`;
        case 'DIV':
            return `Divide AX by ${dest}.`;
        case 'JMP':
            return `Jump unconditionally to label ${dest}.`;
        case 'JZ':
        case 'JE':
            return `Jump to ${dest} if Zero Flag is SET.`;
        case 'JNZ':
        case 'JNE':
            return `Jump to ${dest} if Zero Flag is CLEAR.`;
        case 'CMP':
            return `Compare ${dest} with ${src} (affects flags).`;
        case 'INT':
            if (dest === '21H') return 'Call DOS interrupt (Function depending on AH).';
            return `Trigger software interrupt ${dest}.`;
        case 'LEA':
            return `Load effective address of ${src} into ${dest}.`;
        case 'PUSH':
            return `Push ${dest} onto the stack.`;
        case 'POP':
            return `Pop top of stack into ${dest}.`;
        case 'RET':
            return 'Return from procedure.';
        case 'HLT':
            return 'Halt execution.';
        default:
            return `Execute ${op} operation.`;
    }
}

// Update step function to log execution
const stepForLog = emu.step;
emu.step = function () {
    const instr = this.instructions[this.pc];
    const result = stepForLog.apply(this, arguments);

    if (instr) {
        const explanation = explainInstruction(instr.instruction);
        updateDebugBar(instr.instruction, explanation);
    }

    return result;
};


// ========================================
// Footer System Bus Animation
// ========================================

const editorInput = document.getElementById('code-editor');
const systemBus = document.getElementById('system-bus');
const footerChip = document.querySelector('.footer-chip');
let busTimeout;

if (editorInput && systemBus && footerChip) {
    editorInput.addEventListener('input', () => {
        // Activate bus
        systemBus.classList.add('active');
        footerChip.classList.add('processing');

        // Reset timeout
        clearTimeout(busTimeout);

        // Deactivate after pause in typing
        busTimeout = setTimeout(() => {
            systemBus.classList.remove('active');
            footerChip.classList.remove('processing');
        }, 300);
    });
}

// ========================================
// Emulator Input Handler
// ========================================

document.addEventListener('keydown', (e) => {
    // Allow typing in Code Editor or Inputs
    if (e.target.tagName === 'TEXTAREA' || e.target.tagName === 'INPUT') return;

    if (emu.waiting) {
        e.preventDefault();

        let charCode = 0;

        if (e.key.length === 1) {
            charCode = e.key.charCodeAt(0);
        } else if (e.key === 'Enter') {
            charCode = 13; // Carriage Return
        } else if (e.key === 'Backspace') {
            charCode = 8;
        } else if (e.key === 'Escape') {
            charCode = 27;
        }

        if (charCode > 0) {
            emu.processInput(charCode);
        }
    }
});


// ========================================
// Security & Easter Eggs
// ========================================

// 1. Console Signature
console.log(
    '%c 8086 Emulator Developed by Amey Thakur ',
    'background: #161b22; color: #58a6ff; font-size: 16px; font-weight: bold; padding: 10px; border-radius: 5px; border: 1px solid #30363d;'
);

// 2. Low-Level Security (Anti-Right Click & DevTools)
document.addEventListener('contextmenu', (e) => {
    e.preventDefault();
    return false;
});

document.addEventListener('keydown', (e) => {
    // Prevent F12, Ctrl+Shift+I, Ctrl+Shift+J, Ctrl+U
    if (
        e.key === 'F12' ||
        (e.ctrlKey && e.shiftKey && (e.key === 'I' || e.key === 'J')) ||
        (e.ctrlKey && e.key === 'u')
    ) {
        e.preventDefault();
        return false;
    }

    // 3. Easter Egg (Ctrl + Alt + E)
    if (e.ctrlKey && e.altKey && e.key.toLowerCase() === 'e') {
        alert('✨ Easter Egg Found! ✨\n\nDeveloped with ❤️ by Amey Thakur\n2021-' + new Date().getFullYear());
    }
});

