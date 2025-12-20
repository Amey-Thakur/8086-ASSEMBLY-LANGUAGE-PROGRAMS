; Program: Exchange Values Using Stack
; Description: Swap two register values using stack
; Author: Amey Thakur

.MODEL SMALL
.STACK 100H

.DATA
    VAL1 DW 1111H
    VAL2 DW 2222H

.CODE
MAIN PROC
    MOV AX, @DATA
    MOV DS, AX
    
    MOV AX, VAL1     ; AX = 1111H
    MOV BX, VAL2     ; BX = 2222H
    
    ; Swap using stack
    PUSH AX          ; Push 1111H
    PUSH BX          ; Push 2222H
    POP AX           ; AX = 2222H
    POP BX           ; BX = 1111H
    
    ; Store swapped values
    MOV VAL1, AX     ; VAL1 = 2222H
    MOV VAL2, BX     ; VAL2 = 1111H
    
    MOV AH, 4CH      ; Exit to DOS
    INT 21H
MAIN ENDP
END MAIN
