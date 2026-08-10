; =============================================================================
; TITLE: Based Indexed Addressing Mode
; DESCRIPTION: A base register and an index register together, the natural way to reach row and column of a two dimensional table.
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
    ; A three by three table stored row by row.
    GRID    DW 1, 2, 3
            DW 4, 5, 6
            DW 7, 8, 9
    COLS    EQU 3
    STRIDE  EQU COLS * 2                ; Bytes from one row to the next

    M_TITLE DB 'Based indexed: base register plus index register', 0DH, 0AH, '$'
    M_HOW   DB 'BX carries row*6 and SI carries column*2', 0DH, 0AH, '$'
    M_AT    DB 'row $'
    M_COMMA DB ', column $'
    M_HOLDS DB ' holds $'
    M_WHOLE DB 'The whole table read this way:', 0DH, 0AH, '$'
    M_SPACE DB ' $'
    M_ADJ   DB 'GRID[BX][SI] and [GRID+BX+SI] are the same instruction.', 0DH, 0AH, '$'

; -----------------------------------------------------------------------------
; CODE SEGMENT
; -----------------------------------------------------------------------------
.CODE
START:
    MOV AX, @DATA
    MOV DS, AX

    LEA DX, M_TITLE

    CALL PRINT_MESSAGE
    LEA DX, M_HOW
    CALL PRINT_MESSAGE

    ; -------------------------------------------------------------------------
    ; THREE INDIVIDUAL CELLS FIRST. THE ROW GOES INTO BX MULTIPLIED BY THE ROW
    ; STRIDE AND THE COLUMN INTO SI MULTIPLIED BY THE ELEMENT SIZE.
    ; -------------------------------------------------------------------------
    MOV BX, 0 * STRIDE
    MOV SI, 0 * 2
    CALL REPORT_CELL

    MOV BX, 1 * STRIDE
    MOV SI, 2 * 2
    CALL REPORT_CELL

    MOV BX, 2 * STRIDE
    MOV SI, 1 * 2
    CALL REPORT_CELL
    CALL NEWLINE

    ; -------------------------------------------------------------------------
    ; THE SAME TWO REGISTERS DRIVE A NESTED LOOP: THE OUTER ONE ADVANCES THE
    ; ROW BASE, THE INNER ONE THE COLUMN INDEX. THE READ ITSELF IS ONE
    ; INSTRUCTION WITH NO ARITHMETIC AROUND IT.
    ; -------------------------------------------------------------------------
    LEA DX, M_WHOLE
    CALL PRINT_MESSAGE

    XOR BX, BX
    MOV CX, COLS                        ; Rows, which happens to equal columns
EACH_ROW:
    PUSH CX
    XOR SI, SI
    MOV CX, COLS
EACH_COLUMN:
    MOV AX, GRID[BX][SI]
    CALL PRINT_DECIMAL
    LEA DX, M_SPACE
    CALL PRINT_MESSAGE
    ADD SI, 2
    LOOP EACH_COLUMN

    CALL NEWLINE
    ADD BX, STRIDE
    POP CX
    LOOP EACH_ROW
    CALL NEWLINE

    LEA DX, M_ADJ

    CALL PRINT_MESSAGE

    MOV AH, 4CH
    INT 21H

; -----------------------------------------------------------------------------
; REPORT_CELL
;
; Prints the cell selected by BX and SI, naming the row and column it worked
; out from them. Both registers are left as they were found.
; -----------------------------------------------------------------------------
REPORT_CELL PROC
    PUSH AX
    PUSH BX
    PUSH DX
    PUSH SI

    MOV AX, GRID[BX][SI]                ; Read before the registers are reused
    PUSH AX

    LEA DX, M_AT

    CALL PRINT_MESSAGE
    MOV AX, BX
    MOV BL, STRIDE                      ; Recover the row number from the base
    DIV BL
    XOR AH, AH
    CALL PRINT_DECIMAL

    LEA DX, M_COMMA

    CALL PRINT_MESSAGE
    MOV AX, SI
    SHR AX, 1                           ; And the column number from the index
    CALL PRINT_DECIMAL

    LEA DX, M_HOLDS

    CALL PRINT_MESSAGE
    POP AX
    CALL PRINT_DECIMAL
    CALL NEWLINE

    POP SI
    POP DX
    POP BX
    POP AX
    RET
REPORT_CELL ENDP

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
; 1. Only certain pairs are legal:
;    - The base must be BX or BP and the index must be SI or DI.
;    - [BX+SI], [BX+DI], [BP+SI] and [BP+DI] are the four combinations.
;    - [SI+DI] and [BX+BP] do not exist, because each half comes from a different field.
; 2. Row major arithmetic:
;    - A cell of a table with C columns sits at row*C*size + column*size.
;    - The row part goes in the base and the column part in the index.
;    - Neither register needs to be recomputed inside the inner loop.
; 3. Recovering the indices:
;    - The report divides the base by the stride to get the row back.
;    - It shifts the index right once to get the column, since a word is two bytes.
;    - A shift is the cheap way to divide by a power of two.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
