; Program: Macro with Parameters
; Description: Macros that accept parameters
; Author: Amey Thakur

.MODEL SMALL
.STACK 100H

; Macro: Add two values and store result
ADD_VALUES MACRO VAL1, VAL2, RESULT
    MOV AX, VAL1
    ADD AX, VAL2
    MOV RESULT, AX
ENDM

; Macro: Multiply by power of 2 (using shift)
MULTIPLY_POW2 MACRO VALUE, POWER
    MOV AX, VALUE
    MOV CL, POWER
    SHL AX, CL
ENDM

.DATA
    NUM1 DW 100
    NUM2 DW 50
    SUM DW ?
    PRODUCT DW ?

.CODE
MAIN PROC
    MOV AX, @DATA
    MOV DS, AX
    
    ; Use ADD_VALUES macro
    ADD_VALUES NUM1, NUM2, SUM   ; SUM = 150
    
    ; Use MULTIPLY_POW2 macro (multiply by 8 = 2^3)
    MULTIPLY_POW2 NUM1, 3        ; AX = 800
    MOV PRODUCT, AX
    
    MOV AH, 4CH      ; Exit to DOS
    INT 21H
MAIN ENDP
END MAIN
