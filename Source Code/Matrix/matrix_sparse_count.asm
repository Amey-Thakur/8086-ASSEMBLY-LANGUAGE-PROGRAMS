; =============================================================================
; TITLE: Counting the Zeros in a Matrix
; DESCRIPTION: Counts how much of a matrix is empty and decides whether it is
;              sparse enough to be worth storing differently.
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

    MAT_A   DW  0,  0,  3
            DW  0,  0,  0
            DW  7,  0,  0

    M_A     DB 'A:', 0DH, 0AH, '$'
    M_ZERO  DB 'Zeros:     $'
    M_TOTAL DB ' of $'
    M_SPARSE DB 'More than half the cells are empty, so a list of the non', 0DH, 0AH
             DB 'zero positions would take less room than the matrix.', 0DH, 0AH, '$'
    M_DENSE DB 'Most cells hold something, so the matrix is the better', 0DH, 0AH
            DB 'representation.', 0DH, 0AH, '$'

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

    LEA SI, MAT_A
    MOV CX, CELLS
    XOR BX, BX                          ; How many were zero

COUNT:
    CMP WORD PTR [SI], 0
    JNE NOT_ZERO
    INC BX

NOT_ZERO:
    ADD SI, 2
    LOOP COUNT

    PUSH BX
    LEA DX, M_ZERO
    MOV AH, 09H
    INT 21H
    POP AX
    PUSH AX
    CALL PRINT_DECIMAL
    LEA DX, M_TOTAL
    MOV AH, 09H
    INT 21H
    MOV AX, CELLS
    CALL PRINT_DECIMAL
    CALL NEWLINE
    POP BX

    ; -------------------------------------------------------------------------
    ; A SPARSE MATRIX IS USUALLY STORED AS A LIST OF ROW, COLUMN AND VALUE
    ; TRIPLES. THAT COSTS THREE WORDS PER NON ZERO CELL, SO IT ONLY SAVES
    ; SPACE WHEN FEWER THAN A THIRD OF THE CELLS ARE OCCUPIED.
    ; -------------------------------------------------------------------------
    MOV AX, BX
    SHL AX, 1                           ; Twice the zero count
    CMP AX, CELLS
    JBE MOSTLY_FULL

    LEA DX, M_SPARSE
    JMP REPORT

MOSTLY_FULL:
    LEA DX, M_DENSE

REPORT:
    MOV AH, 09H
    INT 21H

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
; 1. COMPARING WITHOUT DIVIDING:
;    - Asking whether the zeros are more than half is asking whether twice
;    - the count exceeds the total. Doubling is one shift; dividing would
;    - be eighty cycles.
; 2. THE REAL THRESHOLD:
;    - Storing row, column and value costs three words where the matrix
;    - costs one, so the crossover is nearer a third than a half. The
;    - half used here is the simple version of the question.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
