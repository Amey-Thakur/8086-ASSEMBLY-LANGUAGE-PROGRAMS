; =============================================================================
; TITLE: Testing A Loop At The Bottom Instead Of The Top
; DESCRIPTION: Testing at the bottom instead of the top, which is the right shape whenever the body must happen at least once.
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
    CASES   DW 0, 1, 7, 100, 4096
    HOWMANY EQU 5

    M_TITLE DB 'Testing at the bottom, so the body always runs', 0DH, 0AH, '$'
    M_HEAD  DB 0DH, 0AH, 'value   digits   pre-test would give', 0DH, 0AH, '$'
    M_GAP   DB '       $'
    M_GAP2  DB '        $'
    M_WHY   DB 0DH, 0AH
            DB 'Zero has one digit, and only the post-test loop says so. A loop '
            DB 'testing at the top divides zero away before printing anything.'
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

    MOV AX, CASES[SI]
    CALL COUNT_POST_TEST
    CALL PRINT_DECIMAL
    LEA DX, M_GAP2
    CALL PRINT_MESSAGE

    MOV AX, CASES[SI]
    CALL COUNT_PRE_TEST
    CALL PRINT_DECIMAL
    CALL NEWLINE

    ADD SI, 2
    POP CX
    LOOP EACH_CASE

    LEA DX, M_WHY
    CALL PRINT_MESSAGE

    MOV AH, 4CH
    INT 21H

; -----------------------------------------------------------------------------
; COUNT_POST_TEST
;
; How many decimal digits AX has, counted with the test at the bottom.
;
; The division happens before the check, so a value of zero still goes round
; once and is correctly reported as one digit.
; -----------------------------------------------------------------------------
COUNT_POST_TEST PROC
    PUSH BX
    PUSH DX

    XOR BX, BX                          ; Digits so far

AGAIN_POST:
    XOR DX, DX
    MOV CX, 10
    DIV CX
    INC BX
    CMP AX, 0
    JNE AGAIN_POST                      ; The test, at the bottom

    MOV AX, BX

    POP DX
    POP BX
    RET
COUNT_POST_TEST ENDP

; -----------------------------------------------------------------------------
; COUNT_PRE_TEST
;
; The same count with the test at the top, which is wrong for zero.
;
; This is kept deliberately, because the difference is the point of the program
; and a comment claiming it would be less convincing than the number.
; -----------------------------------------------------------------------------
COUNT_PRE_TEST PROC
    PUSH BX
    PUSH DX

    XOR BX, BX

AGAIN_PRE:
    CMP AX, 0                           ; The test, at the top
    JE PRE_DONE

    XOR DX, DX
    MOV CX, 10
    DIV CX
    INC BX
    JMP AGAIN_PRE

PRE_DONE:
    MOV AX, BX

    POP DX
    POP BX
    RET
COUNT_PRE_TEST ENDP

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
; 1. Where the test goes changes the answer:
;    - A post-test loop runs the body and then asks whether to go again.
;    - A pre-test loop asks first, so it can run the body no times at all.
;    - Neither is better; they answer different questions and zero is where they diverge.
; 2. Digits of zero:
;    - Zero is written with one digit, so any digit counter must report one.
;    - The pre-test version reports none, which then prints an empty number.
;    - Every printing routine in this repository is post-test for exactly this reason.
; 3. The shape in assembly:
;    - A post-test loop is a label, the body, a comparison and a conditional jump back.
;    - A pre-test loop needs an extra unconditional jump at the bottom.
;    - So the post-test form is also one instruction shorter per iteration.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
