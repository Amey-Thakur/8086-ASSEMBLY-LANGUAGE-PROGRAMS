; Program: Sum of Array Elements
; Description: Calculate sum of all elements in an array
; Author: Amey Thakur

.MODEL SMALL
.STACK 100H

.DATA
    ARR DB 10H, 20H, 30H, 40H, 50H
    LEN EQU 5
    SUM DW ?

.CODE
MAIN PROC
    MOV AX, @DATA
    MOV DS, AX
    
    LEA SI, ARR
    MOV CL, LEN
    XOR AX, AX       ; Clear accumulator
    
SUM_LOOP:
    MOV BL, [SI]
    XOR BH, BH       ; Clear high byte
    ADD AX, BX       ; Add to sum
    INC SI
    DEC CL
    JNZ SUM_LOOP
    
    MOV SUM, AX      ; Store sum (F0H = 240 decimal)
    
    MOV AH, 4CH      ; Exit to DOS
    INT 21H
MAIN ENDP
END MAIN
