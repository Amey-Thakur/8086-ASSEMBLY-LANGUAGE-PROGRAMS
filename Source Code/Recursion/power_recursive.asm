; =============================================================================
; TITLE: Exponentiation by Recursion
; DESCRIPTION: Raises a number to a power both the plain way and by squaring,
;              and counts the multiplications each needs.
; AUTHOR: Amey Thakur (https://github.com/Amey-Thakur)
; REPOSITORY: https://github.com/Amey-Thakur/8086-ASSEMBLY-LANGUAGE-PROGRAMS
; LICENSE: MIT License
; =============================================================================

.MODEL SMALL
.STACK 200H

; -----------------------------------------------------------------------------
; DATA SEGMENT
; -----------------------------------------------------------------------------
.DATA
    BASE_V  DW 3
    EXPON   DW 9
    M_PLAIN DB 'Three to the ninth, one step at a time: $'
    M_FAST  DB 'The same by squaring:                    $'
    M_MULS  DB '  multiplications: $'
    COUNT_A DW 0
    COUNT_B DW 0

; -----------------------------------------------------------------------------
; CODE SEGMENT
; -----------------------------------------------------------------------------
.CODE
START:
    MOV AX, @DATA
    MOV DS, AX

    ; The plain form: one multiplication per step down
    MOV AX, EXPON
    PUSH AX
    CALL POWER_PLAIN
    ADD SP, 2

    PUSH AX
    LEA DX, M_PLAIN
    MOV AH, 09H
    INT 21H
    POP AX
    CALL PRINT_DECIMAL
    LEA DX, M_MULS
    MOV AH, 09H
    INT 21H
    MOV AX, COUNT_A
    CALL PRINT_DECIMAL
    CALL NEWLINE

    ; By squaring: halve the exponent at every step
    MOV AX, EXPON
    PUSH AX
    CALL POWER_SQUARING
    ADD SP, 2

    PUSH AX
    LEA DX, M_FAST
    MOV AH, 09H
    INT 21H
    POP AX
    CALL PRINT_DECIMAL
    LEA DX, M_MULS
    MOV AH, 09H
    INT 21H
    MOV AX, COUNT_B
    CALL PRINT_DECIMAL
    CALL NEWLINE

    MOV AH, 4CH
    INT 21H

; -----------------------------------------------------------------------------
; POWER_PLAIN
;
; [BP+4] is the exponent. Returns BASE_V raised to it, in AX.
; -----------------------------------------------------------------------------
POWER_PLAIN PROC
    PUSH BP
    MOV BP, SP

    MOV AX, [BP+4]
    OR  AX, AX
    JZ  PP_ONE                          ; Anything to the power zero is one

    DEC AX
    PUSH AX
    CALL POWER_PLAIN
    ADD SP, 2

    MUL WORD PTR BASE_V
    INC COUNT_A
    JMP PP_RETURN

PP_ONE:
    MOV AX, 1

PP_RETURN:
    POP BP
    RET
POWER_PLAIN ENDP

; -----------------------------------------------------------------------------
; POWER_SQUARING
;
; [BP+4] is the exponent. Halving it at each step turns nine multiplications
; into four, because squaring a result doubles the exponent for free.
; -----------------------------------------------------------------------------
POWER_SQUARING PROC
    PUSH BP
    MOV BP, SP
    PUSH BX

    MOV AX, [BP+4]
    OR  AX, AX
    JZ  PS_ONE

    MOV BX, AX
    SHR AX, 1                           ; The exponent, halved
    PUSH AX
    CALL POWER_SQUARING
    ADD SP, 2

    MUL AX                              ; Square what came back
    INC COUNT_B

    TEST BX, 1                          ; An odd exponent needs one more
    JZ  PS_RETURN
    MUL WORD PTR BASE_V
    INC COUNT_B
    JMP PS_RETURN

PS_ONE:
    MOV AX, 1

PS_RETURN:
    POP BX
    POP BP
    RET
POWER_SQUARING ENDP

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
; 1. WHY SQUARING WINS:
;    - Each level halves the exponent rather than reducing it by one, so
;    - the depth is the number of bits rather than the value. For large
;    - exponents the difference is enormous.
; 2. THE ODD CASE:
;    - Halving nine gives four, and four doubled is eight, not nine. The
;    - extra multiplication when the exponent was odd is what makes up
;    - the difference.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
