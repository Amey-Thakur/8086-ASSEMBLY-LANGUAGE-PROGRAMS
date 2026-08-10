// -----------------------------------------------------------------------------
// Script Name: shortcuts.js
// Module:      Interface, 6 of 7
// Stack:       JavaScript (ES2020), no framework
// Description: The keyboard. One table describes every shortcut, and that same
//              table both dispatches the keys and draws the list a reader can
//              call up with a question mark.
//
//              Two rules govern the choices. The keys are the ones a debugger
//              has always used, so F5 runs and F10 steps and nobody has to
//              learn anything. And nothing collides with the browser: Ctrl+R,
//              Ctrl+W, Ctrl+T and Ctrl+D are left alone, and the toggles use
//              Alt, which almost nothing else claims.
//
//              A shortcut is ignored while a text field has focus unless it
//              carries a modifier, so typing an F into the input queue does not
//              reset the machine. F5 and F10 are exceptions: they are function
//              keys, they mean nothing inside a text field, and a debugger that
//              refuses to step while the cursor is in the editor would be
//              useless.
//
// Authors:     Amey Thakur
// Repository:  https://github.com/Amey-Thakur/8086-ASSEMBLY-LANGUAGE-PROGRAMS
// License:     CC BY 4.0
// -----------------------------------------------------------------------------

'use strict';

/**
 * Every shortcut, in the order the help panel lists them.
 *
 *   keys      what to show a reader
 *   match     given the event, is this the one
 *   group     the heading it appears under
 *   inField   may it fire while a text field has focus
 */
export const SHORTCUTS = [
    // ---- running ------------------------------------------------------------
    {
        group: 'Running', keys: 'F5', label: 'Run, or stop while running',
        action: 'run', inField: true,
        match: e => e.key === 'F5' && !e.shiftKey && !e.ctrlKey
    },
    {
        group: 'Running', keys: 'Ctrl + Enter', label: 'Run, or stop while running',
        action: 'run', inField: true,
        match: e => e.ctrlKey && e.key === 'Enter'
    },
    {
        group: 'Running', keys: 'F10', label: 'Step one instruction',
        action: 'step', inField: true,
        match: e => e.key === 'F10'
    },
    {
        group: 'Running', keys: 'F9', label: 'Assemble',
        action: 'assemble', inField: true,
        match: e => e.key === 'F9'
    },
    {
        group: 'Running', keys: 'Ctrl + B', label: 'Assemble',
        action: 'assemble', inField: true,
        match: e => e.ctrlKey && e.key.toLowerCase() === 'b'
    },
    {
        group: 'Running', keys: 'Shift + F5', label: 'Reset the machine',
        action: 'reset', inField: true,
        match: e => e.key === 'F5' && e.shiftKey
    },
    {
        group: 'Running', keys: 'Esc', label: 'Stop',
        action: 'stop', inField: false,
        match: e => e.key === 'Escape'
    },

    // ---- moving about -------------------------------------------------------
    {
        group: 'Moving about', keys: 'Ctrl + K', label: 'Search the program library',
        action: 'search', inField: true,
        match: e => e.ctrlKey && e.key.toLowerCase() === 'k'
    },
    {
        group: 'Moving about', keys: 'Alt + L', label: 'Show or hide the library',
        action: 'library', inField: true,
        match: e => e.altKey && e.key.toLowerCase() === 'l'
    },
    {
        group: 'Moving about', keys: 'Alt + 1', label: 'Show the program',
        action: 'view-editor', inField: true,
        match: e => e.altKey && e.key === '1'
    },
    {
        group: 'Moving about', keys: 'Alt + 2', label: 'Show the machine',
        action: 'view-inspector', inField: true,
        match: e => e.altKey && e.key === '2'
    },
    {
        group: 'Moving about', keys: 'Alt + E', label: 'Put the cursor in the editor',
        action: 'focus-editor', inField: true,
        match: e => e.altKey && e.key.toLowerCase() === 'e'
    },

    // ---- the workspace ------------------------------------------------------
    {
        group: 'The workspace', keys: 'Alt + T', label: 'Switch between light and dark',
        action: 'theme', inField: true,
        match: e => e.altKey && e.key.toLowerCase() === 't'
    },
    {
        group: 'The workspace', keys: 'Alt + C', label: 'Clear the console',
        action: 'clear', inField: true,
        match: e => e.altKey && e.key.toLowerCase() === 'c'
    },
    {
        group: 'The workspace', keys: 'Alt + D', label: 'Download the program',
        action: 'download', inField: true,
        match: e => e.altKey && e.key.toLowerCase() === 'd'
    },
    {
        group: 'The workspace', keys: '?', label: 'Show this list',
        action: 'help', inField: false,
        match: e => e.key === '?'
    },
    {
        group: 'The workspace', keys: 'Esc', label: 'Close this list',
        action: 'help-close', inField: false,
        match: () => false            // handled by the panel while it is open
    }
];

export class Shortcuts {

    /**
     * @param {HTMLElement} panel    where the list is drawn
     * @param {object}      actions  action name to the function that performs it
     */
    constructor(panel, actions) {
        this.panel   = panel;
        this.actions = actions;

        this.render();
        this.attach();
    }

    // -------------------------------------------------------------------------
    // DISPATCH
    // -------------------------------------------------------------------------

    attach() {
        document.addEventListener('keydown', event => this.handle(event));

        // Anywhere outside the list closes it, which is what a reader expects
        // of something summoned by a key.
        this.panel.addEventListener('click', event => {
            if (event.target === this.panel) this.hide();
        });
    }

    handle(event) {
        // While the list is open it owns the keyboard, so that Escape and a
        // second question mark both close it rather than doing something else.
        if (this.isOpen()) {
            if (event.key === 'Escape' || event.key === '?') {
                event.preventDefault();
                this.hide();
            }
            return;
        }

        const typing = ['INPUT', 'TEXTAREA'].includes(document.activeElement?.tagName);

        for (const shortcut of SHORTCUTS) {
            if (!shortcut.match(event)) continue;
            if (typing && !shortcut.inField) continue;

            const action = this.actions[shortcut.action];

            if (!action) continue;

            event.preventDefault();
            action();
            return;
        }
    }

    // -------------------------------------------------------------------------
    // THE LIST
    // -------------------------------------------------------------------------

    isOpen() {
        return !this.panel.hidden;
    }

    show() { this.panel.hidden = false; this.panel.querySelector('button')?.focus(); }
    hide() { this.panel.hidden = true; }

    toggle() { this.isOpen() ? this.hide() : this.show(); }

    /**
     * Draw the list from the same table that dispatches the keys, so the two
     * can never disagree about what a shortcut does.
     */
    render() {
        const groups = new Map();

        for (const shortcut of SHORTCUTS) {
            if (!groups.has(shortcut.group)) groups.set(shortcut.group, []);
            groups.get(shortcut.group).push(shortcut);
        }

        const sections = [...groups.entries()].map(([group, items]) => `
            <section class="keys__group">
                <h3 class="label">${escapeText(group)}</h3>
                <dl class="keys__list">
                    ${items.map(item => `
                        <dt><kbd>${escapeText(item.keys)}</kbd></dt>
                        <dd>${escapeText(item.label)}</dd>
                    `).join('')}
                </dl>
            </section>`).join('');

        this.panel.innerHTML = `
            <div class="keys" role="dialog" aria-modal="true" aria-label="Keyboard shortcuts">
                <header class="keys__head">
                    <h2 class="keys__title">Keyboard</h2>
                    <button type="button" class="button button--quiet button--icon"
                            aria-label="Close">
                        <svg class="button__icon" viewBox="0 0 24 24" aria-hidden="true">
                            <path d="M19 6.41 17.59 5 12 10.59 6.41 5 5 6.41 10.59 12 5 17.59
                                     6.41 19 12 13.41 17.59 19 19 17.59 13.41 12z"/>
                        </svg>
                    </button>
                </header>
                <div class="keys__body">${sections}</div>
            </div>`;

        this.panel.querySelector('button').addEventListener('click', () => this.hide());
    }
}

function escapeText(text) {
    return String(text).replace(/[&<>"']/g, character => ({
        '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;'
    })[character]);
}
