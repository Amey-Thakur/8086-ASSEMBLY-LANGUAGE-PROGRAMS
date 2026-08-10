// -----------------------------------------------------------------------------
// Script Name: console.js
// Module:      Interface, 5 of 6
// Stack:       JavaScript (ES2020), no framework
// Description: The console: what the program has printed, and the keystrokes
//              waiting for it to ask.
//
//              Input is queued rather than typed live. A program that calls
//              INT 21h service 01h expects a key to already be there, and there
//              is no way to suspend a JavaScript function while a person
//              decides what to press. Typing the answers first is honest about
//              that, it makes a run repeatable, and it is how a batch of test
//              input has always been supplied to a program that reads.
//
//              Enter is written as a carriage return, because that is the byte
//              DOS returns and the byte a program compares against.
//
// Authors:     Amey Thakur
// Repository:  https://github.com/Amey-Thakur/8086-ASSEMBLY-LANGUAGE-PROGRAMS
// License:     CC BY 4.0
// -----------------------------------------------------------------------------

'use strict';

export class Console {

    /**
     * @param {HTMLElement}      output  where the transcript is written
     * @param {HTMLInputElement} input   where keystrokes are queued
     */
    constructor(output, input) {
        this.output = output;
        this.input  = input;
    }

    /** Show what the program has printed so far. */
    write(text) {
        if (this.output.textContent === text) return;

        this.output.textContent = text;
        this.output.scrollTop   = this.output.scrollHeight;
    }

    clear() {
        this.output.textContent = '';
    }

    /**
     * The keystrokes to hand the program, in order.
     *
     * The field is plain text, so a newline typed into it means Enter, and \r
     * or \n written out by hand mean the same thing. All three become the
     * carriage return a program actually receives.
     */
    get pendingInput() {
        return this.input.value
            .replace(/\\r|\\n/g, '\r')
            .replace(/\n/g, '\r');
    }

    /** Describe what is queued, for the status bar. */
    describeInput() {
        const queued = this.pendingInput.length;

        return queued === 0 ? 'no input queued'
             : queued === 1 ? '1 key queued'
             :                `${queued} keys queued`;
    }
}
