; =============================================================================
; TITLE: A 32-bit Sum Held in Two Registers
; DESCRIPTION: Adds and subtracts values too large for one word by keeping each
;              in a pair of words and letting ADC and SBB carry the flag from
;              the low half into the high half.
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
    ; Each value is stored low word first, which is the order the 8086 itself
    ; uses in memory, so a pair of words reads as one thirty two bit number.
    P_LOW   DW 722                      ; 1234567890
    P_HIGH  DW 18838
    Q_LOW   DW 26801                    ; 987654321
    Q_HIGH  DW 15070
    A_LOW   DW 60000                    ; 387680
    A_HIGH  DW 5
    B_LOW   DW 40000                    ; 498752
    B_HIGH  DW 7
    S_LOW   DW 24064                    ; 3000000000
    S_HIGH  DW 45776
    T_LOW   DW 37888                    ; 2000000000
    T_HIGH  DW 30517

    ONE_LOW  DW ?                       ; The left operand of the current line
    ONE_HIGH DW ?
    TWO_LOW  DW ?
    TWO_HIGH DW ?

    M_TITLE DB 'Thirty two bit values carried across a pair of words'
            DB 0DH, 0AH, '$'
    M_PLUS  DB ' + $'
    M_MINUS DB ' - $'
    M_EQ    DB ' = $'
    M_WRAP  DB '   (the carry left the pair, so the true sum is this plus '
            DB '4294967296)$'
    M_BORR  DB '   (the answer is negative, so the true value is this less '
            DB '4294967296)$'

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
    ; STEP 1: A SUM AND A DIFFERENCE THAT BOTH STAY INSIDE THE PAIR
    ; -------------------------------------------------------------------------
    MOV AX, P_LOW
    MOV ONE_LOW, AX
    MOV AX, P_HIGH
    MOV ONE_HIGH, AX
    MOV AX, Q_LOW
    MOV TWO_LOW, AX
    MOV AX, Q_HIGH
    MOV TWO_HIGH, AX

    CALL WIDE_ADD
    CALL WIDE_SUB

    ; -------------------------------------------------------------------------
    ; STEP 2: A SMALLER PAIR CHOSEN SO THE LOW WORDS THEMSELVES CARRY AND BORROW
    ; -------------------------------------------------------------------------
    MOV AX, A_LOW
    MOV ONE_LOW, AX
    MOV AX, A_HIGH
    MOV ONE_HIGH, AX
    MOV AX, B_LOW
    MOV TWO_LOW, AX
    MOV AX, B_HIGH
    MOV TWO_HIGH, AX

    CALL WIDE_ADD

    MOV AX, B_LOW                       ; Reversed, so the difference is positive
    MOV ONE_LOW, AX
    MOV AX, B_HIGH
    MOV ONE_HIGH, AX
    MOV AX, A_LOW
    MOV TWO_LOW, AX
    MOV AX, A_HIGH
    MOV TWO_HIGH, AX

    CALL WIDE_SUB

    ; -------------------------------------------------------------------------
    ; STEP 3: THE TWO CASES THAT LEAVE THE PAIR ALTOGETHER
    ; -------------------------------------------------------------------------
    MOV AX, S_LOW
    MOV ONE_LOW, AX
    MOV AX, S_HIGH
    MOV ONE_HIGH, AX
    MOV AX, T_LOW
    MOV TWO_LOW, AX
    MOV AX, T_HIGH
    MOV TWO_HIGH, AX

    CALL WIDE_ADD

    MOV AX, Q_LOW
    MOV ONE_LOW, AX
    MOV AX, Q_HIGH
    MOV ONE_HIGH, AX
    MOV AX, P_LOW
    MOV TWO_LOW, AX
    MOV AX, P_HIGH
    MOV TWO_HIGH, AX

    CALL WIDE_SUB

    MOV AH, 4CH
    INT 21H

; -----------------------------------------------------------------------------
; WIDE_ADD
;
; Prints the sum of the two operands. ADD sets the carry from the low halves
; and ADC reads it back, which is the whole of the technique. MOV does not
; disturb any flag, so the carry out of the high halves can be captured into a
; register before printing destroys it.
; -----------------------------------------------------------------------------
WIDE_ADD PROC
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX

    CALL SHOW_OPERANDS_ADD

    MOV AX, ONE_LOW
    MOV DX, ONE_HIGH
    MOV BX, TWO_LOW
    MOV CX, TWO_HIGH

    ADD AX, BX
    ADC DX, CX
    MOV BX, 0
    ADC BX, 0                           ; BX is one if the value left the pair

    CALL PRINT_LONG

    OR  BX, BX
    JZ  WA_PLAIN
    LEA DX, M_WRAP
    CALL PRINT_MESSAGE

WA_PLAIN:
    CALL NEWLINE

    POP DX
    POP CX
    POP BX
    POP AX
    RET
WIDE_ADD ENDP

; -----------------------------------------------------------------------------
; WIDE_SUB
;
; Prints the difference of the two operands. SBB subtracts the borrow that SUB
; left behind, and a borrow out of the high halves means the answer was
; negative and has wrapped.
; -----------------------------------------------------------------------------
WIDE_SUB PROC
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX

    CALL SHOW_OPERANDS_SUB

    MOV AX, ONE_LOW
    MOV DX, ONE_HIGH
    MOV BX, TWO_LOW
    MOV CX, TWO_HIGH

    SUB AX, BX
    SBB DX, CX
    MOV BX, 0
    ADC BX, 0                           ; BX is one if a borrow was still owed

    CALL PRINT_LONG

    OR  BX, BX
    JZ  WS_PLAIN
    LEA DX, M_BORR
    CALL PRINT_MESSAGE

WS_PLAIN:
    CALL NEWLINE

    POP DX
    POP CX
    POP BX
    POP AX
    RET
WIDE_SUB ENDP

; -----------------------------------------------------------------------------
; SHOW_OPERANDS_ADD
;
; Prints the left operand, a plus sign, the right operand and an equals sign.
; -----------------------------------------------------------------------------
SHOW_OPERANDS_ADD PROC
    PUSH AX
    PUSH DX

    MOV AX, ONE_LOW
    MOV DX, ONE_HIGH
    CALL PRINT_LONG
    LEA DX, M_PLUS
    CALL PRINT_MESSAGE
    MOV AX, TWO_LOW
    MOV DX, TWO_HIGH
    CALL PRINT_LONG
    LEA DX, M_EQ
    CALL PRINT_MESSAGE

    POP DX
    POP AX
    RET
SHOW_OPERANDS_ADD ENDP

; -----------------------------------------------------------------------------
; SHOW_OPERANDS_SUB
;
; The same, with a minus sign between the operands.
; -----------------------------------------------------------------------------
SHOW_OPERANDS_SUB PROC
    PUSH AX
    PUSH DX

    MOV AX, ONE_LOW
    MOV DX, ONE_HIGH
    CALL PRINT_LONG
    LEA DX, M_MINUS
    CALL PRINT_MESSAGE
    MOV AX, TWO_LOW
    MOV DX, TWO_HIGH
    CALL PRINT_LONG
    LEA DX, M_EQ
    CALL PRINT_MESSAGE

    POP DX
    POP AX
    RET
SHOW_OPERANDS_SUB ENDP

; -----------------------------------------------------------------------------
; PRINT_LONG
;
; Prints the thirty two bit unsigned value in DX:AX as decimal.
;
; DIV would overflow if the whole value were offered to it at once, so the top
; word is divided first and its remainder is carried down into the bottom word.
; That remainder is smaller than ten, so the second division can never produce
; a quotient too large for AX.
; -----------------------------------------------------------------------------
PRINT_LONG PROC
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX
    PUSH SI

    MOV SI, DX                          ; The high word of the running quotient
    XOR CX, CX                          ; How many digits have been stacked
    MOV BX, 10

PL_DIVIDE:
    PUSH AX
    MOV AX, SI
    XOR DX, DX
    DIV BX                              ; The high half, leaving DX to carry down
    MOV SI, AX
    POP AX
    DIV BX                              ; DX:AX is now safely under ten times AX

    PUSH DX                             ; Digits arrive lowest first
    INC CX

    MOV DX, SI
    OR  DX, AX                          ; Is anything left of the quotient?
    JNZ PL_DIVIDE

PL_EMIT:
    POP DX                              ; Unstacking reverses them into order
    ADD DL, '0'
    MOV AH, 02H
    INT 21H
    LOOP PL_EMIT

    POP SI
    POP DX
    POP CX
    POP BX
    POP AX
    RET
PRINT_LONG ENDP

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
; 1. Why ADC and SBB exist:
;    - ADD and SUB set the carry flag but cannot read it back in.
;    - ADC and SBB read it, which chains any number of words together.
;    - The same pair extends to sixty four bits with no change of method.
; 2. Order matters:
;    - The low halves must be done first, since they produce the carry.
;    - Anything between the two instructions that touches a flag breaks it.
;    - MOV is safe there, which is how the carry out is captured before printing.
; 3. What a carry out of the top means:
;    - On an addition the answer needed a thirty third bit and has wrapped.
;    - On a subtraction the answer was negative and is the true value plus 2^32.
;    - Neither is an error in itself, but a program must decide which it meant.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
