; Program: Shift Left (SHL) Operation
; Description: Shift bits left by specified count
; Author: Amey Thakur

.MODEL SMALL
.STACK 100H

.DATA
    NUM1 DB 01H      ; Number (00000001)
    RESULT DB ?      ; Result storage

.CODE
MAIN PROC
    MOV AX, @DATA
    MOV DS, AX
    
    MOV AL, NUM1     ; Load number
    MOV CL, 4        ; Shift count
    SHL AL, CL       ; Shift left by 4 (result: 00010000 = 10H)
    MOV RESULT, AL   ; Store result
    
    MOV AH, 4CH      ; Exit to DOS
    INT 21H
MAIN ENDP
END MAIN
