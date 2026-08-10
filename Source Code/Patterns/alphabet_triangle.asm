; =============================================================================
; TITLE: A Triangle of Letters
; DESCRIPTION: Fills a triangle with letters, one pattern restarting the
;              alphabet on each row and one carrying on through it.
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
    ROWS    EQU 6
    M_ONE   DB 'Restarting each row:', 0DH, 0AH, '$'
    M_TWO   DB 0DH, 0AH, 'Continuing through:', 0DH, 0AH, '$'

; -----------------------------------------------------------------------------
; CODE SEGMENT
; -----------------------------------------------------------------------------
.CODE
START:
    MOV AX, @DATA
    MOV DS, AX

    LEA DX, M_ONE
    MOV AH, 09H
    INT 21H

    MOV BX, 1

RESTART_ROWS:
    CMP BX, ROWS
    JA  CONTINUE_SETUP

    MOV CX, BX
    MOV DL, 'A'                         ; Back to the start on every row

RESTART_CELLS:
    MOV AH, 02H
    INT 21H
    INC DL
    LOOP RESTART_CELLS

    CALL NEWLINE
    INC BX
    JMP RESTART_ROWS

CONTINUE_SETUP:
    LEA DX, M_TWO
    MOV AH, 09H
    INT 21H

    ; -------------------------------------------------------------------------
    ; THE SECOND PATTERN NEVER RESETS THE LETTER, SO IT HAS TO BE HELD OUTSIDE
    ; THE ROW LOOP. TWENTY ONE LETTERS ARE NEEDED FOR SIX ROWS, WHICH IS
    ; INSIDE THE ALPHABET; A TALLER TRIANGLE WOULD HAVE TO WRAP.
    ; -------------------------------------------------------------------------
    MOV BX, 1
    MOV BP, 'A'                         ; The next letter, kept across rows

CONTINUE_ROWS:
    CMP BX, ROWS
    JA  FINISHED

    MOV CX, BX

CONTINUE_CELLS:
    MOV DX, BP
    MOV AH, 02H
    INT 21H
    INC BP
    LOOP CONTINUE_CELLS

    CALL NEWLINE
    INC BX
    JMP CONTINUE_ROWS

FINISHED:
    MOV AH, 4CH
    INT 21H

; -----------------------------------------------------------------------------
; REPEAT_CHAR
;
; Prints the character in DL, CX times. A count of nought prints nothing,
; which is what makes the first row of most patterns come out right.
; -----------------------------------------------------------------------------
REPEAT_CHAR PROC
    PUSH AX
    PUSH CX
    PUSH DX

    JCXZ RC_DONE

RC_LOOP:
    MOV AH, 02H
    INT 21H
    LOOP RC_LOOP

RC_DONE:
    POP DX
    POP CX
    POP AX
    RET
REPEAT_CHAR ENDP

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
; 1. WHERE THE LETTER IS HELD:
;    - Inside the row loop it restarts; outside it, it carries on. That
;    - one decision is the entire difference between the two patterns.
; 2. THE ALPHABET RUNS OUT:
;    - Twenty six letters cover a triangle of six rows with five to
;    - spare. Seven rows need twenty eight and would run past Z, which a
;    - general routine has to wrap.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
