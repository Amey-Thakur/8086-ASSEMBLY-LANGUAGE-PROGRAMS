; =============================================================================
; TITLE: Skipping an Element Inside a Loop
; DESCRIPTION: Sums only the even numbers in an array, jumping over the rest,
;              which is what a continue statement compiles into.
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
    NUMBERS DW 3, 8, 15, 22, 7, 40
    HOWMANY EQU 6
    M_EVEN  DB 'Sum of the even values: $'
    M_COUNT DB 'How many were even: $'

; -----------------------------------------------------------------------------
; CODE SEGMENT
; -----------------------------------------------------------------------------
.CODE
START:
    MOV AX, @DATA
    MOV DS, AX

    LEA SI, NUMBERS
    MOV CX, HOWMANY
    XOR BX, BX                          ; Running total
    XOR DI, DI                          ; How many were counted

FILTER_LOOP:
    MOV AX, [SI]

    ; -------------------------------------------------------------------------
    ; A NUMBER IS EVEN WHEN ITS LOWEST BIT IS CLEAR. TEST ASKS THAT QUESTION
    ; WITHOUT CHANGING THE VALUE, WHICH IS STILL NEEDED FOR THE ADDITION.
    ; -------------------------------------------------------------------------
    TEST AX, 1
    JNZ  SKIP                           ; Odd, so move on

    ADD BX, AX
    INC DI

SKIP:
    ; -------------------------------------------------------------------------
    ; THE SKIP LANDS ON THE POINTER ADVANCE, NOT ON THE LOOP INSTRUCTION.
    ; JUMPING PAST THE ADVANCE WOULD READ THE SAME ELEMENT FOREVER.
    ; -------------------------------------------------------------------------
    ADD SI, 2
    LOOP FILTER_LOOP

    LEA DX, M_EVEN
    MOV AH, 09H
    INT 21H
    MOV AX, BX
    CALL PRINT_DECIMAL
    CALL NEWLINE

    LEA DX, M_COUNT
    MOV AH, 09H
    INT 21H
    MOV AX, DI
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
; 1. WHERE THE SKIP LANDS:
;    - On the housekeeping at the end of the body, never past it. This is
;    - exactly what a continue does in a higher level language, and the
;    - same mistake is possible there when the increment is written
;    - inside the body rather than in the loop header.
; 2. TESTING FOR EVEN:
;    - TEST AX, 1 is the whole test. Dividing by two and checking the
;    - remainder gives the same answer at about thirty times the cost.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
