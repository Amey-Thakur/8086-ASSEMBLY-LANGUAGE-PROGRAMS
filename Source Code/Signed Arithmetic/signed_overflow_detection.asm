; =============================================================================
; TITLE: Detecting Signed Overflow
; DESCRIPTION: Adds pairs of values and reports which sums were too large for a
;              signed word, using the overflow flag rather than the carry.
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
    PAIRS   DW 30000, 3000, -30000, -3000, 100, 200
    HOWMANY EQU 3
    M_PLUS  DB ' + $'
    M_GIVES DB ' gives $'
    M_OVER  DB '  (signed overflow)$'
    M_OK    DB '  (fits)$'

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
    PUSH CX
    PUSH SI

    MOV AX, [SI]
    CALL PRINT_SIGNED
    LEA DX, M_PLUS
    MOV AH, 09H
    INT 21H

    POP SI
    PUSH SI
    MOV AX, [SI+2]
    CALL PRINT_SIGNED
    LEA DX, M_GIVES
    MOV AH, 09H
    INT 21H

    POP SI
    PUSH SI

    ; -------------------------------------------------------------------------
    ; THE ADDITION AND THE TEST HAVE TO BE ADJACENT. ANYTHING IN BETWEEN,
    ; INCLUDING A CALL TO PRINT SOMETHING, WOULD REPLACE THE FLAGS.
    ; -------------------------------------------------------------------------
    MOV AX, [SI]
    ADD AX, [SI+2]
    PUSHF
    PUSH AX

    CALL PRINT_SIGNED
    POP AX
    POPF

    JO  OVERFLOWED
    LEA DX, M_OK
    JMP REPORT

OVERFLOWED:
    LEA DX, M_OVER

REPORT:
    MOV AH, 09H
    INT 21H
    CALL NEWLINE

    POP SI
    POP CX
    ADD SI, 4
    LOOP PAIR_LOOP

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
; 1. THE RULE FOR OF:
;    - Two operands of the same sign giving a result of the other sign.
;    - Adding a positive to a negative can never overflow, because the
;    - answer lies between them.
; 2. SAVING THE VERDICT:
;    - PUSHF immediately after the addition keeps the flag while the
;    - result is printed. Without it the branch would test whatever the
;    - printing left behind.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
