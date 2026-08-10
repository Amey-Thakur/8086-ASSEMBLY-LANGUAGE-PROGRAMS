; =============================================================================
; TITLE: A Hollow Pyramid
; DESCRIPTION: Draws the outline of a pyramid, which needs the two sloping
;              edges placed as well as the base.
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
    M_HEAD  DB 'A hollow pyramid of six rows:', 0DH, 0AH, '$'

; -----------------------------------------------------------------------------
; CODE SEGMENT
; -----------------------------------------------------------------------------
.CODE
START:
    MOV AX, @DATA
    MOV DS, AX

    LEA DX, M_HEAD
    MOV AH, 09H
    INT 21H

    MOV BX, 1

EACH_ROW:
    CMP BX, ROWS
    JA  FINISHED

    ; The indent, as for a solid pyramid
    MOV CX, ROWS
    SUB CX, BX
    MOV DL, ' '
    CALL REPEAT_CHAR

    ; -------------------------------------------------------------------------
    ; THE BOTTOM ROW IS SOLID. EVERY OTHER ROW HAS A STAR AT EACH END AND
    ; NOTHING BETWEEN, EXCEPT THE FIRST, WHERE THE TWO ENDS ARE THE SAME STAR.
    ; -------------------------------------------------------------------------
    CMP BX, ROWS
    JE  BASE_ROW

    MOV DL, '*'
    MOV AH, 02H
    INT 21H

    CMP BX, 1
    JE  ROW_DONE                        ; The apex is a single star

    MOV CX, BX
    SHL CX, 1
    SUB CX, 3                           ; The gap between the two edges
    MOV DL, ' '
    CALL REPEAT_CHAR

    MOV DL, '*'
    MOV AH, 02H
    INT 21H
    JMP ROW_DONE

BASE_ROW:
    MOV CX, ROWS
    SHL CX, 1
    DEC CX
    MOV DL, '*'
    CALL REPEAT_CHAR

ROW_DONE:
    CALL NEWLINE
    INC BX
    JMP EACH_ROW

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
; 1. THREE CASES, NOT ONE:
;    - The apex has one star, the base has all of them, and the rows
;    - between have two. A single formula cannot cover all three, and
;    - trying to write one is where these patterns usually go wrong.
; 2. THE GAP IS TWO LESS THAN THE STARS:
;    - A solid row of that width would hold twice the row less one. Taking
;    - off the two edges leaves twice the row less three.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
