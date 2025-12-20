; Program: Text Mode - Colored Text
; Description: Display colored text in text mode
; Author: Amey Thakur

.MODEL SMALL
.STACK 100H

.DATA
    MSG DB 'Colored Text Demo!'

.CODE
MAIN PROC
    MOV AX, @DATA
    MOV DS, AX
    
    ; Set text mode 80x25
    MOV AH, 00H
    MOV AL, 03H
    INT 10H
    
    ; Set ES to video segment (text mode)
    MOV AX, 0B800H
    MOV ES, AX
    
    ; Position: row 12, column 30
    ; Offset = (row * 80 + column) * 2
    MOV DI, (12 * 80 + 30) * 2
    
    ; Display string with different colors
    LEA SI, MSG
    MOV CX, 18       ; String length
    MOV BL, 0        ; Color counter
    
PRINT_LOOP:
    LODSB            ; Get character
    MOV ES:[DI], AL  ; Store character
    INC DI
    
    ; Set color (foreground + background)
    ; Bits 0-3: foreground, Bits 4-6: background, Bit 7: blink
    MOV AL, BL
    AND AL, 0FH      ; Use only foreground colors (0-15)
    OR AL, 10H       ; Blue background
    MOV ES:[DI], AL
    INC DI
    
    INC BL           ; Next color
    LOOP PRINT_LOOP
    
    ; Wait for keypress
    MOV AH, 00H
    INT 16H
    
    MOV AH, 4CH      ; Exit to DOS
    INT 21H
MAIN ENDP
END MAIN

; Color Reference:
; 0 = Black,  1 = Blue,    2 = Green,   3 = Cyan
; 4 = Red,    5 = Magenta, 6 = Brown,   7 = Light Gray
; 8 = Dark Gray, 9 = Light Blue, 10 = Light Green, 11 = Light Cyan
; 12 = Light Red, 13 = Light Magenta, 14 = Yellow, 15 = White
