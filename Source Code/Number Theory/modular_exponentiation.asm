; =============================================================================
; TITLE: Modular Exponentiation
; DESCRIPTION: Raises a number to a power under a modulus by squaring, which
;              keeps every intermediate value small enough for a word.
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
    BASE_V  DW 7
    EXPON   DW 13
    MODULUS DW 11
    MSG     DB '7 to the 13th, modulo 11, is $'

; -----------------------------------------------------------------------------
; CODE SEGMENT
; -----------------------------------------------------------------------------
.CODE
START:
    MOV AX, @DATA
    MOV DS, AX

    ; -------------------------------------------------------------------------
    ; SQUARE AND MULTIPLY. THE EXPONENT IS READ ONE BIT AT A TIME FROM THE
    ; BOTTOM; THE BASE IS SQUARED EVERY PASS, AND FOLDED INTO THE RESULT ONLY
    ; WHEN THE CURRENT BIT IS SET. THIRTEEN PASSES BECOME FOUR.
    ; -------------------------------------------------------------------------
    MOV BX, BASE_V
    MOV CX, EXPON
    MOV SI, 1                           ; The running result

    ; Reduce the base first, so it starts small
    MOV AX, BX
    XOR DX, DX
    DIV MODULUS
    MOV BX, DX

POWER_LOOP:
    OR  CX, CX
    JZ  DONE_POWER

    TEST CX, 1
    JZ  SQUARE_ONLY

    MOV AX, SI                          ; result = result * base mod m
    MUL BX
    DIV MODULUS
    MOV SI, DX

SQUARE_ONLY:
    MOV AX, BX                          ; base = base * base mod m
    MUL BX
    DIV MODULUS
    MOV BX, DX

    SHR CX, 1                           ; Next bit of the exponent
    JMP POWER_LOOP

DONE_POWER:
    LEA DX, MSG
    MOV AH, 09H
    INT 21H
    MOV AX, SI
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
; 1. WHY REDUCE AT EVERY STEP:
;    - 7 to the 13th is nearly a hundred billion and will not fit
;    - anywhere. Taking the modulus after each multiplication keeps every
;    - value below the modulus squared, which fits comfortably.
; 2. DIV AFTER MUL IS EXACT:
;    - MUL leaves a thirty two bit product in DX:AX, and DIV consumes
;    - exactly that pair. The two instructions fit together with no
;    - shuffling in between.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
