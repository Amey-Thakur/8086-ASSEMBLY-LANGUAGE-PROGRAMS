; =============================================================================
; TITLE: Printing with INT 10h Service 0Eh
; DESCRIPTION: Writes characters through the BIOS rather than through DOS,
;              which is what a program that cannot rely on DOS has to do.
; AUTHOR: Amey Thakur (https://github.com/Amey-Thakur)
; REPOSITORY: https://github.com/Amey-Thakur/8086-ASSEMBLY-LANGUAGE-PROGRAMS
; LICENSE: MIT License
; =============================================================================

.MODEL SMALL
.STACK 100H

; -----------------------------------------------------------------------------
; DATA SEGMENT
; -----------------------------------------------------------------------------
.DATA
    TEXT    DB 'Written by the BIOS, one character at a time.'
    TEXTLEN EQU $ - TEXT

; -----------------------------------------------------------------------------
; CODE SEGMENT
; -----------------------------------------------------------------------------
.CODE
START:
    MOV AX, @DATA
    MOV DS, AX

    ; -------------------------------------------------------------------------
    ; SERVICE 0EH IS CALLED TELETYPE OUTPUT BECAUSE IT BEHAVES LIKE ONE: IT
    ; PRINTS THE CHARACTER IN AL, MOVES THE CURSOR ON, AND SCROLLS AT THE
    ; BOTTOM OF THE SCREEN. BH SELECTS THE DISPLAY PAGE AND BL THE COLOUR IN
    ; A GRAPHICS MODE.
    ; -------------------------------------------------------------------------
    LEA SI, TEXT
    MOV CX, TEXTLEN

PRINT_LOOP:
    MOV AL, [SI]
    MOV AH, 0EH
    MOV BH, 0                           ; Page nought
    MOV BL, 07H                         ; Light grey on black
    INT 10H

    INC SI
    LOOP PRINT_LOOP

    ; A new line is two characters here as well
    MOV AL, 0DH
    MOV AH, 0EH
    INT 10H
    MOV AL, 0AH
    MOV AH, 0EH
    INT 10H

    MOV AX, 4C00H
    INT 21H

END START

; =============================================================================
; TECHNICAL NOTES
; =============================================================================
; 1. ONE CHARACTER, NO TERMINATOR:
;    - The BIOS has no string service at all, so the loop is the program
;    -  responsibility. What it gains is not needing DOS to be running.
; 2. WHY A BOOT SECTOR USES THIS:
;    - Before an operating system has loaded there is no INT 21h. The
;    - BIOS is what a boot loader has, which is why every one of them
;    - prints through service 0Eh.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
