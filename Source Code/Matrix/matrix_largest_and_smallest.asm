; =============================================================================
; TITLE: Largest and Smallest Element
; DESCRIPTION: Finds the extremes of a matrix and reports which row and column
;              each was found in.
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

    MAT_A   DW  14,  -3,  27
            DW  -8,  41,   6
            DW  19,   2, -22

    BEST_AT DW 0
    WORST_AT DW 0

    M_A     DB 'A:', 0DH, 0AH, '$'
    M_MAX   DB 'Largest:  $'
    M_MIN   DB 'Smallest: $'
    M_AT    DB '  at row $'
    M_COL   DB ', column $'

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

    ; -------------------------------------------------------------------------
    ; THE MATRIX IS SCANNED AS ONE FLAT RUN, AND THE POSITION IS KEPT AS AN
    ; ELEMENT NUMBER. THE ROW AND COLUMN ARE RECOVERED AT THE END BY ONE
    ; DIVISION, WHICH IS CHEAPER THAN TRACKING BOTH THROUGHOUT.
    ; -------------------------------------------------------------------------
    LEA SI, MAT_A
    MOV BX, [SI]                        ; The largest so far
    MOV DI, [SI]                        ; The smallest so far
    MOV WORD PTR BEST_AT, 0
    MOV WORD PTR WORST_AT, 0

    MOV CX, CELLS
    XOR BP, BP                          ; Which element

SCAN:
    MOV AX, [SI]

    CMP AX, BX
    JLE NOT_LARGER
    MOV BX, AX
    MOV BEST_AT, BP

NOT_LARGER:
    CMP AX, DI
    JGE NOT_SMALLER
    MOV DI, AX
    MOV WORST_AT, BP

NOT_SMALLER:
    ADD SI, 2
    INC BP
    LOOP SCAN

    LEA DX, M_MAX
    MOV AH, 09H
    INT 21H
    MOV AX, BX
    CALL PRINT_SIGNED
    MOV AX, BEST_AT
    CALL SHOW_POSITION

    LEA DX, M_MIN
    MOV AH, 09H
    INT 21H
    MOV AX, DI
    CALL PRINT_SIGNED
    MOV AX, WORST_AT
    CALL SHOW_POSITION

    MOV AH, 4CH
    INT 21H

; -----------------------------------------------------------------------------
; SHOW_POSITION
;
; Turns the element number in AX into a row and a column and prints them.
; -----------------------------------------------------------------------------
SHOW_POSITION PROC
    PUSH AX
    PUSH BX
    PUSH DX

    XOR DX, DX
    MOV BX, N
    DIV BX                              ; AX = row, DX = column
    PUSH DX
    PUSH AX

    LEA DX, M_AT
    MOV AH, 09H
    INT 21H
    POP AX
    CALL PRINT_DECIMAL

    LEA DX, M_COL
    MOV AH, 09H
    INT 21H
    POP AX
    CALL PRINT_DECIMAL
    CALL NEWLINE

    POP DX
    POP BX
    POP AX
    RET
SHOW_POSITION ENDP

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
; 1. ONE DIVISION AT THE END:
;    - Dividing the element number by the width gives the row as the
;    - quotient and the column as the remainder, in a single instruction.
; 2. SIGNED COMPARISONS:
;    - The matrix contains negatives, so JLE and JGE are required. JBE
;    - and JAE would report -22 as the largest value.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
