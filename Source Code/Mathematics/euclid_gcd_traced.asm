; =============================================================================
; TITLE: Euclid's Algorithm Traced Step by Step
; DESCRIPTION: Prints the division that Euclid's rule performs at every stage,
;              so the shrinking remainders can be read off, and then folds the
;              same rule across a list of numbers.
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
    LEFT_W  DW 1071, 3696, 2166, 91
    RIGHT_W DW  462, 1078,  666, 13
    PAIRS   EQU 4

    LIST_W  DW 48, 180, 210, 66
    SPAN    EQU 4

    A_VAL   DW ?                        ; The larger term of the current step
    B_VAL   DW ?                        ; The divisor of the current step
    Q_VAL   DW ?                        ; Held because DX carries print addresses
    R_VAL   DW ?

    M_TITLE DB 'Euclid on four pairs, one line for every division', 0DH, 0AH, '$'
    M_AND   DB ' and $'
    M_STEP  DB '    $'
    M_EQ    DB ' = $'
    M_TIMES DB ' x $'
    M_PLUS  DB ' + $'
    M_GCD   DB '  gcd = $'
    M_LIST  DB 0DH, 0AH, 'The same rule folded across a list', 0DH, 0AH, '$'
    M_SPACE DB ' $'

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
    ; STEP 1: TRACE EVERY PAIR IN TURN
    ; -------------------------------------------------------------------------
    XOR SI, SI
    MOV CX, PAIRS

EACH_PAIR:
    MOV AX, LEFT_W[SI]
    MOV A_VAL, AX
    MOV AX, RIGHT_W[SI]
    MOV B_VAL, AX
    CALL GCD_TRACE
    ADD SI, 2
    LOOP EACH_PAIR

    ; -------------------------------------------------------------------------
    ; STEP 2: THE GCD OF A LIST IS THE GCD OF THE RUNNING ANSWER AND THE NEXT
    ; TERM, BECAUSE A COMMON DIVISOR OF EVERY TERM DIVIDES EACH PARTIAL ANSWER.
    ; -------------------------------------------------------------------------
    LEA DX, M_LIST
    CALL PRINT_MESSAGE

    XOR SI, SI
    MOV CX, SPAN

SHOW_LIST:
    MOV AX, LIST_W[SI]
    CALL PRINT_DECIMAL
    LEA DX, M_SPACE
    CALL PRINT_MESSAGE
    ADD SI, 2
    LOOP SHOW_LIST
    CALL NEWLINE

    MOV AX, LIST_W                      ; The running answer starts at the first
    MOV SI, 2
    MOV CX, SPAN
    DEC CX
    JCXZ FOLD_DONE                      ; A single term is its own answer

FOLD_NEXT:
    MOV BX, LIST_W[SI]
    CALL GCD_PLAIN
    ADD SI, 2
    LOOP FOLD_NEXT

FOLD_DONE:
    LEA DX, M_GCD
    CALL PRINT_MESSAGE
    CALL PRINT_DECIMAL
    CALL NEWLINE

    MOV AH, 4CH
    INT 21H

; -----------------------------------------------------------------------------
; GCD_TRACE
;
; Reduces A_VAL and B_VAL to their greatest common divisor, printing the
; division performed at each stage. Working in memory rather than in registers
; keeps DX free, since DX has to carry the address of every message printed.
; -----------------------------------------------------------------------------
GCD_TRACE PROC
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX

    MOV AX, A_VAL
    CALL PRINT_DECIMAL
    LEA DX, M_AND
    CALL PRINT_MESSAGE
    MOV AX, B_VAL
    CALL PRINT_DECIMAL
    CALL NEWLINE

GT_STEP:
    MOV BX, B_VAL
    OR  BX, BX
    JZ  GT_DONE                         ; Also the guard against dividing by zero

    MOV AX, A_VAL
    XOR DX, DX                          ; DIV reads DX:AX, so the top must be clear
    DIV BX
    MOV Q_VAL, AX
    MOV R_VAL, DX

    LEA DX, M_STEP
    CALL PRINT_MESSAGE
    MOV AX, A_VAL
    CALL PRINT_DECIMAL
    LEA DX, M_EQ
    CALL PRINT_MESSAGE
    MOV AX, Q_VAL
    CALL PRINT_DECIMAL
    LEA DX, M_TIMES
    CALL PRINT_MESSAGE
    MOV AX, B_VAL
    CALL PRINT_DECIMAL
    LEA DX, M_PLUS
    CALL PRINT_MESSAGE
    MOV AX, R_VAL
    CALL PRINT_DECIMAL
    CALL NEWLINE

    MOV AX, B_VAL                       ; The divisor becomes the next dividend
    MOV A_VAL, AX
    MOV AX, R_VAL                       ; The remainder becomes the next divisor
    MOV B_VAL, AX
    JMP GT_STEP

GT_DONE:
    LEA DX, M_GCD
    CALL PRINT_MESSAGE
    MOV AX, A_VAL
    CALL PRINT_DECIMAL
    CALL NEWLINE

    POP DX
    POP CX
    POP BX
    POP AX
    RET
GCD_TRACE ENDP

; -----------------------------------------------------------------------------
; GCD_PLAIN
;
; Returns the greatest common divisor of AX and BX in AX, printing nothing.
; The quotient can never overflow, because a divisor of at least one gives a
; quotient no larger than the dividend.
; -----------------------------------------------------------------------------
GCD_PLAIN PROC
    PUSH BX
    PUSH CX
    PUSH DX

GP_STEP:
    OR  BX, BX
    JZ  GP_DONE

    XOR DX, DX
    DIV BX
    MOV AX, BX
    MOV BX, DX
    JMP GP_STEP

GP_DONE:
    POP DX
    POP CX
    POP BX
    RET
GCD_PLAIN ENDP

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
; 1. Why the remainder may replace the pair:
;    - Any divisor of a and b also divides a minus a multiple of b.
;    - The remainder is exactly that, so the common divisors are unchanged.
;    - Replacing the pair therefore preserves the answer while shrinking it.
; 2. Why it finishes quickly:
;    - Each remainder is smaller than the divisor that produced it.
;    - Two steps at least halve the larger term, so the count is logarithmic.
;    - The worst case is a pair of neighbouring Fibonacci numbers.
; 3. Folding across a list:
;    - The greatest common divisor is associative, so order does not matter.
;    - The running answer only ever shrinks, and it often reaches one early.
;    - A running answer of one may be reported at once, since nothing divides it further.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
