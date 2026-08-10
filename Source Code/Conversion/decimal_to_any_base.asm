; =============================================================================
; TITLE: Writing a Number in Any Base
; DESCRIPTION: Converts one value into base two, eight, ten and sixteen with a
;              single routine, by making the base a parameter.
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
    VALUE   DW 46315
    DIGITS  DB '0123456789ABCDEF'
    SCRATCH DB 20 DUP(0)

    M_HEAD  DB '46315 written in several bases:', 0DH, 0AH, '$'
    M_BASE  DB 'base $'
    M_SEP   DB ':  $'

; -----------------------------------------------------------------------------
; CODE SEGMENT
; -----------------------------------------------------------------------------
.CODE
START:
    MOV AX, @DATA
    MOV DS, AX

    LEA DX, M_HEAD
    MOV AH, 09H
    INT 21H

    MOV BX, 2
    CALL SHOW_IN_BASE
    MOV BX, 8
    CALL SHOW_IN_BASE
    MOV BX, 10
    CALL SHOW_IN_BASE
    MOV BX, 16
    CALL SHOW_IN_BASE

    MOV AH, 4CH
    INT 21H

; -----------------------------------------------------------------------------
; SHOW_IN_BASE
;
; Prints VALUE in the base given in BX.
; -----------------------------------------------------------------------------
SHOW_IN_BASE PROC
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX

    PUSH BX
    LEA DX, M_BASE
    MOV AH, 09H
    INT 21H
    POP BX
    PUSH BX
    MOV AX, BX
    CALL PRINT_DECIMAL
    LEA DX, M_SEP
    MOV AH, 09H
    INT 21H
    POP BX

    ; -------------------------------------------------------------------------
    ; DIVIDING BY THE BASE PRODUCES THE DIGITS FROM THE LEAST SIGNIFICANT
    ; UPWARD, WHICH IS THE OPPOSITE OF THE ORDER THEY MUST BE WRITTEN IN. THEY
    ; ARE COLLECTED INTO A BUFFER AND READ BACK OUT BACKWARDS.
    ; -------------------------------------------------------------------------
    MOV AX, VALUE
    LEA SI, SCRATCH
    XOR CX, CX                          ; How many digits were produced

SIB_DIVIDE:
    XOR DX, DX
    DIV BX                              ; AX = quotient, DX = this digit

    PUSH BX
    MOV BX, DX
    MOV DL, DIGITS[BX]                  ; The character for it
    POP BX

    MOV [SI], DL
    INC SI
    INC CX

    OR  AX, AX
    JNZ SIB_DIVIDE

SIB_EMIT:
    DEC SI
    MOV DL, [SI]
    MOV AH, 02H
    INT 21H
    LOOP SIB_EMIT

    CALL NEWLINE

    POP DX
    POP CX
    POP BX
    POP AX
    RET
SHOW_IN_BASE ENDP

; -----------------------------------------------------------------------------
; PRINT_DECIMAL
;
; Prints the unsigned value in AX as decimal, with no leading zeros.
; Every register it touches is restored, so a caller can rely on it.
; -----------------------------------------------------------------------------
PRINT_DECIMAL PROC
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX

    XOR CX, CX                          ; How many digits have been stacked
    MOV BX, 10

PD_DIVIDE:
    XOR DX, DX                          ; DX:AX is the dividend, so clear DX
    DIV BX                              ; AX = quotient, DX = this digit
    PUSH DX                             ; Digits arrive lowest first
    INC CX
    OR  AX, AX
    JNZ PD_DIVIDE                       ; Keep going until the quotient is zero

PD_EMIT:
    POP DX                              ; Unstacking reverses them into order
    ADD DL, '0'
    MOV AH, 02H
    INT 21H
    LOOP PD_EMIT

    POP DX
    POP CX
    POP BX
    POP AX
    RET
PRINT_DECIMAL ENDP

; -----------------------------------------------------------------------------
; NEWLINE
;
; Moves to the start of the next line. DOS needs both characters: the return
; moves the cursor to column zero and the feed moves it down a line.
; -----------------------------------------------------------------------------
NEWLINE PROC
    PUSH AX
    PUSH DX

    MOV DL, 0DH
    MOV AH, 02H
    INT 21H
    MOV DL, 0AH
    MOV AH, 02H
    INT 21H

    POP DX
    POP AX
    RET
NEWLINE ENDP

END START

; =============================================================================
; TECHNICAL NOTES
; =============================================================================
; 1. ONE ROUTINE FOR EVERY BASE:
;    - Nothing in the division depends on which base it is, so the same
;    - code prints binary, octal, decimal and hexadecimal. Only the digit
;    - table has to be long enough.
; 2. THE DIGITS ARRIVE BACKWARDS:
;    - Every method that divides produces the least significant digit
;    - first. Either buffer them and reverse, as here, or push them onto
;    - the stack and pop them, which reverses them for free.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
