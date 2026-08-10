; =============================================================================
; TITLE: Happy Numbers
; DESCRIPTION: Repeatedly replaces a number with the sum of the squares of its
;              digits, and detects the cycle that shows it will never reach one.
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
    SAMPLES DW 19, 20, 23, 4
    HOWMANY EQU 4
    SEP     DB ' is $'
    M_HAPPY DB 'happy', 0DH, 0AH, '$'
    M_SAD   DB 'not happy', 0DH, 0AH, '$'

; -----------------------------------------------------------------------------
; CODE SEGMENT
; -----------------------------------------------------------------------------
.CODE
START:
    MOV AX, @DATA
    MOV DS, AX

    LEA SI, SAMPLES
    MOV CX, HOWMANY

EACH_SAMPLE:
    MOV BX, [SI]

    PUSH CX
    PUSH SI

    MOV AX, BX
    CALL PRINT_DECIMAL
    LEA DX, SEP
    MOV AH, 09H
    INT 21H

    ; -------------------------------------------------------------------------
    ; A NUMBER IS UNHAPPY WHEN IT FALLS INTO A CYCLE, AND EVERY SUCH CYCLE
    ; PASSES THROUGH FOUR. TESTING FOR FOUR IS THEREFORE ENOUGH, AND NEEDS NO
    ; RECORD OF WHAT HAS BEEN SEEN BEFORE.
    ; -------------------------------------------------------------------------
HAPPY_LOOP:
    CMP BX, 1
    JE  IS_HAPPY
    CMP BX, 4
    JE  IS_SAD

    CALL SUM_SQUARED_DIGITS             ; BX in, BX out
    JMP HAPPY_LOOP

IS_HAPPY:
    LEA DX, M_HAPPY
    JMP REPORT

IS_SAD:
    LEA DX, M_SAD

REPORT:
    MOV AH, 09H
    INT 21H

    POP SI
    POP CX
    ADD SI, 2
    LOOP EACH_SAMPLE

    MOV AH, 4CH
    INT 21H

; -----------------------------------------------------------------------------
; SUM_SQUARED_DIGITS
;
; Replaces BX with the sum of the squares of its decimal digits.
; -----------------------------------------------------------------------------
SUM_SQUARED_DIGITS PROC
    PUSH AX
    PUSH CX
    PUSH DX
    PUSH DI

    XOR DI, DI
    MOV AX, BX
    MOV CX, 10

SSD_LOOP:
    XOR DX, DX
    DIV CX                              ; DX = the lowest digit
    PUSH AX                             ; The quotient, for the next pass

    MOV AX, DX
    MUL DX                              ; The digit squared
    ADD DI, AX

    POP AX
    OR  AX, AX
    JNZ SSD_LOOP

    MOV BX, DI

    POP DI
    POP DX
    POP CX
    POP AX
    RET
SUM_SQUARED_DIGITS ENDP

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
; 1. WHY FOUR IS THE ONLY TEST NEEDED:
;    - Every unhappy number eventually enters the single cycle 4, 16, 37,
;    - 58, 89, 145, 42, 20 and back to 4. Meeting any member is enough,
;    - and four is the smallest.
; 2. THE PROCEDURE RETURNS IN BX:
;    - BX is deliberately not saved, since it carries both the argument
;    - in and the answer out.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
