; =============================================================================
; TITLE: BIOS Keyboard Interface
; DESCRIPTION: Demonstrates direct BIOS keyboard services (INT 16h) to capture 
;              and print keystrokes. It works at a lower level than DOS INT 21h, 
;              allowing detection of special keys like ESC.
; AUTHOR: Amey Thakur (https://github.com/Amey-Thakur)
; REPOSITORY: https://github.com/Amey-Thakur/8086-ASSEMBLY-LANGUAGE-PROGRAMS
; LICENSE: MIT License
; =============================================================================

NAME "keybrd"
ORG 100H

; -----------------------------------------------------------------------------
; CODE SEGMENT
; -----------------------------------------------------------------------------
START:
    ; --- Step 1: Display Welcome Message ---
    MOV DX, OFFSET MSG_INTRO
    MOV AH, 09H
    INT 21H

; --- Step 2: Main Event Loop ---
WAIT_FOR_KEY:
    ; Check Buffer Status (Non-Blocking)
    ; AH=01h -> ZF=0 if key waiting, ZF=1 if buffer empty
    MOV AH, 01H
    INT 16H
    JZ WAIT_FOR_KEY                 ; No key? Keep waiting

    ; Read Key from Buffer (Blocking)
    ; AH=00h -> AL=ASCII, AH=Scan Code
    MOV AH, 00H
    INT 16H

    ; --- Step 3: Echo to Screen ---
    ; BIOS Teletype Output (INT 10h, AH=0Eh)
    MOV AH, 0EH
    INT 10H

    ; --- Step 4: Exit Condition ---
    ; Check for ESC key (ASCII 1Bh / 27)
    CMP AL, 1BH
    JE L_EXIT

    JMP WAIT_FOR_KEY                ; Loop forever

L_EXIT:
    ; Return to DOS (COM file style)
    RET

; -----------------------------------------------------------------------------
; DATA SEGMENT (Embedded for COM)
; -----------------------------------------------------------------------------
MSG_INTRO   DB "Type anything...", 0DH, 0AH
            DB "Keys are echoed using BIOS Teletype.", 0DH, 0AH
            DB "Press [Esc] to exit.", 0DH, 0AH, "$"

END START

; =============================================================================
; TECHNICAL NOTES & ARCHITECTURAL INSIGHTS
; =============================================================================
; 1. INT 16h VS INT 21h:
;    - INT 21h (DOS) is high-level, supports buffering, redirection (pipes).
;    - INT 16h (BIOS) talks directly to the keyboard controller buffer.
;    - Using BIOS is necessary for games or apps needing raw scan codes or 
;      modifier key states (Shift/Ctrl/Alt).
;
; 2. KEYBOARD BUFFER:
;    The BIOS maintains a circular buffer (usually 16 bytes) at 0040:001E.
;    If this fills up, the speaker beeps. INT 16h AH=00h removes items from 
;    this queue.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
