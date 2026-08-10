; =============================================================================
; TITLE: Upper and Lower Triangular Tests
; DESCRIPTION: Decides whether a matrix has zeros below or above its diagonal,
;              which is what makes a system of equations easy to solve.
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
    N       EQU 3

    UPPER   DW  3,  4,  5
            DW  0,  6,  7
            DW  0,  0,  8

    LOWER   DW  3,  0,  0
            DW  4,  6,  0
            DW  5,  7,  8

    M_ONE   DB 'The first matrix is $'
    M_TWO   DB 'The second matrix is $'
    M_UPPER DB 'upper triangular', 0DH, 0AH, '$'
    M_LOWER DB 'lower triangular', 0DH, 0AH, '$'
    M_NONE  DB 'neither', 0DH, 0AH, '$'

; -----------------------------------------------------------------------------
; CODE SEGMENT
; -----------------------------------------------------------------------------
.CODE
START:
    MOV AX, @DATA
    MOV DS, AX

    LEA DX, M_ONE
    MOV AH, 09H
    INT 21H
    LEA SI, UPPER
    CALL CLASSIFY

    LEA DX, M_TWO
    MOV AH, 09H
    INT 21H
    LEA SI, LOWER
    CALL CLASSIFY

    MOV AH, 4CH
    INT 21H

; -----------------------------------------------------------------------------
; CLASSIFY
;
; SI points at an N by N matrix. Two flags are kept: whether everything below
; the diagonal is zero, and whether everything above it is. Both are assumed
; true and cleared by the first counterexample, so one pass answers both
; questions at once.
; -----------------------------------------------------------------------------
CLASSIFY PROC
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX
    PUSH SI
    PUSH DI

    MOV BP, 0303H                       ; BH set means upper, BL set means lower
    MOV BX, 0101H

    XOR CX, CX                          ; The row

C_ROW:
    CMP CX, N
    JAE C_DECIDE

    XOR DX, DX                          ; The column

C_COL:
    CMP DX, N
    JAE C_NEXT_ROW

    ; Read the cell at (row, column)
    MOV AX, CX
    PUSH DX
    MOV DI, N
    MUL DI
    POP DX
    ADD AX, DX
    SHL AX, 1
    MOV DI, AX
    ADD DI, SI
    MOV AX, [DI]

    OR  AX, AX
    JZ  C_NEXT_COL                      ; A zero never rules anything out

    CMP DX, CX
    JB  C_BELOW                         ; Column less than row is below
    JA  C_ABOVE
    JMP C_NEXT_COL                      ; The diagonal itself is unconstrained

C_BELOW:
    MOV BH, 0                           ; Not upper triangular
    JMP C_NEXT_COL

C_ABOVE:
    MOV BL, 0                           ; Not lower triangular

C_NEXT_COL:
    INC DX
    JMP C_COL

C_NEXT_ROW:
    INC CX
    JMP C_ROW

C_DECIDE:
    OR  BH, BH
    JZ  C_TRY_LOWER
    LEA DX, M_UPPER
    JMP C_REPORT

C_TRY_LOWER:
    OR  BL, BL
    JZ  C_NEITHER
    LEA DX, M_LOWER
    JMP C_REPORT

C_NEITHER:
    LEA DX, M_NONE

C_REPORT:
    MOV AH, 09H
    INT 21H

    POP DI
    POP SI
    POP DX
    POP CX
    POP BX
    POP AX
    RET
CLASSIFY ENDP

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
; 1. TWO FLAGS IN ONE REGISTER:
;    - BH and BL are the two halves of BX, so both answers are carried in
;    - one register and both are cleared by the same loop.
; 2. THE DIAGONAL IS NOT CONSTRAINED:
;    - Neither definition says anything about it, so a non zero on the
;    - diagonal rules out nothing and the comparison has to distinguish
;    - three cases rather than two.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
