; =============================================================================
; TITLE: The Determinant Of A Three By Three Matrix
; DESCRIPTION: Expansion along the first row, with the signed arithmetic done carefully because the minors can be negative.
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
    ; Two matrices: one with a determinant that is not zero, one singular.
    GRID_A  DW  6,  1,  1
            DW  4, -2,  5
            DW  2,  8,  7

    GRID_B  DW  1,  2,  3
            DW  4,  5,  6
            DW  7,  8,  9

    M_TITLE DB 'Determinants by expansion along the first row', 0DH, 0AH, '$'
    M_ROW   DB '  $'
    M_SPACE DB ' $'
    M_FIRST DB 0DH, 0AH, 'First matrix:', 0DH, 0AH, '$'
    M_SECND DB 0DH, 0AH, 'Second matrix:', 0DH, 0AH, '$'
    M_MINOR DB '  minor $'
    M_TIMES DB ' times $'
    M_SIGN  DB '  sign $'
    M_TERM  DB '  term $'
    M_DET   DB 0DH, 0AH, 'Determinant: $'
    M_SING  DB '   which is zero, so the matrix is singular.', 0DH, 0AH, '$'
    M_NOT   DB '   which is not zero, so the matrix is invertible.', 0DH, 0AH, '$'
    M_WHY   DB 0DH, 0AH
            DB 'The signs alternate plus, minus, plus along the row. Getting '
            DB 'that wrong gives an answer with the right magnitude and the '
            DB 'wrong sign.', 0DH, 0AH, '$'

; -----------------------------------------------------------------------------
; CODE SEGMENT
; -----------------------------------------------------------------------------
.CODE
START:
    MOV AX, @DATA
    MOV DS, AX

    LEA DX, M_TITLE
    CALL PRINT_MESSAGE

    LEA DX, M_FIRST
    CALL PRINT_MESSAGE
    LEA BX, GRID_A
    CALL SHOW_MATRIX
    LEA BX, GRID_A
    CALL DETERMINANT
    CALL REPORT

    LEA DX, M_SECND
    CALL PRINT_MESSAGE
    LEA BX, GRID_B
    CALL SHOW_MATRIX
    LEA BX, GRID_B
    CALL DETERMINANT
    CALL REPORT

    LEA DX, M_WHY
    CALL PRINT_MESSAGE

    MOV AH, 4CH
    INT 21H

; -----------------------------------------------------------------------------
; DETERMINANT
;
; The determinant of the three by three matrix at BX, returned in AX.
;
; Expanding along the first row:
;     det = a(ei - fh) - b(di - fg) + c(dh - eg)
;
; Every product here is signed, so IMUL is used throughout. MUL would treat a
; negative minor as a very large positive one and the answer would be nonsense.
; -----------------------------------------------------------------------------
DETERMINANT PROC
    PUSH BX
    PUSH CX
    PUSH DX
    PUSH SI
    PUSH DI

    XOR DI, DI                          ; The running determinant

    ; ---- a times (ei - fh) ---------------------------------------------------
    MOV AX, [BX+8]                      ; e
    IMUL WORD PTR [BX+16]               ; times i
    MOV SI, AX
    MOV AX, [BX+10]                     ; f
    IMUL WORD PTR [BX+14]               ; times h
    SUB SI, AX                          ; the minor

    MOV AX, [BX]                        ; a
    IMUL SI
    ADD DI, AX

    ; ---- minus b times (di - fg) --------------------------------------------
    MOV AX, [BX+6]                      ; d
    IMUL WORD PTR [BX+16]               ; times i
    MOV SI, AX
    MOV AX, [BX+10]                     ; f
    IMUL WORD PTR [BX+12]               ; times g
    SUB SI, AX

    MOV AX, [BX+2]                      ; b
    IMUL SI
    SUB DI, AX                          ; the alternating sign

    ; ---- plus c times (dh - eg) ---------------------------------------------
    MOV AX, [BX+6]                      ; d
    IMUL WORD PTR [BX+14]               ; times h
    MOV SI, AX
    MOV AX, [BX+8]                      ; e
    IMUL WORD PTR [BX+12]               ; times g
    SUB SI, AX

    MOV AX, [BX+4]                      ; c
    IMUL SI
    ADD DI, AX

    MOV AX, DI

    POP DI
    POP SI
    POP DX
    POP CX
    POP BX
    RET
DETERMINANT ENDP

; -----------------------------------------------------------------------------
; REPORT
;
; Prints the determinant in AX and says what it means.
; -----------------------------------------------------------------------------
REPORT PROC
    PUSH AX
    PUSH DX
    PUSH SI

    MOV SI, AX

    LEA DX, M_DET
    CALL PRINT_MESSAGE
    MOV AX, SI
    CALL PRINT_SIGNED

    CMP SI, 0
    JNE NOT_SINGULAR
    LEA DX, M_SING
    CALL PRINT_MESSAGE
    JMP REPORT_DONE

NOT_SINGULAR:
    LEA DX, M_NOT
    CALL PRINT_MESSAGE

REPORT_DONE:
    POP SI
    POP DX
    POP AX
    RET
REPORT ENDP

; -----------------------------------------------------------------------------
; SHOW_MATRIX
;
; Prints the three by three matrix at BX, one row to a line.
; -----------------------------------------------------------------------------
SHOW_MATRIX PROC
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX
    PUSH SI

    XOR SI, SI
    MOV CX, 3

EACH_ROW:
    PUSH CX
    LEA DX, M_ROW
    CALL PRINT_MESSAGE
    MOV CX, 3

EACH_CELL:
    PUSH BX
    ADD BX, SI
    MOV AX, [BX]
    POP BX
    CALL PRINT_SIGNED
    LEA DX, M_SPACE
    CALL PRINT_MESSAGE
    ADD SI, 2
    LOOP EACH_CELL

    CALL NEWLINE
    POP CX
    LOOP EACH_ROW

    POP SI
    POP DX
    POP CX
    POP BX
    POP AX
    RET
SHOW_MATRIX ENDP

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
; 1. IMUL, not MUL:
;    - The minors can be negative, and MUL would read a negative word as a large positive one.
;    - IMUL treats both operands as signed and produces a signed product.
;    - Choosing the wrong one gives an answer that looks plausible and is wrong.
; 2. The signs alternate:
;    - Plus, minus, plus along the first row, which is the cofactor sign pattern.
;    - It comes from minus one raised to the sum of the row and column indices.
;    - Getting it wrong yields the right magnitude with the wrong sign.
; 3. A zero determinant means singular:
;    - The second matrix has rows that are an arithmetic progression, so it is singular.
;    - Singular means the rows are linearly dependent and the matrix has no inverse.
;    - That is a genuine mathematical fact about the matrix, not an artefact of the arithmetic.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
