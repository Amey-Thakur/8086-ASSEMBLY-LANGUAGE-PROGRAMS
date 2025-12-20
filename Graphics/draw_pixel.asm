; Program: VGA Graphics - Draw Pixel
; Description: Draw a single pixel in VGA mode 13H (320x200 256 colors)
; Author: Amey Thakur

.MODEL SMALL
.STACK 100H

.DATA
    X_POS DW 160     ; Center X
    Y_POS DW 100     ; Center Y
    COLOR DB 15      ; White color

.CODE
MAIN PROC
    MOV AX, @DATA
    MOV DS, AX
    
    ; Set VGA mode 13H (320x200, 256 colors)
    MOV AH, 00H
    MOV AL, 13H
    INT 10H
    
    ; Calculate video memory address
    ; Address = Y * 320 + X
    MOV AX, Y_POS
    MOV BX, 320
    MUL BX           ; AX = Y * 320
    ADD AX, X_POS    ; AX = Y * 320 + X
    
    ; Set ES to video segment
    MOV BX, 0A000H
    MOV ES, BX
    
    ; Draw pixel
    MOV DI, AX
    MOV AL, COLOR
    MOV ES:[DI], AL
    
    ; Wait for keypress
    MOV AH, 00H
    INT 16H
    
    ; Return to text mode
    MOV AH, 00H
    MOV AL, 03H
    INT 10H
    
    MOV AH, 4CH      ; Exit to DOS
    INT 21H
MAIN ENDP
END MAIN
