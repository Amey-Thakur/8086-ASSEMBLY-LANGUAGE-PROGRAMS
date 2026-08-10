; =============================================================================
; TITLE: A Vertical Histogram With An Axis
; DESCRIPTION: Draws columns upwards rather than bars sideways, which means the screen has to be built one row at a time.
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
    DATA_B  DB 3, 7, 2, 9, 5, 8, 4, 6
    HOWMANY EQU 8
    TALLEST EQU 9                       ; The largest value in the set

    M_TITLE DB 'A vertical histogram, drawn row by row from the top', 0DH, 0AH, '$'
    M_BLANK DB '   $'
    M_BLOCK DB '## $'
    M_AXIS  DB '---$'
    M_CORN  DB '+', '$'
    M_LABEL DB ' $'
    M_LEG   DB 0DH, 0AH, 'Values: $'
    M_SPACE DB ' $'
    M_WHY   DB 0DH, 0AH
            DB 'A column cannot be drawn downwards without moving the cursor, '
            DB 'so the whole picture is emitted in reading order instead.'
            DB 0DH, 0AH, '$'

; -----------------------------------------------------------------------------
; CODE SEGMENT
; -----------------------------------------------------------------------------
.CODE
START:
    MOV AX, @DATA
    MOV DS, AX

    LEA DX, M_TITLE
    CALL PRINT_MESSAGE
    CALL NEWLINE

    ; -------------------------------------------------------------------------
    ; THE OUTER LOOP IS THE SCREEN ROW, COUNTING DOWN FROM THE TALLEST VALUE.
    ; A COLUMN IS PART OF A BAR ON THIS ROW WHEN ITS VALUE IS AT LEAST THE ROW
    ; NUMBER, WHICH IS THE WHOLE TEST.
    ; -------------------------------------------------------------------------
    MOV BP, TALLEST                     ; Current height being drawn

EACH_LEVEL:
    XOR SI, SI
    MOV CX, HOWMANY

EACH_COLUMN:
    MOV BL, DATA_B[SI]
    XOR BH, BH

    CMP BX, BP
    JB COLUMN_BLANK

    LEA DX, M_BLOCK
    CALL PRINT_MESSAGE
    JMP COLUMN_NEXT

COLUMN_BLANK:
    LEA DX, M_BLANK
    CALL PRINT_MESSAGE

COLUMN_NEXT:
    INC SI
    LOOP EACH_COLUMN

    CALL NEWLINE

    DEC BP
    JNZ EACH_LEVEL

    ; ---- the axis under it --------------------------------------------------
    MOV CX, HOWMANY
DRAW_AXIS:
    LEA DX, M_AXIS
    CALL PRINT_MESSAGE
    LOOP DRAW_AXIS
    CALL NEWLINE

    ; ---- and the values, lined up under their columns -----------------------
    XOR SI, SI
    MOV CX, HOWMANY
LABEL_COLUMNS:
    LEA DX, M_LABEL
    CALL PRINT_MESSAGE
    MOV BL, DATA_B[SI]
    XOR BH, BH
    MOV AX, BX
    CALL PRINT_DECIMAL
    LEA DX, M_LABEL
    CALL PRINT_MESSAGE
    INC SI
    LOOP LABEL_COLUMNS
    CALL NEWLINE

    LEA DX, M_WHY
    CALL PRINT_MESSAGE

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

; -----------------------------------------------------------------------------
; PRINT_MESSAGE
;
; Prints the dollar terminated string at DS:DX, leaving AX exactly as it was.
;
; Service 09H needs the service number in AH, and AH is the top half of AX. A
; caller that has just computed a result into AX and then sets AH for itself
; destroys that result: 500 becomes 09F4H, which prints as 2548. Doing the call
; in here, around a push and a pop, removes the trap for good.
; -----------------------------------------------------------------------------
PRINT_MESSAGE PROC
    PUSH AX

    MOV AH, 09H
    INT 21H

    POP AX
    RET
PRINT_MESSAGE ENDP

END START

; =============================================================================
; TECHNICAL NOTES
; =============================================================================
; 1. Rows outside, columns inside:
;    - A terminal can only be written in reading order, left to right and top to bottom.
;    - So a vertical chart is drawn by asking, for each row, which columns reach it.
;    - The test is simply whether the value is at least the current height.
; 2. Three characters to a column:
;    - Every cell is the same width, so the blocks, the axis and the labels line up.
;    - A one character column would be cramped and a variable one would not align.
;    - The label is padded to the same three characters for the same reason.
; 3. Counting down, not up:
;    - The top row of the picture is the tallest value, so the loop starts there.
;    - DEC and JNZ counts down to one and stops, which is the row for a value of one.
;    - Counting up would draw the chart upside down.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
