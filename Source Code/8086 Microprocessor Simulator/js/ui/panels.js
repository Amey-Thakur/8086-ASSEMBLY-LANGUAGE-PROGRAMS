// -----------------------------------------------------------------------------
// Script Name: panels.js
// Module:      Interface, 7 of 8
// Stack:       JavaScript (ES2020), no framework
// Description: Lets the columns be dragged wider or narrower, and remembers
//              where they were left.
//
//              Different work wants different proportions. Reading a long
//              program wants the editor wide; watching memory while stepping
//              wants the machine panel wide. Rather than guess, the two edges
//              between the columns become handles.
//
//              Three things make it feel right rather than merely possible:
//
//                - the pointer is captured on the handle, so a fast drag that
//                  leaves the two pixel strip does not lose the grip
//                - each panel has a floor and a ceiling, so neither can be
//                  dragged away entirely or made to swallow the others
//                - the widths are written to the CSS custom properties the
//                  layout already uses, so nothing else has to know that
//                  dragging exists
//
//              Double clicking a handle puts that column back to its default,
//              which is the way out when a drag has gone badly.
//
// Authors:     Amey Thakur
// Repository:  https://github.com/Amey-Thakur/8086-ASSEMBLY-LANGUAGE-PROGRAMS
// License:     CC BY 4.0
// -----------------------------------------------------------------------------

'use strict';

/** Where the chosen widths are kept between visits. */
const STORAGE_KEY = '8086-simulator-panels';

/** What each handle governs: the property, its default, and its limits. */
const EDGES = {
    library:   { property: '--library-width',   fallback: 248, min: 170, max: 460 },
    inspector: { property: '--inspector-width', fallback: 340, min: 260, max: 620 }
};

/** The editor is never dragged directly; it takes whatever is left. This is
 *  how little of it must remain visible for a drag to be allowed. */
const EDITOR_FLOOR = 320;

export class Panels {

    /**
     * @param {HTMLElement} root     the application shell
     * @param {NodeList}    handles  elements carrying data-edge
     */
    constructor(root, handles) {
        this.root  = root;
        this.drag  = null;

        this.widths = { ...readStored() };

        for (const [name, edge] of Object.entries(EDGES)) {
            this.apply(name, this.widths[name] ?? edge.fallback);
        }

        for (const handle of handles) this.attach(handle);
    }

    // -------------------------------------------------------------------------
    // DRAGGING
    // -------------------------------------------------------------------------

    attach(handle) {
        const name = handle.dataset.edge;

        if (!EDGES[name]) return;

        handle.addEventListener('pointerdown', event => this.begin(event, handle, name));
        handle.addEventListener('pointermove', event => this.move(event));
        handle.addEventListener('pointerup',   () => this.end(handle));
        handle.addEventListener('pointercancel', () => this.end(handle));

        // A double click is the way back to the default width.
        handle.addEventListener('dblclick', () => {
            this.apply(name, EDGES[name].fallback);
            this.remember();
        });

        // The keyboard moves it too, because a handle nobody can reach with a
        // keyboard is a control only some people have.
        handle.addEventListener('keydown', event => this.nudge(event, name));
    }

    begin(event, handle, name) {
        // Only the primary button, and never a second drag on top of the first.
        if (event.button !== 0 || this.drag) return;

        handle.setPointerCapture(event.pointerId);

        this.drag = {
            name,
            startX: event.clientX,
            startWidth: this.currentWidth(name)
        };

        this.root.dataset.dragging = name;
        event.preventDefault();
    }

    move(event) {
        if (!this.drag) return;

        const { name, startX, startWidth } = this.drag;

        // The library grows as the pointer moves right; the inspector, being on
        // the other side of the window, grows as it moves left.
        const travelled = name === 'library'
            ? event.clientX - startX
            : startX - event.clientX;

        this.apply(name, startWidth + travelled);
    }

    end(handle) {
        if (!this.drag) return;

        this.drag = null;
        delete this.root.dataset.dragging;
        this.remember();

        handle.blur?.();
    }

    /** Arrow keys move a handle in steps, Home returns it to the default. */
    nudge(event, name) {
        const step = event.shiftKey ? 48 : 12;
        const away = name === 'library' ? 1 : -1;

        if (event.key === 'ArrowLeft')       this.apply(name, this.currentWidth(name) - step * away);
        else if (event.key === 'ArrowRight') this.apply(name, this.currentWidth(name) + step * away);
        else if (event.key === 'Home')       this.apply(name, EDGES[name].fallback);
        else return;

        event.preventDefault();
        this.remember();
    }

    // -------------------------------------------------------------------------
    // APPLYING
    // -------------------------------------------------------------------------

    currentWidth(name) {
        return this.widths[name] ?? EDGES[name].fallback;
    }

    /**
     * Set a width, clamped so that every panel keeps a usable size.
     *
     * The ceiling is whichever is smaller: the panel's own maximum, or what is
     * left once the editor has been given its floor and the other side has been
     * given its minimum. Without the second term, widening one panel on a
     * narrow window would squeeze the editor out of existence.
     */
    apply(name, requested) {
        const edge  = EDGES[name];
        const other = name === 'library' ? EDGES.inspector : EDGES.library;

        const otherWidth = this.widths[name === 'library' ? 'inspector' : 'library']
                        ?? other.fallback;

        const available = window.innerWidth - EDITOR_FLOOR - otherWidth;
        const ceiling   = Math.max(edge.min, Math.min(edge.max, available));
        const width     = Math.round(Math.max(edge.min, Math.min(ceiling, requested)));

        this.widths[name] = width;
        this.root.style.setProperty(edge.property, `${width}px`);

        const handle = this.root.querySelector(`[data-edge="${name}"]`);

        handle?.setAttribute('aria-valuenow', String(width));
    }

    remember() {
        try { localStorage.setItem(STORAGE_KEY, JSON.stringify(this.widths)); }
        catch { /* a private window is not a reason to fail */ }
    }
}

function readStored() {
    try {
        const stored = JSON.parse(localStorage.getItem(STORAGE_KEY) ?? '{}');

        return typeof stored === 'object' && stored !== null ? stored : {};
    } catch {
        return {};
    }
}
