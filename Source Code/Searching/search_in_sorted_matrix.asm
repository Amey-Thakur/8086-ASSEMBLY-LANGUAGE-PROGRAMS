; =============================================================================
; TITLE: Searching a Sorted Matrix
; DESCRIPTION: Finds a value in a matrix whose rows and columns are both
;              sorted, by starting at a corner where every step is decided.
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
    N       EQU 4

    ; Every row increases left to right and every column top to bottom
    GRID    DW  1,  4,  7, 11
            DW  2,  5,  8, 12
            DW  3,  6,  9, 16
            DW 10, 13, 14, 17

    WANTED  DW 6
    ABSENT  DW 15

    M_LOOK  DB 'Looking for $'
    M_AT    DB '   at row $'
    M_COL   DB ', column $'
    M_NONE  DB '   not present', 0DH, 0AH, '$'
    M_STEPS DB '   steps: $'

; -----------------------------------------------------------------------------
; CODE SEGMENT
; -----------------------------------------------------------------------------
.CODE
START:
    MOV AX, @DATA
    MOV DS, AX

    MOV AX, WANTED
    CALL MATRIX_SEARCH

    MOV AX, ABSENT
    CALL MATRIX_SEARCH

    MOV AX, 4C00H
    INT 21H

; -----------------------------------------------------------------------------
; MATRIX_SEARCH
;
; Looks for AX. Starts at the top right corner, where a value too large means
; the whole column can go and too small means the whole row can go. Every step
; therefore eliminates a line, and the search takes at most N plus N of them.
; -----------------------------------------------------------------------------
MATRIX_SEARCH PROC
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX

    PUSH AX
    LEA DX, M_LOOK
    MOV AH, 09H
    INT 21H
    POP AX
    PUSH AX
    CALL PRINT_DECIMAL
    POP AX

    MOV BP, AX                          ; What is sought
    XOR BX, BX                          ; The row, starting at the top
    MOV CX, N
    DEC CX                              ; The column, starting at the right
    XOR DI, DI                          ; Steps taken

SEARCH:
    CMP BX, N
    JAE MS_ABSENT
    CMP CX, 0FFFFH
    JE  MS_ABSENT

    INC DI

    ; Read the cell at (row, column)
    MOV AX, BX
    PUSH DX
    MOV DX, N
    MUL DX
    POP DX
    ADD AX, CX
    SHL AX, 1
    MOV SI, AX
    MOV AX, GRID[SI]

    CMP AX, BP
    JE  MS_FOUND
    JB  MS_DOWN

    DEC CX                              ; Too large: this column cannot hold it
    JMP SEARCH

MS_DOWN:
    INC BX                              ; Too small: this row cannot hold it
    JMP SEARCH

MS_FOUND:
    PUSH DI
    LEA DX, M_AT
    MOV AH, 09H
    INT 21H
    MOV AX, BX
    CALL PRINT_DECIMAL
    LEA DX, M_COL
    MOV AH, 09H
    INT 21H
    MOV AX, CX
    CALL PRINT_DECIMAL
    POP DI
    JMP MS_STEPS

MS_ABSENT:
    PUSH DI
    LEA DX, M_NONE
    MOV AH, 09H
    INT 21H
    POP DI
    JMP MS_DONE

MS_STEPS:
    PUSH DI
    LEA DX, M_STEPS
    MOV AH, 09H
    INT 21H
    POP AX
    CALL PRINT_DECIMAL
    CALL NEWLINE

MS_DONE:
    POP DX
    POP CX
    POP BX
    POP AX
    RET
MATRIX_SEARCH ENDP

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
; 1. WHY THE TOP RIGHT CORNER:
;    - It is the only corner where both comparisons are decisive. From the
;    - top left, a value too small could be either right or down, and
;    - nothing can be eliminated.
; 2. LINEAR, NOT LOGARITHMIC:
;    - At most 2N steps for an N by N grid, which is far better than
;    - searching every cell but not as good as a true binary search. The
;    - rows overlap, so the grid is not one sorted sequence.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
