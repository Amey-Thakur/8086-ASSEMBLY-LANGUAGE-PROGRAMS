; =============================================================================
; TITLE: Count the Divisors of a Number
; DESCRIPTION: Counts how many numbers divide a value exactly, stopping at the
;              square root and counting each pair of factors together.
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
    NUMBER DW 36
    MSG    DB '36 has $'
    TAIL   DB ' divisors', 0DH, 0AH, '$'

; -----------------------------------------------------------------------------
; CODE SEGMENT
; -----------------------------------------------------------------------------
.CODE
START:
    MOV AX, @DATA
    MOV DS, AX

    MOV BX, NUMBER
    XOR DI, DI                          ; The count
    MOV SI, 1                           ; The divisor being tried

    ; -------------------------------------------------------------------------
    ; DIVISORS COME IN PAIRS: IF SI DIVIDES N THEN SO DOES N DIVIDED BY SI.
    ; SO ONLY DIVISORS UP TO THE SQUARE ROOT NEED TESTING, AND EACH ONE FOUND
    ; COUNTS TWICE, EXCEPT WHEN THE PAIR IS THE SAME NUMBER.
    ; -------------------------------------------------------------------------
COUNT_LOOP:
    MOV AX, SI
    MUL SI                              ; AX = SI squared
    CMP AX, BX
    JA  DONE_COUNTING

    MOV AX, BX
    XOR DX, DX
    DIV SI
    OR  DX, DX
    JNZ NEXT_TRY                        ; Not a divisor

    ADD DI, 2                           ; SI and its partner
    CMP AX, SI                          ; Unless they are the same
    JNE NEXT_TRY
    DEC DI

NEXT_TRY:
    INC SI
    JMP COUNT_LOOP

DONE_COUNTING:
    LEA DX, MSG
    MOV AH, 09H
    INT 21H
    MOV AX, DI
    CALL PRINT_DECIMAL
    LEA DX, TAIL
    MOV AH, 09H
    INT 21H

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
; 1. THE PERFECT SQUARE CASE:
;    - 36 is 6 times 6, so 6 would be counted twice. The test for the
;    - quotient equalling the divisor is what corrects it.
; 2. WHY STOP AT THE SQUARE ROOT:
;    - Past it, every divisor found is the partner of one already seen.
;    - For 36 that turns eighteen divisions into six.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
