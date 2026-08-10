; =============================================================================
; TITLE: Armstrong Numbers
; DESCRIPTION: A number equal to the sum of its own digits each raised to the number of digits, checked across a range.
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
    CASES   DW 153, 370, 371, 407, 100, 9474, 9475, 5
    HOWMANY EQU 8

    M_TITLE DB 'Armstrong numbers: the digits raised to how many there are', 0DH, 0AH, '$'
    M_HEAD  DB 0DH, 0AH, 'number  digits  sum of powers  verdict', 0DH, 0AH, '$'
    M_GAP   DB '     $'
    M_GAP2  DB '       $'
    M_YES   DB 'Armstrong', 0DH, 0AH, '$'
    M_NO    DB 'no', 0DH, 0AH, '$'
    M_WHY   DB 0DH, 0AH
            DB '153 is 1 cubed plus 5 cubed plus 3 cubed. 9474 is the four digit '
            DB 'case, and needs each digit to the fourth power.', 0DH, 0AH, '$'
    M_LIMIT DB 'A five digit Armstrong number would overflow sixteen bits, so '
            DB 'the search stops here.', 0DH, 0AH, '$'

; -----------------------------------------------------------------------------
; CODE SEGMENT
; -----------------------------------------------------------------------------
.CODE
START:
    MOV AX, @DATA
    MOV DS, AX

    LEA DX, M_TITLE
    CALL PRINT_MESSAGE
    LEA DX, M_HEAD
    CALL PRINT_MESSAGE

    XOR SI, SI
    MOV CX, HOWMANY

EACH_CASE:
    PUSH CX

    MOV AX, CASES[SI]
    CALL PRINT_DECIMAL
    LEA DX, M_GAP
    CALL PRINT_MESSAGE

    ; ---- how many digits ----------------------------------------------------
    MOV AX, CASES[SI]
    CALL COUNT_DIGITS
    MOV BP, AX                          ; The exponent
    CALL PRINT_DECIMAL
    LEA DX, M_GAP2
    CALL PRINT_MESSAGE

    ; ---- the sum of the powers ----------------------------------------------
    MOV AX, CASES[SI]
    CALL SUM_OF_POWERS
    MOV DI, AX
    CALL PRINT_DECIMAL
    LEA DX, M_GAP2
    CALL PRINT_MESSAGE

    ; ---- and the verdict ----------------------------------------------------
    MOV AX, CASES[SI]
    CMP AX, DI
    JNE NOT_ARMSTRONG

    LEA DX, M_YES
    CALL PRINT_MESSAGE
    JMP NEXT_CASE

NOT_ARMSTRONG:
    LEA DX, M_NO
    CALL PRINT_MESSAGE

NEXT_CASE:
    ADD SI, 2
    POP CX
    LOOP EACH_CASE

    LEA DX, M_WHY
    CALL PRINT_MESSAGE
    LEA DX, M_LIMIT
    CALL PRINT_MESSAGE

    MOV AH, 4CH
    INT 21H

; -----------------------------------------------------------------------------
; COUNT_DIGITS
;
; How many decimal digits AX has. Post-test, so zero counts as one.
; -----------------------------------------------------------------------------
COUNT_DIGITS PROC
    PUSH BX
    PUSH CX
    PUSH DX

    XOR BX, BX
    MOV CX, 10

DIGIT_AGAIN:
    XOR DX, DX
    DIV CX
    INC BX
    CMP AX, 0
    JNE DIGIT_AGAIN

    MOV AX, BX

    POP DX
    POP CX
    POP BX
    RET
COUNT_DIGITS ENDP

; -----------------------------------------------------------------------------
; SUM_OF_POWERS
;
; Each digit of AX raised to the power in BP, added together.
;
; The digits come out lowest first, which does not matter: addition does not
; care about the order they arrive in.
; -----------------------------------------------------------------------------
SUM_OF_POWERS PROC
    PUSH BX
    PUSH CX
    PUSH DX
    PUSH SI
    PUSH DI

    XOR DI, DI                          ; The running total
    MOV SI, AX                          ; What is left to take digits from

TAKE_DIGIT:
    CMP SI, 0
    JE POWERS_DONE

    MOV AX, SI
    XOR DX, DX
    MOV BX, 10
    DIV BX
    MOV SI, AX                          ; What remains
    MOV AX, DX                          ; This digit

    ; ---- raise it to the power ----------------------------------------------
    MOV BX, AX                          ; The base
    MOV AX, 1
    MOV CX, BP

POWER_AGAIN:
    JCXZ POWER_DONE
    MUL BX
    LOOP POWER_AGAIN

POWER_DONE:
    ADD DI, AX
    JMP TAKE_DIGIT

POWERS_DONE:
    MOV AX, DI

    POP DI
    POP SI
    POP DX
    POP CX
    POP BX
    RET
SUM_OF_POWERS ENDP

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
; 1. The exponent is the digit count:
;    - A three digit number uses cubes, a four digit one fourth powers.
;    - So the count has to be worked out before any power can be raised.
;    - That is why the number is walked twice: once to count, once to sum.
; 2. Order does not matter:
;    - Dividing by ten yields the digits lowest first, which is the wrong end for printing.
;    - Here they are only added up, and addition does not care.
;    - No reversal is needed, which is what keeps the routine short.
; 3. Sixteen bits is the ceiling:
;    - 9474 is the largest Armstrong number that fits in a word.
;    - The five digit cases begin at 54748, which needs a wider accumulator.
;    - The powers themselves overflow first: nine to the fifth is already 59049.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
