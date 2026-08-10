; =============================================================================
; TITLE: Signed Division with IDIV
; DESCRIPTION: Divides negative values and shows the direction IDIV rounds in,
;              together with the sign the remainder takes.
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
    CASES   DW -17, 5, 17, -5, -17, -5
    HOWMANY EQU 3
    M_DIV   DB ' / $'
    M_EQ    DB ' = $'
    M_REM   DB ' remainder $'

; -----------------------------------------------------------------------------
; CODE SEGMENT
; -----------------------------------------------------------------------------
.CODE
START:
    MOV AX, @DATA
    MOV DS, AX

    LEA SI, CASES
    MOV CX, HOWMANY

DIVIDE_LOOP:
    MOV AX, [SI]                        ; The dividend
    MOV BX, [SI+2]                      ; The divisor

    PUSH CX
    PUSH SI
    PUSH BX
    PUSH AX

    CALL PRINT_SIGNED
    LEA DX, M_DIV
    MOV AH, 09H
    INT 21H
    POP AX
    POP BX
    PUSH BX
    MOV AX, BX
    CALL PRINT_SIGNED
    LEA DX, M_EQ
    MOV AH, 09H
    INT 21H

    POP BX
    POP SI
    PUSH SI

    ; -------------------------------------------------------------------------
    ; CWD FIRST, ALWAYS. IDIV DIVIDES DX:AX, AND WITHOUT THE SIGN EXTENSION
    ; DX HOLDS WHATEVER WAS LEFT THERE BY THE LAST MULTIPLICATION.
    ; -------------------------------------------------------------------------
    MOV AX, [SI]
    CWD
    IDIV BX                             ; AX = quotient, DX = remainder

    PUSH DX
    CALL PRINT_SIGNED                   ; The quotient

    LEA DX, M_REM
    MOV AH, 09H
    INT 21H
    POP AX
    CALL PRINT_SIGNED                   ; The remainder
    CALL NEWLINE

    POP SI
    POP CX
    ADD SI, 4
    LOOP DIVIDE_LOOP

    MOV AH, 4CH
    INT 21H

; -----------------------------------------------------------------------------
; PRINT_SIGNED
;
; Prints AX as a signed value, with a minus sign when it is negative.
; -----------------------------------------------------------------------------
PRINT_SIGNED PROC
    PUSH AX
    PUSH DX

    OR  AX, AX
    JNS PS_POSITIVE                     ; Sign flag clear means not negative

    PUSH AX
    MOV DL, '-'
    MOV AH, 02H
    INT 21H
    POP AX
    NEG AX                              ; Print the magnitude

PS_POSITIVE:
    CALL PRINT_DECIMAL

    POP DX
    POP AX
    RET
PRINT_SIGNED ENDP

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
; 1. IDIV ROUNDS TOWARD ZERO:
;    - -17 divided by 5 gives -3 and a remainder of -2, not -4 and 3.
;    - SAR would give -4, which is why a shift is not a drop in
;    - replacement for signed division.
; 2. THE REMAINDER FOLLOWS THE DIVIDEND:
;    - It takes the sign of the number being divided, so that quotient
;    - times divisor plus remainder returns the original value.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
