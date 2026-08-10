; =============================================================================
; TITLE: Sums of Squares and Cubes
; DESCRIPTION: Adds the squares and the cubes of the first ten numbers, and
;              checks the striking identity between the cubes and the plain sum.
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
    LIMIT    EQU 10
    M_SUM    DB 'Sum of 1 to 10:        $'
    M_SQ     DB 'Sum of the squares:    $'
    M_CUBE   DB 'Sum of the cubes:      $'
    M_IDENT  DB 'The sum of the cubes is the plain sum squared.', 0DH, 0AH, '$'
    M_NOT    DB 'The identity did not hold.', 0DH, 0AH, '$'

; -----------------------------------------------------------------------------
; CODE SEGMENT
; -----------------------------------------------------------------------------
.CODE
START:
    MOV AX, @DATA
    MOV DS, AX

    XOR BX, BX                          ; Plain sum
    XOR SI, SI                          ; Sum of squares
    XOR DI, DI                          ; Sum of cubes
    MOV CX, LIMIT

ACCUMULATE:
    MOV AX, LIMIT
    SUB AX, CX
    INC AX                              ; AX counts 1 upward as CX counts down

    ADD BX, AX
    PUSH AX

    MUL AX                              ; The square
    ADD SI, AX
    MOV DX, AX

    POP AX
    PUSH AX
    MUL DX                              ; The cube: value times its square
    ADD DI, AX
    POP AX

    LOOP ACCUMULATE

    LEA DX, M_SUM
    MOV AH, 09H
    INT 21H
    MOV AX, BX
    CALL PRINT_DECIMAL
    CALL NEWLINE

    LEA DX, M_SQ
    MOV AH, 09H
    INT 21H
    MOV AX, SI
    CALL PRINT_DECIMAL
    CALL NEWLINE

    LEA DX, M_CUBE
    MOV AH, 09H
    INT 21H
    MOV AX, DI
    CALL PRINT_DECIMAL
    CALL NEWLINE

    ; -------------------------------------------------------------------------
    ; THE SUM OF THE FIRST N CUBES EQUALS THE SQUARE OF THE SUM OF THE FIRST
    ; N NUMBERS. FOR TEN THAT IS 55 SQUARED, WHICH IS 3025.
    ; -------------------------------------------------------------------------
    MOV AX, BX
    MUL BX
    CMP AX, DI
    JNE NOT_EQUAL

    LEA DX, M_IDENT
    JMP REPORT

NOT_EQUAL:
    LEA DX, M_NOT

REPORT:
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
; 1. DERIVING THE COUNTER:
;    - CX counts down because LOOP requires it, but the calculation needs
;    - the value counting up. Subtracting from the limit gives one from
;    - the other without a second register.
; 2. THE CUBE IN TWO STEPS:
;    - The square is already in hand from the previous multiplication, so
;    - the cube costs one more MUL rather than two.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
