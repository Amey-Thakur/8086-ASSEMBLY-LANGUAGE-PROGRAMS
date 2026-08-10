; =============================================================================
; TITLE: Digital Root
; DESCRIPTION: Adds the digits of a number over and over until one digit is
;              left, then checks the result against the shortcut formula.
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
    NUMBER  DW 9875
    M_LONG  DB 'By repeated addition: $'
    M_SHORT DB 'By the modulo nine rule: $'

; -----------------------------------------------------------------------------
; CODE SEGMENT
; -----------------------------------------------------------------------------
.CODE
START:
    MOV AX, @DATA
    MOV DS, AX

    ; -------------------------------------------------------------------------
    ; THE LONG WAY: SUM THE DIGITS, AND IF THE SUM STILL HAS MORE THAN ONE
    ; DIGIT, SUM IT AGAIN.
    ; -------------------------------------------------------------------------
    MOV BX, NUMBER

OUTER:
    XOR DI, DI                          ; Sum of this pass
    MOV AX, BX
    MOV CX, 10

DIGIT_LOOP:
    XOR DX, DX
    DIV CX                              ; DX = lowest digit
    ADD DI, DX
    OR  AX, AX
    JNZ DIGIT_LOOP

    MOV BX, DI
    CMP BX, 9
    JA  OUTER                           ; Still more than one digit

    LEA DX, M_LONG
    MOV AH, 09H
    INT 21H
    MOV AX, BX
    CALL PRINT_DECIMAL
    CALL NEWLINE

    ; -------------------------------------------------------------------------
    ; THE SHORT WAY: THE DIGITAL ROOT IS THE NUMBER MODULO NINE, EXCEPT THAT
    ; A MULTIPLE OF NINE GIVES NINE RATHER THAN ZERO.
    ; -------------------------------------------------------------------------
    MOV AX, NUMBER
    XOR DX, DX
    MOV CX, 9
    DIV CX
    OR  DX, DX
    JNZ HAVE_ROOT
    MOV DX, 9

HAVE_ROOT:
    MOV BX, DX
    LEA DX, M_SHORT
    MOV AH, 09H
    INT 21H
    MOV AX, BX
    CALL PRINT_DECIMAL
    CALL NEWLINE

    MOV AH, 4CH
    INT 21H

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
; 1. WHY MODULO NINE WORKS:
;    - Ten leaves a remainder of one when divided by nine, and so does
;    - every power of ten. A number is therefore congruent to the sum of
;    - its digits, modulo nine, however many times the sum is taken.
; 2. THE ZERO EXCEPTION:
;    - Nine itself gives a remainder of zero, but its digital root is
;    - nine. The one line that corrects it is easy to leave out.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
