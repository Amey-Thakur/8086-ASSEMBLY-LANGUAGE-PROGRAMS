; =============================================================================
; TITLE: A Triangle of Ones and Zeros
; DESCRIPTION: Fills a triangle with alternating bits, where each cell depends
;              on whether its row and column sum to an even number.
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
    ROWS    EQU 7
    M_HEAD  DB 'Ones where the row and column sum is even:', 0DH, 0AH, '$'

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

    MOV BX, 1                           ; The row

EACH_ROW:
    CMP BX, ROWS
    JA  FINISHED

    MOV CX, 1                           ; The column

EACH_CELL:
    CMP CX, BX
    JA  ROW_DONE

    ; -------------------------------------------------------------------------
    ; ADDING THE ROW AND THE COLUMN AND TESTING THE LOWEST BIT DECIDES THE
    ; CHARACTER. THAT IS THE SAME TEST A CHECKERBOARD USES, AND IT IS ONE
    ; INSTRUCTION RATHER THAN A COUNTER THAT HAS TO BE FLIPPED.
    ; -------------------------------------------------------------------------
    MOV AX, BX
    ADD AX, CX
    TEST AX, 1
    JNZ CELL_ZERO

    MOV DL, '1'
    JMP EMIT

CELL_ZERO:
    MOV DL, '0'

EMIT:
    MOV AH, 02H
    INT 21H

    INC CX
    JMP EACH_CELL

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
; 1. A FUNCTION OF THE POSITION:
;    - Nothing is remembered between cells. Every character is worked out
;    - from where it is, which makes the pattern trivially correct and
;    - means it could be drawn in any order at all.
; 2. TESTING THE LOWEST BIT:
;    - Odd or even is bit zero. TEST answers it without changing the sum,
;    - where a division would cost eighty times as much.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
