; Program: Clear Screen
; Description: Clear the screen using BIOS interrupt
; Author: Amey Thakur
; Keywords: 8086 clear screen, cls assembly, clear display

.MODEL SMALL
.STACK 100H

.CODE
MAIN PROC
    ; Method 1: Using INT 10H, AH=06H (Scroll Up)
    MOV AX, 0600H    ; AH=06 (scroll up), AL=00 (clear entire window)
    MOV BH, 07H      ; Attribute: white on black
    MOV CX, 0000H    ; Upper left corner (row 0, col 0)
    MOV DX, 184FH    ; Lower right corner (row 24, col 79)
    INT 10H
    
    ; Set cursor to top-left
    MOV AH, 02H      ; Set cursor position
    MOV BH, 00H      ; Page 0
    MOV DX, 0000H    ; Row 0, Column 0
    INT 10H
    
    ; Method 2: Set video mode (also clears screen)
    ; MOV AH, 00H
    ; MOV AL, 03H    ; 80x25 text mode
    ; INT 10H
    
    MOV AH, 4CH
    INT 21H
MAIN ENDP
END MAIN
