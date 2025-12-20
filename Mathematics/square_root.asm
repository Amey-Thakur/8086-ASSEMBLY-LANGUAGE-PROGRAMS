; Program: Square Root (Integer)
; Description: Calculate integer square root of a number
; Author: Amey Thakur

.MODEL SMALL
.STACK 100H

.DATA
    NUM DW 144       ; Number to find square root of
    ROOT DW ?
    MSG DB 'Square root calculated$'

.CODE
MAIN PROC
    MOV AX, @DATA
    MOV DS, AX
    
    MOV BX, NUM
    MOV CX, 1        ; Starting guess
    
    ; Newton's method for integer square root
    ; Or simple iteration: find largest n where n*n <= NUM
FIND_ROOT:
    MOV AX, CX
    MUL CX           ; AX = CX * CX
    CMP AX, BX
    JA FOUND         ; If CX*CX > NUM, previous was the answer
    MOV ROOT, CX     ; Save current value
    INC CX
    JMP FIND_ROOT
    
FOUND:
    ; ROOT now contains square root of 144 = 12
    
    LEA DX, MSG
    MOV AH, 09H
    INT 21H
    
    MOV AH, 4CH      ; Exit to DOS
    INT 21H
MAIN ENDP
END MAIN
