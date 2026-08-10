; =============================================================================
; TITLE: Binary Text to a Value
; DESCRIPTION: Reads a string of ones and zeros into a number, using a shift
;              in place of a multiplication.
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
    SAMPLES DB '1011010011010010'
            DB '0000000011111111'
            DB '1000000000000000'
    BITS    EQU 16
    HOWMANY EQU 3

    M_IS    DB ' is $'

; -----------------------------------------------------------------------------
; CODE SEGMENT
; -----------------------------------------------------------------------------
.CODE
START:
    MOV AX, @DATA
    MOV DS, AX

    LEA SI, SAMPLES
    MOV CX, HOWMANY

EACH:
    PUSH CX
    PUSH SI

    MOV CX, BITS
    CALL PRINT_TEXT

    LEA DX, M_IS
    MOV AH, 09H
    INT 21H

    POP SI
    PUSH SI
    CALL READ_BINARY
    CALL PRINT_DECIMAL
    CALL NEWLINE

    POP SI
    POP CX
    ADD SI, BITS
    LOOP EACH

    MOV AH, 4CH
    INT 21H

; -----------------------------------------------------------------------------
; READ_BINARY
;
; SI points at BITS characters of '0' and '1'. The value comes back in AX.
; -----------------------------------------------------------------------------
READ_BINARY PROC
    PUSH BX
    PUSH CX
    PUSH SI

    XOR BX, BX
    MOV CX, BITS

RB_LOOP:
    ; -------------------------------------------------------------------------
    ; DOUBLING THE TOTAL AND ADDING THE NEW BIT IS THE SAME ACCUMULATION AS
    ; FOR DECIMAL, EXCEPT THAT MULTIPLYING BY THE BASE IS ONE SHIFT.
    ; -------------------------------------------------------------------------
    SHL BX, 1

    MOV AL, [SI]
    CMP AL, '1'
    JNE RB_NEXT
    OR  BX, 1

RB_NEXT:
    INC SI
    LOOP RB_LOOP

    MOV AX, BX

    POP SI
    POP CX
    POP BX
    RET
READ_BINARY ENDP

; -----------------------------------------------------------------------------
; PRINT_TEXT
;
; Prints CX characters starting at DS:SI. Both are left as they were found.
; -----------------------------------------------------------------------------
PRINT_TEXT PROC
    PUSH AX
    PUSH CX
    PUSH DX
    PUSH SI

    JCXZ PT_DONE                        ; Nothing to print

PT_LOOP:
    MOV DL, [SI]
    MOV AH, 02H
    INT 21H
    INC SI
    LOOP PT_LOOP

PT_DONE:
    POP SI
    POP DX
    POP CX
    POP AX
    RET
PRINT_TEXT ENDP

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
; 1. THE BASE DECIDES THE INSTRUCTION:
;    - Base two is a shift of one, base eight a shift of three, base
;    - sixteen a shift of four. Only base ten needs an actual
;    - multiplication.
; 2. ANYTHING NOT A ONE IS A ZERO:
;    - The test only asks whether the character is a one, so a stray
;    - character contributes nothing rather than causing an error. A
;    - validating version would reject it instead.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
