; =============================================================================
; TITLE: Printing a Matrix in a Spiral
; DESCRIPTION: Reads a grid from the outside inward, going right, down, left
;              and up, shrinking the boundary after each side.
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

    GRID    DW  1,  2,  3,  4
            DW  5,  6,  7,  8
            DW  9, 10, 11, 12
            DW 13, 14, 15, 16

    TOP_    DW 0
    BOTTOM_ DW N - 1
    LEFT_   DW 0
    RIGHT_  DW N - 1

    M_HEAD  DB 'The grid read as a spiral:', 0DH, 0AH, '$'

; -----------------------------------------------------------------------------
; CODE SEGMENT
; -----------------------------------------------------------------------------
.CODE
START:
    MOV AX, @DATA
    MOV DS, AX

    LEA DX, M_HEAD
    MOV AH, 09H
    INT 21H

    ; -------------------------------------------------------------------------
    ; FOUR BOUNDARIES CLOSE IN ON EACH OTHER. AFTER THE TOP ROW IS READ THE
    ; TOP MOVES DOWN, AFTER THE RIGHT COLUMN THE RIGHT MOVES LEFT, AND SO ON.
    ; THE SPIRAL ENDS WHEN THE BOUNDARIES CROSS.
    ; -------------------------------------------------------------------------
SPIRAL:
    MOV AX, TOP_
    CMP AX, BOTTOM_
    JA  FINISHED
    MOV AX, LEFT_
    CMP AX, RIGHT_
    JA  FINISHED

    ; ---- along the top, left to right --------------------------------------
    MOV CX, LEFT_

TOP_ROW:
    MOV AX, RIGHT_
    CMP CX, AX
    JA  TOP_DONE

    MOV AX, TOP_
    CALL SHOW_CELL
    INC CX
    JMP TOP_ROW

TOP_DONE:
    INC WORD PTR TOP_

    MOV AX, TOP_
    CMP AX, BOTTOM_
    JA  FINISHED

    ; ---- down the right side ------------------------------------------------
    MOV BX, TOP_

RIGHT_COL:
    MOV AX, BOTTOM_
    CMP BX, AX
    JA  RIGHT_DONE

    MOV CX, RIGHT_
    MOV AX, BX
    CALL SHOW_CELL
    INC BX
    JMP RIGHT_COL

RIGHT_DONE:
    DEC WORD PTR RIGHT_

    MOV AX, LEFT_
    CMP AX, RIGHT_
    JA  FINISHED

    ; ---- along the bottom, right to left ------------------------------------
    MOV CX, RIGHT_

BOTTOM_ROW:
    MOV AX, LEFT_
    CMP CX, AX
    JB  BOTTOM_DONE

    MOV AX, BOTTOM_
    CALL SHOW_CELL
    DEC CX
    CMP CX, 0FFFFH
    JE  BOTTOM_DONE
    JMP BOTTOM_ROW

BOTTOM_DONE:
    DEC WORD PTR BOTTOM_

    MOV AX, TOP_
    CMP AX, BOTTOM_
    JA  FINISHED

    ; ---- up the left side ---------------------------------------------------
    MOV BX, BOTTOM_

LEFT_COL:
    MOV AX, TOP_
    CMP BX, AX
    JB  LEFT_DONE

    MOV CX, LEFT_
    MOV AX, BX
    CALL SHOW_CELL
    DEC BX
    CMP BX, 0FFFFH
    JE  LEFT_DONE
    JMP LEFT_COL

LEFT_DONE:
    INC WORD PTR LEFT_
    JMP SPIRAL

FINISHED:
    CALL NEWLINE
    MOV AH, 4CH
    INT 21H

; -----------------------------------------------------------------------------
; SHOW_CELL
;
; Prints the cell at row AX, column CX.
; -----------------------------------------------------------------------------
SHOW_CELL PROC
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX
    PUSH SI

    MOV BX, N
    MUL BX
    ADD AX, CX
    SHL AX, 1
    MOV SI, AX
    MOV AX, GRID[SI]

    CALL PRINT_CELL

    POP SI
    POP DX
    POP CX
    POP BX
    POP AX
    RET
SHOW_CELL ENDP

; -----------------------------------------------------------------------------
; REPEAT_CHAR
;
; Prints the character in DL, CX times. A count of nought prints nothing,
; which is what makes the first row of most patterns come out right.
; -----------------------------------------------------------------------------
REPEAT_CHAR PROC
    PUSH AX
    PUSH CX
    PUSH DX

    JCXZ RC_DONE

RC_LOOP:
    MOV AH, 02H
    INT 21H
    LOOP RC_LOOP

RC_DONE:
    POP DX
    POP CX
    POP AX
    RET
REPEAT_CHAR ENDP

; -----------------------------------------------------------------------------
; PRINT_CELL
;
; Prints AX followed by enough spaces to fill four columns, so that a grid of
; numbers lines up whether the values are one digit or three.
; -----------------------------------------------------------------------------
PRINT_CELL PROC
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX

    MOV BX, AX

    ; How many digits will it take
    MOV CX, 1
    MOV AX, BX

PC_COUNT:
    CMP AX, 10
    JB  PC_EMIT
    PUSH BX
    XOR DX, DX
    MOV BX, 10
    DIV BX
    POP BX
    INC CX
    JMP PC_COUNT

PC_EMIT:
    PUSH CX
    MOV AX, BX
    CALL PRINT_DECIMAL
    POP CX

    MOV AX, 4
    CMP AX, CX
    JBE PC_DONE
    SUB AX, CX
    MOV CX, AX
    MOV DL, ' '
    CALL REPEAT_CHAR

PC_DONE:
    POP DX
    POP CX
    POP BX
    POP AX
    RET
PRINT_CELL ENDP

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
; 1. THE BOUNDARY CHECKS BETWEEN SIDES:
;    - Without them, a grid with an odd number of rows reads its middle
;    - row twice. Each side has to confirm there is still something left
;    - before it starts.
; 2. COUNTING DOWN PAST ZERO:
;    - The two sides that travel backwards would wrap from nought to
;    - 65535, so they test for that rather than comparing against the
;    - boundary alone.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
