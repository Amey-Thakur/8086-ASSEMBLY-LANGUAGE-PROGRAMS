// -----------------------------------------------------------------------------
// Script Name: library.js
// Module:      Interface, 4 of 6
// Stack:       JavaScript (ES2020), no framework
// Description: The list of programs in this repository, and the code that
//              fetches one when it is chosen.
//
//              The programs are real files in the folders beside this one
//              rather than strings pasted into the page, so the simulator runs
//              exactly what the repository contains. Editing a .asm file
//              changes what the simulator loads, with nothing to regenerate.
//
//              Because they are fetched, opening index.html straight off the
//              disk will not work: a browser refuses to read neighbouring files
//              over the file protocol. The failure is reported plainly, with
//              the one line needed to serve the folder instead, rather than
//              leaving an empty list and no explanation.
//
// Authors:     Amey Thakur
// Repository:  https://github.com/Amey-Thakur/8086-ASSEMBLY-LANGUAGE-PROGRAMS
// License:     CC BY 4.0
// -----------------------------------------------------------------------------

'use strict';

import { PROGRAMS } from '../../programs.js';

/** Where the program folders sit relative to this page. */
const LIBRARY_ROOT = '..';

export class Library {

    /**
     * @param {HTMLElement} list      where the categories are drawn
     * @param {HTMLInputElement} search  the filter field above it
     */
    constructor(list, search) {
        this.list    = list;
        this.search  = search;
        this.current = null;
        this.onOpen  = () => {};

        this.entries = flatten(PROGRAMS);

        this.search.addEventListener('input', () => this.render(this.search.value));
        this.list.addEventListener('click', event => this.handleClick(event));

        this.render('');
    }

    /** How many programs the library holds. */
    get count() {
        return this.entries.length;
    }

    // -------------------------------------------------------------------------
    // DRAWING
    // -------------------------------------------------------------------------

    render(query) {
        const needle  = query.trim().toLowerCase();
        const matches = needle === ''
            ? this.entries
            : this.entries.filter(entry =>
                entry.file.toLowerCase().includes(needle) ||
                entry.category.toLowerCase().includes(needle));

        if (matches.length === 0) {
            this.list.innerHTML =
                `<p class="table__empty">Nothing matches &ldquo;${escapeText(query)}&rdquo;.</p>`;
            return;
        }

        const groups   = new Map();
        const fragment = document.createDocumentFragment();

        for (const entry of matches) {
            if (!groups.has(entry.category)) groups.set(entry.category, []);
            groups.get(entry.category).push(entry);
        }

        for (const [category, items] of groups) {
            const group = document.createElement('section');

            group.className = 'library__group';
            group.innerHTML = `
                <header class="library__groupname">
                    <span class="label">${escapeText(category)}</span>
                    <span class="library__count">${items.length}</span>
                </header>
                ${items.map(entry => `
                    <button type="button"
                            class="library__item"
                            data-path="${escapeText(entry.path)}"
                            data-file="${escapeText(entry.file)}"
                            aria-current="${entry.path === this.current}"
                            title="${escapeText(entry.file)}">${escapeText(shorten(entry.file))}</button>
                `).join('')}`;

            fragment.append(group);
        }

        this.list.replaceChildren(fragment);
    }

    handleClick(event) {
        const button = event.target.closest('.library__item');

        if (!button) return;

        this.open(button.dataset.path, button.dataset.file);
    }

    // -------------------------------------------------------------------------
    // LOADING
    // -------------------------------------------------------------------------

    /** Fetch a program and hand its source to whoever is listening. */
    async open(path, file) {
        this.current = path;
        this.markCurrent();

        try {
            const response = await fetch(`${LIBRARY_ROOT}/${encodePath(path)}`);

            if (!response.ok) {
                throw new Error(`the server answered ${response.status}`);
            }

            this.onOpen({ file, path, source: await response.text() });

        } catch (error) {
            this.onOpen({
                file,
                path,
                source: null,
                error: describeFailure(error)
            });
        }
    }

    markCurrent() {
        for (const button of this.list.querySelectorAll('.library__item')) {
            button.setAttribute('aria-current', String(button.dataset.path === this.current));
        }
    }
}

// -----------------------------------------------------------------------------
// HELPERS
// -----------------------------------------------------------------------------

/** Turn the category to file-list map into one flat, ordered list. */
function flatten(catalogue) {
    const entries = [];

    for (const [category, files] of Object.entries(catalogue)) {
        for (const file of files) {
            entries.push({ category, file, path: `${category}/${file}` });
        }
    }

    return entries;
}

/** Each path segment is encoded separately, so the slashes survive. */
function encodePath(path) {
    return path.split('/').map(encodeURIComponent).join('/');
}

/** File names carry the .asm and read better without it in a narrow column. */
function shorten(file) {
    return file.replace(/\.asm$/i, '').replace(/_/g, ' ');
}

/**
 * Say what actually went wrong.
 *
 * A fetch that fails on the file protocol produces a bare TypeError, which
 * tells a reader nothing. The likely cause is worth naming, along with the fix.
 */
function describeFailure(error) {
    if (location.protocol === 'file:') {
        return 'A browser will not read neighbouring files when a page is opened ' +
               'directly from disk. Serve this folder instead, for example with ' +
               '"python -m http.server", and open it through localhost.';
    }

    return `The program could not be loaded: ${error.message}.`;
}

function escapeText(text) {
    return String(text).replace(/[&<>"']/g, character => ({
        '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;'
    })[character]);
}
