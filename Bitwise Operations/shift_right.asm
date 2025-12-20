; Program: Shift Right (SHR) Operation
; Description: Shift bits right by specified count
; Author: Amey Thakur

.MODEL SMALL
.STACK 100H

.DATA
    NUM1 DB 80H      ; Number (10000000)
    RESULT DB ?      ; Result storage

.CODE
MAIN PROC
    MOV AX, @DATA
    MOV DS, AX
    
    MOV AL, NUM1     ; Load number
    MOV CL, 4        ; Shift count
    SHR AL, CL       ; Shift right by 4 (result: 00001000 = 08H)
    MOV RESULT, AL   ; Store result
    
    MOV AH, 4CH      ; Exit to DOS
    INT 21H
MAIN ENDP
END MAIN
