; =============================================================================
; TITLE: Unpack a Word into Two Bytes
; DESCRIPTION: Splits a word into its high and low bytes, by shifting for one
;              half and masking for the other.
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
    VALUE  DW 0A73CH
    HIGH_M DB 'High byte: $'
    LOW_M  DB 'Low byte:  $'

; -----------------------------------------------------------------------------
; CODE SEGMENT
; -----------------------------------------------------------------------------
.CODE
START:
    MOV AX, @DATA
    MOV DS, AX

    ; The high byte: shift it down to the bottom
    MOV BX, VALUE
    MOV CL, 8
    SHR BX, CL

    LEA DX, HIGH_M
    MOV AH, 09H
    INT 21H
    MOV AX, BX
    CALL PRINT_DECIMAL
    CALL NEWLINE

    ; The low byte: mask the top away
    MOV BX, VALUE
    AND BX, 00FFH

    LEA DX, LOW_M
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
; 1. TWO HALVES, TWO METHODS:
;    - The high byte has to move, so it is shifted. The low byte is
;    - already in place, so it only needs the rest cleared away.
; 2. THE MASK:
;    - 00FFh keeps the bottom eight bits and clears the top eight. A mask
;    - is the standard way of saying which bits are wanted.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
