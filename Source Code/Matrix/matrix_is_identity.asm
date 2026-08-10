; =============================================================================
; TITLE: Testing for the Identity Matrix
; DESCRIPTION: Checks that a matrix has ones on the diagonal and zeros
;              everywhere else, in a single pass over all its cells.
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
    N       EQU 3

    IDENT   DW  1,  0,  0
            DW  0,  1,  0
            DW  0,  0,  1

    ALMOST  DW  1,  0,  0
            DW  0,  1,  0
            DW  0,  1,  1

    M_ONE   DB 'The first matrix:', 0DH, 0AH, '$'
    M_TWO   DB 'The second matrix:', 0DH, 0AH, '$'
    M_YES   DB 'is the identity', 0DH, 0AH, '$'
    M_NO    DB 'is not the identity', 0DH, 0AH, '$'

; -----------------------------------------------------------------------------
; CODE SEGMENT
; -----------------------------------------------------------------------------
.CODE
START:
    MOV AX, @DATA
    MOV DS, AX

    LEA DX, M_ONE
    MOV AH, 09H
    INT 21H
    LEA SI, IDENT
    CALL SHOW_MATRIX
    LEA SI, IDENT
    CALL CHECK_IDENTITY

    LEA DX, M_TWO
    MOV AH, 09H
    INT 21H
    LEA SI, ALMOST
    CALL SHOW_MATRIX
    LEA SI, ALMOST
    CALL CHECK_IDENTITY

    MOV AH, 4CH
    INT 21H

; -----------------------------------------------------------------------------
; CHECK_IDENTITY
;
; SI points at an N by N matrix. Reports whether it is the identity.
; -----------------------------------------------------------------------------
CHECK_IDENTITY PROC
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX
    PUSH SI

    XOR BX, BX                          ; The row

CI_ROW:
    CMP BX, N
    JAE CI_IS_IDENTITY

    XOR CX, CX                          ; The column

CI_COL:
    CMP CX, N
    JAE CI_NEXT_ROW

    ; -------------------------------------------------------------------------
    ; ONE PASS OVER EVERY CELL. WHAT IT SHOULD CONTAIN DEPENDS ONLY ON WHETHER
    ; THE ROW AND THE COLUMN ARE THE SAME, SO THE EXPECTED VALUE IS DECIDED
    ; BEFORE THE CELL IS EVEN READ.
    ; -------------------------------------------------------------------------
    MOV AX, BX
    PUSH DX
    MOV DX, N
    MUL DX
    POP DX
    ADD AX, CX
    SHL AX, 1
    MOV DI, AX
    ADD DI, SI
    MOV AX, [DI]

    CMP BX, CX
    JE  CI_WANT_ONE

    OR  AX, AX                          ; Off the diagonal it must be zero
    JNZ CI_NOT_IDENTITY
    JMP CI_NEXT_COL

CI_WANT_ONE:
    CMP AX, 1                           ; On the diagonal it must be one
    JNE CI_NOT_IDENTITY

CI_NEXT_COL:
    INC CX
    JMP CI_COL

CI_NEXT_ROW:
    INC BX
    JMP CI_ROW

CI_IS_IDENTITY:
    LEA DX, M_YES
    JMP CI_REPORT

CI_NOT_IDENTITY:
    LEA DX, M_NO

CI_REPORT:
    MOV AH, 09H
    INT 21H

    POP SI
    POP DX
    POP CX
    POP BX
    POP AX
    RET
CHECK_IDENTITY ENDP

; -----------------------------------------------------------------------------
; SHOW_MATRIX
;
; Prints the N by N matrix at DS:SI, one row per line.
; -----------------------------------------------------------------------------
SHOW_MATRIX PROC
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX
    PUSH SI

    MOV BX, N                           ; Rows still to print

SM_ROW:
    MOV CX, N                           ; Columns in this row

SM_CELL:
    MOV AX, [SI]
    PUSH BX
    PUSH CX
    PUSH SI
    CALL PRINT_PADDED
    POP SI
    POP CX
    POP BX

    ADD SI, 2
    LOOP SM_CELL

    CALL NEWLINE
    DEC BX
    JNZ SM_ROW

    POP SI
    POP DX
    POP CX
    POP BX
    POP AX
    RET
SHOW_MATRIX ENDP

; -----------------------------------------------------------------------------
; PRINT_PADDED
;
; Prints AX right aligned in five columns, so the rows line up whatever the
; magnitude of the values.
; -----------------------------------------------------------------------------
FIELD EQU 6                             ; Columns each value is given

PRINT_PADDED PROC
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX

    MOV BX, AX                          ; Keep the value; AX is needed to count

    ; ---- how many characters will it occupy ---------------------------------
    MOV CX, 1                           ; Every value has at least one digit
    MOV AX, BX
    OR  AX, AX
    JNS PP_COUNT
    INC CX                              ; And a negative one needs a sign
    NEG AX                              ; Count the digits of the magnitude

PP_COUNT:
    CMP AX, 10
    JB  PP_PAD                          ; A single digit is left

    PUSH BX                             ; DIV needs BX as the divisor
    XOR DX, DX
    MOV BX, 10
    DIV BX                              ; One digit fewer
    POP BX
    INC CX
    JMP PP_COUNT

    ; ---- pad to the field width, then print --------------------------------
PP_PAD:
    MOV AX, FIELD
    CMP AX, CX
    JBE PP_VALUE                        ; Too wide to pad at all

    SUB AX, CX
    MOV CX, AX                          ; This many spaces

PP_SPACES:
    MOV DL, ' '
    MOV AH, 02H
    INT 21H
    LOOP PP_SPACES

PP_VALUE:
    MOV AX, BX
    CALL PRINT_SIGNED

    POP DX
    POP CX
    POP BX
    POP AX
    RET
PRINT_PADDED ENDP

; -----------------------------------------------------------------------------
; PRINT_SIGNED
;
; Prints AX as a signed value, with a minus sign when it is negative.
; -----------------------------------------------------------------------------
PRINT_SIGNED PROC
    PUSH AX
    PUSH DX

    OR  AX, AX
    JNS PS_POSITIVE                     ; Sign flag clear means not negative

    PUSH AX
    MOV DL, '-'
    MOV AH, 02H
    INT 21H
    POP AX
    NEG AX                              ; Print the magnitude

PS_POSITIVE:
    CALL PRINT_DECIMAL

    POP DX
    POP AX
    RET
PRINT_SIGNED ENDP

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
; 1. THE TEST IS THE SAME COMPARISON:
;    - Whether the row equals the column decides what the cell should
;    - hold, so one branch covers both cases and no separate diagonal
;    - pass is needed.
; 2. WHY IT MATTERS:
;    - Multiplying by the identity leaves a matrix unchanged, so it is
;    - the matrix equivalent of one. Verifying that an inverse is correct
;    - means multiplying and testing for exactly this.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
