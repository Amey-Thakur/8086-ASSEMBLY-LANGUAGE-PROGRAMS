; =============================================================================
; TITLE: Multiply by a Power of Two with SHL
; DESCRIPTION: Shows that shifting left by N multiplies by two to the N, and
;              prints the same value doubled four times over.
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
    VALUE DW 25
    MSG   DB 'Doubling 25 four times:', 0DH, 0AH, '$'

; -----------------------------------------------------------------------------
; CODE SEGMENT
; -----------------------------------------------------------------------------
.CODE
START:
    MOV AX, @DATA
    MOV DS, AX

    LEA DX, MSG
    MOV AH, 09H
    INT 21H

    MOV BX, VALUE
    MOV CX, 4                           ; Four doublings

DOUBLE_LOOP:
    SHL BX, 1                           ; One place left is one multiplication
    MOV AX, BX
    CALL PRINT_DECIMAL
    CALL NEWLINE
    LOOP DOUBLE_LOOP

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
; 1. WHY IT WORKS:
;    - Each bit position is worth twice the one below it, so moving every
;    - bit one place left doubles the value the word represents.
;    - Shifting by N therefore multiplies by two to the power N.
; 2. WHEN IT STOPS BEING TRUE:
;    - A bit shifted off the top is lost, and the carry flag is the only
;    - record that it happened. Check CF if the value may be large.
; 3. WHY NOT MUL:
;    - MUL is correct but far slower on the 8086, and it clobbers DX.
;    - A shift is the usual way to multiply by a power of two.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
