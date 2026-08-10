; =============================================================================
; TITLE: A Bar Chart In Text Mode
; DESCRIPTION: Scales a set of values to the width available and draws one row per value, with the value printed beside it.
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
    DATA_W  DW 34, 17, 48, 5, 29, 41
    HOWMANY EQU 6
    WIDEST  EQU 40                      ; Columns available for the longest bar

    M_TITLE DB 'A bar chart scaled to forty columns', 0DH, 0AH, '$'
    M_LARG  DB 'Largest value: $'
    M_SCALE DB 0DH, 0AH, 'Each block stands for one unit of the scaled length.'
            DB 0DH, 0AH, 0DH, 0AH, '$'
    M_PAD   DB '  $'
    M_SPACE DB ' $'
    M_BLOCK DB '#$'

; -----------------------------------------------------------------------------
; CODE SEGMENT
; -----------------------------------------------------------------------------
.CODE
START:
    MOV AX, @DATA
    MOV DS, AX

    LEA DX, M_TITLE
    CALL PRINT_MESSAGE

    ; -------------------------------------------------------------------------
    ; THE LARGEST VALUE HAS TO BE FOUND BEFORE ANYTHING CAN BE DRAWN, BECAUSE IT
    ; IS WHAT THE OTHERS ARE SCALED AGAINST. A CHART SCALED TO A GUESSED MAXIMUM
    ; EITHER CLIPS OR WASTES THE WIDTH.
    ; -------------------------------------------------------------------------
    XOR SI, SI
    XOR BX, BX                          ; The largest seen
    MOV CX, HOWMANY

FIND_LARGEST:
    MOV AX, DATA_W[SI]
    CMP AX, BX
    JBE NOT_LARGER
    MOV BX, AX
NOT_LARGER:
    ADD SI, 2
    LOOP FIND_LARGEST

    MOV BP, BX                          ; Keep it out of the way of the division

    LEA DX, M_LARG
    CALL PRINT_MESSAGE
    MOV AX, BP
    CALL PRINT_DECIMAL
    LEA DX, M_SCALE
    CALL PRINT_MESSAGE

    ; -------------------------------------------------------------------------
    ; SCALING. THE LENGTH IS VALUE TIMES WIDEST DIVIDED BY THE LARGEST, DONE IN
    ; THAT ORDER SO THE MULTIPLY HAPPENS BEFORE THE DIVIDE AND NO PRECISION IS
    ; THROWN AWAY. THE PRODUCT CAN EXCEED A WORD, SO DX:AX HOLDS IT AND DIV
    ; TAKES BOTH HALVES.
    ; -------------------------------------------------------------------------
    XOR SI, SI
    MOV CX, HOWMANY

EACH_BAR:
    ; ---- the value, right aligned in two columns ----------------------------
    MOV AX, DATA_W[SI]
    CMP AX, 10
    JAE NO_PAD
    LEA DX, M_SPACE
    CALL PRINT_MESSAGE
NO_PAD:
    MOV AX, DATA_W[SI]
    CALL PRINT_DECIMAL
    LEA DX, M_PAD
    CALL PRINT_MESSAGE

    ; ---- the scaled length --------------------------------------------------
    MOV AX, DATA_W[SI]
    MOV BX, WIDEST
    MUL BX                              ; DX:AX = value * WIDEST
    MOV BX, BP
    DIV BX                              ; AX = that / largest

    ; A value of zero would give a bar of nothing, which is correct, so the
    ; count is tested rather than assumed to be positive.
    MOV DI, AX
    PUSH CX
    MOV CX, DI
    JCXZ BAR_DONE

DRAW_BLOCK:
    LEA DX, M_BLOCK
    CALL PRINT_MESSAGE
    LOOP DRAW_BLOCK

BAR_DONE:
    POP CX
    CALL NEWLINE

    ADD SI, 2
    LOOP EACH_BAR

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
; 1. Multiply before dividing:
;    - Value times width divided by the maximum keeps the ratio exact to the unit.
;    - Dividing first would round every bar down to zero or one.
;    - MUL leaves the product in DX:AX and DIV consumes both halves, so nothing overflows.
; 2. Find the maximum first:
;    - The scale cannot be chosen until every value has been seen.
;    - So the data is walked twice: once to measure, once to draw.
;    - A guessed maximum either clips the tall bars or wastes most of the width.
; 3. A zero length bar is legal:
;    - LOOP with CX at zero would run 65536 times, not none.
;    - JCXZ is the guard, and is needed wherever a count could be zero.
;    - The smallest value here scales to four, but the guard costs nothing.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
