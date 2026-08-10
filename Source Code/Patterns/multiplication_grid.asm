; =============================================================================
; TITLE: A Multiplication Grid
; DESCRIPTION: Prints a times table with headings, which is a nested loop and
;              a column alignment problem.
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
    SIZE_   EQU 9
    M_HEAD  DB 'The nine times nine table:', 0DH, 0AH, '$'
    M_CORNER DB '  x $'
    M_RULE  DB '$'

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

    ; The heading row
    LEA DX, M_CORNER
    MOV AH, 09H
    INT 21H

    MOV BX, 1

HEADINGS:
    CMP BX, SIZE_
    JA  HEADINGS_DONE
    MOV AX, BX
    CALL PRINT_CELL
    INC BX
    JMP HEADINGS

HEADINGS_DONE:
    CALL NEWLINE

    ; -------------------------------------------------------------------------
    ; ONE ROW PER MULTIPLICAND, WITH THE MULTIPLICAND ITSELF PRINTED FIRST SO
    ; THE TABLE CAN BE READ IN EITHER DIRECTION. EVERY VALUE GOES THROUGH THE
    ; SAME CELL ROUTINE, WHICH IS WHAT KEEPS THE COLUMNS STRAIGHT WHEN THE
    ; PRODUCTS GO FROM ONE DIGIT TO TWO.
    ; -------------------------------------------------------------------------
    MOV BX, 1

EACH_ROW:
    CMP BX, SIZE_
    JA  FINISHED

    MOV AX, BX
    CALL PRINT_CELL

    MOV CX, 1

EACH_COLUMN:
    CMP CX, SIZE_
    JA  ROW_DONE

    MOV AX, BX
    PUSH DX
    MUL CX
    POP DX
    CALL PRINT_CELL

    INC CX
    JMP EACH_COLUMN

ROW_DONE:
    CALL NEWLINE
    INC BX
    JMP EACH_ROW

FINISHED:
    MOV AH, 4CH
    INT 21H

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
; 1. MUL WRITES DX:
;    - Which is why it is saved around the multiplication here. A word
;    - multiply always writes the high half, even when the product is
;    - small enough that it is zero.
; 2. ONE ROUTINE FOR EVERY CELL:
;    - The headings, the row labels and the products all go through the
;    - same padding routine, so nothing can drift out of alignment.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
