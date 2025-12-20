; Program: Find Maximum in Array
; Description: Find the maximum value in an array of numbers
; Author: Amey Thakur

.MODEL SMALL
.STACK 100H

.DATA
    ARR DB 45H, 23H, 89H, 12H, 67H
    LEN EQU 5
    MAX DB ?
    MSG DB 'Maximum value found$'

.CODE
MAIN PROC
    MOV AX, @DATA
    MOV DS, AX
    
    LEA SI, ARR
    MOV CL, LEN
    MOV AL, [SI]     ; First element as initial max
    INC SI
    DEC CL
    
FIND_MAX:
    CMP AL, [SI]
    JA SKIP          ; Jump if AL > [SI]
    MOV AL, [SI]     ; Update max
SKIP:
    INC SI
    DEC CL
    JNZ FIND_MAX
    
    MOV MAX, AL      ; Store maximum
    
    MOV AH, 4CH      ; Exit to DOS
    INT 21H
MAIN ENDP
END MAIN
