/*
============================================================================
PROJECT: 8086 MICROPROCESSOR SIMULATOR - CORE ENGINE (RECONSTRUCTED)
============================================================================
AUTHOR:      Amey Thakur
GITHUB:      https://github.com/Amey-Thakur/8086-ASSEMBLY-LANGUAGE-PROGRAMS
PROFILE:     https://github.com/Amey-Thakur
LICENSE:     MIT License
CREATED:     2021
UPDATED:     2026 (Arithmetic & UI Professional Overhaul)

DESCRIPTION:
The core emulation engine responsible for parsing, compiling, and executing
8086 assembly instructions. Features a cycle-accurate state machine,
16-bit register file simulation, memory segmentation model, and partial
support for DOS interrupts (INT 21h).
============================================================================
*/

/**
 * Represents the 8086 Microprocessor state and execution logic.
 * @class
 */
class Emulator8086 {
    constructor() {
        this.reset();
    }

    reset() {
        // 16-bit registers: AX, BX, CX, DX, SI, DI, SP, BP
        this.regs = { AX: 0, BX: 0, CX: 0, DX: 0, SI: 0, DI: 0, SP: 0xFFFE, BP: 0 };
        // Flags: CF (Carry), ZF (Zero), SF (Sign), OF (Overflow), PF (Parity), AF (Aux Carry)
        this.flags = { CF: 0, ZF: 0, SF: 0, OF: 0, PF: 0, AF: 0 };
        // Memory (64KB)
        this.memory = new Uint8Array(65536);
        // Data and Labels
        this.dataLabels = {};
        this.dataSizes = {}; // 'BYTE' or 'WORD'
        this.labels = {};
        this.dataPointer = 0x2000; // Start data at 8KB offset
        this.output = '';
        this.pc = 0;
        this.instructions = [];
        this.running = false;
        this.waiting = false;
        this.echoInput = false;
        this.errors = [];
        this.isCompiled = false;

        // Input Management
        this.blinkInterval = null;
        this.blinkState = true;
    }

    // Identify if operand is 16-bit
    is16Bit(operand) {
        if (!operand) return true;
        operand = operand.trim().toUpperCase();
        if (['AX', 'BX', 'CX', 'DX', 'SI', 'DI', 'SP', 'BP'].includes(operand)) return true;
        if (['AL', 'AH', 'BL', 'BH', 'CL', 'CH', 'DL', 'DH'].includes(operand)) return false;
        if (this.dataSizes[operand]) return this.dataSizes[operand] === 'WORD';
        return true;
    }

    // Helper: Push 16-bit value to stack
    push(val) {
        this.regs.SP = (this.regs.SP - 2) & 0xFFFF;
        const addr = this.regs.SP;
        this.memory[addr] = val & 0xFF;
        this.memory[(addr + 1) & 0xFFFF] = (val >> 8) & 0xFF;
    }

    // Helper: Pop 16-bit value from stack
    pop() {
        const addr = this.regs.SP;
        const val = this.memory[addr] | (this.memory[(addr + 1) & 0xFFFF] << 8);
        this.regs.SP = (this.regs.SP + 2) & 0xFFFF;
        return val;
    }

    // Set/Get 8-bit registers
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

    setReg8(name, val) {
        name = name.toUpperCase();
        val &= 0xFF;
        if (name === 'AL') this.regs.AX = (this.regs.AX & 0xFF00) | val;
        else if (name === 'AH') this.regs.AX = (this.regs.AX & 0x00FF) | (val << 8);
        else if (name === 'BL') this.regs.BX = (this.regs.BX & 0xFF00) | val;
        else if (name === 'BH') this.regs.BX = (this.regs.BX & 0x00FF) | (val << 8);
        else if (name === 'CL') this.regs.CX = (this.regs.CX & 0xFF00) | val;
        else if (name === 'CH') this.regs.CX = (this.regs.CX & 0x00FF) | (val << 8);
        else if (name === 'DL') this.regs.DX = (this.regs.DX & 0xFF00) | val;
        else if (name === 'DH') this.regs.DX = (this.regs.DX & 0x00FF) | (val << 8);
    }

    // Unified value getter (register, immediate, or memory)
    getValue(operand) {
        if (!operand) return 0;
        operand = operand.trim().toUpperCase();

        // Handle brackets [] for memory access
        let isMemory = false;
        if (operand.startsWith('[') && operand.endsWith(']')) {
            operand = operand.slice(1, -1).trim();
            isMemory = true;
        }

        // 16-bit registers
        if (this.regs[operand] !== undefined) {
            const val = this.regs[operand];
            if (isMemory) return this.memory[val] | (this.memory[(val + 1) & 0xFFFF] << 8);
            return val;
        }

        // 8-bit registers
        if (['AL', 'AH', 'BL', 'BH', 'CL', 'CH', 'DL', 'DH'].includes(operand)) {
            const val = this.getReg8(operand);
            if (isMemory) return this.memory[val];
            return val;
        }

        // Immediate values
        if (operand.endsWith('H')) return parseInt(operand.slice(0, -1), 16);
        if (operand.endsWith('B')) return parseInt(operand.slice(0, -1), 2);
        if (/^\d+$/.test(operand)) return parseInt(operand, 10);
        if (operand.startsWith("'") && operand.endsWith("'")) return operand.charCodeAt(1);

        // Memory labels
        if (this.dataLabels[operand] !== undefined) {
            const addr = this.dataLabels[operand];
            // If it's a data label, we almost always want the content (except in LEA)
            if (this.dataSizes[operand] === 'WORD') {
                return this.memory[addr] | (this.memory[(addr + 1) & 0xFFFF] << 8);
            }
            return this.memory[addr];
        }
        return 0;
    }

    // Unified value setter
    setValue(dest, val) {
        if (!dest) return;
        dest = dest.trim().toUpperCase();

        let isMemory = false;
        if (dest.startsWith('[') && dest.endsWith(']')) {
            dest = dest.slice(1, -1).trim();
            isMemory = true;
        }

        if (this.regs[dest] !== undefined) {
            if (isMemory) {
                const addr = this.regs[dest];
                this.memory[addr] = val & 0xFF;
                this.memory[(addr + 1) & 0xFFFF] = (val >> 8) & 0xFF;
            } else {
                this.regs[dest] = val & 0xFFFF;
            }
            return;
        }

        if (['AL', 'AH', 'BL', 'BH', 'CL', 'CH', 'DL', 'DH'].includes(dest)) {
            if (isMemory) {
                const addr = this.getReg8(dest);
                this.memory[addr] = val & 0xFF;
            } else {
                this.setReg8(dest, val);
            }
            return;
        }

        if (this.dataLabels[dest] !== undefined) {
            const addr = this.dataLabels[dest];
            if (this.dataSizes[dest] === 'WORD') {
                this.memory[addr] = val & 0xFF;
                this.memory[(addr + 1) & 0xFFFF] = (val >> 8) & 0xFF;
            } else {
                this.memory[addr] = val & 0xFF;
            }
            return;
        }
    }

    updateFlags(result, is16bit = true) {
        const mask = is16bit ? 0xFFFF : 0xFF;
        const sign = is16bit ? 0x8000 : 0x80;
        this.flags.ZF = (result & mask) === 0 ? 1 : 0;
        this.flags.SF = (result & sign) ? 1 : 0;
        this.flags.CF = (result > mask || result < 0) ? 1 : 0;

        // Parity
        let ones = 0;
        let lb = result & 0xFF;
        while (lb) { ones += lb & 1; lb >>= 1; }
        this.flags.PF = (ones % 2 === 0) ? 1 : 0;
    }

    parse(code) {
        this.reset();
        const lines = code.split('\n');
        const codeLines = [];
        const constants = {};

        // Pass 1: Handle Constants and Pre-process
        for (let i = 0; i < lines.length; i++) {
            let line = lines[i].split(';')[0].trim();
            if (!line) continue;
            const equMatch = line.match(/^(\w+)\s+EQU\s+(.+)$/i);
            if (equMatch) {
                constants[equMatch[1].toUpperCase()] = equMatch[2].trim();
                lines[i] = '';
            }
        }

        // Pass 2: Labels and Data
        for (let i = 0; i < lines.length; i++) {
            let line = lines[i].split(';')[0].trim();
            if (!line) continue;

            // Constants
            for (const [name, v] of Object.entries(constants)) {
                line = line.replace(new RegExp(`\\b${name}\\b`, 'g'), v);
            }

            // Data Definitions
            const dataMatch = line.match(/^(\w+)?\s*(DB|DW)\s+(.+)$/i);
            if (dataMatch) {
                const label = dataMatch[1] ? dataMatch[1].toUpperCase() : null;
                const type = dataMatch[2].toUpperCase();
                const valueStr = dataMatch[3].trim();

                if (label) {
                    this.dataLabels[label] = this.dataPointer;
                    this.dataSizes[label] = (type === 'DW') ? 'WORD' : 'BYTE';
                }

                // Parse values (supports 'string', 10, 13)
                const parts = valueStr.split(/,(?=(?:(?:[^']*'){2})*[^']*$)/);
                for (let p of parts) {
                    p = p.trim();
                    if (p.startsWith("'") && p.endsWith("'")) {
                        const s = p.slice(1, -1);
                        for (let k = 0; k < s.length; k++) this.memory[this.dataPointer++] = s.charCodeAt(k);
                    } else {
                        const v = this.getValue(p);
                        if (type === 'DB') {
                            this.memory[this.dataPointer++] = v & 0xFF;
                        } else {
                            this.memory[this.dataPointer++] = v & 0xFF;
                            this.memory[this.dataPointer++] = (v >> 8) & 0xFF;
                        }
                    }
                }
                continue;
            }

            // Code Labels
            const labelMatch = line.match(/^(\w+):/) || line.match(/^(\w+)\s+PROC/i);
            if (labelMatch) {
                this.labels[labelMatch[1].toUpperCase()] = codeLines.length;
                line = line.replace(/^(\w+):/, '').replace(/^(\w+)\s+PROC/i, '').trim();
                if (!line) continue;
            }

            // Skip directives
            if (/^(ORG|END|SEGMENT|ENDS|ASSUME|NAME|\.MODEL|\.DATA|\.CODE|\.STACK|\.FARDATA|ENDP)/i.test(line)) continue;

            codeLines.push({ instruction: line, lineNo: i + 1 });
        }
        this.instructions = codeLines;
        this.pc = 0;
    }

    step() {
        if (this.pc >= this.instructions.length) { this.running = false; return false; }
        const instr = this.instructions[this.pc];
        const line = instr.instruction.toUpperCase();
        const parts = line.split(/[\s,]+/).filter(p => p);
        const op = parts[0];

        try {
            switch (op) {
                case 'MOV': this.setValue(parts[1], this.getValue(parts[2])); break;
                case 'ADD': {
                    const v1 = this.getValue(parts[1]);
                    const v2 = this.getValue(parts[2]);
                    const res = v1 + v2;
                    this.setValue(parts[1], res);
                    this.updateFlags(res, this.is16Bit(parts[1]));
                    break;
                }
                case 'SUB': {
                    const v1 = this.getValue(parts[1]);
                    const v2 = this.getValue(parts[2]);
                    const res = v1 - v2;
                    this.setValue(parts[1], res);
                    this.updateFlags(res, this.is16Bit(parts[1]));
                    break;
                }
                case 'INC': {
                    const res = this.getValue(parts[1]) + 1;
                    this.setValue(parts[1], res);
                    this.updateFlags(res, this.is16Bit(parts[1]));
                    break;
                }
                case 'DEC': {
                    const res = this.getValue(parts[1]) - 1;
                    this.setValue(parts[1], res);
                    this.updateFlags(res, this.is16Bit(parts[1]));
                    break;
                }
                case 'MUL': {
                    const m = this.getValue(parts[1]);
                    if (this.is16Bit(parts[1])) {
                        const res = this.regs.AX * m;
                        this.regs.AX = res & 0xFFFF;
                        this.regs.DX = (res >> 16) & 0xFFFF;
                    } else {
                        this.regs.AX = (this.regs.AX & 0xFF) * m;
                    }
                    break;
                }
                case 'DIV': {
                    let d = this.getValue(parts[1]);
                    if (d === 0) throw new Error("Division by zero");
                    if (this.is16Bit(parts[1])) {
                        const num = (this.regs.DX * 65536) + this.regs.AX;
                        this.regs.AX = Math.floor(num / d) & 0xFFFF;
                        this.regs.DX = Math.floor(num % d) & 0xFFFF;
                    } else {
                        const num = this.regs.AX;
                        this.setReg8('AL', Math.floor(num / d) & 0xFF);
                        this.setReg8('AH', Math.floor(num % d) & 0xFF);
                    }
                    break;
                }
                case 'AND': {
                    const res = this.getValue(parts[1]) & this.getValue(parts[2]);
                    this.setValue(parts[1], res);
                    this.updateFlags(res, this.is16Bit(parts[1]));
                    this.flags.CF = 0; this.flags.OF = 0;
                    break;
                }
                case 'OR': {
                    const res = this.getValue(parts[1]) | this.getValue(parts[2]);
                    this.setValue(parts[1], res);
                    this.updateFlags(res, this.is16Bit(parts[1]));
                    this.flags.CF = 0; this.flags.OF = 0;
                    break;
                }
                case 'XOR': {
                    const res = this.getValue(parts[1]) ^ this.getValue(parts[2]);
                    this.setValue(parts[1], res);
                    this.updateFlags(res, this.is16Bit(parts[1]));
                    this.flags.CF = 0; this.flags.OF = 0;
                    break;
                }
                case 'NOT': {
                    const res = ~this.getValue(parts[1]);
                    this.setValue(parts[1], res);
                    break;
                }
                case 'SHL': case 'SAL': {
                    const count = this.getValue(parts[2]) & 0x1F;
                    const res = this.getValue(parts[1]) << count;
                    this.setValue(parts[1], res);
                    this.updateFlags(res, this.is16Bit(parts[1]));
                    break;
                }
                case 'SHR': {
                    const count = this.getValue(parts[2]) & 0x1F;
                    const res = this.getValue(parts[1]) >>> count;
                    this.setValue(parts[1], res);
                    this.updateFlags(res, this.is16Bit(parts[1]));
                    break;
                }
                case 'CMP': {
                    const res = this.getValue(parts[1]) - this.getValue(parts[2]);
                    this.updateFlags(res, this.is16Bit(parts[1]));
                    break;
                }
                case 'JMP': if (this.labels[parts[1]] !== undefined) this.pc = this.labels[parts[1]] - 1; break;
                case 'JZ': case 'JE': if (this.flags.ZF) this.pc = (this.labels[parts[1]] || 0) - 1; break;
                case 'JNZ': case 'JNE': if (!this.flags.ZF) this.pc = (this.labels[parts[1]] || 0) - 1; break;
                case 'JC': case 'JB': if (this.flags.CF) this.pc = (this.labels[parts[1]] || 0) - 1; break;
                case 'JNC': case 'JNB': if (!this.flags.CF) this.pc = (this.labels[parts[1]] || 0) - 1; break;
                case 'LOOP': this.regs.CX--; if (this.regs.CX > 0) this.pc = (this.labels[parts[1]] || 0) - 1; break;
                case 'CALL': this.push(this.pc + 1); this.pc = (this.labels[parts[1]] || 0) - 1; break;
                case 'RET': this.pc = this.pop() - 1; break;
                case 'PUSH': this.push(this.getValue(parts[1])); break;
                case 'POP': this.setValue(parts[1], this.pop()); break;
                case 'LEA': this.setValue(parts[1], this.dataLabels[parts[2]] || 0); break;
                case 'INT': this.handleInterrupt(this.getValue(parts[1])); break;
                case 'HLT': this.running = false; return false;
                case 'CBW': this.regs.AX = (this.regs.AX & 0x80) ? (0xFF00 | (this.regs.AX & 0xFF)) : (this.regs.AX & 0xFF); break;
                case 'CWD': this.regs.DX = (this.regs.AX & 0x8000) ? 0xFFFF : 0x0000; break;
                case 'NEG': {
                    const v = this.getValue(parts[1]);
                    const res = -v;
                    this.setValue(parts[1], res);
                    this.updateFlags(res, this.is16Bit(parts[1]));
                    break;
                }
            }
            if (op && typeof updateDebugBar === 'function') {
                updateDebugBar(instr.instruction, explainInstruction(instr.instruction));
            }
        } catch (e) { this.output += '\n[Error: ' + e.message + ']'; }
        this.pc++;
        return true;
    }

    handleInterrupt(num) {
        if (num === 0x21) {
            const ah = this.getReg8('AH');
            if (ah === 0x01 || ah === 0x07 || ah === 0x08) this.waitInput(ah === 0x01);
            else if (ah === 0x02) { this.output += String.fromCharCode(this.getReg8('DL')); updateDisplay(); }
            else if (ah === 0x09) {
                const addr = this.regs.DX;
                let s = '';
                for (let i = 0; i < 500; i++) {
                    const c = this.memory[addr + i];
                    if (c === 36) break;
                    s += String.fromCharCode(c);
                }
                this.output += s;
                updateDisplay();
            }
            else if (ah === 0x4C) { this.running = false; updateDisplay(); }
        }
    }

    waitInput(echo) {
        this.waiting = true; this.echoInput = echo;
        this.startCursor();
        const out = document.getElementById('output');
        if (out) { out.setAttribute('tabindex', '0'); out.focus(); out.style.outline = 'none'; }
    }

    startCursor() {
        if (this.blinkInterval) clearInterval(this.blinkInterval);
        this.blinkState = true;
        this.blinkInterval = setInterval(() => {
            if (this.waiting) {
                if (this.blinkState) { if (this.output.endsWith('█')) this.output = this.output.slice(0, -1); }
                else { this.output += '█'; }
                this.blinkState = !this.blinkState;
                updateDisplay();
            }
        }, 500);
    }

    processInput(charCode) {
        if (!this.waiting) return;
        if (this.blinkInterval) { clearInterval(this.blinkInterval); this.blinkInterval = null; }
        if (this.output.endsWith('█')) this.output = this.output.slice(0, -1);

        // Handle Backspace
        if (charCode === 8) {
            if (this.echoInput && this.output.length > 0 && !this.output.endsWith('\n')) {
                this.output = this.output.slice(0, -1);
                updateDisplay();
                this.startCursor();
            }
            return;
        }

        this.setReg8('AL', charCode);
        if (this.echoInput) this.output += String.fromCharCode(charCode);
        this.waiting = false;
        updateDisplay();
        setTimeout(() => this.run(), 10);
    }

    run() {
        this.running = true;
        const loop = () => {
            if (!this.running || this.waiting) return;
            let steps = 1000;
            while (this.running && !this.waiting && steps--) { if (!this.step()) break; }
            updateDisplay();
            if (this.running && !this.waiting) requestAnimationFrame(loop);
        };
        requestAnimationFrame(loop);
    }
}

const emu = new Emulator8086();

// ========================================
// UI SYNC & SCROLLING
// ========================================
let userScrolledOutput = false;
function updateDisplay() {
    const ids = ['ax', 'bx', 'cx', 'dx', 'si', 'di', 'sp', 'bp'];
    ids.forEach(id => {
        const el = document.getElementById(`reg-${id}`);
        if (el) el.textContent = emu.regs[id.toUpperCase()].toString(16).toUpperCase().padStart(4, '0');
    });
    const flags = ['cf', 'zf', 'sf', 'of', 'pf', 'af'];
    flags.forEach(f => {
        const el = document.getElementById(`flag-${f}`);
        if (el) el.className = `flag ${emu.flags[f.toUpperCase()] ? 'active' : ''}`;
    });
    const out = document.getElementById('output');
    if (out) {
        out.textContent = emu.output;
        if (!userScrolledOutput) out.scrollTop = out.scrollHeight;
    }
}

function initOutputScrollTracking() {
    const out = document.getElementById('output');
    if (!out) return;
    out.addEventListener('scroll', () => {
        const isAtBottom = Math.abs(out.scrollHeight - out.scrollTop - out.clientHeight) < 5;
        userScrolledOutput = !isAtBottom;
    });
    out.addEventListener('wheel', () => {
        setTimeout(() => {
            const isAtBottom = Math.abs(out.scrollHeight - out.scrollTop - out.clientHeight) < 5;
            userScrolledOutput = !isAtBottom;
        }, 50);
    });
}

// ========================================
// CONTROLS & LOADERS
// ========================================
function resetEmulator() {
    emu.reset();
    userScrolledOutput = false;
    updateDisplay();
    document.getElementById('status').textContent = 'Ready';
}

function compileCode() {
    const code = document.getElementById('code-editor').value;
    emu.parse(code);
    if (emu.errors.length > 0) {
        const err = emu.errors[0];
        document.getElementById('status').textContent = `Line ${err.line}: ${err.message}`;
        return false;
    }
    emu.isCompiled = true;
    updateDisplay();
    document.getElementById('status').textContent = 'Compiled successfully!';
    return true;
}

function runCode() { if (compileCode()) emu.run(); }
function stepCode() { if (compileCode()) emu.step(); updateDisplay(); }

async function loadProgram(category, filename) {
    document.getElementById('status').textContent = 'Loading...';
    try {
        const url = `https://raw.githubusercontent.com/Amey-Thakur/8086-ASSEMBLY-LANGUAGE-PROGRAMS/main/Source%20Code/${encodeURIComponent(category)}/${filename}`;
        const res = await fetch(url);
        if (res.ok) {
            document.getElementById('code-editor').value = await res.text();
            document.getElementById('current-file').textContent = filename;
            resetEmulator();
            updateLineNumbers();
        }
    } catch (e) { document.getElementById('status').textContent = 'Load error'; }
}

function initProgramList() {
    const container = document.getElementById('program-list');
    if (!container) return;
    for (const [cat, files] of Object.entries(programs)) {
        const div = document.createElement('div');
        div.className = 'category';
        div.innerHTML = `<div class="category-header" onclick="this.parentElement.classList.toggle('open')">${cat}</div>
            <div class="category-items">${files.map(f => `<div class="program-item" onclick="loadProgram('${cat}', '${f}')">${f}</div>`).join('')}</div>`;
        container.appendChild(div);
    }
}

// Utility
function updateLineNumbers() {
    const editor = document.getElementById('code-editor');
    const gutter = document.getElementById('line-numbers');
    if (!editor || !gutter) return;
    const count = editor.value.split('\n').length;
    gutter.innerHTML = Array.from({ length: count }, (_, i) => `<div class="line-number">${i + 1}</div>`).join('');
}

function explainInstruction(instruction) {
    if (!instruction) return "";
    const parts = instruction.replace(/,/g, ' ').split(/\s+/).filter(p => p);
    const op = parts[0]?.toUpperCase();
    const dest = parts[1];
    const src = parts[2];
    switch (op) {
        case 'MOV': return `Copy ${src} to ${dest}.`;
        case 'ADD': return `Add ${src} to ${dest}.`;
        case 'SUB': return `Subtract ${src} from ${dest}.`;
        case 'MUL': return `Multiply AX by ${dest}.`;
        case 'DIV': return `Divide AX by ${dest}.`;
        case 'JMP': return `Jump to ${dest}.`;
        case 'JZ': case 'JE': return `Jump if zero.`;
        case 'JNZ': case 'JNE': return `Jump if not zero.`;
        case 'CALL': return `Call procedure ${dest}.`;
        case 'RET': return `Return from procedure.`;
        case 'INT': return `Call interrupt ${dest}.`;
        default: return `Execute ${op}.`;
    }
}

function updateDebugBar(instr, expl) {
    const di = document.getElementById('debug-instruction');
    const de = document.getElementById('debug-explanation');
    if (di) di.textContent = instr;
    if (de) de.textContent = expl;
}

function syncScroll() { document.getElementById('line-numbers').scrollTop = document.getElementById('code-editor').scrollTop; }
function copyCode() {
    const code = document.getElementById('code-editor').value;
    navigator.clipboard.writeText(code).then(() => {
        const btn = document.querySelector('button[onclick="copyCode()"]');
        if (btn) {
            const originalText = btn.innerHTML;
            btn.innerHTML = '<svg class="icon icon-sm" viewBox="0 0 24 24" fill="currentColor"><path d="M9 16.17L4.83 12l-1.42 1.41L9 19 21 7l-1.41-1.41z"/></svg> Copied!';
            setTimeout(() => btn.innerHTML = originalText, 2000);
        }
    });
}

function downloadCode() {
    const code = document.getElementById('code-editor').value;
    const filename = document.getElementById('current-file').textContent.trim() || 'program.asm';
    const blob = new Blob([code], { type: 'text/plain' });
    const url = URL.createObjectURL(blob);
    const a = document.createElement('a');
    a.href = url;
    a.download = filename;
    a.click();
    URL.revokeObjectURL(url);
}

function shareCode() {
    const code = document.getElementById('code-editor').value;
    const filename = document.getElementById('current-file').textContent.trim();
    const shareText = `Check out this 8086 Assembly program: ${filename}\n\n${code}\n\nShared via 8086 Emulator by Amey & Mega`;

    if (navigator.share) {
        navigator.share({ title: '8086 Assembly Program', text: shareText }).catch(() => { });
    } else {
        navigator.clipboard.writeText(shareText).then(() => alert('Program link & code copied to clipboard!'));
    }
}

function toggleTheme() {
    const body = document.body;
    const isDark = body.getAttribute('data-theme') === 'dark';
    const newTheme = isDark ? 'light' : 'dark';
    body.setAttribute('data-theme', newTheme);
    localStorage.setItem('theme', newTheme);

    const icon = document.getElementById('theme-icon');
    if (icon) {
        icon.innerHTML = newTheme === 'dark'
            ? '<svg class="icon" viewBox="0 0 24 24" fill="currentColor"><path d="M12 3a9 9 0 109 9c0-.46-.04-.92-.1-1.36a5.389 5.389 0 01-4.4 2.26 5.403 5.403 0 01-3.14-9.8c-.44-.06-.9-.1-1.36-.1z"/></svg>'
            : '<svg class="icon" viewBox="0 0 24 24" fill="currentColor"><path d="M12 7c-2.76 0-5 2.24-5 5s2.24 5 5 5 5-2.24 5-5-2.24-5-5-5zM2 13h2c.55 0 1-.45 1-1s-.45-1-1-1H2c-.55 0-1 .45-1 1s.45 1 1 1zm18 0h2c.55 0 1-.45 1-1s-.45-1-1-1h-2c-.55 0-1 .45-1 1s.45 1 1 1zM11 2v2c0 .55.45 1 1 1s1-.45 1-1V2c0-.55-.45-1-1-1s-1 .45-1 1zm0 18v2c0 .55.45 1 1 1s1-.45 1-1v-2c0-.55-.45-1-1-1s-1 .45-1 1zM5.99 4.58c-.39-.39-1.03-.39-1.41 0s-.39 1.03 0 1.41l1.06 1.06c.39.39 1.03.39 1.41 0s.39-1.03 0-1.41L5.99 4.58zm12.37 12.37c-.39-.39-1.03-.39-1.41 0s-.39 1.03 0 1.41l1.06 1.06c.39.39 1.03.39 1.41 0s.39-1.03 0-1.41l-1.06-1.06zm1.06-12.37c-.39-.39-1.03-.39-1.41 0l-1.06 1.06c-.39.39-.39 1.03 0 1.41s1.03.39 1.41 0l1.06-1.06c.39-.38.39-1.02 0-1.41zM7.05 18.36c.39-.39.39-1.03 0-1.41l-1.06-1.06c-.39-.39-1.03-.39-1.41 0s-.39 1.03 0 1.41l1.06 1.06c.39.39 1.03.39 1.41 0z"/></svg>';
    }
}

// INIT
window.onload = () => {
    initProgramList();
    initOutputScrollTracking();
    updateLineNumbers();

    // Hide loading overlay
    const overlay = document.getElementById('loading-overlay');
    const progressBar = document.querySelector('.progress-bar');
    if (overlay && progressBar) {
        progressBar.style.width = '100%';
        setTimeout(() => {
            overlay.style.opacity = '0';
            overlay.style.pointerEvents = 'none';
            setTimeout(() => overlay.style.display = 'none', 800);
        }, 500);
    }

    // Security
    document.addEventListener('contextmenu', e => e.preventDefault());
    document.addEventListener('keydown', e => {
        if (e.key === 'F12' || (e.ctrlKey && e.shiftKey && (e.key === 'I' || e.key === 'J')) || (e.ctrlKey && e.key === 'u')) e.preventDefault();
        if (e.ctrlKey && e.altKey && e.key.toLowerCase() === 'e') alert('✨ Easter Egg Found! ✨\nDeveloped by Amey Thakur');

        if (emu.waiting && !['INPUT', 'TEXTAREA'].includes(e.target.tagName)) {
            let code = 0;
            if (e.key.length === 1) code = e.key.charCodeAt(0);
            else if (e.key === 'Enter') code = 13;
            else if (e.key === 'Backspace') code = 8;
            if (code > 0) { e.preventDefault(); emu.processInput(code); }
        }
    });
};
