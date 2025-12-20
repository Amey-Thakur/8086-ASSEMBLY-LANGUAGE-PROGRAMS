; Program: Conditional Assembly Macros
; Description: Macros with conditional assembly directives
; Author: Amey Thakur

.MODEL SMALL
.STACK 100H

; Macro with conditional assembly
MOVE_DATA MACRO DEST, SOURCE
    IF TYPE SOURCE EQ 1      ; If byte
        MOV AL, SOURCE
        MOV DEST, AL
    ELSE                     ; If word
        MOV AX, SOURCE
        MOV DEST, AX
    ENDIF
ENDM

; Macro: Check if zero
CHECK_ZERO MACRO VALUE, ZERO_MSG, NONZERO_MSG
    MOV AX, VALUE
    CMP AX, 0
    JNE NOT_ZERO
    LEA DX, ZERO_MSG
    JMP DISPLAY
NOT_ZERO:
    LEA DX, NONZERO_MSG
DISPLAY:
    MOV AH, 09H
    INT 21H
ENDM

.DATA
    BYTE_VAL DB 10
    WORD_VAL DW 1000
    RESULT_B DB ?
    RESULT_W DW ?
    TEST_VAL DW 0
    MSG_ZERO DB 'Value is zero$'
    MSG_NONZERO DB 'Value is not zero$'

.CODE
MAIN PROC
    MOV AX, @DATA
    MOV DS, AX
    
    ; Use CHECK_ZERO macro
    CHECK_ZERO TEST_VAL, MSG_ZERO, MSG_NONZERO
    
    MOV AH, 4CH      ; Exit to DOS
    INT 21H
MAIN ENDP
END MAIN
