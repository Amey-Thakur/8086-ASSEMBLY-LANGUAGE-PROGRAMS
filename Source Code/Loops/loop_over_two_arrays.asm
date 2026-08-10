; =============================================================================
; TITLE: Walking Two Arrays at Once
; DESCRIPTION: Advances two pointers in step to combine a pair of arrays, using
;              SI for one and DI for the other.
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
    PRICES   DW 12, 40, 7, 25
    QUANTITY DW 3, 1, 10, 2
    HOWMANY  EQU 4
    M_TOTAL  DB 'Order total: $'

; -----------------------------------------------------------------------------
; CODE SEGMENT
; -----------------------------------------------------------------------------
.CODE
START:
    MOV AX, @DATA
    MOV DS, AX

    LEA SI, PRICES
    LEA DI, QUANTITY
    MOV CX, HOWMANY
    XOR BX, BX                          ; Running total

    ; -------------------------------------------------------------------------
    ; SI AND DI ARE THE TWO INDEX REGISTERS, AND HAVING BOTH IS EXACTLY WHY
    ; THE PROCESSOR PROVIDES TWO. A THIRD ARRAY WOULD HAVE TO USE BX OR AN
    ; EXPLICIT DISPLACEMENT.
    ; -------------------------------------------------------------------------
PAIR_LOOP:
    MOV AX, [SI]                        ; The price
    MUL WORD PTR [DI]                   ; Times the quantity
    ADD BX, AX                          ; Into the total

    ADD SI, 2
    ADD DI, 2
    LOOP PAIR_LOOP

    LEA DX, M_TOTAL
    MOV AH, 09H
    INT 21H
    MOV AX, BX
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
; 1. WORD PTR ON THE MULTIPLIER:
;    - MUL takes one operand and decides its width from it. [DI] alone
;    - does not say whether a byte or a word is meant, so it has to be
;    - stated. Omitting it is an assembly error, not a silent bug.
; 2. MUL USES AX AND DX:
;    - The product of two words is thirty two bits, so the high half
;    - lands in DX. Here the totals are small enough for DX to stay zero,
;    - but a larger order would need it.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
