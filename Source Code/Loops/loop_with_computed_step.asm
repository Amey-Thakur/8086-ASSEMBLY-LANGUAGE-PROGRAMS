; =============================================================================
; TITLE: Stepping by More Than One
; DESCRIPTION: Visits every third element of an array by advancing the pointer
;              further each pass, and derives the count rather than assuming it.
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
    SERIES  DW 1, 2, 3, 4, 5, 6, 7, 8, 9
    HOWMANY EQU 9
    STEP    EQU 3
    M_HEAD  DB 'Every third element: $'
    SPACE   DB ' $'

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

    LEA SI, SERIES

    ; -------------------------------------------------------------------------
    ; THE NUMBER OF PASSES IS THE ELEMENT COUNT DIVIDED BY THE STEP, WORKED
    ; OUT BY THE ASSEMBLER RATHER THAN WRITTEN AS A LITERAL. CHANGING EITHER
    ; CONSTANT KEEPS THE LOOP CORRECT.
    ; -------------------------------------------------------------------------
    MOV CX, HOWMANY / STEP

STEP_LOOP:
    MOV AX, [SI]

    PUSH CX
    PUSH SI
    CALL PRINT_DECIMAL
    LEA DX, SPACE
    MOV AH, 09H
    INT 21H
    POP SI
    POP CX

    ADD SI, STEP * 2                    ; Three words, so six bytes
    LOOP STEP_LOOP

    CALL NEWLINE

    MOV AH, 4CH
    INT 21H

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
; 1. LET THE ASSEMBLER DO THE ARITHMETIC:
;    - HOWMANY / STEP and STEP * 2 are worked out at assembly time and
;    - cost nothing at run time. Writing 3 and 6 as literals would work
;    - until one of the constants changed.
; 2. DIVISION TRUNCATES:
;    - Nine divided by three is exact. Ten would give three passes and
;    - quietly ignore the tenth element, which is the kind of thing to
;    - check rather than assume.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
