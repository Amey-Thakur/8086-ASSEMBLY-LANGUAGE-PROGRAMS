; Program: Armstrong Number Check
; Description: Check if a number is an Armstrong number (sum of cubes = number for 3-digit)
; Author: Amey Thakur

.MODEL SMALL
.STACK 100H

.DATA
    NUM DW 153       ; 153 = 1^3 + 5^3 + 3^3 = 1 + 125 + 27
    SUM DW 0
    MSG_YES DB 'Number is ARMSTRONG$'
    MSG_NO DB 'Number is NOT Armstrong$'

.CODE
MAIN PROC
    MOV AX, @DATA
    MOV DS, AX
    
    MOV AX, NUM
    MOV BX, 10
    
EXTRACT_DIGIT:
    CMP AX, 0
    JE CHECK_RESULT
    
    XOR DX, DX
    DIV BX           ; AX = quotient, DX = digit
    
    PUSH AX          ; Save quotient
    
    ; Calculate digit^3
    MOV AX, DX
    MUL DX           ; AX = digit^2
    MUL DX           ; AX = digit^3
    
    ADD SUM, AX      ; Add to sum
    
    POP AX           ; Restore quotient
    JMP EXTRACT_DIGIT
    
CHECK_RESULT:
    MOV AX, SUM
    CMP AX, NUM
    JE IS_ARMSTRONG
    
    LEA DX, MSG_NO
    JMP DISPLAY
    
IS_ARMSTRONG:
    LEA DX, MSG_YES
    
DISPLAY:
    MOV AH, 09H
    INT 21H
    
    MOV AH, 4CH      ; Exit to DOS
    INT 21H
MAIN ENDP
END MAIN

; Armstrong numbers (3-digit): 153, 370, 371, 407
