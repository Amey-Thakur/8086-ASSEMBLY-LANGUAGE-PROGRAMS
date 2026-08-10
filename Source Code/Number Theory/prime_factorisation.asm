; =============================================================================
; TITLE: Prime Factorisation
; DESCRIPTION: Breaks a number into its prime factors by dividing out the
;              smallest factor repeatedly until nothing is left but one.
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
    NUMBER DW 360
    MSG    DB '360 factorises as $'
    TIMES_ DB ' x $'

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

    MOV BX, NUMBER
    MOV SI, 2                           ; The divisor being tried
    XOR DI, DI                          ; Whether anything has been printed

FACTOR_LOOP:
    CMP BX, 1
    JE  FINISH

    ; -------------------------------------------------------------------------
    ; TRY THE CURRENT DIVISOR. IF IT GOES IN EXACTLY, DIVIDE IT OUT AND TRY
    ; THE SAME ONE AGAIN, SO A REPEATED FACTOR IS FOUND AS MANY TIMES AS IT
    ; OCCURS.
    ; -------------------------------------------------------------------------
    MOV AX, BX
    XOR DX, DX
    DIV SI                              ; AX = quotient, DX = remainder
    OR  DX, DX
    JNZ NEXT_DIVISOR

    MOV BX, AX                          ; Divide it out

    OR  DI, DI
    JZ  NO_SEPARATOR
    PUSH BX
    LEA DX, TIMES_
    MOV AH, 09H
    INT 21H
    POP BX

NO_SEPARATOR:
    MOV DI, 1
    PUSH BX
    PUSH SI
    MOV AX, SI
    CALL PRINT_DECIMAL
    POP SI
    POP BX
    JMP FACTOR_LOOP

NEXT_DIVISOR:
    INC SI
    JMP FACTOR_LOOP

FINISH:
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
; 1. WHY THE DIVISOR IS NOT ADVANCED ON SUCCESS:
;    - 360 has three factors of two. Advancing after the first would find
;    - only one of them and leave the rest hidden inside the quotient.
; 2. EVERY FACTOR FOUND IS PRIME:
;    - Smaller factors have already been divided out, so the first
;    - divisor that goes in cannot itself be composite.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
