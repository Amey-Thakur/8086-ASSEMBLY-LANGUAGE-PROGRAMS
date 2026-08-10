; =============================================================================
; TITLE: A Hollow Square
; DESCRIPTION: Draws only the border of a square, by printing a solid row at
;              the top and bottom and just the edges in between.
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
    SIDE    EQU 7
    M_HEAD  DB 'A hollow square of side seven:', 0DH, 0AH, '$'

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
    CMP BX, SIDE
    JA  FINISHED

    ; -------------------------------------------------------------------------
    ; THE FIRST AND LAST ROWS ARE SOLID. EVERY OTHER ROW IS AN EDGE, A GAP AND
    ; ANOTHER EDGE, WHICH IS WHY THE TEST IS ON THE ROW NUMBER RATHER THAN ON
    ; EVERY INDIVIDUAL POSITION.
    ; -------------------------------------------------------------------------
    CMP BX, 1
    JE  SOLID_ROW
    CMP BX, SIDE
    JE  SOLID_ROW

    ; A hollow row
    MOV DL, '*'
    MOV AH, 02H
    INT 21H

    MOV CX, SIDE
    SUB CX, 2
    MOV DL, ' '
    CALL REPEAT_CHAR

    MOV DL, '*'
    MOV AH, 02H
    INT 21H
    JMP ROW_DONE

SOLID_ROW:
    MOV CX, SIDE
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
; 1. TESTING THE ROW, NOT THE CELL:
;    - Deciding per cell whether it is on the border needs four
;    - comparisons for every character. Deciding per row needs two for
;    - the whole line.
; 2. A SIDE OF ONE OR TWO:
;    - Both rows are solid, and the gap count of side less two would be
;    - negative for a side of one. A general routine has to guard that.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
