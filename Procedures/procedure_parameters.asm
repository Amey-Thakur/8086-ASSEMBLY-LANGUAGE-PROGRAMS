; Program: Procedure with Parameters
; Description: Procedure that accepts parameters via registers
; Author: Amey Thakur

.MODEL SMALL
.STACK 100H

.DATA
    NUM1 DW 10
    NUM2 DW 20
    RESULT DW ?

.CODE
; Procedure to add two numbers
; Input: AX = first number, BX = second number
; Output: AX = sum
ADD_NUMS PROC
    ADD AX, BX
    RET
ADD_NUMS ENDP

MAIN PROC
    MOV AX, @DATA
    MOV DS, AX
    
    MOV AX, NUM1     ; First parameter
    MOV BX, NUM2     ; Second parameter
    CALL ADD_NUMS    ; Call procedure
    MOV RESULT, AX   ; Store result
    
    MOV AH, 4CH      ; Exit to DOS
    INT 21H
MAIN ENDP
END MAIN
