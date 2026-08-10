; =============================================================================
; TITLE: Testing Whether Two Numbers Are Coprime
; DESCRIPTION: Decides whether two numbers share any factor, by computing their
;              greatest common divisor with the remainder form of Euclid's method.
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
    PAIRS   DW 35, 64, 24, 36, 17, 51
    HOWMANY EQU 3
    M_AND   DB ' and $'
    M_YES   DB ': coprime', 0DH, 0AH, '$'
    M_NO    DB ': share a factor of $'

; -----------------------------------------------------------------------------
; CODE SEGMENT
; -----------------------------------------------------------------------------
.CODE
START:
    MOV AX, @DATA
    MOV DS, AX

    LEA SI, PAIRS
    MOV CX, HOWMANY

PAIR_LOOP:
    MOV BX, [SI]
    MOV DI, [SI+2]

    PUSH CX
    PUSH SI

    MOV AX, BX
    CALL PRINT_DECIMAL
    LEA DX, M_AND
    MOV AH, 09H
    INT 21H
    MOV AX, DI
    CALL PRINT_DECIMAL

    CALL GREATEST_COMMON_DIVISOR        ; BX and DI in, BX out

    CMP BX, 1
    JNE SHARE_FACTOR

    LEA DX, M_YES
    MOV AH, 09H
    INT 21H
    JMP NEXT_PAIR

SHARE_FACTOR:
    PUSH BX
    LEA DX, M_NO
    MOV AH, 09H
    INT 21H
    POP AX
    CALL PRINT_DECIMAL
    CALL NEWLINE

NEXT_PAIR:
    POP SI
    POP CX
    ADD SI, 4
    LOOP PAIR_LOOP

    MOV AH, 4CH
    INT 21H

; -----------------------------------------------------------------------------
; GREATEST_COMMON_DIVISOR
;
; Euclid's method by remainder. BX and DI go in, the divisor comes back in BX.
; -----------------------------------------------------------------------------
GREATEST_COMMON_DIVISOR PROC
    PUSH AX
    PUSH CX
    PUSH DX

GCD_LOOP:
    OR  DI, DI
    JZ  GCD_DONE                        ; A zero remainder means BX is the answer

    MOV AX, BX
    XOR DX, DX
    DIV DI                              ; DX = BX modulo DI

    MOV BX, DI                          ; Shuffle down and repeat
    MOV DI, DX
    JMP GCD_LOOP

GCD_DONE:
    POP DX
    POP CX
    POP AX
    RET
GREATEST_COMMON_DIVISOR ENDP

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
; 1. WHY THE REMAINDER FORM:
;    - Repeated subtraction reaches the same answer but takes one pass
;    - per subtraction. Using DIV gets there in a handful of steps
;    - however far apart the two numbers are.
; 2. COPRIME MEANS A DIVISOR OF ONE:
;    - Two numbers with no common factor have a greatest common divisor
;    - of one, which is all the test has to check.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
