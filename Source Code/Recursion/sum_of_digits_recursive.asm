; =============================================================================
; TITLE: Sum of Digits by Recursion
; DESCRIPTION: Adds the digits of a number by taking one off and asking for the
;              sum of the rest.
; AUTHOR: Amey Thakur (https://github.com/Amey-Thakur)
; REPOSITORY: https://github.com/Amey-Thakur/8086-ASSEMBLY-LANGUAGE-PROGRAMS
; LICENSE: MIT License
; =============================================================================

.MODEL SMALL
.STACK 200H

; -----------------------------------------------------------------------------
; DATA SEGMENT
; -----------------------------------------------------------------------------
.DATA
    NUMBER  DW 48963
    M_HEAD  DB 'The digits of 48963 add up to $'

; -----------------------------------------------------------------------------
; CODE SEGMENT
; -----------------------------------------------------------------------------
.CODE
START:
    MOV AX, @DATA
    MOV DS, AX

    MOV AX, NUMBER
    PUSH AX
    CALL DIGIT_SUM
    ADD SP, 2

    PUSH AX
    LEA DX, M_HEAD
    MOV AH, 09H
    INT 21H
    POP AX
    CALL PRINT_DECIMAL
    CALL NEWLINE

    MOV AH, 4CH
    INT 21H

; -----------------------------------------------------------------------------
; DIGIT_SUM
;
; [BP+4] is the number. The total comes back in AX.
;
;     sum(0) = 0
;     sum(n) = (n mod 10) + sum(n / 10)
; -----------------------------------------------------------------------------
DIGIT_SUM PROC
    PUSH BP
    MOV BP, SP
    PUSH BX
    PUSH DX

    MOV AX, [BP+4]
    OR  AX, AX
    JZ  DS_BASE                         ; Nothing left to add

    ; -------------------------------------------------------------------------
    ; ONE DIVISION SPLITS THE NUMBER INTO ITS LAST DIGIT AND EVERYTHING ELSE.
    ; THE REMAINDER IS THIS LEVEL'S CONTRIBUTION; THE QUOTIENT IS THE SMALLER
    ; PROBLEM TO HAND DOWNWARD.
    ; -------------------------------------------------------------------------
    XOR DX, DX
    MOV BX, 10
    DIV BX                              ; AX = the rest, DX = the last digit

    PUSH DX                             ; Keep this digit across the call
    PUSH AX
    CALL DIGIT_SUM
    ADD SP, 2
    POP DX

    ADD AX, DX
    JMP DS_RETURN

DS_BASE:
    XOR AX, AX

DS_RETURN:
    POP DX
    POP BX
    POP BP
    RET
DIGIT_SUM ENDP

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

END START

; =============================================================================
; TECHNICAL NOTES
; =============================================================================
; 1. THE DIGIT MUST OUTLIVE THE CALL:
;    - DX holds the digit found at this level, and the recursive call
;    - will need DX for its own division.
;    - for its own division. Pushing it is what keeps the levels from
;    - overwriting each other.
; 2. THE DEPTH IS THE DIGIT COUNT:
;    - Five digits, five levels. A word can hold at most five, so this
;    - recursion can never run away.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
