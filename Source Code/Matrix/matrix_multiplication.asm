; =============================================================================
; TITLE: Matrix Multiplication
; DESCRIPTION: Multiplies two three by three matrices, walking one along its
;              rows and the other down its columns.
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
    CELLS   EQU N * N

    MAT_A   DW 1, 2, 3
            DW 4, 5, 6
            DW 7, 8, 9

    MAT_B   DW 9, 8, 7
            DW 6, 5, 4
            DW 3, 2, 1

    RESULT  DW CELLS DUP(0)

    ROW     DW 0
    COL     DW 0
    STEP_K  DW 0

    M_A     DB 'A:', 0DH, 0AH, '$'
    M_B     DB 'B:', 0DH, 0AH, '$'
    M_C     DB 'A x B:', 0DH, 0AH, '$'

; -----------------------------------------------------------------------------
; CODE SEGMENT
; -----------------------------------------------------------------------------
.CODE
START:
    MOV AX, @DATA
    MOV DS, AX

    LEA DX, M_A
    MOV AH, 09H
    INT 21H
    LEA SI, MAT_A
    CALL SHOW_MATRIX

    LEA DX, M_B
    MOV AH, 09H
    INT 21H
    LEA SI, MAT_B
    CALL SHOW_MATRIX

    ; -------------------------------------------------------------------------
    ; THREE NESTED LOOPS. THE OUTER TWO CHOOSE WHICH CELL OF THE RESULT IS
    ; BEING FILLED; THE INNER ONE ADDS UP THE PRODUCTS THAT MAKE IT. ELEMENT
    ; (I,J) OF A MATRIX OF WORDS SITS AT (I * N + J) * 2 BYTES FROM THE START.
    ; -------------------------------------------------------------------------
    MOV WORD PTR ROW, 0

ROW_LOOP:
    MOV AX, ROW
    CMP AX, N
    JAE MULTIPLY_DONE

    MOV WORD PTR COL, 0

COL_LOOP:
    MOV AX, COL
    CMP AX, N
    JAE NEXT_ROW

    XOR BP, BP                          ; The running total for this cell
    MOV WORD PTR STEP_K, 0

K_LOOP:
    MOV AX, STEP_K
    CMP AX, N
    JAE STORE_CELL

    ; A[row][k]
    MOV AX, ROW
    MOV BX, N
    MUL BX
    ADD AX, STEP_K
    SHL AX, 1
    MOV SI, AX
    MOV AX, MAT_A[SI]

    ; times B[k][col]
    MOV BX, STEP_K
    PUSH AX
    MOV AX, BX
    MOV BX, N
    MUL BX
    ADD AX, COL
    SHL AX, 1
    MOV DI, AX
    POP AX

    MUL WORD PTR MAT_B[DI]
    ADD BP, AX                          ; Into the running total

    INC WORD PTR STEP_K
    JMP K_LOOP

STORE_CELL:
    MOV AX, ROW
    MOV BX, N
    MUL BX
    ADD AX, COL
    SHL AX, 1
    MOV SI, AX
    MOV RESULT[SI], BP

    INC WORD PTR COL
    JMP COL_LOOP

NEXT_ROW:
    INC WORD PTR ROW
    JMP ROW_LOOP

MULTIPLY_DONE:
    LEA DX, M_C
    MOV AH, 09H
    INT 21H
    LEA SI, RESULT
    CALL SHOW_MATRIX

    MOV AH, 4CH
    INT 21H

; -----------------------------------------------------------------------------
; SHOW_MATRIX
;
; Prints the N by N matrix at DS:SI, one row per line.
; -----------------------------------------------------------------------------
SHOW_MATRIX PROC
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX
    PUSH SI

    MOV BX, N                           ; Rows still to print

SM_ROW:
    MOV CX, N                           ; Columns in this row

SM_CELL:
    MOV AX, [SI]
    PUSH BX
    PUSH CX
    PUSH SI
    CALL PRINT_PADDED
    POP SI
    POP CX
    POP BX

    ADD SI, 2
    LOOP SM_CELL

    CALL NEWLINE
    DEC BX
    JNZ SM_ROW

    POP SI
    POP DX
    POP CX
    POP BX
    POP AX
    RET
SHOW_MATRIX ENDP

; -----------------------------------------------------------------------------
; PRINT_PADDED
;
; Prints AX right aligned in five columns, so the rows line up whatever the
; magnitude of the values.
; -----------------------------------------------------------------------------
FIELD EQU 6                             ; Columns each value is given

PRINT_PADDED PROC
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX

    MOV BX, AX                          ; Keep the value; AX is needed to count

    ; ---- how many characters will it occupy ---------------------------------
    MOV CX, 1                           ; Every value has at least one digit
    MOV AX, BX
    OR  AX, AX
    JNS PP_COUNT
    INC CX                              ; And a negative one needs a sign
    NEG AX                              ; Count the digits of the magnitude

PP_COUNT:
    CMP AX, 10
    JB  PP_PAD                          ; A single digit is left

    PUSH BX                             ; DIV needs BX as the divisor
    XOR DX, DX
    MOV BX, 10
    DIV BX                              ; One digit fewer
    POP BX
    INC CX
    JMP PP_COUNT

    ; ---- pad to the field width, then print --------------------------------
PP_PAD:
    MOV AX, FIELD
    CMP AX, CX
    JBE PP_VALUE                        ; Too wide to pad at all

    SUB AX, CX
    MOV CX, AX                          ; This many spaces

PP_SPACES:
    MOV DL, ' '
    MOV AH, 02H
    INT 21H
    LOOP PP_SPACES

PP_VALUE:
    MOV AX, BX
    CALL PRINT_SIGNED

    POP DX
    POP CX
    POP BX
    POP AX
    RET
PRINT_PADDED ENDP

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
; 1. THE ADDRESS ARITHMETIC:
;    - Row times the width, plus the column, then doubled because the
;    - elements are words. Every two dimensional access on this processor
;    - is that same calculation.
; 2. WHY THE INNER LOOP WALKS DIFFERENTLY:
;    - A is read along a row, so its index rises by one each step. B is
;    - read down a column, so its index rises by the width. That
;    - asymmetry is the whole of matrix multiplication.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
