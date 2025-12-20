; Program: Nested Procedure Calls
; Description: Demonstrate nested procedure calls
; Author: Amey Thakur

.MODEL SMALL
.STACK 100H

.DATA
    NUM DW 10
    RESULT DW ?
    MSG DB 'Nested procedures executed$'

.CODE
; Inner procedure - doubles a number
DOUBLE_NUM PROC
    SHL AX, 1        ; Multiply by 2
    RET
DOUBLE_NUM ENDP

; Outer procedure - doubles twice (x4)
QUADRUPLE_NUM PROC
    CALL DOUBLE_NUM  ; First double
    CALL DOUBLE_NUM  ; Second double
    RET
QUADRUPLE_NUM ENDP

MAIN PROC
    MOV AX, @DATA
    MOV DS, AX
    
    MOV AX, NUM          ; Load number (10)
    CALL QUADRUPLE_NUM   ; Result = 40
    MOV RESULT, AX
    
    ; Display message
    LEA DX, MSG
    MOV AH, 09H
    INT 21H
    
    MOV AH, 4CH      ; Exit to DOS
    INT 21H
MAIN ENDP
END MAIN
