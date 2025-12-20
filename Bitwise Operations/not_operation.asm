; Program: Bitwise NOT Operation
; Description: Perform NOT (complement) operation on an 8-bit number
; Author: Amey Thakur

.MODEL SMALL
.STACK 100H

.DATA
    NUM1 DB 0FH      ; Number (00001111)
    RESULT DB ?      ; Result storage

.CODE
MAIN PROC
    MOV AX, @DATA
    MOV DS, AX
    
    MOV AL, NUM1     ; Load number
    NOT AL           ; Perform NOT operation (1's complement)
    MOV RESULT, AL   ; Store result (11110000 = F0H)
    
    MOV AH, 4CH      ; Exit to DOS
    INT 21H
MAIN ENDP
END MAIN
