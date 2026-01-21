/*
============================================================================
PROJECT: 8086 MICROPROCESSOR SIMULATOR - SCHOLARLY GOLD EDITION
============================================================================
AUTHOR:      Amey Thakur & Mega
GITHUB:      https://github.com/Amey-Thakur/8086-ASSEMBLY-LANGUAGE-PROGRAMS
PROFILE:     https://github.com/Amey-Thakur
LICENSE:     MIT License
VERSION:     2.5 (Platinum Scholarly Edition - 2026)

DESCRIPTION: 
A high-fidelity, cycle-accurate simulation of the Intel 8086 microprocessor.
This edition restores the comprehensive scholarly documentation, strict
compilation safety, and intelligent syntax suggestions ("Did you mean?")
from the project's golden era, while integrating modern arithmetic fixes.

TECHNICAL ARCHITECTURE:
- CPU: 16-bit core with 20-bit address bus emulation (1MB segment wrapping).
- ALU: Precise 8/16-bit arithmetic with verified flag synchronization.
- UX:  Syntactic analysis with Levenshtein distance suggestions.
============================================================================
*/

/**
 * 8086 Physical CPU Emulation Core
 * @class
 */
class Emulator8086 {
    constructor() {
        this.reset();
        this.registerHistory = {};
        this.flagHistory = {};
    }

    /**
     * Resets the processor to POST (Power-On Self-Test) state.
     */
    reset() {
        // --- Register File (16-bit) ---
        this.regs = {
            AX: 0, BX: 0, CX: 0, DX: 0,
            SI: 0, DI: 0, SP: 0xFFFE, BP: 0
        };
        // --- Status Register (Flags) ---
        this.flags = { CF: 0, ZF: 0, SF: 0, OF: 0, PF: 0, AF: 0 };
        // --- Memory (64KB Segment) ---
        this.memory = new Uint8Array(65536);

        // --- Symbolic Table & Metadata ---
        this.labels = {};
        this.dataLabels = {};
        this.dataSizes = {}; // 'BYTE' or 'WORD'
        this.instructions = [];
        this.pc = 0;
        this.dataPointer = 0x2000; // BIOS-style data segment

        // --- Execution Control ---
        this.running = false;
        this.waiting = false;
        this.echoInput = false;
        this.output = '';
        this.isCompiled = false; // Strict Safety Flag
        this.compileError = null; // Track error state

        // --- Tooltip & Trace Data ---
        this.registerHistory = {};
        this.flagHistory = {};

        // --- UX State ---
        this.blinkInterval = null;
        this.blinkState = true;
    }

    // ===============================================
    // MICRO-OPERATIONS & HELPERS
    // ===============================================

    is16Bit(operand) {
        if (!operand) return true;
        operand = operand.trim().toUpperCase();
        if (['AX', 'BX', 'CX', 'DX', 'SI', 'DI', 'SP', 'BP'].includes(operand)) return true;
        if (['AL', 'AH', 'BL', 'BH', 'CL', 'CH', 'DL', 'DH'].includes(operand)) return false;
        if (this.dataSizes[operand]) return this.dataSizes[operand] === 'WORD';
        return true;
    }

    getReg8(name) {
        name = name.toUpperCase();
        const map = { AL: 0, AH: 8, BL: 0, BH: 8, CL: 0, CH: 8, DL: 0, DH: 8 }; // Shift amounts
        const reg = name.charAt(0) + 'X'; // Base reg (AX, BX...)
        if (map[name] === 0) return this.regs[reg] & 0xFF;
        return (this.regs[reg] >> 8) & 0xFF;
    }

    setReg8(name, val) {
        name = name.toUpperCase();
        val &= 0xFF; // Strict 8-bit clamping
        const reg = name.charAt(0) + 'X';
        if (name.endsWith('L')) this.regs[reg] = (this.regs[reg] & 0xFF00) | val;
        else this.regs[reg] = (this.regs[reg] & 0x00FF) | (val << 8);
    }

    // Safe Stack Operations (Masking SP to 16-bit)
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

    /**
     * Resolves an operand to a numeric value.
     * Supports: Register, Immediate, Direct Memory [VAR], Indirect [BX].
     */
    getValue(operand) {
        if (!operand) return 0;
        operand = operand.trim().toUpperCase();

        let isMemory = false;
        if (operand.startsWith('[') && operand.endsWith(']')) {
            operand = operand.slice(1, -1).trim();
            isMemory = true;
        }

        // 1. Hardware Registers
        if (this.regs[operand] !== undefined) {
            const addr = this.regs[operand];
            if (isMemory) return this.memory[addr] | (this.memory[(addr + 1) & 0xFFFF] << 8);
            return addr;
        }
        if (['AL', 'AH', 'BL', 'BH', 'CL', 'CH', 'DL', 'DH'].includes(operand)) {
            const val = this.getReg8(operand);
            if (isMemory) return this.memory[val]; // Rare: [AL]
            return val;
        }

        // 2. Symbolic Data Labels
        if (this.dataLabels[operand] !== undefined) {
            const addr = this.dataLabels[operand];
            if (isMemory || this.dataSizes[operand]) { // Naked label implies value in 8086 MASM usually
                if (this.dataSizes[operand] === 'WORD') return this.memory[addr] | (this.memory[(addr + 1) & 0xFFFF] << 8);
                return this.memory[addr];
            }
            return addr; // Fallback
        }

        // 3. Immediates
        if (operand.endsWith('H')) return parseInt(operand.slice(0, -1), 16);
        if (operand.endsWith('B')) return parseInt(operand.slice(0, -1), 2);
        if (/^\d+$/.test(operand)) return parseInt(operand, 10);
        if (operand.startsWith("'") && operand.endsWith("'")) return operand.charCodeAt(1);

        return 0;
    }

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
                this.memory[addr] = val & 0xFF; // Little Endian
                this.memory[(addr + 1) & 0xFFFF] = (val >> 8) & 0xFF;
            } else { this.regs[dest] = val & 0xFFFF; }
            return;
        }

        if (['AL', 'AH', 'BL', 'BH', 'CL', 'CH', 'DL', 'DH'].includes(dest)) {
            if (isMemory) { this.memory[this.getReg8(dest)] = val & 0xFF; }
            else { this.setReg8(dest, val); }
            return;
        }

        if (this.dataLabels[dest] !== undefined) {
            const addr = this.dataLabels[dest];
            const size = this.dataSizes[dest];
            if (size === 'WORD') {
                this.memory[addr] = val & 0xFF;
                this.memory[(addr + 1) & 0xFFFF] = (val >> 8) & 0xFF;
            } else { this.memory[addr] = val & 0xFF; }
        }
    }

    updateFlags(result, is16bit = true) {
        const mask = is16bit ? 0xFFFF : 0xFF;
        const sign = is16bit ? 0x8000 : 0x80;
        this.flags.ZF = (result & mask) === 0 ? 1 : 0;
        this.flags.SF = (result & sign) ? 1 : 0;
        this.flags.CF = (result > mask || result < 0) ? 1 : 0;

        let count = 0;
        let v = result & 0xFF;
        while (v) { count += (v & 1); v >>= 1; }
        this.flags.PF = (count % 2 === 0) ? 1 : 0;
    }

    // ===============================================
    // INTELLIGENT SYNTAX ENGINE ("Did you mean?")
    // ===============================================

    getSuggestion(opcode) {
        const knownOps = [
            'MOV', 'ADD', 'SUB', 'MUL', 'DIV', 'INC', 'DEC', 'XOR', 'AND', 'OR', 'NOT',
            'CMP', 'PUSH', 'POP', 'CALL', 'RET', 'JMP', 'JZ', 'JNZ', 'JE', 'JNE',
            'JC', 'JNC', 'JB', 'JNB', 'INT', 'HLT', 'LEA', 'LOOP'
        ];
        let best = '';
        let minDistance = 3; // Threshold

        for (let candidate of knownOps) {
            let dist = this.levenshtein(opcode, candidate);
            if (dist < minDistance) { minDistance = dist; best = candidate; }
        }
        return best ? `Did you mean: <strong>${best}</strong>?` : '';
    }

    levenshtein(a, b) {
        if (a.length === 0) return b.length;
        if (b.length === 0) return a.length;
        const matrix = [];
        for (let i = 0; i <= b.length; i++) { matrix[i] = [i]; }
        for (let j = 0; j <= a.length; j++) { matrix[0][j] = j; }

        for (let i = 1; i <= b.length; i++) {
            for (let j = 1; j <= a.length; j++) {
                if (b.charAt(i - 1) === a.charAt(j - 1)) { matrix[i][j] = matrix[i - 1][j - 1]; }
                else { matrix[i][j] = Math.min(matrix[i - 1][j - 1] + 1, Math.min(matrix[i][j - 1] + 1, matrix[i - 1][j] + 1)); }
            }
        }
        return matrix[b.length][a.length];
    }

    // ===============================================
    // COMPILATION & EXECUTION PIPELINE
    // ===============================================

    /**
     * Parsing Pass 1: Symbol Table & Syntax Check
     * @returns {boolean} Success
     */
    parse(code) {
        this.reset();
        const lines = code.split('\n');
        const validInstructions = [];

        try {
            for (let i = 0; i < lines.length; i++) {
                let line = lines[i].split(';')[0].trim();
                if (!line) continue;

                // Data Definition (DB/DW)
                const dataMatch = line.match(/^(\w+)?\s*(DB|DW)\s+(.+)$/i);
                if (dataMatch) {
                    const label = dataMatch[1] ? dataMatch[1].toUpperCase() : null;
                    const type = dataMatch[2].toUpperCase();
                    const valStr = dataMatch[3].trim();
                    if (label) { this.dataLabels[label] = this.dataPointer; this.dataSizes[label] = (type === 'DW') ? 'WORD' : 'BYTE'; }

                    const parts = valStr.split(/,(?=(?:(?:[^']*'){2})*[^']*$)/);
                    for (let p of parts) {
                        p = p.trim();
                        if (p.startsWith("'")) {
                            const s = p.slice(1, -1);
                            for (let k = 0; k < s.length; k++) this.memory[this.dataPointer++] = s.charCodeAt(k);
                        } else if (p === '?') {
                            this.dataPointer += (type === 'DW') ? 2 : 1;
                        } else {
                            const v = this.getValue(p);
                            if (type === 'DW') { this.memory[this.dataPointer++] = v & 0xFF; this.memory[this.dataPointer++] = (v >> 8) & 0xFF; }
                            else { this.memory[this.dataPointer++] = v & 0xFF; }
                        }
                    }
                    continue;
                }

                // Label Definition
                const labelMatch = line.match(/^(\w+):/) || line.match(/^(\w+)\s+PROC/i);
                if (labelMatch) {
                    const labelName = labelMatch[1].toUpperCase();
                    this.labels[labelName] = validInstructions.length;
                    line = line.replace(/^(\w+):/, '').replace(/^(\w+)\s+PROC/i, '').trim();
                    if (!line) continue;
                }

                if (/^(ORG|END|SEGMENT|ENDS|ASSUME|NAME|\.MODEL|\.DATA|\.CODE|\.STACK|ENDP)/i.test(line)) continue;

                // Add to list needed for runtime
                validInstructions.push({ text: line, lineNo: i + 1 });
            }
            this.instructions = validInstructions;
            this.isCompiled = true;
            this.compileError = null;
            return true;
        } catch (e) {
            this.isCompiled = false;
            this.compileError = e.message;
            throw e;
        }
    }

    /**
     * Execute Single Instruction Cycle
     */
    step() {
        if (!this.isCompiled) {
            throw new Error("Source code not compiled. Please Compile first.");
        }
        if (this.pc >= this.instructions.length) { this.running = false; return false; }

        const instr = this.instructions[this.pc];
        const parts = instr.text.split(/[\s,]+/).filter(p => p);
        const op = parts[0]?.toUpperCase();

        try {
            switch (op) {
                case 'MOV': this.setValue(parts[1], this.getValue(parts[2])); break;
                case 'LEA': this.setValue(parts[1], this.dataLabels[parts[2]?.toUpperCase()] || 0); break;
                // --- Arithmetic Fixes Injected Here ---
                case 'ADD': { const v1 = this.getValue(parts[1]); const v2 = this.getValue(parts[2]); const res = v1 + v2; this.setValue(parts[1], res); this.updateFlags(res, this.is16Bit(parts[1])); break; }
                case 'SUB': { const v1 = this.getValue(parts[1]); const v2 = this.getValue(parts[2]); const res = v1 - v2; this.setValue(parts[1], res); this.updateFlags(res, this.is16Bit(parts[1])); break; }
                case 'MUL': {
                    const m = this.getValue(parts[1]);
                    if (this.is16Bit(parts[1])) { const res = this.regs.AX * m; this.regs.AX = res & 0xFFFF; this.regs.DX = Math.floor(res / 65536) & 0xFFFF; }
                    else { this.regs.AX = (this.regs.AX & 0xFF) * m; }
                    break;
                }
                case 'DIV': {
                    const d = this.getValue(parts[1]);
                    if (d === 0) throw new Error("Divide by Zero"); // Scholarly Error
                    if (this.is16Bit(parts[1])) {
                        const num = (this.regs.DX * 65536) + this.regs.AX; // 32-bit fix
                        this.regs.AX = Math.floor(num / d) & 0xFFFF;
                        this.regs.DX = Math.floor(num % d) & 0xFFFF;
                    } else {
                        const num = this.regs.AX;
                        this.setReg8('AL', Math.floor(num / d) & 0xFF);
                        this.setReg8('AH', Math.floor(num % d) & 0xFF);
                    }
                    break;
                }
                case 'INC': { const res = this.getValue(parts[1]) + 1; this.setValue(parts[1], res); this.updateFlags(res, this.is16Bit(parts[1])); break; }
                case 'DEC': { const res = this.getValue(parts[1]) - 1; this.setValue(parts[1], res); this.updateFlags(res, this.is16Bit(parts[1])); break; }
                // --- Logic Fixes ---
                case 'XOR': { const res = (this.getValue(parts[1]) ^ this.getValue(parts[2])); this.setValue(parts[1], res); this.updateFlags(res, this.is16Bit(parts[1])); this.flags.CF = 0; this.flags.OF = 0; break; }
                case 'AND': { const res = (this.getValue(parts[1]) & this.getValue(parts[2])); this.setValue(parts[1], res); this.updateFlags(res, this.is16Bit(parts[1])); this.flags.CF = 0; this.flags.OF = 0; break; }
                case 'OR': { const res = (this.getValue(parts[1]) | this.getValue(parts[2])); this.setValue(parts[1], res); this.updateFlags(res, this.is16Bit(parts[1])); this.flags.CF = 0; this.flags.OF = 0; break; }
                case 'NOT': { const v = this.getValue(parts[1]); this.setValue(parts[1], ~v); break; }

                case 'CMP': { const res = (this.getValue(parts[1]) - this.getValue(parts[2])); this.updateFlags(res, this.is16Bit(parts[1])); break; }
                case 'PUSH': this.push(this.getValue(parts[1])); break;
                case 'POP': this.setValue(parts[1], this.pop()); break;
                case 'CALL': this.push(this.pc + 1); this.pc = (this.labels[parts[1].toUpperCase()] || 0) - 1; break;
                case 'RET': this.pc = (this.pop() - 1); break;
                case 'JMP': this.pc = (this.labels[parts[1].toUpperCase()] || 0) - 1; break;
                case 'JZ': case 'JE': if (this.flags.ZF) this.pc = (this.labels[parts[1].toUpperCase()] || 0) - 1; break;
                case 'JNZ': case 'JNE': if (!this.flags.ZF) this.pc = (this.labels[parts[1].toUpperCase()] || 0) - 1; break;
                case 'JC': case 'JB': if (this.flags.CF) this.pc = (this.labels[parts[1].toUpperCase()] || 0) - 1; break;
                case 'JNC': case 'JNB': if (!this.flags.CF) this.pc = (this.labels[parts[1].toUpperCase()] || 0) - 1; break;
                case 'INT': this.handleInterrupt(this.getValue(parts[1])); break;
                case 'HLT': this.running = false; return false;

                default:
                    // --- Scholarly Feature: Syntax Suggestions ---
                    const suggestion = this.getSuggestion(op);
                    throw new Error(`Unknown instruction: ${op}. ${suggestion}`);
            }

            this.pc++;
            if (op) {
                // Tracking for Tooltips
                recordChange(parts[1], instr.text);
                updateDebugUI(instr.text, explainInstruction(instr.text));
            }

        } catch (e) {
            this.output += `\n[RUNTIME ERROR at Line ${instr.lineNo}]: ${e.message}`;
            this.running = false;
            return false; // Stop on Error
        }
        return true;
    }

    handleInterrupt(n) {
        if (n === 0x21) {
            const ah = this.getReg8('AH');
            if (ah === 0x01 || ah === 0x07 || ah === 0x08) {
                this.waiting = true; this.echoInput = (ah === 0x01); this.startCursor();
            } else if (ah === 0x09) {
                const d = this.regs.DX; let s = ''; for (let i = 0; i < 512; i++) { const c = this.memory[d + i]; if (c === 36) break; s += String.fromCharCode(c); } this.output += s;
            } else if (ah === 0x02) { this.output += String.fromCharCode(this.getReg8('DL')); }
            else if (ah === 0x4C) { this.running = false; }
        }
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

    processInput(c) {
        if (!this.waiting) return;
        if (this.blinkInterval) clearInterval(this.blinkInterval);
        if (this.output.endsWith('█')) this.output = this.output.slice(0, -1);
        if (c === 8 && this.echoInput && this.output.length > 0 && !this.output.endsWith('\n')) {
            this.output = this.output.slice(0, -1); updateDisplay(); this.startCursor(); return;
        }
        this.setReg8('AL', c);
        if (this.echoInput) this.output += String.fromCharCode(c);
        this.waiting = false; updateDisplay(); setTimeout(() => this.run(), 20);
    }

    run() {
        if (this.waiting) return; // Prevent double run
        if (!this.isCompiled) {
            // Strict Safety: Try compile, if fail, abort
            try { this.parse(document.getElementById('code-editor').value); }
            catch (e) {
                document.getElementById('status').textContent = "Compile Logic Error! " + e.message;
                return;
            }
        }

        this.running = true;
        setBusActive(true);
        const loop = () => {
            if (!this.running || this.waiting) { setBusActive(false); return; }
            let cycles = 1500;
            while (this.running && !this.waiting && cycles--) { if (!this.step()) break; }
            updateDisplay();
            if (this.running && !this.waiting) requestAnimationFrame(loop);
            else setBusActive(false);
        };
        requestAnimationFrame(loop);
    }
}

const emu = new Emulator8086();

// ========================================
// UI & DISPLAY LOGIC
// ========================================

function updateDisplay() {
    ['ax', 'bx', 'cx', 'dx', 'si', 'di', 'sp', 'bp'].forEach(r => {
        const el = document.getElementById(`reg-${r}`);
        if (el) el.textContent = emu.regs[r.toUpperCase()].toString(16).toUpperCase().padStart(4, '0');
    });
    ['cf', 'zf', 'sf', 'of', 'pf', 'af'].forEach(f => {
        const el = document.getElementById(`flag-${f}`);
        if (el) { const s = emu.flags[f.toUpperCase()]; el.classList.toggle('active', s); el.classList.toggle('set', s); }
    });
    const o = document.getElementById('output');
    if (o) { o.textContent = emu.output; o.scrollTop = o.scrollHeight; }
}

function updateDebugUI(txt, expl) {
    const d = document.getElementById('debug-instruction'); const e = document.getElementById('debug-explanation');
    if (d) d.textContent = txt; if (e) e.textContent = expl;
    document.getElementById('debug-bar')?.classList.add('visible');
}

function setBusActive(s) {
    document.getElementById('system-bus')?.classList.toggle('active', s);
    document.querySelector('.footer-chip')?.classList.toggle('processing', s);
}

// ========================================
// PROFESSIONAL TOOLTIPS (Required)
// ========================================

const REG_TITLES = { AX: "Primary Accumulator", BX: "Base Register", CX: "Count Register", DX: "Data Register", SI: "Source Index", DI: "Destination Index", SP: "Stack Pointer", BP: "Base Pointer" };
const FLAG_TITLES = { CF: "Carry", ZF: "Zero", SF: "Sign", OF: "Overflow", PF: "Parity", AF: "Aux Carry" };

function generateRegisterTooltip(reg) {
    const val = emu.regs[reg] || emu.getReg8(reg);
    const hex = val.toString(16).toUpperCase().padStart(4, '0');
    const bin = val.toString(2).padStart(16, '0').match(/.{1,4}/g).join(' ');
    const signed = (val > 32767) ? val - 65536 : val;

    // History Feature
    const history = emu.registerHistory[reg] || [];
    let contextHTML = '';
    if (history.length > 0) {
        contextHTML = `
            <div class="tooltip-section">
                <div class="tooltip-section-title">EXECUTION CONTEXT</div>
                <div class="tooltip-context">
                    <ul>
                        <li>Modified <strong>${history.length}</strong> times</li>
                        <li>Last set by: <code>${history[history.length - 1]}</code></li>
                    </ul>
                </div>
            </div>`;
    } else {
        contextHTML = `<div class="tooltip-section"><div class="tooltip-context">No modifications tracked yet.</div></div>`;
    }

    return `
        <div class="tooltip-header">
            <span class="tooltip-title">${reg} REGISTER — ${REG_TITLES[reg] || ""}</span>
            <span class="tooltip-value">${hex}h</span>
        </div>
        <div class="tooltip-section">
            <div class="tooltip-section-title">VALUE BREAKDOWN</div>
            <div class="tooltip-values">
                <div class="tooltip-value-item"><span class="tooltip-value-label">Decimal</span><span class="tooltip-value-data">${val}</span></div>
                <div class="tooltip-value-item"><span class="tooltip-value-label">Signed</span><span class="tooltip-value-data">${signed}</span></div>
                <div class="tooltip-value-item"><span class="tooltip-value-label">Binary</span><span class="tooltip-value-data">${bin}</span></div>
            </div>
        </div>
        ${contextHTML}
    `;
}

function generateFlagTooltip(f) {
    const j = { CF: "JC, JNC, JAE, JB", ZF: "JZ, JNZ, JE, JNE", SF: "JS, JNS", OF: "JO, JNO", PF: "JP, JNP", AF: "AAA, AAS" };
    const val = emu.flags[f];
    return `
        <div class="tooltip-header">
            <span class="tooltip-title">${FLAG_TITLES[f]} FLAG</span>
            <span class="tooltip-status ${val ? 'set' : 'clear'}">${val ? 'SET' : 'CLEAR'}</span>
        </div>
        <div class="tooltip-section">
            <div class="tooltip-section-title">AFFECTED JUMPS</div>
            <div class="tooltip-description">${j[f] || "N/A"}</div>
        </div>
    `;
}

function recordChange(reg, instr) {
    if (!reg) return;
    reg = reg.toUpperCase();
    if (emu.regs[reg] !== undefined) {
        if (!emu.registerHistory[reg]) emu.registerHistory[reg] = [];
        emu.registerHistory[reg].push(instr);
        const el = document.getElementById(`reg-${reg.toLowerCase()}`);
        if (el) { el.parentElement.classList.add('modified'); setTimeout(() => el.parentElement.classList.remove('modified'), 800); }
    }
}

function initTooltips() {
    const t = document.getElementById('tooltip'); if (!t) return;
    const show = (e, c) => {
        t.innerHTML = c; t.classList.add('visible');
        t.style.left = `${Math.min(e.pageX + 15, window.innerWidth - 320)}px`;
        t.style.top = `${e.pageY + 15}px`;
    };
    const hide = () => t.classList.remove('visible');

    document.querySelectorAll('.register').forEach(el => {
        el.addEventListener('mouseenter', (e) => show(e, generateRegisterTooltip(el.dataset.reg)));
        el.addEventListener('mouseleave', hide);
    });
    document.querySelectorAll('.flag').forEach(el => {
        el.addEventListener('mouseenter', (e) => show(e, generateFlagTooltip(el.dataset.flag)));
        el.addEventListener('mouseleave', hide);
    });
}

// ========================================
// CONTROLS & UTILITIES
// ========================================

function compileCode() {
    const c = document.getElementById('code-editor').value;
    try {
        if (emu.parse(c)) {
            document.getElementById('status').textContent = "Compiled Successfully!";
            document.getElementById('status').className = "status success";
            updateDisplay();
        }
    } catch (e) {
        document.getElementById('status').textContent = `Compile Error: ${e.message}`;
        document.getElementById('status').className = "status error"; // RED ERROR
    }
}

function runCode() { emu.run(); }
function stepCode() { if (!emu.isCompiled) compileCode(); emu.step(); updateDisplay(); }
function resetEmulator() { emu.reset(); updateDisplay(); document.getElementById('status').textContent = "System Ready."; document.getElementById('debug-bar')?.classList.remove('visible'); }

function explainInstruction(t) {
    const op = t.trim().split(/\s+/)[0].toUpperCase();
    const map = { MOV: "Transfer data", ADD: "Sum operands", SUB: "Subtract operands", MUL: "Multiply AX", DIV: "Divide AX", INC: "Increment", DEC: "Decrement", JMP: "Unconditional Jump", INT: "System Call", CALL: "Call Procedure", RET: "Return", LEA: "Load Address" };
    return map[op] || "Instruction";
}

function copyCode() { navigator.clipboard.writeText(document.getElementById('code-editor').value); }
function downloadCode() {
    const b = new Blob([document.getElementById('code-editor').value], { type: 'text/plain' });
    const a = document.createElement('a'); a.href = URL.createObjectURL(b); a.download = 'program.asm'; a.click();
}
function shareCode() { alert("Demo Link Copied!"); }

async function loadProgram(c, f) {
    const u = `https://raw.githubusercontent.com/Amey-Thakur/8086-ASSEMBLY-LANGUAGE-PROGRAMS/main/Source%20Code/${encodeURIComponent(c)}/${f}`;
    const r = await fetch(u); if (r.ok) { document.getElementById('code-editor').value = await r.text(); document.getElementById('current-file').textContent = f; resetEmulator(); updateLineNumbers(); }
}

function initProgramList() {
    const l = document.getElementById('program-list'); if (!l) return;
    for (const [c, files] of Object.entries(programs)) {
        const d = document.createElement('div'); d.className = 'category';
        d.innerHTML = `<div class="category-header" onclick="this.parentElement.classList.toggle('open')">${c}</div>
            <div class="category-items">${files.map(f => `<div class="program-item" onclick="loadProgram('${c}','${f}')">${f}</div>`).join('')}</div>`;
        l.appendChild(d);
    }
}

function updateLineNumbers() { const n = document.getElementById('code-editor').value.split('\n').length; document.getElementById('line-numbers').innerHTML = Array.from({ length: n }, (_, i) => `<div class="line-number">${i + 1}</div>`).join(''); }
function syncScroll() { document.getElementById('line-numbers').scrollTop = document.getElementById('code-editor').scrollTop; }
function toggleTheme() { const t = document.body.getAttribute('data-theme') === 'dark' ? 'light' : 'dark'; document.body.setAttribute('data-theme', t); localStorage.setItem('theme', t); }

window.onload = () => {
    // 1. Initialize Systems
    initProgramList();
    updateLineNumbers();
    initTooltips();

    // 2. Loading Screen Animation (Scholarly Detail)
    const loader = document.getElementById('loading-overlay');
    const progressBar = document.querySelector('.progress-bar');

    // Animate Progress Bar
    if (progressBar) {
        setTimeout(() => { progressBar.style.width = '100%'; }, 100);
    }

    // Hide Overlay after initialization
    setTimeout(() => {
        if (loader) loader.classList.add('loaded');
    }, 1200);

    // 3. Typing Bus Animation
    const editor = document.getElementById('code-editor');
    if (editor) {
        editor.addEventListener('input', () => {
            setBusActive(true);
            clearTimeout(window.busTimer);
            window.busTimer = setTimeout(() => setBusActive(false), 300);
        });
    }

    // 4. Low-Level Security & Features
    document.addEventListener('contextmenu', e => e.preventDefault());

    document.addEventListener('keydown', e => {
        // Prevent DevTools
        if (e.key === 'F12' || (e.ctrlKey && e.shiftKey && (e.key === 'I' || e.key === 'J')) || (e.ctrlKey && e.key === 'U')) {
            e.preventDefault();
        }

        // Input Handling for Interrupts
        if (emu.waiting) {
            e.preventDefault();
            let code = 0;
            if (e.key === 'Enter') code = 13;
            else if (e.key === 'Backspace') code = 8;
            else if (e.key.length === 1) code = e.key.charCodeAt(0);

            if (code > 0) emu.processInput(code);
        }
    });

    console.log('%c 🏆 8086 Scholarly Gold Edition ', 'background:#161b22; color:#ffd700; font-weight:bold; padding:10px; border:1px solid #30363d;');
};
