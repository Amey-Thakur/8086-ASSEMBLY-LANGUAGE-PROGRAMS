; Program: Check Perfect Number
; Description: Check if a number is perfect (sum of divisors = number)
; Author: Amey Thakur

.MODEL SMALL
.STACK 100H

.DATA
    NUM DW 28        ; 28 = 1 + 2 + 4 + 7 + 14 (perfect number)
    SUM DW 0
    MSG_PERFECT DB 'Number is PERFECT$'
    MSG_NOT DB 'Number is NOT perfect$'

.CODE
MAIN PROC
    MOV AX, @DATA
    MOV DS, AX
    
    MOV BX, 1        ; Divisor starts at 1
    MOV CX, NUM
    SHR CX, 1        ; Only check up to NUM/2
    
CHECK_DIVISOR:
    MOV AX, NUM
    XOR DX, DX
    DIV BX           ; AX = NUM / BX, DX = remainder
    
    CMP DX, 0        ; If remainder is 0, BX is a divisor
    JNE NEXT_DIV
    
    ADD SUM, BX      ; Add divisor to sum
    
NEXT_DIV:
    INC BX
    CMP BX, NUM
    JL CHECK_DIVISOR
    
    ; Compare sum with number
    MOV AX, SUM
    CMP AX, NUM
    JE IS_PERFECT
    
    LEA DX, MSG_NOT
    JMP DISPLAY
    
IS_PERFECT:
    LEA DX, MSG_PERFECT
    
DISPLAY:
    MOV AH, 09H
    INT 21H
    
    MOV AH, 4CH      ; Exit to DOS
    INT 21H
MAIN ENDP
END MAIN

; Perfect numbers: 6, 28, 496, 8128...
