; =============================================================================
; TITLE: Counting Occurrences by Bisection
; DESCRIPTION: Counts how many elements are less than a value and how many are
;              at most that value, and subtracts to get the count.
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
    SORTED  DW 1, 3, 3, 3, 7, 7, 9, 12, 12, 12, 12, 15
    HOWMANY EQU 12

    TRIALS  DW 3, 7, 12, 8
    COUNT   EQU 4

    M_ARRAY DB 'Sorted: $'
    M_TIMES DB ' appears $'
    M_TAIL  DB ' times', 0DH, 0AH, '$'

; -----------------------------------------------------------------------------
; CODE SEGMENT
; -----------------------------------------------------------------------------
.CODE
START:
    MOV AX, @DATA
    MOV DS, AX

    LEA DX, M_ARRAY
    MOV AH, 09H
    INT 21H
    LEA SI, SORTED
    MOV CX, HOWMANY
    CALL SHOW_RUN

    LEA SI, TRIALS
    MOV CX, COUNT

EACH_TRIAL:
    MOV BP, [SI]

    PUSH CX
    PUSH SI

    MOV AX, BP
    CALL PRINT_DECIMAL

    ; -------------------------------------------------------------------------
    ; TWO BISECTIONS. THE FIRST FINDS WHERE THE VALUE WOULD BE INSERTED, WHICH
    ; IS HOW MANY ARE STRICTLY SMALLER. THE SECOND FINDS WHERE ONE MORE THAN
    ; THE VALUE WOULD GO, WHICH IS HOW MANY ARE AT MOST THE VALUE. THE
    ; DIFFERENCE IS THE ANSWER, AND IT IS RIGHT EVEN WHEN THE ANSWER IS NOUGHT.
    ; -------------------------------------------------------------------------
    CALL LOWER_BOUND
    MOV BX, AX                          ; How many are smaller

    INC BP
    CALL LOWER_BOUND
    DEC BP
    SUB AX, BX                          ; How many equal the value

    PUSH AX
    LEA DX, M_TIMES
    MOV AH, 09H
    INT 21H
    POP AX
    CALL PRINT_DECIMAL
    LEA DX, M_TAIL
    MOV AH, 09H
    INT 21H

    POP SI
    POP CX
    ADD SI, 2
    LOOP EACH_TRIAL

    MOV AX, 4C00H
    INT 21H

; -----------------------------------------------------------------------------
; LOWER_BOUND
;
; Returns in AX how many elements are strictly less than BP.
; -----------------------------------------------------------------------------
LOWER_BOUND PROC
    PUSH BX
    PUSH CX
    PUSH DX

    XOR BX, BX
    MOV DX, HOWMANY

LB_LOOP:
    CMP BX, DX
    JAE LB_DONE

    MOV CX, BX
    ADD CX, DX
    SHR CX, 1

    MOV SI, CX
    SHL SI, 1
    MOV AX, SORTED[SI]

    CMP AX, BP
    JAE LB_LEFT

    MOV BX, CX
    INC BX
    JMP LB_LOOP

LB_LEFT:
    MOV DX, CX
    JMP LB_LOOP

LB_DONE:
    MOV AX, BX

    POP DX
    POP CX
    POP BX
    RET
LOWER_BOUND ENDP

; -----------------------------------------------------------------------------
; SHOW_RUN
;
; Prints CX words starting at DS:SI, then a newline.
; -----------------------------------------------------------------------------
SHOW_RUN PROC
    PUSH AX
    PUSH CX
    PUSH DX
    PUSH SI

    JCXZ SR_DONE

SR_LOOP:
    MOV AX, [SI]
    PUSH CX
    PUSH SI
    CALL PRINT_DECIMAL
    MOV DL, ' '
    MOV AH, 02H
    INT 21H
    POP SI
    POP CX
    ADD SI, 2
    LOOP SR_LOOP

SR_DONE:
    CALL NEWLINE

    POP SI
    POP DX
    POP CX
    POP AX
    RET
SHOW_RUN ENDP

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
; 1. ONE ROUTINE, TWO QUESTIONS:
;    - Asking for the lower bound of the value and of one more than it
;    - brackets the run. No separate upper bound routine is needed.
; 2. A VALUE THAT IS ABSENT:
;    - Both bisections return the same position, so the difference is
;    - nought. That falls out of the method rather than needing a test.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
