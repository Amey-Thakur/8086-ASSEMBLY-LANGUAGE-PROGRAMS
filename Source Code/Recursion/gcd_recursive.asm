; =============================================================================
; TITLE: Greatest Common Divisor by Recursion
; DESCRIPTION: States Euclid's method as it is usually written in mathematics,
;              where the recursive form is the natural one.
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
    FIRST   DW 1071
    SECOND  DW 462
    M_HEAD  DB 'The greatest common divisor of 1071 and 462 is $'

; -----------------------------------------------------------------------------
; CODE SEGMENT
; -----------------------------------------------------------------------------
.CODE
START:
    MOV AX, @DATA
    MOV DS, AX

    MOV AX, FIRST
    PUSH AX
    MOV AX, SECOND
    PUSH AX
    CALL GCD
    ADD SP, 4

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
; GCD
;
; [BP+6] is a and [BP+4] is b. The divisor comes back in AX.
;
;     gcd(a, 0) = a
;     gcd(a, b) = gcd(b, a mod b)
; -----------------------------------------------------------------------------
GCD PROC
    PUSH BP
    MOV BP, SP
    PUSH BX
    PUSH DX

    MOV BX, [BP+4]                      ; b
    OR  BX, BX
    JZ  GCD_BASE                        ; gcd(a, 0) is a

    MOV AX, [BP+6]                      ; a
    XOR DX, DX
    DIV BX                              ; DX = a modulo b

    PUSH BX                             ; b becomes the new a
    PUSH DX                             ; the remainder becomes the new b
    CALL GCD
    ADD SP, 4
    JMP GCD_RETURN

GCD_BASE:
    MOV AX, [BP+6]

GCD_RETURN:
    POP DX
    POP BX
    POP BP
    RET
GCD ENDP

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
; 1. THE CALL IS THE LAST THING:
;    - Nothing happens after the recursive call except returning its
;    - answer. That makes it tail recursion, which a loop can replace
;    - exactly, with no stack growth at all.
; 2. WHY 1071 AND 462:
;    - It is the pair Euclid used. The answer is 21, reached in four
;    - steps: 1071, 462, 147, 21, 0.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
