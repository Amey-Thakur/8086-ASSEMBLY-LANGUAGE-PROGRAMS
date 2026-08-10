; =============================================================================
; TITLE: Multiply a Matrix by a Scalar
; DESCRIPTION: Scales every element by the same value, and shows the shift that
;              replaces the multiplication when the scalar is a power of two.
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
    CELLS   EQU N * N
    SCALAR  EQU 7

    MAT_A   DW 1, 2, 3
            DW 4, 5, 6
            DW 7, 8, 9

    RESULT  DW CELLS DUP(0)
    DOUBLED DW CELLS DUP(0)

    M_A     DB 'A:', 0DH, 0AH, '$'
    M_C     DB 'A x 7:', 0DH, 0AH, '$'
    M_D     DB 'A x 4, by shifting:', 0DH, 0AH, '$'

; -----------------------------------------------------------------------------
; CODE SEGMENT
; -----------------------------------------------------------------------------
.CODE
START:
    MOV AX, @DATA
    MOV DS, AX

    LEA DX, M_A
    MOV AH, 09H
    INT 21H
    LEA SI, MAT_A
    CALL SHOW_MATRIX

    ; The general case: one multiplication per element
    XOR SI, SI
    MOV CX, CELLS

SCALE:
    MOV AX, MAT_A[SI]
    MOV BX, SCALAR
    MUL BX
    MOV RESULT[SI], AX

    ADD SI, 2
    LOOP SCALE

    LEA DX, M_C
    MOV AH, 09H
    INT 21H
    LEA SI, RESULT
    CALL SHOW_MATRIX

    ; -------------------------------------------------------------------------
    ; WHEN THE SCALAR IS A POWER OF TWO THE MULTIPLICATION IS A SHIFT, WHICH
    ; ON AN 8086 IS AROUND SEVEN TIMES FASTER PER ELEMENT.
    ; -------------------------------------------------------------------------
    XOR SI, SI
    MOV CX, CELLS

SHIFT_SCALE:
    MOV AX, MAT_A[SI]
    SHL AX, 2                           ; Four times
    MOV DOUBLED[SI], AX

    ADD SI, 2
    LOOP SHIFT_SCALE

    LEA DX, M_D
    MOV AH, 09H
    INT 21H
    LEA SI, DOUBLED
    CALL SHOW_MATRIX

    MOV AH, 4CH
    INT 21H

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
; 1. MUL DESTROYS DX:
;    - The high half of every product lands there whether it is wanted or
;    - not. Anything held in DX across a scaling loop is lost.
; 2. OVERFLOW IS SILENT:
;    - Only AX is stored, so a product above 65535 keeps its low half and
;    - the rest is discarded. Checking DX after each MUL is the only way
;    - to know it happened.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
