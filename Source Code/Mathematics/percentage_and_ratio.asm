; =============================================================================
; TITLE: Percentage and Ratio, Multiply Before Divide
; DESCRIPTION: Integer division throws away the fraction, so the scaling has to
;              happen first. Shows what dividing first costs, takes one decimal
;              place from the remainder, and guards the division that follows.
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
    PART_W  DW    37, 1234, 450, 7, 30000
    WHOLE_W DW   250, 5000, 600, 9, 40000
    HOWMANY EQU 5

    PART_V  DW ?                        ; The case being worked
    WHOLE_V DW ?
    SCALE   DW 100                      ; Per hundred is what per cent means
    TEN     DW 10                       ; The scale again, for one more digit

    M_TITLE DB 'A part of a whole, expressed per hundred', 0DH, 0AH, '$'
    M_SLASH DB ' / $'
    M_DFIRST DB '   dividing first: $'
    M_MFIRST DB '   multiplying first: $'
    M_PC    DB ' per cent$'
    M_BIG   DB 'larger than sixteen bits will hold$'
    M_RATIO DB 0DH, 0AH, 'The same pair read both ways round', 0DH, 0AH, '$'
    M_OUTOF DB ' out of $'
    M_IS    DB ' is $'

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
    ; STEP 1: EVERY CASE BOTH WAYS ROUND, SO THE COST OF THE WRONG ORDER SHOWS
    ; -------------------------------------------------------------------------
    XOR SI, SI
    MOV CX, HOWMANY

EACH_CASE:
    MOV AX, PART_W[SI]
    MOV PART_V, AX
    MOV AX, WHOLE_W[SI]
    MOV WHOLE_V, AX

    CALL SHOW_CASE

    ADD SI, 2
    LOOP EACH_CASE

    ; -------------------------------------------------------------------------
    ; STEP 2: A RATIO IS TWO PERCENTAGES. READ THE OTHER WAY ROUND THE ANSWER
    ; CAN BE FAR ABOVE A HUNDRED, WHICH IS WHY THE GUARD IS NOT DECORATION.
    ; -------------------------------------------------------------------------
    LEA DX, M_RATIO
    CALL PRINT_MESSAGE

    MOV AX, 40
    MOV PART_V, AX
    MOV AX, 250
    MOV WHOLE_V, AX
    CALL SHOW_BOTH_WAYS

    MOV AX, 17
    MOV PART_V, AX
    MOV AX, 391
    MOV WHOLE_V, AX
    CALL SHOW_BOTH_WAYS

    MOV AX, 9
    MOV PART_V, AX
    MOV AX, 4
    MOV WHOLE_V, AX
    CALL SHOW_BOTH_WAYS

    MOV AX, 3
    MOV PART_V, AX
    MOV AX, 60000
    MOV WHOLE_V, AX
    CALL SHOW_BOTH_WAYS

    MOV AH, 4CH
    INT 21H

; -----------------------------------------------------------------------------
; SHOW_CASE
;
; Prints one row: the pair, the answer that dividing first gives, and the
; answer that multiplying first gives.
; -----------------------------------------------------------------------------
SHOW_CASE PROC
    PUSH AX
    PUSH BX
    PUSH DX

    MOV AX, PART_V
    CALL PRINT_DECIMAL
    LEA DX, M_SLASH
    CALL PRINT_MESSAGE
    MOV AX, WHOLE_V
    CALL PRINT_DECIMAL

    LEA DX, M_DFIRST
    CALL PRINT_MESSAGE

    ; Dividing first discards everything below one whole, and a genuine part of
    ; a whole is entirely below one, so nothing at all survives the division.
    ; Scaling the ruin by a hundred afterwards cannot bring any of it back.
    MOV AX, PART_V
    XOR DX, DX
    MOV BX, WHOLE_V
    DIV BX
    MUL SCALE
    CALL PRINT_DECIMAL

    LEA DX, M_MFIRST
    CALL PRINT_MESSAGE

    CALL PRINT_PERCENT
    CALL NEWLINE

    POP DX
    POP BX
    POP AX
    RET
SHOW_CASE ENDP

; -----------------------------------------------------------------------------
; SHOW_BOTH_WAYS
;
; Prints the part as a percentage of the whole, and then the whole as a
; percentage of the part, which is the same ratio inverted. The two values are
; put back as they were, so a caller sees no side effect.
; -----------------------------------------------------------------------------
SHOW_BOTH_WAYS PROC
    PUSH AX
    PUSH DX

    CALL SHOW_ONE_WAY

    MOV AX, PART_V
    MOV DX, WHOLE_V
    MOV PART_V, DX
    MOV WHOLE_V, AX

    CALL SHOW_ONE_WAY

    MOV AX, PART_V
    MOV DX, WHOLE_V
    MOV PART_V, DX
    MOV WHOLE_V, AX

    POP DX
    POP AX
    RET
SHOW_BOTH_WAYS ENDP

; -----------------------------------------------------------------------------
; SHOW_ONE_WAY
;
; Prints a single sentence naming the part, the whole and the percentage. The
; percentage comes last so that the sentence still reads properly on the case
; where the guard fires and a message is printed in place of a number.
; -----------------------------------------------------------------------------
SHOW_ONE_WAY PROC
    PUSH AX
    PUSH DX

    MOV AX, PART_V
    CALL PRINT_DECIMAL
    LEA DX, M_OUTOF
    CALL PRINT_MESSAGE
    MOV AX, WHOLE_V
    CALL PRINT_DECIMAL
    LEA DX, M_IS
    CALL PRINT_MESSAGE
    CALL PRINT_PERCENT
    CALL NEWLINE

    POP DX
    POP AX
    RET
SHOW_ONE_WAY ENDP

; -----------------------------------------------------------------------------
; PRINT_PERCENT
;
; Prints PART_V as a percentage of WHOLE_V, to one decimal place.
;
; MUL leaves a thirty two bit product across DX and AX, and DIV consumes
; exactly that, so the scaling costs no precision at all. DIV faults when the
; quotient will not fit in AX, and the test for that is simply whether DX is
; already as large as the divisor, so the guard is one compare.
; -----------------------------------------------------------------------------
PRINT_PERCENT PROC
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX

    MOV AX, PART_V
    MUL SCALE                           ; DX:AX is now a hundred times the part
    MOV BX, WHOLE_V

    CMP DX, BX
    JAE PP_BIG                          ; The quotient would not fit in AX

    DIV BX
    MOV CX, AX                          ; The whole per cent
    MOV AX, DX                          ; What the division left over

    ; A tenth of a per cent is the leftover scaled again. The leftover is
    ; smaller than the divisor, so ten times it cannot make DX reach the
    ; divisor either, and this second division needs no guard of its own.
    MUL TEN
    DIV BX

    PUSH AX
    MOV AX, CX
    CALL PRINT_DECIMAL
    MOV DL, '.'
    MOV AH, 02H
    INT 21H
    POP AX
    CALL PRINT_DECIMAL

    LEA DX, M_PC
    CALL PRINT_MESSAGE
    JMP PP_DONE

PP_BIG:
    LEA DX, M_BIG
    CALL PRINT_MESSAGE

PP_DONE:
    POP DX
    POP CX
    POP BX
    POP AX
    RET
PRINT_PERCENT ENDP

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
; 1. Why the order decides the answer:
;    - Integer division keeps only whole units and discards the rest.
;    - A part of a whole is below one, so dividing first leaves nothing.
;    - Scaling by a hundred first moves the wanted digits above the point.
; 2. What MUL and DIV were built to do:
;    - MUL widens two words into thirty two bits across DX and AX.
;    - DIV narrows exactly that pair back down, so the wide product costs nothing.
;    - Together they give a scaled division with no loss beyond the last digit.
; 3. Guarding the division:
;    - DIV raises interrupt zero when the quotient will not fit in AX.
;    - That happens precisely when DX is already as large as the divisor.
;    - One compare before the divide turns a fault into a message.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
