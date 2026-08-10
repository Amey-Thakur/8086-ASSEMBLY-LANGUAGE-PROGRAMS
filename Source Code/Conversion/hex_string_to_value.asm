; =============================================================================
; TITLE: Reading Hexadecimal Text
; DESCRIPTION: Turns a string of hexadecimal digits into a value, accepting
;              either case and stopping at anything else.
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
    ONE     DB 'B4D2', 0
    TWO     DB 'ffff', 0
    THREE   DB '1F', 0
    FOUR    DB '0', 0

    M_FROM  DB 'The text "$'
    M_IS    DB '" is the value $'

; -----------------------------------------------------------------------------
; CODE SEGMENT
; -----------------------------------------------------------------------------
.CODE
START:
    MOV AX, @DATA
    MOV DS, AX

    LEA SI, ONE
    CALL SHOW
    LEA SI, TWO
    CALL SHOW
    LEA SI, THREE
    CALL SHOW
    LEA SI, FOUR
    CALL SHOW

    MOV AH, 4CH
    INT 21H

; -----------------------------------------------------------------------------
; SHOW
; -----------------------------------------------------------------------------
SHOW PROC
    PUSH SI

    LEA DX, M_FROM
    MOV AH, 09H
    INT 21H

    POP SI
    PUSH SI

PRINT_IT:
    MOV DL, [SI]
    OR  DL, DL
    JZ  PRINTED
    MOV AH, 02H
    INT 21H
    INC SI
    JMP PRINT_IT

PRINTED:
    LEA DX, M_IS
    MOV AH, 09H
    INT 21H

    POP SI
    CALL READ_HEX
    CALL PRINT_DECIMAL
    CALL NEWLINE
    RET
SHOW ENDP

; -----------------------------------------------------------------------------
; READ_HEX
;
; SI points at a zero terminated hexadecimal string. Value returned in AX.
; -----------------------------------------------------------------------------
READ_HEX PROC
    PUSH BX
    PUSH CX
    PUSH SI

    XOR BX, BX

RH_LOOP:
    MOV AL, [SI]

    ; -------------------------------------------------------------------------
    ; THREE RANGES TO ACCEPT: THE DIGITS, THE CAPITALS AND THE LOWER CASE
    ; LETTERS. EACH IS BROUGHT DOWN TO A VALUE BETWEEN NOUGHT AND FIFTEEN BY
    ; SUBTRACTING WHERE ITS RANGE BEGINS.
    ; -------------------------------------------------------------------------
    CMP AL, '0'
    JB  RH_DONE
    CMP AL, '9'
    JBE RH_DIGIT

    CMP AL, 'A'
    JB  RH_DONE
    CMP AL, 'F'
    JBE RH_UPPER

    CMP AL, 'a'
    JB  RH_DONE
    CMP AL, 'f'
    JBE RH_LOWER
    JMP RH_DONE

RH_DIGIT:
    SUB AL, '0'
    JMP RH_ACCUMULATE

RH_UPPER:
    SUB AL, 'A' - 10
    JMP RH_ACCUMULATE

RH_LOWER:
    SUB AL, 'a' - 10

RH_ACCUMULATE:
    SHL BX, 4                           ; Sixteen times, as one shift
    XOR AH, AH
    ADD BX, AX

    INC SI
    JMP RH_LOOP

RH_DONE:
    MOV AX, BX

    POP SI
    POP CX
    POP BX
    RET
READ_HEX ENDP

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
; 1. SUBTRACTING THE RIGHT OFFSET:
;    - 'A' has to become ten, so 'A' less ten is what is subtracted. The
;    - assembler works that out, which is clearer than writing 55 and
;    - leaving the reader to discover why.
; 2. FOUR BITS PER DIGIT:
;    - Hexadecimal is exactly four bits, so the accumulation is a shift of
;    - four rather than a multiplication. That is the whole reason it is
;    - used to write binary values.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
