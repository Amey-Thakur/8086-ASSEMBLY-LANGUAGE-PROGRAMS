; Program: Rotate Left (ROL) Operation
; Description: Rotate bits left by specified count
; Author: Amey Thakur

.MODEL SMALL
.STACK 100H

.DATA
    NUM1 DB 81H      ; Number (10000001)
    RESULT DB ?      ; Result storage

.CODE
MAIN PROC
    MOV AX, @DATA
    MOV DS, AX
    
    MOV AL, NUM1     ; Load number
    MOV CL, 1        ; Rotate count
    ROL AL, CL       ; Rotate left by 1 (result: 00000011 = 03H)
    MOV RESULT, AL   ; Store result
    
    MOV AH, 4CH      ; Exit to DOS
    INT 21H
MAIN ENDP
END MAIN
