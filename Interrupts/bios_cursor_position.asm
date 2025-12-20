; Program: BIOS Interrupt 10H - Set Cursor Position
; Description: Position cursor on screen using INT 10H, AH=02H
; Author: Amey Thakur

.MODEL SMALL
.STACK 100H

.DATA
    MSG DB 'Cursor positioned at row 10, column 20!$'

.CODE
MAIN PROC
    MOV AX, @DATA
    MOV DS, AX
    
    ; Set cursor position
    MOV AH, 02H      ; BIOS function: set cursor position
    MOV BH, 00H      ; Page number
    MOV DH, 10       ; Row (0-24)
    MOV DL, 20       ; Column (0-79)
    INT 10H          ; Call BIOS interrupt
    
    ; Display message at cursor position
    LEA DX, MSG
    MOV AH, 09H
    INT 21H
    
    MOV AH, 4CH      ; Exit to DOS
    INT 21H
MAIN ENDP
END MAIN
