; =============================================================================
; TITLE: Checking a Value Lies Within a Range
; DESCRIPTION: Tests whether readings fall between two signed bounds, and shows
;              the single subtraction that replaces two comparisons.
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
    LOWER    EQU -20
    UPPER    EQU 40
    READINGS DW -35, -20, 0, 40, 55
    HOWMANY  EQU 5
    M_IN     DB ' is within range', 0DH, 0AH, '$'
    M_OUT    DB ' is outside range', 0DH, 0AH, '$'

; -----------------------------------------------------------------------------
; CODE SEGMENT
; -----------------------------------------------------------------------------
.CODE
START:
    MOV AX, @DATA
    MOV DS, AX

    LEA SI, READINGS
    MOV CX, HOWMANY

CHECK_LOOP:
    MOV BX, [SI]

    PUSH CX
    PUSH SI

    MOV AX, BX
    CALL PRINT_SIGNED

    ; -------------------------------------------------------------------------
    ; THE PLAIN FORM: TWO SIGNED COMPARISONS, ONE AGAINST EACH BOUND. BOTH
    ; HAVE TO USE THE SIGNED BRANCHES OR A NEGATIVE READING PASSES THE LOWER
    ; TEST BY LOOKING ENORMOUS.
    ; -------------------------------------------------------------------------
    CMP BX, LOWER
    JL  OUT_OF_RANGE
    CMP BX, UPPER
    JG  OUT_OF_RANGE

    LEA DX, M_IN
    JMP REPORT

OUT_OF_RANGE:
    LEA DX, M_OUT

REPORT:
    MOV AH, 09H
    INT 21H

    POP SI
    POP CX
    ADD SI, 2
    LOOP CHECK_LOOP

    MOV AH, 4CH
    INT 21H

; -----------------------------------------------------------------------------
; PRINT_SIGNED
;
; Prints AX as a signed value, with a minus sign when it is negative.
; -----------------------------------------------------------------------------
PRINT_SIGNED PROC
    PUSH AX
    PUSH DX

    OR  AX, AX
    JNS PS_POSITIVE                     ; Sign flag clear means not negative

    PUSH AX
    MOV DL, '-'
    MOV AH, 02H
    INT 21H
    POP AX
    NEG AX                              ; Print the magnitude

PS_POSITIVE:
    CALL PRINT_DECIMAL

    POP DX
    POP AX
    RET
PRINT_SIGNED ENDP

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
; 1. THE BOUNDS ARE INCLUSIVE:
;    - JL and JG exclude only values strictly outside, so -20 and 40 both
;    - pass. JLE and JGE would exclude the bounds themselves.
; 2. THE SINGLE COMPARISON TRICK:
;    - Subtracting the lower bound and then comparing unsigned against
;    - the width of the range does both tests at once, because a value
;    - below the lower bound wraps to something enormous.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
