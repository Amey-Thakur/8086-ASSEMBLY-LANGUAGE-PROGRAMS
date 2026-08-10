; =============================================================================
; TITLE: A Centred Pyramid
; DESCRIPTION: Prints a pyramid of stars, where each row needs one fewer space
;              in front and two more stars than the last.
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
    M_HEAD  DB 'A pyramid of six rows:', 0DH, 0AH, '$'

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

    MOV BX, 1                           ; The row number

EACH_ROW:
    CMP BX, ROWS
    JA  FINISHED

    ; -------------------------------------------------------------------------
    ; TWO COUNTS PER ROW, BOTH DERIVED FROM THE ROW NUMBER. THE SPACES ARE THE
    ; HEIGHT LESS THE ROW, AND THE STARS ARE TWICE THE ROW LESS ONE, WHICH IS
    ; WHAT KEEPS THE APEX OVER THE MIDDLE OF THE BASE.
    ; -------------------------------------------------------------------------
    MOV CX, ROWS
    SUB CX, BX
    MOV DL, ' '
    CALL REPEAT_CHAR

    MOV CX, BX
    SHL CX, 1
    DEC CX
    MOV DL, '*'
    CALL REPEAT_CHAR

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
; 1. ODD NUMBERS OF STARS:
;    - One, three, five, seven. An odd count is what allows a single
;    - star at the top to sit exactly over the centre of the row below.
; 2. THE INDENT IS THE HEIGHT LESS THE ROW:
;    - Which reaches nought on the last row, so the base starts at the
;    - left margin. Getting this off by one is what leaves a pyramid
;    - leaning.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
