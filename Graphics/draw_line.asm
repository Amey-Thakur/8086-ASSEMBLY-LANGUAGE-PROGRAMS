; Program: VGA Graphics - Draw Line
; Description: Draw a horizontal line in VGA mode
; Author: Amey Thakur

.MODEL SMALL
.STACK 100H

.DATA
    X_START DW 50
    X_END DW 270
    Y_POS DW 100
    COLOR DB 14      ; Yellow

.CODE
MAIN PROC
    MOV AX, @DATA
    MOV DS, AX
    
    ; Set VGA mode 13H
    MOV AH, 00H
    MOV AL, 13H
    INT 10H
    
    ; Set ES to video segment
    MOV AX, 0A000H
    MOV ES, AX
    
    ; Calculate starting address
    MOV AX, Y_POS
    MOV BX, 320
    MUL BX
    ADD AX, X_START
    MOV DI, AX
    
    ; Calculate line length
    MOV CX, X_END
    SUB CX, X_START
    
    ; Draw horizontal line
    MOV AL, COLOR
    REP STOSB
    
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
