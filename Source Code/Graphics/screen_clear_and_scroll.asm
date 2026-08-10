; =============================================================================
; TITLE: Clearing And Scrolling The Screen
; DESCRIPTION: Service 06h scrolls a rectangle, and scrolling one by zero lines is how the screen is cleared.
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
    LINES   EQU 12                      ; Lines written before any scrolling
    ROLLED  EQU 3                       ; Lines the whole screen is scrolled by
    WIN_TOP EQU 5
    WIN_BOT EQU 10

    M_LINE  DB 'line $'
    M_DONE  DB 'Service 06h, in the order this program used it:', 0DH, 0AH, 0DH, 0AH, '$'
    M_ONE   DB '1. Wrote 12 numbered lines, to have something to move.', 0DH, 0AH, '$'
    M_TWO   DB '2. Scrolled the whole screen up 3 lines.', 0DH, 0AH, '$'
    M_THREE DB '3. Scrolled only rows 5 to 10 up 1 line.', 0DH, 0AH, '$'
    M_FOUR  DB '4. Cleared everything with a scroll of zero lines.', 0DH, 0AH, '$'
    M_WHY   DB 0DH, 0AH
            DB 'Which is why nothing above this appears: step four erased it. '
            DB 'The report is printed afterwards for that reason.', 0DH, 0AH, '$'
    M_MODE  DB 0DH, 0AH, 'Video mode reported by service 0Fh: $'
    M_COLS  DB ', columns: $'

; -----------------------------------------------------------------------------
; CODE SEGMENT
; -----------------------------------------------------------------------------
.CODE
START:
    MOV AX, @DATA
    MOV DS, AX

    ; -------------------------------------------------------------------------
    ; SOMETHING TO SCROLL. THESE LINES ARE WRITTEN AND THEN DELIBERATELY LOST,
    ; WHICH IS THE POINT OF THE PROGRAM.
    ; -------------------------------------------------------------------------
    MOV SI, 1
    MOV CX, LINES
NUMBER_LINES:
    LEA DX, M_LINE
    CALL PRINT_MESSAGE
    MOV AX, SI
    CALL PRINT_DECIMAL
    CALL NEWLINE
    INC SI
    LOOP NUMBER_LINES

    ; -------------------------------------------------------------------------
    ; SERVICE 06H SCROLLS A RECTANGLE. AL IS HOW MANY LINES, CH AND CL THE TOP
    ; LEFT CORNER, DH AND DL THE BOTTOM RIGHT, AND BH THE ATTRIBUTE THE VACATED
    ; LINES ARE PAINTED WITH.
    ; -------------------------------------------------------------------------
    MOV AH, 06H
    MOV AL, ROLLED
    MOV BH, 07H                         ; Ordinary grey on black
    MOV CH, 0
    MOV CL, 0
    MOV DH, 24                          ; Last row of an eighty by twenty-five screen
    MOV DL, 79                          ; Last column
    INT 10H

    ; -------------------------------------------------------------------------
    ; THE SAME CALL WITH A SMALLER RECTANGLE SCROLLS A WINDOW AND LEAVES THE
    ; REST OF THE SCREEN ALONE. THIS IS HOW A STATUS LINE STAYS PUT WHILE THE
    ; TEXT ABOVE IT MOVES.
    ; -------------------------------------------------------------------------
    MOV AH, 06H
    MOV AL, 1
    MOV BH, 07H
    MOV CH, WIN_TOP
    MOV CL, 0
    MOV DH, WIN_BOT
    MOV DL, 79
    INT 10H

    ; -------------------------------------------------------------------------
    ; ZERO LINES IS THE SPECIAL CASE: THE RECTANGLE IS BLANKED RATHER THAN
    ; MOVED. GIVEN THE WHOLE SCREEN, THAT IS THE STANDARD CLEAR.
    ; -------------------------------------------------------------------------
    MOV AH, 06H
    MOV AL, 0
    MOV BH, 07H
    MOV CH, 0
    MOV CL, 0
    MOV DH, 24
    MOV DL, 79
    INT 10H

    ; A clear does not move the cursor, so it is put back by hand.
    MOV AH, 02H
    MOV BH, 0
    MOV DH, 0
    MOV DL, 0
    INT 10H

    ; -------------------------------------------------------------------------
    ; AND ONLY NOW THE REPORT, BECAUSE ANYTHING PRINTED EARLIER WAS ERASED BY
    ; THE CLEAR.
    ; -------------------------------------------------------------------------
    LEA DX, M_DONE
    CALL PRINT_MESSAGE
    LEA DX, M_ONE
    CALL PRINT_MESSAGE
    LEA DX, M_TWO
    CALL PRINT_MESSAGE
    LEA DX, M_THREE
    CALL PRINT_MESSAGE
    LEA DX, M_FOUR
    CALL PRINT_MESSAGE
    LEA DX, M_WHY
    CALL PRINT_MESSAGE

    ; Service 0Fh reports the mode actually in force, which is still text.
    MOV AH, 0FH
    INT 10H
    MOV SI, AX

    LEA DX, M_MODE
    CALL PRINT_MESSAGE
    MOV AX, SI
    AND AX, 0FFH
    CALL PRINT_DECIMAL

    LEA DX, M_COLS
    CALL PRINT_MESSAGE
    MOV AX, SI
    MOV AL, AH
    XOR AH, AH
    CALL PRINT_DECIMAL
    CALL NEWLINE

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
; 1. Zero lines means blank:
;    - AL holding zero clears the rectangle instead of scrolling it.
;    - Given the whole screen as the rectangle, that is the standard clear.
;    - Any other value moves the contents up by that many lines.
; 2. The rectangle is inclusive:
;    - CH and CL are the top row and left column, DH and DL the bottom and right.
;    - Row 24 and column 79 are the last of an eighty by twenty-five screen.
;    - Passing 25 and 80 asks for a rectangle one row and one column too large.
; 3. Print the report after the clear:
;    - Anything written before a clear is erased by it, including the explanation.
;    - The first version of this program narrated each step and lost all of it.
;    - So the order is: do the work, clear, then say what was done.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
