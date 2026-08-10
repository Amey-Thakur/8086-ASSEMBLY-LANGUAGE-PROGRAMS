; =============================================================================
; TITLE: A Yes Or No Confirmation
; DESCRIPTION: Accepts either case, rejects anything else, and gives up after a fixed number of attempts rather than looping for ever.
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
    TRIES   EQU 3

    M_TITLE DB 'A confirmation that cannot loop for ever', 0DH, 0AH, '$'
    M_ASK   DB 'Proceed? (y/n) $'
    M_YES   DB 0DH, 0AH, 'Answered yes. Proceeding.', 0DH, 0AH, '$'
    M_NO    DB 0DH, 0AH, 'Answered no. Stopping.', 0DH, 0AH, '$'
    M_AGAIN DB 0DH, 0AH, 'Please answer y or n. $'
    M_GIVE  DB 0DH, 0AH, 'No clear answer after three attempts. Treating that '
            DB 'as no.', 0DH, 0AH, '$'
    M_LEFT  DB 0DH, 0AH, 'Attempts remaining: $'
    M_WHY   DB 0DH, 0AH
            DB 'The safe default matters: an unanswered prompt should decline, '
            DB 'not agree.', 0DH, 0AH, '$'

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

    MOV CX, TRIES

EACH_TRY:
    MOV AH, 01H
    INT 21H

    ; -------------------------------------------------------------------------
    ; THE CASE IS FOLDED SO Y AND y ARE THE SAME ANSWER. DOING THIS WITH TWO
    ; COMPARISONS PER LETTER WOULD WORK AND IS WHAT MOST PEOPLE WRITE FIRST.
    ; -------------------------------------------------------------------------
    OR AL, 20H

    CMP AL, 'y'
    JE ANSWERED_YES
    CMP AL, 'n'
    JE ANSWERED_NO

    ; ---- neither, so say so and count the attempt down ----------------------
    LEA DX, M_AGAIN
    CALL PRINT_MESSAGE

    MOV AX, CX
    DEC AX
    PUSH CX
    PUSH AX
    LEA DX, M_LEFT
    CALL PRINT_MESSAGE
    POP AX
    CALL PRINT_DECIMAL
    POP CX
    CALL NEWLINE

    LOOP EACH_TRY

    ; -------------------------------------------------------------------------
    ; RUNNING OUT OF ATTEMPTS IS TREATED AS NO. A PROMPT THAT DEFAULTED TO YES
    ; WOULD PROCEED ON SILENCE, WHICH IS THE WRONG WAY ROUND FOR ANYTHING
    ; IRREVERSIBLE.
    ; -------------------------------------------------------------------------
    LEA DX, M_GIVE
    CALL PRINT_MESSAGE
    JMP EXPLAIN

ANSWERED_YES:
    LEA DX, M_YES
    CALL PRINT_MESSAGE
    JMP EXPLAIN

ANSWERED_NO:
    LEA DX, M_NO
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
; 1. Fold the case once:
;    - ORing with 20h maps Y to y and leaves y alone.
;    - One comparison per answer then covers both cases.
;    - It works because the two forms of a letter differ by exactly that bit.
; 2. Bounded retries:
;    - A prompt that repeats until satisfied never ends on exhausted input.
;    - Three attempts is enough for a mistyped key and short enough to finish.
;    - The count comes from CX, so LOOP does the bookkeeping.
; 3. Default to the safe answer:
;    - No clear answer is treated as no, not as yes.
;    - For anything destructive, silence must not mean consent.
;    - The same rule applies to a timeout as to running out of attempts.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
