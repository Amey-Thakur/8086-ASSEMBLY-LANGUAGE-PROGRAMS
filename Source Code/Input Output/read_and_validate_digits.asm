; =============================================================================
; TITLE: Reading A Number And Rejecting Rubbish
; DESCRIPTION: Every character is checked before it is used, so a typing mistake produces a message rather than a wrong answer.
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
    CAPACITY EQU 12
    BUFFER   DB CAPACITY
             DB 0
             DB CAPACITY DUP (0)

    VALUE_W DW 0
    GOOD_B  DB 0

    M_TITLE DB 'Reading a number, checking every character', 0DH, 0AH, '$'
    M_ASK   DB 'Enter a number: $'
    M_OK    DB 0DH, 0AH, 'Accepted: $'
    M_TIMES DB 0DH, 0AH, 'Ten times it is $'
    M_EMPTY DB 0DH, 0AH, 'Nothing was entered.', 0DH, 0AH, '$'
    M_BAD   DB 0DH, 0AH, 'Rejected: the character '
    M_BADCH DB '?', ' is not a digit.', 0DH, 0AH, '$'
    M_BIG   DB 0DH, 0AH, 'Rejected: the number will not fit in sixteen bits.'
            DB 0DH, 0AH, '$'
    M_WHY   DB 0DH, 0AH
            DB 'Checking as the digits arrive costs one comparison each and '
            DB 'removes a whole class of wrong answers.', 0DH, 0AH, '$'

; -----------------------------------------------------------------------------
; CODE SEGMENT
; -----------------------------------------------------------------------------
.CODE
START:
    MOV AX, @DATA
    MOV DS, AX

    LEA DX, M_TITLE
    CALL PRINT_MESSAGE
    LEA DX, M_ASK
    CALL PRINT_MESSAGE

    LEA DX, BUFFER
    MOV AH, 0AH
    INT 21H

    ; -------------------------------------------------------------------------
    ; AN EMPTY LINE IS ITS OWN CASE. TREATING IT AS ZERO WOULD HIDE THE FACT
    ; THAT NOTHING WAS TYPED, WHICH IS USUALLY WORTH KNOWING.
    ; -------------------------------------------------------------------------
    MOV CL, BUFFER + 1
    XOR CH, CH
    JCXZ NOTHING_TYPED

    LEA SI, BUFFER + 2
    MOV VALUE_W, 0

EACH_DIGIT:
    MOV AL, [SI]
    INC SI

    ; ---- is it a digit? -----------------------------------------------------
    CMP AL, '0'
    JB NOT_A_DIGIT
    CMP AL, '9'
    JA NOT_A_DIGIT

    ; -------------------------------------------------------------------------
    ; VALUE TIMES TEN PLUS THE DIGIT. THE MULTIPLY IS CHECKED FOR OVERFLOW
    ; BEFORE THE ADD, BECAUSE ONCE IT HAS WRAPPED THERE IS NO WAY TO TELL.
    ; -------------------------------------------------------------------------
    SUB AL, '0'
    MOV BL, AL
    XOR BH, BH                          ; BX is the digit

    MOV AX, VALUE_W
    MOV DX, 10
    MUL DX                              ; DX:AX = value * 10
    CMP DX, 0
    JNE TOO_LARGE

    ADD AX, BX
    JC TOO_LARGE

    MOV VALUE_W, AX
    LOOP EACH_DIGIT

    ; ---- accepted -----------------------------------------------------------
    LEA DX, M_OK
    CALL PRINT_MESSAGE
    MOV AX, VALUE_W
    CALL PRINT_DECIMAL

    ; Ten times it, which needs the same overflow care and is not checked here
    ; on purpose: the wrap is visible in the output and discussed in the notes.
    LEA DX, M_TIMES
    CALL PRINT_MESSAGE
    MOV AX, VALUE_W
    MOV DX, 10
    MUL DX
    CALL PRINT_DECIMAL
    JMP EXPLAIN

NOT_A_DIGIT:
    MOV M_BADCH, AL                     ; Show which character was refused
    LEA DX, M_BAD
    CALL PRINT_MESSAGE
    JMP EXPLAIN

TOO_LARGE:
    LEA DX, M_BIG
    CALL PRINT_MESSAGE
    JMP EXPLAIN

NOTHING_TYPED:
    LEA DX, M_EMPTY
    CALL PRINT_MESSAGE

EXPLAIN:
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
; 1. Check before accumulating:
;    - A character outside 0 to 9 is refused before it can join the total.
;    - Subtracting the code of zero from a letter gives a value above nine, silently.
;    - Two comparisons per character is the whole cost of not being wrong.
; 2. Overflow has to be caught early:
;    - Once value times ten has wrapped, nothing about the result says so.
;    - MUL puts the high word in DX, so DX being non-zero is the test.
;    - The carry after the add catches the remaining case.
; 3. An empty line is not zero:
;    - Pressing Enter alone means no answer, which is different from answering nought.
;    - DOS reports a count of zero, so the case is easy to detect and easy to forget.
;    - JCXZ before the loop handles it, and also stops LOOP running 65536 times.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
