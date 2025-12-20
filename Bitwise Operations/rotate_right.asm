; Program: Rotate Right (ROR) Operation
; Description: Rotate bits right by specified count
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
    ROR AL, CL       ; Rotate right by 1 (result: 11000000 = C0H)
    MOV RESULT, AL   ; Store result
    
    MOV AH, 4CH      ; Exit to DOS
    INT 21H
MAIN ENDP
END MAIN
