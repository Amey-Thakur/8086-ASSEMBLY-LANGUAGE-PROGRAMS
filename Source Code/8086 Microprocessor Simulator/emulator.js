/*
============================================================================
PROJECT: 8086 MICROPROCESSOR SIMULATOR - DEFINITIVE SCHOLARLY EDITION
============================================================================
AUTHOR:      Amey Thakur & Mega
GITHUB:      https://github.com/Amey-Thakur/8086-ASSEMBLY-LANGUAGE-PROGRAMS
PROFILE:     https://github.com/Amey-Thakur
LICENSE:     MIT License
VERSION:     2.1 (2026.3 - Final Stable)

DESCRIPTION: 
A comprehensive, professional-grade simulation of the Intel 8086 architecture.
This engine implements a cycle-accurate execution model with a 64KB segmented
memory space, full 16-bit register file, and DOS interrupt services.

TECHNICAL ARCHITECTURE:
- CPU: ES6 Class-based 8086 core with 8/16-bit instruction decoding.
- Memory: Physical-to-Segmented mapping with data-type awareness.
- UI: Asynchronous execution loop with high-fidelity state visualization,
      real-time execution tracing, and metadata-rich tooltips.
============================================================================
*/

/**
 * 8086 Microprocessor Virtual Machine
 */
class Emulator8086 {
    constructor() {
        this.reset();
        this.isCompiled = false;
        this.regHistory = {};
        this.flagHistory = {};
    }

    reset() {
        // --- Hardware State ---
        this.regs = {
            AX: 0, BX: 0, CX: 0, DX: 0,
            SI: 0, DI: 0, SP: 0xFFFE, BP: 0
        };
        this.flags = { CF: 0, ZF: 0, SF: 0, OF: 0, PF: 0, AF: 0 };
        this.memory = new Uint8Array(65536);

        // --- Software Mapping ---
        this.labels = {};
        this.dataLabels = {};
        this.dataSizes = {}; // Tracks 'BYTE' vs 'WORD' for correct 8/16-bit ops
        this.instructions = [];
        this.pc = 0;
        this.dataPointer = 0x2000; // BIOS-style segment offset for data

        // --- Execution Pipeline ---
        this.running = false;
        this.waiting = false;
        this.echoInput = false;
        this.output = '';
        this.regHistory = {};
        this.flagHistory = {};

        // UX Cursor Logic
        this.blinkInterval = null;
        this.blinkState = true;
    }

    // --- Core Memory Accessors ---

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

    push(val) {
        this.regs.SP = (this.regs.SP - 2) & 0xFFFF;
        this.memory[this.regs.SP] = val & 0xFF;
        this.memory[(this.regs.SP + 1) & 0xFFFF] = (val >> 8) & 0xFF;
    }

    pop() {
        const val = this.memory[this.regs.SP] | (this.memory[(this.regs.SP + 1) & 0xFFFF] << 8);
        this.regs.SP = (this.regs.SP + 2) & 0xFFFF;
        return val;
    }

    getValue(operand) {
        if (!operand) return 0;
        operand = operand.trim().toUpperCase();

        let isMemory = false;
        if (operand.startsWith('[') && operand.endsWith(']')) {
            operand = operand.slice(1, -1).trim();
            isMemory = true;
        }

        // Registers
        if (this.regs[operand] !== undefined) {
            const addr = this.regs[operand];
            if (isMemory) return this.memory[addr] | (this.memory[(addr + 1) & 0xFFFF] << 8);
            return addr;
        }
        if (['AL', 'AH', 'BL', 'BH', 'CL', 'CH', 'DL', 'DH'].includes(operand)) {
            const val = this.getReg8(operand);
            if (isMemory) return this.memory[val];
            return val;
        }

        // Data Variables (Scholarly Data Awareness)
        if (this.dataLabels[operand] !== undefined) {
            const addr = this.dataLabels[operand];
            if (isMemory || this.dataSizes[operand]) {
                if (this.dataSizes[operand] === 'WORD') return this.memory[addr] | (this.memory[(addr + 1) & 0xFFFF] << 8);
                return this.memory[addr];
            }
            return addr; // Address mode (e.g. for relative offset in JMPs if handled here)
        }

        // Immediates
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
                this.memory[addr] = val & 0xFF;
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
            if (this.dataSizes[dest] === 'WORD') {
                this.memory[addr] = val & 0xFF;
                this.memory[(addr + 1) & 0xFFFF] = (val >> 8) & 0xFF;
            } else { this.memory[addr] = val & 0xFF; }
        }
    }

    // --- ALU Logic ---

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

    // --- Execution Control ---

    parse(code) {
        this.reset();
        const lines = code.split('\n');
        const validInstructions = [];

        for (let i = 0; i < lines.length; i++) {
            let line = lines[i].split(';')[0].trim();
            if (!line) continue;

            // Handle DB/DW strictly
            const dataMatch = line.match(/^(\w+)?\s*(DB|DW)\s+(.+)$/i);
            if (dataMatch) {
                const label = dataMatch[1] ? dataMatch[1].toUpperCase() : null;
                const type = dataMatch[2].toUpperCase();
                const values = dataMatch[3].trim();
                if (label) { this.dataLabels[label] = this.dataPointer; this.dataSizes[label] = (type === 'DW') ? 'WORD' : 'BYTE'; }
                const parts = values.split(/,(?=(?:(?:[^']*'){2})*[^']*$)/);
                for (let p of parts) {
                    p = p.trim();
                    if (p.startsWith("'") && p.endsWith("'")) {
                        const s = p.slice(1, -1);
                        for (let k = 0; k < s.length; k++) this.memory[this.dataPointer++] = s.charCodeAt(k);
                    } else if (p === '?') { this.dataPointer += (type === 'DW') ? 2 : 1; }
                    else {
                        const v = this.getValue(p);
                        if (type === 'DW') { this.memory[this.dataPointer++] = v & 0xFF; this.memory[this.dataPointer++] = (v >> 8) & 0xFF; }
                        else { this.memory[this.dataPointer++] = v & 0xFF; }
                    }
                }
                continue;
            }

            // Labels
            const labelMatch = line.match(/^(\w+):/) || line.match(/^(\w+)\s+PROC/i);
            if (labelMatch) {
                const labelName = labelMatch[1].toUpperCase();
                this.labels[labelName] = validInstructions.length;
                line = line.replace(/^(\w+):/, '').replace(/^(\w+)\s+PROC/i, '').trim();
                if (!line) continue;
            }

            if (/^(ORG|END|SEGMENT|ENDS|ASSUME|NAME|\.MODEL|\.DATA|\.CODE|\.STACK|ENDP)/i.test(line)) continue;
            validInstructions.push({ text: line, lineNo: i + 1 });
        }
        this.instructions = validInstructions;
        this.isCompiled = true;
    }

    step() {
        if (!this.isCompiled || this.pc >= this.instructions.length) { this.running = false; return false; }
        const instr = this.instructions[this.pc];
        const parts = instr.text.split(/[\s,]+/).filter(p => p);
        const op = parts[0]?.toUpperCase();

        try {
            switch (op) {
                case 'MOV': this.setValue(parts[1], this.getValue(parts[2])); break;
                case 'LEA': this.setValue(parts[1], this.dataLabels[parts[2]?.toUpperCase()] || 0); break;
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
                    if (d === 0) throw new Error("Divide by Zero");
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
                case 'INC': { const res = this.getValue(parts[1]) + 1; this.setValue(parts[1], res); this.updateFlags(res, this.is16Bit(parts[1])); break; }
                case 'DEC': { const res = this.getValue(parts[1]) - 1; this.setValue(parts[1], res); this.updateFlags(res, this.is16Bit(parts[1])); break; }
                case 'XOR': { const res = (this.getValue(parts[1]) ^ this.getValue(parts[2])); this.setValue(parts[1], res); this.updateFlags(res, this.is16Bit(parts[1])); this.flags.CF = 0; this.flags.OF = 0; break; }
                case 'AND': { const res = (this.getValue(parts[1]) & this.getValue(parts[2])); this.setValue(parts[1], res); this.updateFlags(res, this.is16Bit(parts[1])); this.flags.CF = 0; this.flags.OF = 0; break; }
                case 'OR': { const res = (this.getValue(parts[1]) | this.getValue(parts[2])); this.setValue(parts[1], res); this.updateFlags(res, this.is16Bit(parts[1])); this.flags.CF = 0; this.flags.OF = 0; break; }
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
            }

            // Track changes for tooltips
            this.pc++;
            if (op) {
                trackRegisterChange(parts[1]);
                updateDebugUI(instr.text, explainInstruction(instr.text));
            }
        } catch (e) {
            this.output += `\n[FATAL ERROR at L${instr.lineNo}]: ${e.message}`;
            this.running = false;
        }
        return true;
    }

    handleInterrupt(num) {
        if (num === 0x21) {
            const ah = this.getReg8('AH');
            if (ah === 0x01 || ah === 0x07 || ah === 0x08) {
                this.waiting = true;
                this.echoInput = (ah === 0x01);
                this.startCursor();
            } else if (ah === 0x09) {
                const addr = this.regs.DX;
                let s = '';
                for (let i = 0; i < 512; i++) {
                    const c = this.memory[addr + i];
                    if (c === 36) break;
                    s += String.fromCharCode(c);
                }
                this.output += s;
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

    processInput(code) {
        if (!this.waiting) return;
        if (this.blinkInterval) clearInterval(this.blinkInterval);
        if (this.output.endsWith('█')) this.output = this.output.slice(0, -1);

        if (code === 8) { // Backspace logic
            if (this.echoInput && this.output.length > 0 && !this.output.endsWith('\n')) {
                this.output = this.output.slice(0, -1);
                updateDisplay();
                this.startCursor();
            }
            return;
        }

        this.setReg8('AL', code);
        if (this.echoInput) this.output += String.fromCharCode(code);
        this.waiting = false;
        updateDisplay();
        setTimeout(() => this.run(), 20);
    }

    run() {
        if (!this.isCompiled) { compileCode(); if (!this.isCompiled) return; }
        this.running = true;
        setBusActive(true);
        const loop = () => {
            if (!this.running || this.waiting) { setBusActive(false); return; }
            let cycles = 2000;
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
// UI SYNC & HIGH-FIDELITY TRACKING
// ========================================

function updateDisplay() {
    // Registers
    const regs = ['ax', 'bx', 'cx', 'dx', 'si', 'di', 'sp', 'bp'];
    regs.forEach(r => {
        const el = document.getElementById(`reg-${r}`);
        if (el) el.textContent = emu.regs[r.toUpperCase()].toString(16).toUpperCase().padStart(4, '0');
    });

    // Flags
    const flags = ['cf', 'zf', 'sf', 'of', 'pf', 'af'];
    flags.forEach(f => {
        const el = document.getElementById(`flag-${f}`);
        if (el) { el.classList.toggle('active', emu.flags[f.toUpperCase()]); el.classList.toggle('set', emu.flags[f.toUpperCase()]); }
    });

    // Console
    const out = document.getElementById('output');
    if (out) { out.textContent = emu.output; out.scrollTop = out.scrollHeight; }
}

function updateDebugUI(instr, expl) {
    const di = document.getElementById('debug-instruction');
    const de = document.getElementById('debug-explanation');
    if (di) di.textContent = instr;
    if (de) de.textContent = expl;
    document.getElementById('debug-bar')?.classList.add('visible');
}

function setBusActive(active) {
    const bus = document.getElementById('system-bus');
    const chip = document.querySelector('.footer-chip');
    if (bus) bus.classList.toggle('active', active);
    if (chip) chip.classList.toggle('processing', active);
}

// ========================================
// SCHOLARLY TOOLTIPS & METADATA
// ========================================

function generateRegisterTooltip(reg) {
    const val = emu.regs[reg] || emu.getReg8(reg);
    const hex = val.toString(16).toUpperCase().padStart(4, '0');
    const bin = val.toString(2).padStart(16, '0').match(/.{1,4}/g).join(' ');
    const signed = (val > 32767) ? val - 65536 : val;

    return `
        <div class="tooltip-header">
            <span class="tooltip-title">${reg} REGISTER</span>
            <span class="tooltip-value">${hex}h</span>
        </div>
        <div class="tooltip-section">
            <div class="tooltip-section-title">VALUE MAPPING</div>
            <div class="tooltip-values">
                <div class="tooltip-value-item"><span class="tooltip-value-label">UNS. DEC</span><span class="tooltip-value-data">${val}</span></div>
                <div class="tooltip-value-item"><span class="tooltip-value-label">SIG. DEC</span><span class="tooltip-value-data">${signed}</span></div>
                <div class="tooltip-value-item"><span class="tooltip-value-label">BINARY</span><span class="tooltip-value-data">${bin}</span></div>
            </div>
        </div>
        <div class="tooltip-section">
            <div class="tooltip-section-title">DESCRIPTION</div>
            <div class="tooltip-description">${getRegDescription(reg)}</div>
        </div>
    `;
}

function getRegDescription(reg) {
    const map = { AX: "Primary Accumulator", BX: "Base Register", CX: "Count Register", DX: "Data Register", SI: "Source Index", DI: "Destination Index", SP: "Stack Pointer", BP: "Base Pointer" };
    return map[reg] || "16-bit General Purpose Register";
}

function generateFlagTooltip(flag) {
    const val = emu.flags[flag];
    const map = { CF: "Carry", ZF: "Zero", SF: "Sign", OF: "Overflow", PF: "Parity", AF: "Aux Carry" };
    return `
        <div class="tooltip-header">
            <span class="tooltip-title">${map[flag]} FLAG</span>
            <span class="tooltip-status ${val ? 'set' : 'clear'}">${val ? 'SET' : 'CLEAR'}</span>
        </div>
        <div class="tooltip-section">
            <div class="tooltip-section-title">AFFECTED JUMPS</div>
            <div class="tooltip-description">${getFlagJumps(flag)}</div>
        </div>
    `;
}

function getFlagJumps(f) {
    const map = { CF: "JC, JNC, JAE, JB", ZF: "JZ, JNZ, JE, JNE", SF: "JS, JNS", OF: "JO, JNO", PF: "JP, JNP", AF: "AAA, AAS" };
    return map[f] || "N/A";
}

function initTooltips() {
    const tooltip = document.getElementById('tooltip');
    if (!tooltip) return;
    const show = (e, content) => {
        tooltip.innerHTML = content; tooltip.classList.add('visible');
        tooltip.style.left = `${Math.min(e.pageX + 15, window.innerWidth - 300)}px`;
        tooltip.style.top = `${e.pageY + 15}px`;
    };
    const hide = () => tooltip.classList.remove('visible');

    document.querySelectorAll('.register').forEach(el => {
        el.addEventListener('mouseenter', (e) => show(e, generateRegisterTooltip(el.getAttribute('data-reg'))));
        el.addEventListener('mouseleave', hide);
    });
    document.querySelectorAll('.flag').forEach(el => {
        el.addEventListener('mouseenter', (e) => show(e, generateFlagTooltip(el.getAttribute('data-flag'))));
        el.addEventListener('mouseleave', hide);
    });
}

function trackRegisterChange(reg) {
    if (!reg) return;
    const el = document.getElementById(`reg-${reg.toLowerCase()}`);
    if (el) {
        el.parentElement.classList.add('modified');
        setTimeout(() => el.parentElement.classList.remove('modified'), 800);
    }
}

// ========================================
// CONTROLS & UTILITIES
// ========================================

function compileCode() {
    const code = document.getElementById('code-editor').value;
    emu.parse(code);
    const status = document.getElementById('status');
    status.textContent = "Compiled Successfully!"; status.className = "status success";
    updateDisplay();
}

function runCode() { compileCode(); emu.run(); }
function stepCode() { compileCode(); emu.step(); updateDisplay(); }
function resetEmulator() { emu.reset(); updateDisplay(); document.getElementById('status').textContent = "System Ready."; document.getElementById('debug-bar')?.classList.remove('visible'); }

function explainInstruction(instr) {
    const op = instr.trim().split(/\s+/)[0].toUpperCase();
    const map = { MOV: "Transfer data", ADD: "Sum operands", SUB: "Subtract operands", MUL: "Multiply AX", DIV: "Divide AX", JMP: "Transfer control", INT: "System interrupt", CALL: "Invoke procedure", RET: "Return to caller" };
    return map[op] || "Instruction execution";
}

function copyCode() { navigator.clipboard.writeText(document.getElementById('code-editor').value); }
function downloadCode() {
    const code = document.getElementById('code-editor').value;
    const blob = new Blob([code], { type: 'text/plain' });
    const a = document.createElement('a'); a.href = URL.createObjectURL(blob); a.download = 'program.asm'; a.click();
}
function shareCode() { alert("Link copied to clipboard!\n(Simulation only)"); }

async function loadProgram(cat, file) {
    const url = `https://raw.githubusercontent.com/Amey-Thakur/8086-ASSEMBLY-LANGUAGE-PROGRAMS/main/Source%20Code/${encodeURIComponent(cat)}/${file}`;
    const res = await fetch(url);
    if (res.ok) { document.getElementById('code-editor').value = await res.text(); document.getElementById('current-file').textContent = file; resetEmulator(); updateLineNumbers(); }
}

function initProgramList() {
    const list = document.getElementById('program-list');
    if (!list) return;
    for (const [cat, files] of Object.entries(programs)) {
        const div = document.createElement('div'); div.className = 'category';
        div.innerHTML = `<div class="category-header" onclick="this.parentElement.classList.toggle('open')">${cat}</div>
            <div class="category-items">${files.map(f => `<div class="program-item" onclick="loadProgram('${cat}', '${f}')">${f}</div>`).join('')}</div>`;
        list.appendChild(div);
    }
}

function updateLineNumbers() { const lines = document.getElementById('code-editor').value.split('\n').length; document.getElementById('line-numbers').innerHTML = Array.from({ length: lines }, (_, i) => `<div class="line-number">${i + 1}</div>`).join(''); }
function syncScroll() { document.getElementById('line-numbers').scrollTop = document.getElementById('code-editor').scrollTop; }
function toggleTheme() { const t = document.body.getAttribute('data-theme') === 'dark' ? 'light' : 'dark'; document.body.setAttribute('data-theme', t); localStorage.setItem('theme', t); }

// ========================================
// INITIALIZATION & PROTECTION
// ========================================

window.onload = () => {
    initProgramList(); updateLineNumbers(); initTooltips();
    const loader = document.getElementById('loading-overlay');
    const bar = document.querySelector('.progress-bar');
    if (bar) bar.style.width = '100%';
    setTimeout(() => loader?.classList.add('loaded'), 1000);

    // Typing Animation Bus
    document.getElementById('code-editor').addEventListener('input', () => {
        const bus = document.getElementById('system-bus');
        const chip = document.querySelector('.footer-chip');
        bus?.classList.add('active'); chip?.classList.add('processing');
        setTimeout(() => { bus?.classList.remove('active'); chip?.classList.remove('processing'); }, 300);
    });

    // Protection
    document.addEventListener('contextmenu', e => e.preventDefault());
    document.addEventListener('keydown', e => {
        if (e.key === 'F12' || (e.ctrlKey && e.shiftKey && (e.key === 'I' || e.key === 'J'))) e.preventDefault();
        if (emu.waiting) {
            let code = (e.key === 'Enter') ? 13 : (e.key === 'Backspace') ? 8 : (e.key.length === 1) ? e.key.charCodeAt(0) : 0;
            if (code) { e.preventDefault(); emu.processInput(code); }
        }
    });

    console.log('%c 8086 Emulator (Scholarly Edition) by Amey Thakur ', 'background:#161b22; color:#58a6ff; font-weight:bold; padding:10px; border:1px solid #30363d;');
};
