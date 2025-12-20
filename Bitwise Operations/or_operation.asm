; Program: Bitwise OR Operation
; Description: Perform OR operation on two 8-bit numbers
; Author: Amey Thakur

.MODEL SMALL
.STACK 100H

.DATA
    NUM1 DB 0FH      ; First number (00001111)
    NUM2 DB 0F0H     ; Second number (11110000)
    RESULT DB ?      ; Result storage

.CODE
MAIN PROC
    MOV AX, @DATA
    MOV DS, AX
    
    MOV AL, NUM1     ; Load first number
    OR AL, NUM2      ; Perform OR operation
    MOV RESULT, AL   ; Store result (11111111 = FFH)
    
    MOV AH, 4CH      ; Exit to DOS
    INT 21H
MAIN ENDP
END MAIN
