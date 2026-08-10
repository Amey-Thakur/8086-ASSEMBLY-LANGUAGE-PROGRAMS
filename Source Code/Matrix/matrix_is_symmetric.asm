; =============================================================================
; TITLE: Testing a Matrix for Symmetry
; DESCRIPTION: Decides whether a matrix equals its own transpose, comparing only
;              the cells above the diagonal.
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

    SYM     DW  1,  7,  3
            DW  7,  4,  5
            DW  3,  5,  6

    NOTSYM  DW  1,  7,  3
            DW  2,  4,  5
            DW  3,  5,  6

    M_ONE   DB 'The first matrix:', 0DH, 0AH, '$'
    M_TWO   DB 'The second matrix:', 0DH, 0AH, '$'
    M_YES   DB 'is symmetric', 0DH, 0AH, '$'
    M_NO    DB 'is not symmetric', 0DH, 0AH, '$'

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
    LEA SI, SYM
    CALL SHOW_MATRIX
    LEA SI, SYM
    CALL CHECK_SYMMETRY

    LEA DX, M_TWO
    MOV AH, 09H
    INT 21H
    LEA SI, NOTSYM
    CALL SHOW_MATRIX
    LEA SI, NOTSYM
    CALL CHECK_SYMMETRY

    MOV AH, 4CH
    INT 21H

; -----------------------------------------------------------------------------
; CHECK_SYMMETRY
;
; SI points at an N by N matrix. Reports whether it equals its transpose.
; -----------------------------------------------------------------------------
CHECK_SYMMETRY PROC
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX
    PUSH SI
    PUSH DI

    XOR BX, BX                          ; The row

CS_ROW:
    CMP BX, N
    JAE CS_SYMMETRIC

    MOV CX, BX
    INC CX                              ; The column, starting past the diagonal

CS_COL:
    CMP CX, N
    JAE CS_NEXT_ROW

    ; -------------------------------------------------------------------------
    ; ONLY THE CELLS ABOVE THE DIAGONAL NEED CHECKING. EVERY PAIR BELOW IT IS
    ; THE SAME COMPARISON MADE THE OTHER WAY ROUND, AND THE DIAGONAL ITSELF IS
    ; ALWAYS EQUAL TO ITSELF.
    ; -------------------------------------------------------------------------
    ; The cell at (row, col)
    MOV AX, BX
    PUSH DX
    MOV DX, N
    MUL DX
    POP DX
    ADD AX, CX
    SHL AX, 1
    MOV DI, AX
    ADD DI, SI
    MOV AX, [DI]

    ; against the cell at (col, row)
    PUSH AX
    MOV AX, CX
    PUSH DX
    MOV DX, N
    MUL DX
    POP DX
    ADD AX, BX
    SHL AX, 1
    MOV DI, AX
    ADD DI, SI
    POP AX

    CMP AX, [DI]
    JNE CS_ASYMMETRIC

    INC CX
    JMP CS_COL

CS_NEXT_ROW:
    INC BX
    JMP CS_ROW

CS_SYMMETRIC:
    LEA DX, M_YES
    JMP CS_REPORT

CS_ASYMMETRIC:
    LEA DX, M_NO

CS_REPORT:
    MOV AH, 09H
    INT 21H

    POP DI
    POP SI
    POP DX
    POP CX
    POP BX
    POP AX
    RET
CHECK_SYMMETRY ENDP

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
; 1. HALF THE COMPARISONS:
;    - Starting the column at the row plus one skips the diagonal and
;    - everything below it, which halves the work and cannot change the
;    - answer.
; 2. ONE MISMATCH DECIDES IT:
;    - Symmetry needs every pair to agree; asymmetry needs one pair not
;    - to. The loop leaves at the first disagreement.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
