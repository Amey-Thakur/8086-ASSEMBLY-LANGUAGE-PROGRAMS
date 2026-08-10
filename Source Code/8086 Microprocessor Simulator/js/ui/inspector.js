// -----------------------------------------------------------------------------
// Script Name: inspector.js
// Module:      Interface, 3 of 6
// Stack:       JavaScript (ES2020), no framework
// Description: The machine state panel: registers, flags, the stack, a window
//              into memory, and whatever the program sent to a device.
//
//              One idea shapes all of it. Between one step and the next, almost
//              nothing changes, so the panel compares the new state against the
//              previous one and marks only what moved. Watching which register
//              lights up is how the effect of an instruction is read, and a
//              panel that redraws everything makes that impossible to see.
//
//              Nothing is rebuilt that has not changed, which also means the
//              text a reader is midway through selecting stays selected.
//
// Authors:     Amey Thakur
// Repository:  https://github.com/Amey-Thakur/8086-ASSEMBLY-LANGUAGE-PROGRAMS
// License:     CC BY 4.0
// -----------------------------------------------------------------------------

'use strict';

/** The registers shown, in the order the manuals list them. */
const REGISTERS = [
    'AX', 'BX', 'CX', 'DX',
    'SI', 'DI', 'BP', 'SP',
    'CS', 'DS', 'SS', 'ES',
    'IP'
];

/** The flags shown, in bit order within the flags word. */
const FLAGS = ['CF', 'PF', 'AF', 'ZF', 'SF', 'TF', 'IF', 'DF', 'OF'];

/** How many bytes of memory the window shows, and how many to a row. */
const MEMORY_ROWS    = 8;
const BYTES_PER_ROW  = 8;

const hex = (value, width) => (value >>> 0).toString(16).toUpperCase().padStart(width, '0');

export class Inspector {

    /**
     * @param {object} elements  the containers this panel writes into
     */
    constructor(elements) {
        this.elements = elements;
        this.previous = null;

        this.memoryBase = 0x0000;
        this.buildRegisters();
        this.buildFlags();
    }

    // -------------------------------------------------------------------------
    // BUILDING  (once, at start up)
    // -------------------------------------------------------------------------

    buildRegisters() {
        const fragment = document.createDocumentFragment();

        this.registerCells = new Map();

        for (const name of REGISTERS) {
            const cell  = document.createElement('div');
            const label = document.createElement('span');
            const value = document.createElement('span');

            cell.className  = name === 'IP' ? 'register register--wide' : 'register';
            label.className = 'register__name';
            value.className = 'register__value';

            cell.dataset.register = name;

            label.textContent = name;
            value.textContent = '0000';

            cell.append(label, value);
            fragment.append(cell);

            this.registerCells.set(name, { cell, value });
        }

        this.elements.registers.replaceChildren(fragment);
    }

    buildFlags() {
        const fragment = document.createDocumentFragment();

        this.flagCells = new Map();

        for (const name of FLAGS) {
            const cell  = document.createElement('div');
            const label = document.createElement('span');
            const value = document.createElement('span');

            cell.className  = 'flag';
            label.className = 'flag__name';
            value.className = 'flag__value';

            cell.dataset.flag = name;

            label.textContent = name;
            value.textContent = '0';

            cell.title = FLAG_MEANINGS[name] ?? name;

            cell.append(label, value);
            fragment.append(cell);

            this.flagCells.set(name, { cell, value });
        }

        this.elements.flags.replaceChildren(fragment);
    }

    // -------------------------------------------------------------------------
    // UPDATING
    // -------------------------------------------------------------------------

    /**
     * Show a snapshot of the machine.
     *
     * @param {object}  snapshot  from CPU.snapshot()
     * @param {Memory}  memory    the live memory, for the window
     * @param {boolean} compare   mark what changed since the previous call
     */
    update(snapshot, memory, compare = true) {
        this.updateRegisters(snapshot.registers, compare);
        this.updateFlags(snapshot.flags);
        this.updateStack(snapshot);
        this.updateMemory(memory, snapshot.registers.DS);
        this.updateDevices(snapshot);

        this.previous = snapshot;
    }

    updateRegisters(registers, compare) {
        const before = compare ? this.previous?.registers : null;

        for (const [name, parts] of this.registerCells) {
            const value = registers[name] ?? 0;
            const text  = hex(value, 4);

            if (parts.value.textContent !== text) parts.value.textContent = text;

            parts.cell.classList.toggle(
                'register--changed',
                Boolean(before) && before[name] !== value && name !== 'IP'
            );
        }
    }

    updateFlags(flags) {
        for (const [name, parts] of this.flagCells) {
            const set = Boolean(flags[name]);

            parts.value.textContent = set ? '1' : '0';
            parts.cell.classList.toggle('flag--set', set);
        }
    }

    /** The top of the stack downward, with SP's own row marked. */
    updateStack(snapshot) {
        const pointer = snapshot.registers.SP;
        const rows    = snapshot.stack ?? [];

        if (rows.length === 0) {
            this.elements.stack.innerHTML =
                '<p class="table__empty">Nothing has been pushed.</p>';
            return;
        }

        const body = rows.map(entry => `
            <tr data-top="${entry.offset === pointer}">
                <td class="table__address">${hex(entry.offset, 4)}</td>
                <td>${hex(entry.value, 4)}</td>
            </tr>`).join('');

        this.elements.stack.innerHTML = `
            <table class="table">
                <thead><tr><th>Offset</th><th>Word</th></tr></thead>
                <tbody>${body}</tbody>
            </table>`;
    }

    /** A window into the data segment, as bytes and as the text they spell. */
    updateMemory(memory, segment) {
        if (!memory) return;

        const rows = [];

        for (let row = 0; row < MEMORY_ROWS; row++) {
            const offset = (this.memoryBase + row * BYTES_PER_ROW) & 0xFFFF;
            const bytes  = [];
            const text   = [];

            for (let column = 0; column < BYTES_PER_ROW; column++) {
                const byte = memory.readByte(segment, (offset + column) & 0xFFFF);

                bytes.push(hex(byte, 2));

                // Anything outside printable ASCII is shown as a full stop, the
                // convention every hex dump has used since the seventies.
                text.push(byte >= 0x20 && byte < 0x7F ? String.fromCharCode(byte) : '.');
            }

            rows.push(`
                <tr>
                    <td class="table__address">${hex(offset, 4)}</td>
                    <td>${bytes.join(' ')}</td>
                    <td>${escapeText(text.join(''))}</td>
                </tr>`);
        }

        this.elements.memory.innerHTML = `
            <table class="table">
                <thead><tr><th>Offset</th><th>Bytes</th><th>Text</th></tr></thead>
                <tbody>${rows.join('')}</tbody>
            </table>`;
    }

    /** Everything the program sent to a port, and any file it produced. */
    updateDevices(snapshot) {
        const ports = snapshot.ports ?? [];
        const files = snapshot.files ?? [];

        if (ports.length === 0 && files.length === 0) {
            this.elements.devices.innerHTML =
                '<p class="table__empty">No device has been used.</p>';
            return;
        }

        const portRows = ports.map(entry => `
            <tr>
                <td class="table__address">${hex(entry.port, 4)}</td>
                <td>${hex(entry.value, entry.width * 2)}</td>
                <td>${escapeText(entry.device ?? '')}</td>
            </tr>`).join('');

        const fileRows = files.map(file => `
            <tr>
                <td>${escapeText(file.name)}</td>
                <td>${file.size}</td>
                <td>${escapeText(file.text.slice(0, 24))}</td>
            </tr>`).join('');

        this.elements.devices.innerHTML = [
            ports.length ? `
                <table class="table">
                    <thead><tr><th>Port</th><th>Sent</th><th>Device</th></tr></thead>
                    <tbody>${portRows}</tbody>
                </table>` : '',
            files.length ? `
                <table class="table">
                    <thead><tr><th>File</th><th>Bytes</th><th>Contents</th></tr></thead>
                    <tbody>${fileRows}</tbody>
                </table>` : ''
        ].join('');
    }

    /** Move the memory window. Used by the offset field above it. */
    setMemoryBase(offset) {
        this.memoryBase = offset & 0xFFF8;   // aligned to a row
    }

    /** Forget the previous snapshot, so nothing is marked as changed. */
    forget() {
        this.previous = null;
    }
}

/** What each flag means, shown when the pointer rests on it. */
const FLAG_MEANINGS = {
    CF: 'Carry: the unsigned result did not fit',
    PF: 'Parity: the low byte has an even number of ones',
    AF: 'Auxiliary carry: carried out of the low four bits, used by BCD',
    ZF: 'Zero: the result was zero',
    SF: 'Sign: the result is negative when read as signed',
    TF: 'Trap: the processor is single stepping',
    IF: 'Interrupt: hardware interrupts are accepted',
    DF: 'Direction: string instructions count downward',
    OF: 'Overflow: the signed result did not fit'
};

/** Escape text before it goes into markup. */
function escapeText(text) {
    return String(text).replace(/[&<>"']/g, character => ({
        '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;'
    })[character]);
}
