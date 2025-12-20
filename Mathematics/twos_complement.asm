; Program: Negate Number (2's Complement)
; Description: Calculate 2's complement of a number
; Author: Amey Thakur

.MODEL SMALL
.STACK 100H

.DATA
    NUM DW 25
    NEG_NUM DW ?
    MSG DB 'Negation completed$'

.CODE
MAIN PROC
    MOV AX, @DATA
    MOV DS, AX
    
    MOV AX, NUM
    NEG AX           ; 2's complement (negate)
    MOV NEG_NUM, AX  ; -25 in 2's complement
    
    ; Alternative method (manual):
    ; NOT AX          ; 1's complement
    ; INC AX          ; Add 1 = 2's complement
    
    LEA DX, MSG
    MOV AH, 09H
    INT 21H
    
    MOV AH, 4CH      ; Exit to DOS
    INT 21H
MAIN ENDP
END MAIN
