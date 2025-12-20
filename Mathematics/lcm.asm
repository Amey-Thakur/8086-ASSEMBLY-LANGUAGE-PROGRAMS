; Program: LCM of Two Numbers
; Description: Calculate Least Common Multiple using GCD
; Author: Amey Thakur

.MODEL SMALL
.STACK 100H

.DATA
    NUM1 DW 12
    NUM2 DW 18
    GCD_VAL DW ?
    LCM_VAL DW ?
    MSG DB 'LCM calculated$'

.CODE
MAIN PROC
    MOV AX, @DATA
    MOV DS, AX
    
    ; First find GCD
    MOV AX, NUM1
    MOV BX, NUM2
    
GCD_LOOP:
    CMP BX, 0
    JE GCD_DONE
    XOR DX, DX
    DIV BX
    MOV AX, BX
    MOV BX, DX
    JMP GCD_LOOP
    
GCD_DONE:
    MOV GCD_VAL, AX
    
    ; LCM = (NUM1 * NUM2) / GCD
    MOV AX, NUM1
    MUL NUM2         ; DX:AX = NUM1 * NUM2
    DIV GCD_VAL      ; AX = result / GCD
    MOV LCM_VAL, AX  ; LCM of 12 and 18 = 36
    
    LEA DX, MSG
    MOV AH, 09H
    INT 21H
    
    MOV AH, 4CH      ; Exit to DOS
    INT 21H
MAIN ENDP
END MAIN
