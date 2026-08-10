// -----------------------------------------------------------------------------
// Script Name: editor.js
// Module:      Interface, 2 of 6
// Stack:       JavaScript (ES2020), no framework
// Description: The source editor: a line number gutter, a coloured rendering of
//              the source, and the text area the source is actually typed into.
//
//              A textarea is used rather than a rich editor on purpose. It
//              accepts a paste from anywhere, it works with a screen reader, it
//              has undo already, and it behaves the way a text field is
//              expected to behave on a phone. What it cannot do is colour its
//              own contents, so the colouring is drawn on a layer underneath
//              and the text area's own text is made transparent above it.
//
//              That only holds together while the two layers agree to the
//              pixel, which is why both use the same font, the same line
//              height, the same padding, and no wrapping. The gutter is a third
//              layer, scrolled by the same amount.
//
//              Neither the gutter nor the colouring is rebuilt unless it has to
//              be: the gutter only when the line count changes, the colouring
//              only after typing has paused, because re-colouring a two hundred
//              line program on every keystroke is visible work for no gain.
//
// Authors:     Amey Thakur
// Repository:  https://github.com/Amey-Thakur/8086-ASSEMBLY-LANGUAGE-PROGRAMS
// License:     CC BY 4.0
// -----------------------------------------------------------------------------

'use strict';

import { highlight } from './highlight.js';

/** How long typing must pause before the colouring is redrawn. Short enough
 *  that it feels immediate, long enough that a fast typist is never waiting. */
const RECOLOUR_DELAY = 90;

export class Editor {

    /**
     * @param {HTMLTextAreaElement} input      where the source is typed
     * @param {HTMLElement}         gutter     where the line numbers are drawn
     * @param {HTMLElement}         [painted]  where the colouring is drawn
     */
    constructor(input, gutter, painted = null) {
        this.input   = input;
        this.gutter  = gutter;
        this.painted = painted;

        this.lineCount   = 0;
        this.currentLine = null;
        this.errorLines  = new Set();
        this.recolourAt  = null;
        this.onChange    = () => {};

        this.attach();
        this.refresh();
    }

    // -------------------------------------------------------------------------
    // WIRING
    // -------------------------------------------------------------------------

    attach() {
        this.input.addEventListener('input', () => {
            this.refresh();
            this.onChange(this.value);
        });

        // Neither the gutter nor the coloured layer scrolls on its own; both
        // are moved by exactly what the text area reports.
        this.input.addEventListener('scroll', () => this.syncScroll());

        // Tab indents rather than leaving the field. A tab key that moves focus
        // out of a code editor is the single most irritating thing a text area
        // can do, and assembly is written in columns.
        this.input.addEventListener('keydown', event => {
            if (event.key !== 'Tab' || event.ctrlKey || event.altKey) return;

            event.preventDefault();
            this.insertAtCursor('    ');
        });
    }

    // -------------------------------------------------------------------------
    // CONTENT
    // -------------------------------------------------------------------------

    get value() {
        return this.input.value;
    }

    set value(text) {
        this.input.value = text;
        this.input.scrollTop = 0;
        this.clearMarkers();
        this.refresh();
        this.recolour();          // a loaded program should arrive coloured
    }

    insertAtCursor(text) {
        const start = this.input.selectionStart;
        const end   = this.input.selectionEnd;

        this.input.setRangeText(text, start, end, 'end');
        this.refresh();
        this.onChange(this.value);
    }

    focus() {
        this.input.focus();
    }

    // -------------------------------------------------------------------------
    // MARKERS
    // -------------------------------------------------------------------------

    /** Mark the line whose instruction is about to be executed. */
    setCurrentLine(line) {
        if (this.currentLine === line) return;

        this.currentLine = line;
        this.paint();
        this.scrollLineIntoView(line);
    }

    /** Mark every line the assembler reported a problem on. */
    setErrorLines(lines) {
        this.errorLines = new Set(lines.filter(line => Number.isInteger(line)));
        this.paint();
    }

    clearMarkers() {
        this.currentLine = null;
        this.errorLines  = new Set();
    }

    /** Put the caret on a line and show it, for when a diagnostic is clicked. */
    revealLine(line) {
        const lines = this.input.value.split('\n');

        if (line < 1 || line > lines.length) return;

        const offset = lines.slice(0, line - 1).reduce((sum, text) => sum + text.length + 1, 0);

        this.input.focus();
        this.input.setSelectionRange(offset, offset + (lines[line - 1]?.length ?? 0));
        this.scrollLineIntoView(line);
    }

    // -------------------------------------------------------------------------
    // THE GUTTER
    // -------------------------------------------------------------------------

    /** Rebuild the gutter if the line count moved, then repaint the markers. */
    refresh() {
        const count = Math.max(1, this.input.value.split('\n').length);

        if (count !== this.lineCount) {
            this.lineCount = count;
            this.rebuild();
        }

        this.paint();
        this.scheduleRecolour();
    }

    // -------------------------------------------------------------------------
    // THE COLOURED LAYER
    // -------------------------------------------------------------------------

    /** Redraw the colouring once typing has paused. */
    scheduleRecolour() {
        if (!this.painted) return;

        clearTimeout(this.recolourAt);
        this.recolourAt = setTimeout(() => this.recolour(), RECOLOUR_DELAY);
    }

    /** Redraw it now, for a program that has just been loaded. */
    recolour() {
        if (!this.painted) return;

        clearTimeout(this.recolourAt);
        this.painted.innerHTML = highlight(this.input.value);
        this.syncScroll();
    }

    /** Hold all three layers at the same scroll position. */
    syncScroll() {
        this.gutter.scrollTop = this.input.scrollTop;

        if (!this.painted) return;

        this.painted.scrollTop  = this.input.scrollTop;
        this.painted.scrollLeft = this.input.scrollLeft;
    }

    rebuild() {
        const fragment = document.createDocumentFragment();

        for (let line = 1; line <= this.lineCount; line++) {
            const element = document.createElement('div');

            element.className   = 'editor__line';
            element.textContent = String(line);
            element.dataset.line = String(line);

            fragment.append(element);
        }

        this.gutter.replaceChildren(fragment);
        this.gutter.scrollTop = this.input.scrollTop;
    }

    paint() {
        for (const element of this.gutter.children) {
            const line = Number(element.dataset.line);

            element.classList.toggle('editor__line--current', line === this.currentLine);
            element.classList.toggle('editor__line--error',   this.errorLines.has(line));
        }
    }

    /**
     * Scroll a line into view, but only when it is off screen.
     *
     * Scrolling on every step, even by a pixel, makes single stepping feel
     * unsteady. The line is only chased when it has actually left the window,
     * and then it is placed a third of the way down so the following
     * instructions are visible too.
     */
    scrollLineIntoView(line) {
        if (!line) return;

        const lineHeight = this.measureLineHeight();
        const top        = (line - 1) * lineHeight;
        const viewTop    = this.input.scrollTop;
        const viewHeight = this.input.clientHeight;

        if (top >= viewTop && top < viewTop + viewHeight - lineHeight) return;

        this.input.scrollTop = Math.max(0, top - viewHeight / 3);
        this.syncScroll();
    }

    /** One line's height, read from the gutter, which uses the same metrics. */
    measureLineHeight() {
        const first = this.gutter.firstElementChild;

        return first ? first.getBoundingClientRect().height || 21 : 21;
    }
}
