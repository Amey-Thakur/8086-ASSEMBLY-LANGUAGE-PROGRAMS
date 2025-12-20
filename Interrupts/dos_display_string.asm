; Program: DOS Interrupt 21H - Display String
; Description: Display a string using INT 21H, AH=09H
; Author: Amey Thakur

.MODEL SMALL
.STACK 100H

.DATA
    MSG DB 'Hello, 8086 Assembly World!', 0DH, 0AH, '$'

.CODE
MAIN PROC
    MOV AX, @DATA
    MOV DS, AX
    
    LEA DX, MSG      ; Load address of string
    MOV AH, 09H      ; DOS function: display string
    INT 21H          ; Call DOS interrupt
    
    MOV AH, 4CH      ; Exit to DOS
    INT 21H
MAIN ENDP
END MAIN
