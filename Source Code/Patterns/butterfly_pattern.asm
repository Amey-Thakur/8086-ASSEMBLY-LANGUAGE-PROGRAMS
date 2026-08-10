; =============================================================================
; TITLE: A Butterfly
; DESCRIPTION: Two triangles facing each other with a widening gap, then the
;              whole thing mirrored.
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
    M_HEAD  DB 'A butterfly:', 0DH, 0AH, '$'

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
    ; EACH ROW IS STARS, A GAP, THEN STARS AGAIN. THE WINGS GROW AS THE GAP
    ; SHRINKS, SO THE TOTAL WIDTH NEVER CHANGES AND THE EDGES STAY STRAIGHT.
    ; -------------------------------------------------------------------------
    MOV BX, 1                           ; The upper half, widening

UPPER:
    CMP BX, HALF
    JA  LOWER_SETUP
    CALL DRAW_ROW
    INC BX
    JMP UPPER

LOWER_SETUP:
    MOV BX, HALF

LOWER:
    CMP BX, 1
    JB  FINISHED
    CALL DRAW_ROW
    DEC BX
    JMP LOWER

FINISHED:
    MOV AH, 4CH
    INT 21H

; -----------------------------------------------------------------------------
; DRAW_ROW
;
; One row: BX stars, a gap of twice the remaining rows, then BX stars.
; -----------------------------------------------------------------------------
DRAW_ROW PROC
    PUSH BX
    PUSH CX
    PUSH DX

    MOV CX, BX
    MOV DL, '*'
    CALL REPEAT_CHAR

    MOV CX, HALF
    SUB CX, BX
    SHL CX, 1
    MOV DL, ' '
    CALL REPEAT_CHAR

    MOV CX, BX
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
; 1. THE WIDTH IS CONSTANT:
;    - Two wings of BX plus a gap of twice the remainder always comes to
;    - twice the half. That is why both outer edges are vertical.
; 2. THE HALVES ARE THE SAME ROWS REVERSED:
;    - So the second loop simply counts the other way. Nothing about the
;    - row itself changes.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
