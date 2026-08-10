; =============================================================================
; TITLE: Power by Repeated Squaring
; DESCRIPTION: Raises a number to a power by reading the exponent as binary and
;              squaring the base once per bit, which costs a count proportional
;              to the number of bits rather than to the exponent itself.
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
    BASE_W  DW 3, 2, 5, 13, 3
    EXP_W   DW 9, 15, 6,  4, 11
    HOWMANY EQU 5

    BASE_V  DW ?                        ; The base of the case being worked
    EXP_V   DW ?
    RESULT  DW ?
    OPS     DW ?                        ; Multiplications actually performed
    TOOBIG  DB ?                        ; Set once the value leaves sixteen bits

    M_TITLE DB 'Raising a number to a power by squaring rather than repeating'
            DB 0DH, 0AH, '$'
    M_CARET DB ' ^ $'
    M_EQ    DB ' = $'
    M_OPS   DB '   multiplications: $'
    M_PLAIN DB '   the plain loop would need: $'
    M_OVER  DB 'more than sixteen bits will hold$'

; -----------------------------------------------------------------------------
; CODE SEGMENT
; -----------------------------------------------------------------------------
.CODE
START:
    MOV AX, @DATA
    MOV DS, AX

    LEA DX, M_TITLE
    CALL PRINT_MESSAGE

    XOR SI, SI
    MOV CX, HOWMANY

EACH_CASE:
    MOV AX, BASE_W[SI]
    MOV BASE_V, AX
    MOV AX, EXP_W[SI]
    MOV EXP_V, AX

    CALL POWER
    CALL REPORT

    ADD SI, 2
    LOOP EACH_CASE

    MOV AH, 4CH
    INT 21H

; -----------------------------------------------------------------------------
; POWER
;
; Raises BASE_V to EXP_V, leaving the answer in RESULT and the number of
; multiplications in OPS. TOOBIG is set if any product needs more than sixteen
; bits, which MUL reports by leaving something in DX.
; -----------------------------------------------------------------------------
POWER PROC
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX
    PUSH DI

    MOV AX, 1                           ; An empty product is one
    MOV RESULT, AX
    XOR AX, AX
    MOV OPS, AX
    MOV TOOBIG, AL

    MOV BX, BASE_V                      ; The base squared once per bit
    MOV CX, EXP_V                       ; The exponent, consumed a bit at a time
    XOR DI, DI                          ; Multiplications counted here

    JCXZ PW_DONE                        ; An exponent of zero leaves the one

    ; -------------------------------------------------------------------------
    ; THE EXPONENT IN BINARY SELECTS WHICH SQUARES TO KEEP. A SET BIT MEANS THE
    ; SQUARE OF THAT WEIGHT BELONGS IN THE ANSWER, WHICH IS WHY THE WORK GROWS
    ; WITH THE NUMBER OF BITS AND NOT WITH THE EXPONENT.
    ; -------------------------------------------------------------------------
PW_STEP:
    TEST CX, 1
    JZ  PW_SQUARE                       ; This weight is not wanted

    MOV AX, RESULT
    MUL BX
    OR  DX, DX
    JNZ PW_OVERFLOW
    MOV RESULT, AX
    INC DI

PW_SQUARE:
    SHR CX, 1
    JCXZ PW_DONE                        ; Nothing left to select, so do not square

    MOV AX, BX
    MUL BX
    OR  DX, DX
    JNZ PW_OVERFLOW
    MOV BX, AX
    INC DI
    JMP PW_STEP

PW_OVERFLOW:
    MOV AL, 1
    MOV TOOBIG, AL

PW_DONE:
    MOV OPS, DI

    POP DI
    POP DX
    POP CX
    POP BX
    POP AX
    RET
POWER ENDP

; -----------------------------------------------------------------------------
; REPORT
;
; Prints one line for the case just worked. The plain loop multiplies the base
; into a running product once for every step after the first, so its cost is
; the exponent less one.
; -----------------------------------------------------------------------------
REPORT PROC
    PUSH AX
    PUSH DX

    MOV AX, BASE_V
    CALL PRINT_DECIMAL
    LEA DX, M_CARET
    CALL PRINT_MESSAGE
    MOV AX, EXP_V
    CALL PRINT_DECIMAL
    LEA DX, M_EQ
    CALL PRINT_MESSAGE

    MOV AL, TOOBIG
    OR  AL, AL
    JZ  RP_VALUE

    LEA DX, M_OVER
    CALL PRINT_MESSAGE
    CALL NEWLINE
    JMP RP_END

RP_VALUE:
    MOV AX, RESULT
    CALL PRINT_DECIMAL

    LEA DX, M_OPS
    CALL PRINT_MESSAGE
    MOV AX, OPS
    CALL PRINT_DECIMAL

    LEA DX, M_PLAIN
    CALL PRINT_MESSAGE
    MOV AX, EXP_V
    DEC AX
    CALL PRINT_DECIMAL
    CALL NEWLINE

RP_END:
    POP DX
    POP AX
    RET
REPORT ENDP

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

; -----------------------------------------------------------------------------
; PRINT_MESSAGE
;
; Prints the dollar terminated string at DS:DX, leaving AX exactly as it was.
;
; Service 09H needs the service number in AH, and AH is the top half of AX. A
; caller that has just computed a result into AX and then sets AH for itself
; destroys that result: 500 becomes 09F4H, which prints as 2548. Doing the call
; in here, around a push and a pop, removes the trap for good.
; -----------------------------------------------------------------------------
PRINT_MESSAGE PROC
    PUSH AX

    MOV AH, 09H
    INT 21H

    POP AX
    RET
PRINT_MESSAGE ENDP

END START

; =============================================================================
; TECHNICAL NOTES
; =============================================================================
; 1. Why the count is smaller:
;    - The plain loop costs one multiplication for every step of the exponent.
;    - Squaring costs one for each bit, plus one for each bit that is set.
;    - The saving grows quickly, and it is what makes modular powers practical.
; 2. The final squaring is waste:
;    - Once the shifted exponent reaches zero no further square is ever used.
;    - Squaring anyway wastes work and can overflow on a value never needed.
;    - The test after the shift removes both faults at once.
; 3. Detecting the overflow:
;    - MUL always writes a thirty two bit product across DX and AX.
;    - DX left holding anything at all means the answer needs more than a word.
;    - Reporting that is honest, whereas keeping AX alone would quietly lie.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
