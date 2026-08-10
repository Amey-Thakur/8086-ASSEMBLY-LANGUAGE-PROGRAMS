; =============================================================================
; TITLE: Binomial Coefficient
; DESCRIPTION: Computes n choose r by multiplying and dividing alternately, so
;              that no intermediate value grows beyond a word.
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
    N_VAL DW 12
    R_VAL DW 5
    MSG   DB '12 choose 5 is $'

; -----------------------------------------------------------------------------
; CODE SEGMENT
; -----------------------------------------------------------------------------
.CODE
START:
    MOV AX, @DATA
    MOV DS, AX

    ; -------------------------------------------------------------------------
    ; COMPUTING THE THREE FACTORIALS WOULD NEED 12 FACTORIAL, WHICH IS ABOUT
    ; 479 MILLION AND WILL NOT FIT. INSTEAD THE RESULT IS BUILT UP ONE TERM
    ; AT A TIME, MULTIPLYING BY (N - R + I) AND DIVIDING BY I, WHICH IS EXACT
    ; AT EVERY STEP BECAUSE THE PARTIAL RESULT IS ALWAYS A BINOMIAL ITSELF.
    ; -------------------------------------------------------------------------
    MOV SI, 1                           ; The running result
    MOV CX, 1                           ; The term number, i

    MOV BX, N_VAL
    SUB BX, R_VAL                       ; BX = n - r

TERM_LOOP:
    CMP CX, R_VAL
    JA  DONE_TERMS

    MOV AX, BX
    ADD AX, CX                          ; n - r + i
    MUL SI                              ; times the running result
    DIV CX                              ; divided by i, exactly
    MOV SI, AX

    INC CX
    JMP TERM_LOOP

DONE_TERMS:
    LEA DX, MSG
    MOV AH, 09H
    INT 21H
    MOV AX, SI
    CALL PRINT_DECIMAL
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
; 1. WHY THE DIVISION IS ALWAYS EXACT:
;    - After i terms the running value is n-r+i choose i, which is a
;    - whole number. The division therefore never leaves a remainder,
;    - and no rounding error can build up.
; 2. THE ORDER MATTERS:
;    - Multiplying before dividing keeps the value a whole number.
;    - Dividing first would truncate and the answer would drift.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
