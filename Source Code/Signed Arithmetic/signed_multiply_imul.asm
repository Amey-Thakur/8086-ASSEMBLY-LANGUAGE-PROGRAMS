; =============================================================================
; TITLE: Signed Multiplication with IMUL
; DESCRIPTION: Multiplies signed values with IMUL and shows what MUL produces
;              for the same operands, which is not the same number.
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
    LEFT    DW -12
    RIGHT   DW 7
    M_IMUL  DB 'IMUL: -12 x 7 = $'
    M_MUL   DB 'MUL:  the same bits read unsigned = $'

; -----------------------------------------------------------------------------
; CODE SEGMENT
; -----------------------------------------------------------------------------
.CODE
START:
    MOV AX, @DATA
    MOV DS, AX

    ; -------------------------------------------------------------------------
    ; IMUL TREATS BOTH OPERANDS AS SIGNED AND PRODUCES A CORRECTLY SIGNED
    ; THIRTY TWO BIT PRODUCT IN DX:AX.
    ; -------------------------------------------------------------------------
    MOV AX, LEFT
    IMUL WORD PTR RIGHT

    MOV BX, AX
    LEA DX, M_IMUL
    MOV AH, 09H
    INT 21H
    MOV AX, BX
    CALL PRINT_SIGNED
    CALL NEWLINE

    ; -------------------------------------------------------------------------
    ; MUL READS THE SAME BITS AS UNSIGNED, SO -12 BECOMES 65524 AND THE
    ; PRODUCT IS AN ENTIRELY DIFFERENT NUMBER.
    ; -------------------------------------------------------------------------
    MOV AX, LEFT
    MUL WORD PTR RIGHT

    MOV BX, AX
    LEA DX, M_MUL
    MOV AH, 09H
    INT 21H
    MOV AX, BX
    CALL PRINT_DECIMAL
    CALL NEWLINE

    MOV AH, 4CH
    INT 21H

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
; 1. THE LOW HALVES CAN AGREE:
;    - For small values the bottom sixteen bits of both products often
;    - match, which is why using the wrong one can go unnoticed until
;    - the numbers grow.
; 2. CF AND OF AFTER IMUL:
;    - Both are clear when the whole product fitted in AX alone, so a
;    - JNC after IMUL is the test for whether DX can be ignored.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
