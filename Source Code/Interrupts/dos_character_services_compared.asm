; =============================================================================
; TITLE: The Five Ways DOS Reads And Writes A Character
; DESCRIPTION: Services 01h, 02h, 06h, 07h and 08h differ in echoing, in waiting, and in whether they notice a break.
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
    LIMIT   EQU 6

    M_TITLE DB 'The five character services, and what separates them', 0DH, 0AH, '$'
    M_TABLE DB 0DH, 0AH
            DB '  01h  read, echo, waits, notices a break', 0DH, 0AH
            DB '  02h  write one character from DL', 0DH, 0AH
            DB '  06h  read or write, never waits, no echo, no break', 0DH, 0AH
            DB '  07h  read, no echo, waits, no break check', 0DH, 0AH
            DB '  08h  read, no echo, waits, notices a break', 0DH, 0AH, '$'

    M_WRITE DB 0DH, 0AH, 'Writing ABC with 02h: $'
    M_ECHO  DB 0DH, 0AH, 'Reading with 01h, which echoes: $'
    M_QUIET DB 0DH, 0AH, 'Reading with 08h, which does not: $'
    M_SHOWN DB '   the character was $'
    M_POLL  DB 0DH, 0AH, 'Polling with 06h until nothing is waiting: $'
    M_TOOK  DB 0DH, 0AH, 'Characters taken by the poll: $'
    M_NONE  DB 0DH, 0AH, 'A poll that finds nothing returns with the zero flag '
            DB 'set, which is how a program stays responsive.', 0DH, 0AH, '$'

; -----------------------------------------------------------------------------
; CODE SEGMENT
; -----------------------------------------------------------------------------
.CODE
START:
    MOV AX, @DATA
    MOV DS, AX

    LEA DX, M_TITLE
    CALL PRINT_MESSAGE
    LEA DX, M_TABLE
    CALL PRINT_MESSAGE

    ; ---- 02h writes one character from DL -----------------------------------
    LEA DX, M_WRITE
    CALL PRINT_MESSAGE
    MOV DL, 'A'
    MOV AH, 02H
    INT 21H
    MOV DL, 'B'
    MOV AH, 02H
    INT 21H
    MOV DL, 'C'
    MOV AH, 02H
    INT 21H

    ; ---- 01h reads and echoes -----------------------------------------------
    LEA DX, M_ECHO
    CALL PRINT_MESSAGE
    MOV AH, 01H
    INT 21H
    MOV BL, AL                          ; Keep it, AL is about to be reused

    ; ---- 08h reads and does not echo ----------------------------------------
    LEA DX, M_QUIET
    CALL PRINT_MESSAGE
    MOV AH, 08H
    INT 21H
    MOV BH, AL

    LEA DX, M_SHOWN
    CALL PRINT_MESSAGE
    XOR AX, AX
    MOV AL, BH
    CALL PRINT_DECIMAL

    ; -------------------------------------------------------------------------
    ; 06H WITH DL SET TO FFH IS THE ONLY SERVICE THAT ASKS WITHOUT WAITING. IT
    ; RETURNS WITH THE ZERO FLAG SET WHEN NOTHING IS THERE, WHICH IS WHAT LETS A
    ; PROGRAM DO SOMETHING ELSE INSTEAD OF BLOCKING.
    ;
    ; THE COUNTED LIMIT IS NOT DECORATION. WITHOUT IT A POLL THAT ALWAYS FINDS
    ; SOMETHING WOULD NEVER FINISH.
    ; -------------------------------------------------------------------------
    LEA DX, M_POLL
    CALL PRINT_MESSAGE

    XOR BP, BP                          ; How many the poll took
    MOV CX, LIMIT

POLL_AGAIN:
    MOV DL, 0FFH
    MOV AH, 06H
    INT 21H
    JZ NOTHING_WAITING

    INC BP
    LOOP POLL_AGAIN

NOTHING_WAITING:
    LEA DX, M_TOOK
    CALL PRINT_MESSAGE
    MOV AX, BP
    CALL PRINT_DECIMAL

    LEA DX, M_NONE
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
; 1. Echoing is the usual difference:
;    - 01h prints what it read, which is right for a visible prompt.
;    - 07h and 08h do not, which is what a password field or a menu key needs.
;    - Neither gives the program any way to undo an echo that has already happened.
; 2. Only 06h refuses to wait:
;    - With DL set to FFh it asks whether a key is there and returns either way.
;    - The zero flag says nothing was waiting, so the program can carry on.
;    - Every other read service blocks until something arrives.
; 3. The break check:
;    - 01h and 08h act on a break key; 06h and 07h ignore it entirely.
;    - That is why 07h is the right service for reading a password.
;    - It is also why a program using 07h needs its own way of being stopped.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
