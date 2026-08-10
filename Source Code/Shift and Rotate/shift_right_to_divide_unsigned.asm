; =============================================================================
; TITLE: Divide an Unsigned Value with SHR
; DESCRIPTION: Halves an unsigned value repeatedly with SHR, and shows that the
;              bit shifted out is the remainder.
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
    VALUE DW 200
    MSG   DB 'Halving 200 four times:', 0DH, 0AH, '$'
    REM   DB '  remainder ', '$'

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
    MOV CX, 4

HALVE_LOOP:
    SHR BX, 1                           ; The bit leaving is the remainder
    PUSHF                               ; Keep CF; printing will destroy it

    MOV AX, BX
    CALL PRINT_DECIMAL

    LEA DX, REM
    MOV AH, 09H
    INT 21H

    POPF                                ; Recover the remainder
    MOV DL, '0'
    JNC SHOW_REM
    MOV DL, '1'

SHOW_REM:
    MOV AH, 02H
    INT 21H
    CALL NEWLINE

    LOOP HALVE_LOOP

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
; 1. THE CARRY IS THE REMAINDER:
;    - Dividing by two leaves a remainder of nought or one, and that is
;    - exactly the bit SHR pushes into the carry flag.
; 2. WHY PUSHF:
;    - Printing calls DOS, which runs many instructions and will not leave
;    - the flags alone. The carry has to be saved before anything else.
; 3. UNSIGNED ONLY:
;    - SHR brings in zeros at the top, which is right for an unsigned
;    - value and wrong for a negative one. Use SAR for signed division.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
