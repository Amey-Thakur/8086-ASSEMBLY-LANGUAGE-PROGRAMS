; Program: DOS Interrupt 21H - Display Character
; Description: Display a single character using INT 21H, AH=02H
; Author: Amey Thakur

.MODEL SMALL
.STACK 100H

.CODE
MAIN PROC
    MOV DL, 'A'      ; Character to display
    MOV AH, 02H      ; DOS function: display character
    INT 21H          ; Call DOS interrupt
    
    MOV AH, 4CH      ; Exit to DOS
    INT 21H
MAIN ENDP
END MAIN
