;=============================================================================
; Program:     Hello World (Interrupt-based)
; Description: Demonstrate character-by-character printing using BIOS TTY
;              sub-function (INT 10H / AH=0EH).
; 
; Author:      Amey Thakur
; Repository:  https://github.com/Amey-Thakur/8086-ASSEMBLY-LANGUAGE-PROGRAMS
; License:     MIT License
;=============================================================================

ORG 100H                            ; COM file entry point

;-----------------------------------------------------------------------------
; MAIN CODE SECTION
;-----------------------------------------------------------------------------
START:
    ; AH does not change during INT 10H / 0EH, so we set it only once
    MOV AH, 0EH                     ; Select BIOS Teletype (TTY) function

    ; Print each character of "Hello World!" manually
    MOV AL, 'H'                     ; Load ASCII char
    INT 10H                         ; Trigger BIOS video service

    MOV AL, 'e'
    INT 10H

    MOV AL, 'l'
    INT 10H

    MOV AL, 'l'
    INT 10H

    MOV AL, 'o'
    INT 10H

    MOV AL, ' '
    INT 10H

    MOV AL, 'W'
    INT 10H

    MOV AL, 'o'
    INT 10H

    MOV AL, 'r'
    INT 10H

    MOV AL, 'l'
    INT 10H

    MOV AL, 'd'
    INT 10H

    MOV AL, '!'
    INT 10H

    ; Back to OS
    RET

END

;=============================================================================
; INTERRUPT NOTES:
; - INT 10h AH=0Eh is a BIOS level service, making it more low-level than DOS.
; - It handles cursor advancement and screen wrapping automatically.
; - Efficient for single character logic without complex buffer overhead.
;=============================================================================
