; Program: Recursive Procedure - Factorial
; Description: Calculate factorial using recursive procedure
; Author: Amey Thakur

.MODEL SMALL
.STACK 100H

.DATA
    NUM DW 5
    RESULT DW ?

.CODE
; Recursive Factorial Procedure
; Input: AX = number
; Output: AX = factorial
FACTORIAL PROC
    CMP AX, 1
    JLE BASE_CASE
    
    PUSH AX          ; Save current number
    DEC AX           ; n-1
    CALL FACTORIAL   ; Recursive call
    POP BX           ; Restore saved number
    MUL BX           ; AX = AX * BX
    RET
    
BASE_CASE:
    MOV AX, 1
    RET
FACTORIAL ENDP

MAIN PROC
    MOV AX, @DATA
    MOV DS, AX
    
    MOV AX, NUM      ; Load number
    CALL FACTORIAL   ; Calculate factorial
    MOV RESULT, AX   ; Store result (120 for 5!)
    
    MOV AH, 4CH      ; Exit to DOS
    INT 21H
MAIN ENDP
END MAIN
