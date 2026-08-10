; =============================================================================
; TITLE: When a Shift Is Not a Division
; DESCRIPTION: Compares IDIV against SAR on the same negative values and shows
;              the two rounding in opposite directions.
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
    VALUES  DW -7, -8, -9, 7
    HOWMANY EQU 4
    M_IDIV  DB '  IDIV by 2: $'
    M_SAR   DB '   SAR by 1: $'

; -----------------------------------------------------------------------------
; CODE SEGMENT
; -----------------------------------------------------------------------------
.CODE
START:
    MOV AX, @DATA
    MOV DS, AX

    LEA SI, VALUES
    MOV CX, HOWMANY

COMPARE_LOOP:
    PUSH CX
    PUSH SI

    MOV AX, [SI]
    CALL PRINT_SIGNED

    LEA DX, M_IDIV
    MOV AH, 09H
    INT 21H

    POP SI
    PUSH SI
    MOV AX, [SI]
    CWD
    MOV BX, 2
    IDIV BX
    CALL PRINT_SIGNED

    LEA DX, M_SAR
    MOV AH, 09H
    INT 21H

    POP SI
    PUSH SI
    MOV AX, [SI]
    SAR AX, 1
    CALL PRINT_SIGNED
    CALL NEWLINE

    POP SI
    POP CX
    ADD SI, 2
    LOOP COMPARE_LOOP

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
; 1. THEY DISAGREE ON ODD NEGATIVES:
;    - -7 halved gives -3 by IDIV and -4 by SAR. Even values and
;    - positive values agree, which is why the difference is so easy to
;    - miss during testing.
; 2. WHICH IS CORRECT:
;    - Both are. IDIV rounds toward zero, as most languages define
;    - integer division. SAR rounds toward negative infinity, which is
;    - what a true arithmetic shift means.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
