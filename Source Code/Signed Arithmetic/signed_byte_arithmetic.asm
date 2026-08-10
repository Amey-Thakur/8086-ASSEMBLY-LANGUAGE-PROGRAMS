; =============================================================================
; TITLE: Signed Arithmetic on Bytes
; DESCRIPTION: Adds and multiplies signed bytes, where the sign bit is bit seven
;              and widening has to happen before anything larger is attempted.
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
    TEMPS   DB -8, 15, -3, 22
    HOWMANY EQU 4
    M_SUM   DB 'Sum of the byte readings: $'
    M_SCALE DB 'The first reading times nine: $'

; -----------------------------------------------------------------------------
; CODE SEGMENT
; -----------------------------------------------------------------------------
.CODE
START:
    MOV AX, @DATA
    MOV DS, AX

    LEA SI, TEMPS
    MOV CX, HOWMANY
    XOR BX, BX                          ; The total, kept as a word

SUM_LOOP:
    ; -------------------------------------------------------------------------
    ; EACH BYTE IS WIDENED BEFORE IT IS ADDED. ADDING BYTES DIRECTLY WOULD
    ; OVERFLOW AT 127, AND THE TOTAL HERE IS SAFELY INSIDE A WORD.
    ; -------------------------------------------------------------------------
    MOV AL, [SI]
    CBW
    ADD BX, AX

    INC SI
    LOOP SUM_LOOP

    LEA DX, M_SUM
    MOV AH, 09H
    INT 21H
    MOV AX, BX
    CALL PRINT_SIGNED
    CALL NEWLINE

    ; -------------------------------------------------------------------------
    ; A BYTE IMUL MULTIPLIES AL BY THE OPERAND AND PUTS THE WHOLE SIXTEEN BIT
    ; ANSWER IN AX, SO NO WIDENING IS NEEDED FIRST.
    ; -------------------------------------------------------------------------
    MOV AL, TEMPS
    MOV BL, 9
    IMUL BL

    MOV BX, AX
    LEA DX, M_SCALE
    MOV AH, 09H
    INT 21H
    MOV AX, BX
    CALL PRINT_SIGNED
    CALL NEWLINE

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
; 1. THE BYTE RANGE:
;    - A signed byte holds -128 to 127. Four readings that each fit can
;    - still sum to something that does not, so the total is kept wider.
; 2. IMUL WIDENS BY ITSELF:
;    - The byte form writes its answer into the whole of AX, so the
;    - product of two bytes can never overflow.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
