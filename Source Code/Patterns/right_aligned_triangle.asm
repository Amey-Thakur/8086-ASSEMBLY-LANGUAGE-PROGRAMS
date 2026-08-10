; =============================================================================
; TITLE: A Right Aligned Triangle
; DESCRIPTION: Pushes each row to the right by padding in front, so the
;              vertical edge is on the right instead of the left.
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
    M_HEAD  DB 'Right aligned, then left aligned:', 0DH, 0AH, '$'
    M_GAP   DB 0DH, 0AH, '$'

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
    ; THE PADDING IS WHAT MOVES THE SHAPE. THE STARS THEMSELVES ARE PRINTED
    ; THE SAME WAY IN BOTH CASES, WHICH IS WHY ONE EXTRA CALL TURNS A LEFT
    ; ALIGNED TRIANGLE INTO A RIGHT ALIGNED ONE.
    ; -------------------------------------------------------------------------
    MOV BX, 1

RIGHT_ROWS:
    CMP BX, ROWS
    JA  LEFT_SETUP

    MOV CX, ROWS
    SUB CX, BX
    MOV DL, ' '
    CALL REPEAT_CHAR

    MOV CX, BX
    MOV DL, '*'
    CALL REPEAT_CHAR

    CALL NEWLINE
    INC BX
    JMP RIGHT_ROWS

LEFT_SETUP:
    LEA DX, M_GAP
    MOV AH, 09H
    INT 21H

    MOV BX, 1

LEFT_ROWS:
    CMP BX, ROWS
    JA  FINISHED

    MOV CX, BX
    MOV DL, '*'
    CALL REPEAT_CHAR

    CALL NEWLINE
    INC BX
    JMP LEFT_ROWS

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
; 1. ALIGNMENT IS ONLY PADDING:
;    - Nothing about the content changes. Every alignment problem in a
;    - text layout reduces to how many spaces come first.
; 2. THE PADDING SHRINKS AS THE ROW GROWS:
;    - Together they always come to the height, which is what keeps the
;    - right hand edge straight.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
