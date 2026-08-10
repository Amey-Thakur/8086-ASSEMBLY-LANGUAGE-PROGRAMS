// -----------------------------------------------------------------------------
// Script Name: app.js
// Module:      Interface, 8 of 8
// Stack:       JavaScript (ES2020), no framework
// Description: The controller. Owns the machine, drives assemble, run, step and
//              reset, and keeps every panel showing the same state.
//
//              The important decision here is how a program is run. Calling the
//              executor until the program stops would freeze the page for as
//              long as that took, and some of these programs never stop at all.
//              So a run is executed in slices, one slice per animation frame,
//              with the panels redrawn between them. A traffic light controller
//              can therefore run indefinitely while the interface stays
//              responsive and the Stop button still works.
//
//              Everything else follows from keeping one machine and one program
//              in this object and rendering from them, so there is exactly one
//              answer to what the processor currently holds.
//
// Authors:     Amey Thakur
// Repository:  https://github.com/Amey-Thakur/8086-ASSEMBLY-LANGUAGE-PROGRAMS
// License:     CC BY 4.0
// -----------------------------------------------------------------------------

'use strict';

import { CPU }       from '../cpu/cpu.js';
import { Assembler } from '../asm/assembler.js';
import { Executor }  from '../exec/executor.js';

import { Editor }    from './editor.js';
import { Inspector } from './inspector.js';
import { Library }   from './library.js';
import { Console }   from './console.js';
import { Shortcuts } from './shortcuts.js';
import { Panels }    from './panels.js';

/** Instructions executed per animation frame while running. Chosen so a frame
 *  stays inside its budget on a modest laptop, and a delay loop still finishes
 *  in a few seconds rather than a few minutes. */
const SLICE = 250_000;

/** Where the theme choice is kept between visits. */
const THEME_KEY = '8086-simulator-theme';

/**
 * The program the editor opens with.
 *
 * It is Hello World on purpose. It is the smallest program that is still a
 * complete one, so every part of it has to be there, and explaining those parts
 * explains the shape of every other program in the library. Somebody arriving
 * with no 8086 at all can press Run, see output, and then read why it worked.
 *
 * Every line is commented for that reason. The other programs comment only what
 * is interesting; this one comments everything.
 */
const WELCOME = `; =============================================================================
; HELLO WORLD
;
; Press Assemble, then Run. The output appears in the console panel.
;
; Then read the comments: this is the smallest complete 8086 program, and every
; other program in the library is built the same way.
;
; Choose something from the library on the left when you are ready, or write
; your own over the top of this.
; =============================================================================

.MODEL SMALL                ; one 64K segment of code and one of data, which is
                            ; the model nearly every program here uses
.STACK 100H                 ; reserve 256 bytes for the stack

; -----------------------------------------------------------------------------
; DATA
;
; The dollar sign is not printed. It marks the end of the string for DOS, which
; has no length to work from and so keeps writing until it finds one. Leaving it
; out is the classic first mistake: the output runs on into whatever follows.
;
; 0DH is a carriage return and 0AH a line feed. DOS wants both to end a line.
; -----------------------------------------------------------------------------
.DATA
    MESSAGE DB 'Hello from the 8086.', 0DH, 0AH, '$'

; -----------------------------------------------------------------------------
; CODE
; -----------------------------------------------------------------------------
.CODE
MAIN PROC
    ; The processor reaches memory as a segment plus an offset, and a name like
    ; MESSAGE is only the offset. DS has to point at the data segment before any
    ; of it can be read. @DATA is the assembler telling you where it put it.
    ;
    ; This cannot be done in one instruction: MOV DS, @DATA is not legal,
    ; because a segment register cannot be loaded from a constant.
    MOV AX, @DATA
    MOV DS, AX

    ; DOS services are asked for through interrupt 21h, with the service number
    ; in AH. Service 09h writes the string at DS:DX.
    ;
    ; LEA loads the address of MESSAGE. MOV DX, MESSAGE would load the first two
    ; characters instead, which is the second classic mistake.
    LEA DX, MESSAGE
    MOV AH, 09H
    INT 21H

    ; Service 4Ch ends the program and hands the code in AL back to DOS. Without
    ; it the processor would carry on into whatever bytes came next.
    MOV AH, 4CH
    MOV AL, 0
    INT 21H
MAIN ENDP

END MAIN                    ; where execution begins
`;

// -----------------------------------------------------------------------------
// APPLICATION
// -----------------------------------------------------------------------------
export class Application {

    constructor() {
        this.element = query('.app');

        this.cpu      = new CPU();
        this.program  = null;
        this.executor = null;

        this.running  = false;
        this.frame    = null;

        // How many bell rings have already been sounded, so a run does not
        // replay every ring from the start of the program each frame.
        this.bellsPlayed = 0;
        this.audio       = null;

        this.buildPanels();
        this.bindControls();
        this.restoreTheme();

        this.editor.value = WELCOME;
        this.reset('Ready. Assemble the program, then run it or step through it.');

        this.dismissLoading();
    }

    /**
     * Take the loading screen away.
     *
     * It exists because the interface is built from fifteen ES modules, and
     * between the first byte of HTML and the moment they have all loaded there
     * is a stretch with nothing on the page. It is removed rather than hidden,
     * so it cannot intercept a click afterwards, and only once everything it
     * was covering for is genuinely ready.
     */
    dismissLoading() {
        const screen = document.querySelector('#loading');

        if (!screen) return;

        screen.dataset.state = 'done';
        setTimeout(() => screen.remove(), 260);
    }

    // -------------------------------------------------------------------------
    // SET UP
    // -------------------------------------------------------------------------

    buildPanels() {
        this.editor = new Editor(query('#source'), query('#gutter'), query('#painted'));

        this.inspector = new Inspector({
            registers: query('#registers'),
            flags:     query('#flags'),
            stack:     query('#stack'),
            memory:    query('#memory'),
            devices:   query('#devices')
        });

        this.console = new Console(query('#output'), query('#input'));

        // The columns can be dragged wider or narrower, and remember where
        // they were left. Redrawing on release lets the memory view pick a
        // new row width for the space it now has.
        this.panels = new Panels(this.element, document.querySelectorAll('.handle'));

        for (const handle of document.querySelectorAll('.handle')) {
            handle.addEventListener('pointermove', () => this.fitSearchPlaceholder());
            handle.addEventListener('pointerup',   () => this.render(false));
            handle.addEventListener('keyup',       () => this.render(false));
        }

        window.addEventListener('resize', () => this.render(false));
        this.library = new Library(query('#library-list'), query('#library-search'));

        // Editing invalidates whatever was assembled: the instructions in hand
        // no longer correspond to the text on screen.
        this.editor.onChange = () => {
            if (!this.program) return;

            this.program = null;
            this.executor = null;
            this.editor.setCurrentLine(null);
            this.setState('ready', 'The program has changed. Assemble it again.');
        };

        this.library.onOpen = result => this.loadProgram(result);

        // Both counts come from the library itself, so adding a program never
        // means editing a number in the markup.
        query('#library-total').textContent = `${this.library.count} programs`;

        this.fitSearchPlaceholder();
    }

    /**
     * Choose a placeholder that fits the width the search box currently has.
     *
     * A placeholder wider than its field is clipped mid word, which reads as a
     * rendering fault rather than as a hint. Three lengths cover the range the
     * panel can be dragged to, and the longest one that fits is used.
     *
     * The count comes from the library rather than the markup, so adding a
     * program never means editing a number by hand.
     */
    fitSearchPlaceholder() {
        const field = query('#library-search');
        const width = field.clientWidth;

        // Roughly the width of a character in the monospaced field, less the
        // padding either side. Deliberately generous: a placeholder that stops
        // short looks deliberate, one that is cut off does not.
        const room = Math.floor((width - 24) / 7);

        const choices = [
            `Search ${this.library.count} programs`,
            `Search ${this.library.count}`,
            'Search'
        ];

        field.placeholder = choices.find(text => text.length <= room) ?? '';
    }

    bindControls() {
        on('#action-assemble', () => this.assemble());
        on('#action-run',      () => this.toggleRun());
        on('#action-step',     () => this.step());
        on('#action-reset',    () => { this.reset('Machine reset.'); });
        on('#action-theme',    () => this.toggleTheme());
        on('#action-copy',     () => this.copySource());
        on('#action-download', () => this.downloadSource());

        // The library drawer, on screens too narrow to keep it open.
        on('#action-library', () => this.toggleLibrary());
        on('.drawer-scrim',   () => this.toggleLibrary(false));

        // The tab bar, on screens that show one panel at a time.
        for (const tab of document.querySelectorAll('.viewtabs__tab')) {
            tab.addEventListener('click', () => this.showView(tab.dataset.view));
        }

        // The memory window follows whatever offset is typed above it.
        query('#memory-offset').addEventListener('change', event => {
            const offset = parseInt(event.target.value.replace(/[^0-9a-f]/gi, ''), 16);

            this.inspector.setMemoryBase(Number.isNaN(offset) ? 0 : offset);
            this.render(false);
        });

        // Clicking a diagnostic puts the caret on the line it names.
        query('#diagnostics-list').addEventListener('click', event => {
            const item = event.target.closest('.diagnostics__item');

            if (item?.dataset.line) this.editor.revealLine(Number(item.dataset.line));
        });

        on('#action-keys', () => this.shortcuts.toggle());

        // Every shortcut is declared in shortcuts.js. This is only the map from
        // the name of an action to the method that carries it out, so the key
        // table and the behaviour stay in one place each.
        this.shortcuts = new Shortcuts(query('#shortcuts'), {
            run:              () => this.toggleRun(),
            step:             () => this.step(),
            assemble:         () => this.assemble(),
            reset:            () => this.reset('Machine reset.'),
            stop:             () => this.stop('Stopped.'),
            search:           () => { this.toggleLibrary(true); query('#library-search').focus(); },
            library:          () => this.toggleLibrary(),
            'view-editor':    () => this.showView('editor'),
            'view-inspector': () => this.showView('inspector'),
            'focus-editor':   () => this.editor.focus(),
            theme:            () => this.toggleTheme(),
            clear:            () => { this.console.clear(); this.setNotice('info', 'Console cleared.'); },
            download:         () => this.downloadSource(),
            help:             () => this.shortcuts.toggle()
        });
    }

    // -------------------------------------------------------------------------
    // LOADING
    // -------------------------------------------------------------------------

    loadProgram({ file, source, error }) {
        if (error) {
            this.setNotice('error', error);
            return;
        }

        this.stop();
        this.editor.value = source;

        query('#filename').textContent = file;

        this.reset(`Loaded ${file}.`);
        this.assemble();
        this.toggleLibrary(false);
    }

    // -------------------------------------------------------------------------
    // ASSEMBLING
    // -------------------------------------------------------------------------

    assemble() {
        this.stop();

        const result = new Assembler().assemble(this.editor.value);

        this.showDiagnostics(result.diagnostics);

        if (!result.ok) {
            this.program = null;
            this.editor.setErrorLines(result.diagnostics.map(item => item.line));
            this.setState('error',
                `${result.diagnostics.length} ` +
                `${result.diagnostics.length === 1 ? 'problem' : 'problems'} found. ` +
                `Nothing was run.`);
            return false;
        }

        this.program = result;
        this.editor.setErrorLines([]);
        this.loadIntoMachine();

        this.setState('ready',
            `Assembled: ${result.instructions.length} instructions, ` +
            `${result.data.length} bytes of data.`);

        this.render(false);
        return true;
    }

    /** Put the assembled program into a freshly reset machine. */
    loadIntoMachine() {
        this.cpu.reset();
        this.cpu.memory.load(this.cpu.registers.get('DS') << 4, this.program.data);
        this.cpu.registers.set('IP', this.program.entryPoint);
        this.cpu.pendingInput = this.console.pendingInput;

        this.executor = new Executor(this.cpu, this.program);
        this.inspector.forget();
        this.console.clear();
    }

    showDiagnostics(diagnostics) {
        const panel = query('#diagnostics');
        const list  = query('#diagnostics-list');

        if (diagnostics.length === 0) {
            panel.hidden = true;
            list.replaceChildren();
            return;
        }

        panel.hidden = false;
        query('#diagnostics-count').textContent =
            `${diagnostics.length} ${diagnostics.length === 1 ? 'problem' : 'problems'}`;

        list.innerHTML = diagnostics.map(item => `
            <div class="diagnostics__item" data-line="${item.line ?? ''}">
                <span class="diagnostics__line">${item.line ? `line ${item.line}` : ''}</span>
                <span>${escapeText(item.message)}</span>
            </div>`).join('');
    }

    // -------------------------------------------------------------------------
    // RUNNING
    // -------------------------------------------------------------------------

    toggleRun() {
        if (this.running) { this.stop('Stopped by hand.'); return; }
        if (!this.ensureAssembled()) return;

        // Starting again after the program finished means starting again.
        if (this.cpu.halted) this.loadIntoMachine();

        this.cpu.pendingInput = this.console.pendingInput;

        this.running = true;
        this.setRunLabel(true);
        this.setState('running', 'Running.');
        this.tick();
    }

    /**
     * Execute one slice, draw, and ask for the next frame.
     *
     * Handing control back between slices is what keeps the page alive. It also
     * means the console fills in as the program prints rather than all at once
     * when it ends, which is how a terminal behaves.
     */
    tick() {
        if (!this.running) return;

        let outcome;

        try {
            outcome = this.executor.run(SLICE);
        } catch (error) {
            this.failed(error);
            return;
        }

        this.render();

        if (outcome.reason === 'halted') {
            this.finished();
            return;
        }

        this.frame = requestAnimationFrame(() => this.tick());
    }

    step() {
        if (!this.ensureAssembled()) return;

        this.stop();

        if (this.cpu.halted) {
            this.loadIntoMachine();
            this.render(false);
            this.setState('ready', 'Started again from the beginning.');
            return;
        }

        this.cpu.pendingInput = this.console.pendingInput;

        try {
            const continues = this.executor.step();

            this.render();

            if (!continues) { this.finished(); return; }

            const instruction = this.program.instructions[this.cpu.registers.get('IP')];

            this.setState('ready', instruction
                ? `Next: ${instruction.source.trim()}`
                : 'At the end of the program.');

        } catch (error) {
            this.failed(error);
        }
    }

    stop(message = null) {
        this.running = false;

        if (this.frame !== null) {
            cancelAnimationFrame(this.frame);
            this.frame = null;
        }

        this.setRunLabel(false);

        if (message) this.setState('ready', message);
    }

    reset(message = 'Machine reset.') {
        this.stop();

        if (this.program) this.loadIntoMachine();
        else              this.cpu.reset();

        this.console.clear();
        this.editor.setCurrentLine(null);
        this.inspector.forget();
        this.render(false);
        this.setState('ready', message);
    }

    finished() {
        this.stop();
        this.render(false);
        this.editor.setCurrentLine(null);

        const code = this.cpu.exitCode;

        this.setState('halted', code === null
            ? `Finished after ${this.cpu.instructionCount.toLocaleString('en-US')} instructions.`
            : `Finished with exit code ${code}, after ` +
              `${this.cpu.instructionCount.toLocaleString('en-US')} instructions.`);
    }

    failed(error) {
        this.stop();
        this.render(false);

        if (error.line) this.editor.setErrorLines([error.line]);

        this.setState('error', error.line
            ? `Line ${error.line}: ${error.message}`
            : error.message);
    }

    /** Assemble first if that has not happened, and say so if it cannot. */
    ensureAssembled() {
        if (this.program) return true;

        return this.assemble();
    }

    // -------------------------------------------------------------------------
    // DRAWING
    // -------------------------------------------------------------------------

    render(compare = true) {
        const snapshot = this.cpu.snapshot();

        this.inspector.update(snapshot, this.cpu.memory, compare);
        this.console.write(snapshot.output);

        const instruction = this.program?.instructions[this.cpu.registers.get('IP')];

        this.editor.setCurrentLine(this.cpu.halted ? null : (instruction?.line ?? null));

        query('#count').textContent =
            `${snapshot.instructionCount.toLocaleString('en-US')} executed`;
        query('#queued').textContent = this.console.describeInput();

        this.ringBell();
        this.fitSearchPlaceholder();
    }

    /**
     * Sound the bell once for each ring the program has made since the last look.
     *
     * A program that writes the bell character expects to be heard. Printing it
     * as a glyph, which is what happened before, put an invisible control
     * character in the transcript and made the program look as though it had
     * done nothing at all.
     *
     * The tone is built rather than loaded, because the simulator has no assets
     * and a data URI for a sound file would be far larger than the code. The
     * audio context is created on the first ring, since a browser will not allow
     * one before the visitor has interacted with the page.
     */
    ringBell() {
        const rung = this.cpu.bellCount ?? 0;

        if (rung <= this.bellsPlayed) { this.bellsPlayed = rung; return; }

        // However many rings were missed, one tone is enough. A loop that beeps
        // a thousand times should not queue a thousand tones.
        this.bellsPlayed = rung;

        try {
            this.audio ??= new (window.AudioContext ?? window.webkitAudioContext)();

            const tone = this.audio.createOscillator();
            const gain = this.audio.createGain();

            // The PC speaker beep was a square wave near 800 Hz for about a
            // fifth of a second, which is what this imitates.
            tone.type            = 'square';
            tone.frequency.value = 800;

            // A short fade at each end, because a square wave cut off abruptly
            // clicks.
            const now = this.audio.currentTime;

            gain.gain.setValueAtTime(0, now);
            gain.gain.linearRampToValueAtTime(0.08, now + 0.01);
            gain.gain.setValueAtTime(0.08, now + 0.16);
            gain.gain.linearRampToValueAtTime(0, now + 0.2);

            tone.connect(gain).connect(this.audio.destination);
            tone.start(now);
            tone.stop(now + 0.2);
        } catch {
            // No audio available, which is not a reason to stop the program.
        }
    }

    setState(state, message) {
        const indicator = query('#state');

        indicator.dataset.state = state;
        query('#state-text').textContent = {
            ready: 'Ready', running: 'Running', halted: 'Finished', error: 'Error'
        }[state] ?? state;

        this.setNotice(state === 'ready' ? 'info' : state === 'halted' ? 'ok' : state, message);
    }

    setNotice(kind, message) {
        const notice = query('#notice');

        if (!message) { notice.hidden = true; return; }

        notice.hidden    = false;
        notice.className = `notice notice--${kind === 'running' ? 'warn' : kind}`;
        notice.textContent = message;
    }

    setRunLabel(running) {
        query('#action-run-label').textContent = running ? 'Stop' : 'Run';
        query('#action-run').classList.toggle('button--primary', !running);
    }

    // -------------------------------------------------------------------------
    // LAYOUT AND THEME
    // -------------------------------------------------------------------------

    /** Which single panel is shown, on a screen too narrow for all of them. */
    showView(view) {
        this.element.dataset.view = view;

        for (const tab of document.querySelectorAll('.viewtabs__tab')) {
            tab.setAttribute('aria-selected', String(tab.dataset.view === view));
        }
    }

    toggleLibrary(force = null) {
        const open = force ?? this.element.dataset.library !== 'open';

        this.element.dataset.library = open ? 'open' : 'closed';
        query('#action-library').setAttribute('aria-expanded', String(open));
    }

    restoreTheme() {
        const stored = readStored(THEME_KEY);
        const dark   = stored
            ? stored === 'dark'
            : window.matchMedia?.('(prefers-color-scheme: dark)').matches;

        this.applyTheme(dark ? 'dark' : 'light');
    }

    toggleTheme() {
        const next = document.documentElement.dataset.theme === 'dark' ? 'light' : 'dark';

        this.applyTheme(next);
        writeStored(THEME_KEY, next);
    }

    applyTheme(theme) {
        document.documentElement.dataset.theme = theme;

        query('#action-theme').setAttribute(
            'aria-label',
            theme === 'dark' ? 'Switch to the light theme' : 'Switch to the dark theme'
        );
    }

    // -------------------------------------------------------------------------
    // THE SOURCE, OUT OF THE PAGE
    // -------------------------------------------------------------------------

    async copySource() {
        try {
            await navigator.clipboard.writeText(this.editor.value);
            this.setNotice('ok', 'The program was copied to the clipboard.');
        } catch {
            this.setNotice('warn', 'This browser would not give access to the clipboard.');
        }
    }

    downloadSource() {
        const name = query('#filename').textContent.trim() || 'program.asm';
        const blob = new Blob([this.editor.value], { type: 'text/plain;charset=utf-8' });
        const url  = URL.createObjectURL(blob);
        const link = document.createElement('a');

        link.href     = url;
        link.download = name.endsWith('.asm') ? name : `${name}.asm`;
        link.click();

        URL.revokeObjectURL(url);
    }
}

// -----------------------------------------------------------------------------
// SMALL HELPERS
// -----------------------------------------------------------------------------

function query(selector) {
    const element = document.querySelector(selector);

    if (!element) throw new Error(`the page is missing "${selector}"`);
    return element;
}

function on(selector, handler) {
    document.querySelector(selector)?.addEventListener('click', handler);
}

/** Storage is unavailable in a private window in some browsers, and a theme
 *  preference is not worth an exception. */
function readStored(key) {
    try { return localStorage.getItem(key); } catch { return null; }
}

function writeStored(key, value) {
    try { localStorage.setItem(key, value); } catch { /* nothing to do */ }
}

function escapeText(text) {
    return String(text).replace(/[&<>"']/g, character => ({
        '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;'
    })[character]);
}

// -----------------------------------------------------------------------------
// START
// -----------------------------------------------------------------------------
document.addEventListener('DOMContentLoaded', () => {
    window.simulator = new Application();
});
