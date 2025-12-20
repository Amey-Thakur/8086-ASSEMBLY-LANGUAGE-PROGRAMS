; Program: Find Minimum in Array
; Description: Find the minimum value in an array of numbers
; Author: Amey Thakur

.MODEL SMALL
.STACK 100H

.DATA
    ARR DB 45H, 23H, 89H, 12H, 67H
    LEN EQU 5
    MIN DB ?
    MSG DB 'Minimum value found$'

.CODE
MAIN PROC
    MOV AX, @DATA
    MOV DS, AX
    
    LEA SI, ARR
    MOV CL, LEN
    MOV AL, [SI]     ; First element as initial min
    INC SI
    DEC CL
    
FIND_MIN:
    CMP AL, [SI]
    JB SKIP          ; Jump if AL < [SI]
    MOV AL, [SI]     ; Update min
SKIP:
    INC SI
    DEC CL
    JNZ FIND_MIN
    
    MOV MIN, AL      ; Store minimum (12H)
    
    MOV AH, 4CH      ; Exit to DOS
    INT 21H
MAIN ENDP
END MAIN
