; =============================================================================
; TITLE: Row and Column Sums
; DESCRIPTION: Totals every row and every column, and checks the two grand
;              totals against each other.
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

    MAT_A   DW  2,  7,  6
            DW  9,  5,  1
            DW  4,  3,  8

    M_A     DB 'A:', 0DH, 0AH, '$'
    M_ROWS  DB 'Row sums:    $'
    M_COLS  DB 'Column sums: $'
    M_AGREE DB 'Both totals agree.', 0DH, 0AH, '$'
    M_DIFF  DB 'The totals disagree.', 0DH, 0AH, '$'
    SPACE   DB '  $'

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
    ; A ROW IS CONTIGUOUS, SO ITS ELEMENTS ARE TWO BYTES APART. THE POINTER
    ; SIMPLY WALKS FORWARD AND THE ROWS FALL OUT ONE AFTER ANOTHER.
    ; -------------------------------------------------------------------------
    LEA DX, M_ROWS
    MOV AH, 09H
    INT 21H

    LEA SI, MAT_A
    MOV BX, N                           ; Rows remaining
    XOR BP, BP                          ; The grand total

ROW_SUMS:
    MOV CX, N
    XOR DI, DI                          ; This row's total

ROW_CELLS:
    ADD DI, [SI]
    ADD SI, 2
    LOOP ROW_CELLS

    ADD BP, DI

    PUSH BX
    PUSH SI
    MOV AX, DI
    CALL PRINT_DECIMAL
    LEA DX, SPACE
    MOV AH, 09H
    INT 21H
    POP SI
    POP BX

    DEC BX
    JNZ ROW_SUMS

    CALL NEWLINE
    PUSH BP                             ; Keep the grand total

    ; -------------------------------------------------------------------------
    ; A COLUMN IS NOT CONTIGUOUS. ITS ELEMENTS ARE A WHOLE ROW APART, WHICH IS
    ; N TIMES TWO BYTES, SO THE POINTER JUMPS RATHER THAN WALKS.
    ; -------------------------------------------------------------------------
    LEA DX, M_COLS
    MOV AH, 09H
    INT 21H

    XOR BX, BX                          ; Which column
    XOR BP, BP

COL_SUMS:
    CMP BX, N
    JAE COLUMNS_DONE

    MOV SI, BX
    SHL SI, 1                           ; The top of this column
    MOV CX, N
    XOR DI, DI

COL_CELLS:
    ADD DI, MAT_A[SI]
    ADD SI, N * 2                       ; Straight down a row
    LOOP COL_CELLS

    ADD BP, DI

    PUSH BX
    MOV AX, DI
    CALL PRINT_DECIMAL
    LEA DX, SPACE
    MOV AH, 09H
    INT 21H
    POP BX

    INC BX
    JMP COL_SUMS

COLUMNS_DONE:
    CALL NEWLINE

    POP AX                              ; The row grand total
    CMP AX, BP
    JNE TOTALS_DIFFER

    LEA DX, M_AGREE
    JMP REPORT

TOTALS_DIFFER:
    LEA DX, M_DIFF

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
; 1. ROWS ARE CHEAP, COLUMNS ARE NOT:
;    - Walking a row reads consecutive memory; walking a column jumps by
;    - the width every time. On a machine with a cache that difference is
;    - enormous, and it is why algorithms are written to favour rows.
; 2. THE TOTALS MUST MATCH:
;    - Both add up every element once, so any difference means one of the
;    - loops is wrong. Checking is free and catches a stride error at
;    - once.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
