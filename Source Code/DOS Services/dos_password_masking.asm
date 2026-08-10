; =============================================================================
; TITLE: Reading a Password Without Showing It
; DESCRIPTION: Reads characters without echoing them, printing a star for each
;              one, and allows a backspace to take one back.
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
    MAXLEN   EQU 16
    ENTERED  DB MAXLEN DUP(0)
    GOTLEN   DW 0

    SECRET   DB 'amey'
    SECRETLEN EQU $ - SECRET

    M_ASK    DB 'Password: $'
    M_RIGHT  DB 0DH, 0AH, 'Accepted.', 0DH, 0AH, '$'
    M_WRONG  DB 0DH, 0AH, 'Rejected.', 0DH, 0AH, '$'

; -----------------------------------------------------------------------------
; CODE SEGMENT
; -----------------------------------------------------------------------------
.CODE
START:
    MOV AX, @DATA
    MOV DS, AX

    LEA DX, M_ASK
    MOV AH, 09H
    INT 21H

    LEA DI, ENTERED
    MOV WORD PTR GOTLEN, 0

READ_LOOP:
    ; -------------------------------------------------------------------------
    ; SERVICE 08H READS WITHOUT ECHOING, WHICH IS THE WHOLE POINT. THE STAR IS
    ; PRINTED BY THIS PROGRAM RATHER THAN BY DOS, SO THE LENGTH IS VISIBLE AND
    ; THE CHARACTERS ARE NOT.
    ; -------------------------------------------------------------------------
    MOV AH, 08H
    INT 21H

    CMP AL, 0DH
    JE  ENTERED_DONE                    ; Enter ends it

    CMP AL, 08H
    JE  BACKSPACE

    CMP WORD PTR GOTLEN, MAXLEN
    JAE READ_LOOP                       ; Full, so ignore anything more

    MOV [DI], AL
    INC DI
    INC WORD PTR GOTLEN

    MOV DL, '*'
    MOV AH, 02H
    INT 21H
    JMP READ_LOOP

BACKSPACE:
    CMP WORD PTR GOTLEN, 0
    JE  READ_LOOP                       ; Nothing to take back

    DEC DI
    DEC WORD PTR GOTLEN

    ; -------------------------------------------------------------------------
    ; ERASING A CHARACTER ON SCREEN TAKES THREE: BACK ONE PLACE, WRITE A SPACE
    ; OVER WHAT WAS THERE, AND GO BACK AGAIN. A BACKSPACE ALONE ONLY MOVES THE
    ; CURSOR.
    ; -------------------------------------------------------------------------
    MOV DL, 08H
    MOV AH, 02H
    INT 21H
    MOV DL, ' '
    MOV AH, 02H
    INT 21H
    MOV DL, 08H
    MOV AH, 02H
    INT 21H
    JMP READ_LOOP

ENTERED_DONE:
    ; Compare what was typed against the expected password
    MOV AX, GOTLEN
    CMP AX, SECRETLEN
    JNE REJECTED

    LEA SI, SECRET
    LEA DI, ENTERED
    MOV CX, SECRETLEN

COMPARE:
    MOV AL, [SI]
    CMP AL, [DI]
    JNE REJECTED
    INC SI
    INC DI
    LOOP COMPARE

    LEA DX, M_RIGHT
    MOV AH, 09H
    INT 21H
    JMP FINISH

REJECTED:
    LEA DX, M_WRONG
    MOV AH, 09H
    INT 21H

FINISH:
    MOV AX, 4C00H
    INT 21H

END START

; =============================================================================
; TECHNICAL NOTES
; =============================================================================
; 1. THE LENGTH IS CHECKED FIRST:
;    - Two strings of different lengths cannot match, and testing that
;    - before comparing avoids reading past the end of the shorter one.
; 2. THIS IS A DEMONSTRATION, NOT SECURITY:
;    - The password sits in the data segment in plain sight, and the
;    - comparison stops at the first wrong character, which leaks how
;    - much of a guess was right. Both are wrong for anything real.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
