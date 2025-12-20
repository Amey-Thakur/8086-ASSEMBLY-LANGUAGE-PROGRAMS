; Program: VGA Graphics - Draw Rectangle
; Description: Draw a filled rectangle in VGA mode
; Author: Amey Thakur

.MODEL SMALL
.STACK 100H

.DATA
    X1 DW 50         ; Left
    Y1 DW 50         ; Top
    X2 DW 150        ; Right
    Y2 DW 100        ; Bottom
    COLOR DB 12      ; Light Red

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
    
    ; Calculate height
    MOV DX, Y2
    SUB DX, Y1       ; DX = height
    
    ; Calculate width
    MOV BX, X2
    SUB BX, X1       ; BX = width
    
    ; Starting Y position
    MOV AX, Y1
    
DRAW_ROW:
    PUSH AX
    PUSH DX
    
    ; Calculate row starting address
    MOV DX, 320
    MUL DX
    ADD AX, X1
    MOV DI, AX
    
    ; Draw one row
    MOV CX, BX
    MOV AL, COLOR
    REP STOSB
    
    POP DX
    POP AX
    INC AX           ; Next row
    DEC DX
    JNZ DRAW_ROW
    
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
