; =============================================================================
; TITLE: Triangular Numbers
; DESCRIPTION: Produces the running totals 1, 3, 6, 10 and so on, and checks
;              each against the closed formula for the same value.
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
    HOWMANY EQU 8
    MSG     DB 'The first eight triangular numbers:', 0DH, 0AH, '$'
    SPACE   DB ' $'
    M_AGREE DB 'The formula agreed at every step.', 0DH, 0AH, '$'
    M_DIFF  DB 'The formula disagreed.', 0DH, 0AH, '$'

; -----------------------------------------------------------------------------
; CODE SEGMENT
; -----------------------------------------------------------------------------
.CODE
START:
    MOV AX, @DATA
    MOV DS, AX

    LEA DX, MSG
    MOV AH, 09H
    INT 21H

    MOV CX, HOWMANY
    MOV BX, 1                           ; The term number
    XOR SI, SI                          ; The running total
    MOV DI, 1                           ; Set to zero if the formula ever differs

TRIANGLE_LOOP:
    ADD SI, BX                          ; The definition: add the next number

    ; -------------------------------------------------------------------------
    ; THE CLOSED FORM IS N TIMES N PLUS ONE, HALVED. THE PRODUCT OF TWO
    ; CONSECUTIVE NUMBERS IS ALWAYS EVEN, SO THE HALVING IS EXACT AND CAN BE
    ; DONE WITH A SHIFT.
    ; -------------------------------------------------------------------------
    MOV AX, BX
    INC AX
    MUL BX
    SHR AX, 1

    CMP AX, SI
    JE  STILL_AGREES
    XOR DI, DI

STILL_AGREES:
    PUSH CX
    PUSH BX
    MOV AX, SI
    CALL PRINT_DECIMAL
    LEA DX, SPACE
    MOV AH, 09H
    INT 21H
    POP BX
    POP CX

    INC BX
    LOOP TRIANGLE_LOOP

    CALL NEWLINE

    OR  DI, DI
    JZ  DISAGREED
    LEA DX, M_AGREE
    JMP REPORT

DISAGREED:
    LEA DX, M_DIFF

REPORT:
    MOV AH, 09H
    INT 21H

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
; 1. TWO WAYS, CHECKED AGAINST EACH OTHER:
;    - One accumulates and one computes directly. Running both and
;    - comparing is a cheap way to be sure neither is wrong.
; 2. THE HALVING IS SAFE:
;    - One of any two consecutive numbers is even, so the product is
;    - always divisible by two and the shift never loses anything.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
