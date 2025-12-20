; Program: Bitwise XOR Operation
; Description: Perform XOR operation on two 8-bit numbers
; Author: Amey Thakur

.MODEL SMALL
.STACK 100H

.DATA
    NUM1 DB 0AAH     ; First number (10101010)
    NUM2 DB 55H      ; Second number (01010101)
    RESULT DB ?      ; Result storage

.CODE
MAIN PROC
    MOV AX, @DATA
    MOV DS, AX
    
    MOV AL, NUM1     ; Load first number
    XOR AL, NUM2     ; Perform XOR operation
    MOV RESULT, AL   ; Store result (11111111 = FFH)
    
    MOV AH, 4CH      ; Exit to DOS
    INT 21H
MAIN ENDP
END MAIN
