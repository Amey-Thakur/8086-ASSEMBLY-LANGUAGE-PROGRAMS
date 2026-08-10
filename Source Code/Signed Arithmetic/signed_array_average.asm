; =============================================================================
; TITLE: Average of Signed Values
; DESCRIPTION: Averages a set of readings that may be negative, which needs the
;              sum sign extended before the division.
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
    READINGS DW -20, -15, 40, 5, -10, 30
    HOWMANY  EQU 6
    M_SUM    DB 'Sum:     $'
    M_AVG    DB 'Average: $'
    M_REM    DB ' remainder $'

; -----------------------------------------------------------------------------
; CODE SEGMENT
; -----------------------------------------------------------------------------
.CODE
START:
    MOV AX, @DATA
    MOV DS, AX

    LEA SI, READINGS
    MOV CX, HOWMANY
    XOR BX, BX

SUM_LOOP:
    ADD BX, [SI]                        ; Signed addition is the same as unsigned
    ADD SI, 2
    LOOP SUM_LOOP

    LEA DX, M_SUM
    MOV AH, 09H
    INT 21H
    MOV AX, BX
    CALL PRINT_SIGNED
    CALL NEWLINE

    ; -------------------------------------------------------------------------
    ; ADDITION NEEDS NO SIGNED VARIANT, BECAUSE THE BITS COME OUT THE SAME
    ; EITHER WAY. DIVISION DOES, AND IT NEEDS DX SET FROM THE SIGN FIRST.
    ; -------------------------------------------------------------------------
    MOV AX, BX
    CWD
    MOV BX, HOWMANY
    IDIV BX

    PUSH AX                             ; The quotient, before DOS can touch AH
    PUSH DX                             ; The remainder

    LEA DX, M_AVG
    MOV AH, 09H
    INT 21H

    POP BX                              ; Hold the remainder
    POP AX                              ; Recover the quotient intact
    PUSH BX
    CALL PRINT_SIGNED

    LEA DX, M_REM
    MOV AH, 09H
    INT 21H
    POP AX
    CALL PRINT_SIGNED
    CALL NEWLINE

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
; 1. WHY ADD HAS NO SIGNED FORM:
;    - Two complement addition produces the right bits whichever way the
;    - operands are read. Only the flags differ, and only multiplication,
;    - division and comparison need to know.
; 2. THE AVERAGE OF THESE SIX:
;    - The sum is 30 and there are six readings, so the average is five
;    - exactly and the remainder is zero.
; 3. WHY THE QUOTIENT IS PUSHED FIRST:
;    - The next instruction after the division is MOV AH, 09H, and AH is
;    - the top half of AX. Setting up the DOS call overwrites the top of
;    - the very answer that is about to be printed.
;    - An average of five became 0905h, which printed as 2309. The value
;    - was never wrong; it was destroyed by the code that displayed it.
;    - Any result left in AX has to be saved before AH is loaded.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
