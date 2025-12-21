; =============================================================================
; TITLE: DOS Display String
; DESCRIPTION: Displays a '$' terminated string using DOS Interrupt 21H, 
;              Function 09H.
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
    MSG_HELLO   DB "Hello, 8086 World!", 0DH, 0AH, "$"

; -----------------------------------------------------------------------------
; CODE SEGMENT
; -----------------------------------------------------------------------------
.CODE
MAIN PROC
    ; --- Step 1: Initialize DS ---
    MOV AX, @DATA
    MOV DS, AX

    ; --- Step 2: Print String (INT 21h / AH=09h) ---
    LEA DX, MSG_HELLO
    MOV AH, 09H
    INT 21H

    ; --- Step 3: Exit ---
    MOV AH, 4CH
    INT 21H
MAIN ENDP
END MAIN

; =============================================================================
; TECHNICAL NOTES & ARCHITECTURAL INSIGHTS
; =============================================================================
; 1. TERMINATOR '$':
;    - DOS Function 09h prints characters starting at DS:DX until it finds '$'.
;    - This means you literally CANNOT print a '$' symbol with this function 
;      (use Function 02h or 40h instead).
;    - The terminator is NOT printed.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
