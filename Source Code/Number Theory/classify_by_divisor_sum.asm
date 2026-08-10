; =============================================================================
; TITLE: Abundant, Deficient or Perfect
; DESCRIPTION: Adds up the proper divisors of several numbers and classifies
;              each by how the total compares with the number itself.
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
    SAMPLES DW 6, 12, 15, 28
    HOWMANY EQU 4
    SEP     DB ': $'
    M_PERF  DB 'perfect', 0DH, 0AH, '$'
    M_ABUN  DB 'abundant', 0DH, 0AH, '$'
    M_DEFI  DB 'deficient', 0DH, 0AH, '$'

; -----------------------------------------------------------------------------
; CODE SEGMENT
; -----------------------------------------------------------------------------
.CODE
START:
    MOV AX, @DATA
    MOV DS, AX

    LEA SI, SAMPLES
    MOV CX, HOWMANY

EACH_NUMBER:
    MOV BX, [SI]

    PUSH CX
    PUSH SI

    MOV AX, BX
    CALL PRINT_DECIMAL
    LEA DX, SEP
    MOV AH, 09H
    INT 21H

    CALL SUM_PROPER_DIVISORS            ; BX in, DI out

    ; -------------------------------------------------------------------------
    ; THE THREE CLASSES ARE DECIDED BY ONE COMPARISON BETWEEN THE NUMBER AND
    ; THE SUM OF EVERYTHING THAT DIVIDES IT BELOW ITSELF.
    ; -------------------------------------------------------------------------
    CMP DI, BX
    JE  IS_PERFECT
    JA  IS_ABUNDANT

    LEA DX, M_DEFI
    JMP REPORT

IS_PERFECT:
    LEA DX, M_PERF
    JMP REPORT

IS_ABUNDANT:
    LEA DX, M_ABUN

REPORT:
    MOV AH, 09H
    INT 21H

    POP SI
    POP CX
    ADD SI, 2
    LOOP EACH_NUMBER

    MOV AH, 4CH
    INT 21H

; -----------------------------------------------------------------------------
; SUM_PROPER_DIVISORS
;
; Adds every divisor of BX below BX itself, and returns the total in DI.
; -----------------------------------------------------------------------------
SUM_PROPER_DIVISORS PROC
    PUSH AX
    PUSH BX
    PUSH DX
    PUSH SI

    XOR DI, DI
    MOV SI, 1

SPD_LOOP:
    CMP SI, BX
    JAE SPD_DONE

    MOV AX, BX
    XOR DX, DX
    DIV SI
    OR  DX, DX
    JNZ SPD_NEXT

    ADD DI, SI

SPD_NEXT:
    INC SI
    JMP SPD_LOOP

SPD_DONE:
    POP SI
    POP DX
    POP BX
    POP AX
    RET
SUM_PROPER_DIVISORS ENDP

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
; 1. PROPER MEANS BELOW ITSELF:
;    - Every number divides itself, so including it would make every
;    - number abundant. The divisors counted stop one short.
; 2. DI IS THE RETURN VALUE:
;    - The procedure saves everything it touches except DI, which is how
;    - it hands its answer back. Saving DI too would leave nowhere for
;    - the result to go.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
