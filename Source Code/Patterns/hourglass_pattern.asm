; =============================================================================
; TITLE: An Hourglass
; DESCRIPTION: Prints a shrinking triangle above a growing one, sharing a
;              single row where the two meet.
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
    HALF    EQU 5
    M_HEAD  DB 'An hourglass:', 0DH, 0AH, '$'

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

    ; -------------------------------------------------------------------------
    ; THE UPPER HALF NARROWS AND THE LOWER HALF WIDENS. WRITING BOTH AS ONE
    ; ROUTINE THAT TAKES A WIDTH AVOIDS DUPLICATING THE ROW DRAWING, AND THE
    ; MIDDLE ROW IS PRINTED ONCE RATHER THAN BY BOTH HALVES.
    ; -------------------------------------------------------------------------
    MOV BX, HALF                        ; The upper half, narrowing

UPPER:
    CMP BX, 1
    JB  LOWER_SETUP

    CALL DRAW_ROW
    DEC BX
    JMP UPPER

LOWER_SETUP:
    MOV BX, 2                           ; The middle row is already drawn

LOWER:
    CMP BX, HALF
    JA  FINISHED

    CALL DRAW_ROW
    INC BX
    JMP LOWER

FINISHED:
    MOV AH, 4CH
    INT 21H

; -----------------------------------------------------------------------------
; DRAW_ROW
;
; Draws one row of the hourglass, BX stars wide, centred within HALF.
; -----------------------------------------------------------------------------
DRAW_ROW PROC
    PUSH BX
    PUSH CX
    PUSH DX

    MOV CX, HALF
    SUB CX, BX
    MOV DL, ' '
    CALL REPEAT_CHAR

    MOV CX, BX
    SHL CX, 1
    DEC CX
    MOV DL, '*'
    CALL REPEAT_CHAR

    CALL NEWLINE

    POP DX
    POP CX
    POP BX
    RET
DRAW_ROW ENDP

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
; 1. THE MIDDLE ROW IS SHARED:
;    - The upper half ends at a width of one and the lower half starts at
;    - two, so the single star in the middle is printed once. Starting the
;    - lower half at one would print it twice and the waist would look
;    - wrong.
; 2. ONE ROUTINE, TWO DIRECTIONS:
;    - The row drawing does not care whether the pattern is widening or
;    - narrowing. Only the loop that calls it does.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
