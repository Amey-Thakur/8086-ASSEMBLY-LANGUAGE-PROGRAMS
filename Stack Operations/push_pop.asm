; Program: Stack PUSH and POP Operations
; Description: Demonstrate basic stack operations with PUSH and POP
; Author: Amey Thakur

.MODEL SMALL
.STACK 100H

.DATA
    MSG DB 'Stack Operations Demo$'

.CODE
MAIN PROC
    MOV AX, @DATA
    MOV DS, AX
    
    ; Push values onto stack
    MOV AX, 1234H
    PUSH AX          ; Push 1234H
    
    MOV BX, 5678H
    PUSH BX          ; Push 5678H
    
    MOV CX, 9ABCH
    PUSH CX          ; Push 9ABCH
    
    ; Pop values from stack (LIFO order)
    POP DX           ; DX = 9ABCH (last pushed)
    POP DX           ; DX = 5678H
    POP DX           ; DX = 1234H (first pushed)
    
    MOV AH, 4CH      ; Exit to DOS
    INT 21H
MAIN ENDP
END MAIN
