; Program: Print Inverted Triangle Pattern
; Description: Print an inverted triangle pattern
; Author: Amey Thakur

.MODEL SMALL
.STACK 100H

.DATA
    ROWS DB 5
    MSG DB 'Inverted Triangle:', 0DH, 0AH, '$'

.CODE
MAIN PROC
    MOV AX, @DATA
    MOV DS, AX
    
    LEA DX, MSG
    MOV AH, 09H
    INT 21H
    
    MOV CL, ROWS
    MOV BL, ROWS     ; Start with max stars
    
ROW_LOOP:
    PUSH CX
    MOV CL, BL
    
STAR_LOOP:
    MOV DL, '*'
    MOV AH, 02H
    INT 21H
    DEC CL
    JNZ STAR_LOOP
    
    MOV DL, 0DH
    MOV AH, 02H
    INT 21H
    MOV DL, 0AH
    MOV AH, 02H
    INT 21H
    
    DEC BL           ; Less stars next row
    POP CX
    DEC CL
    JNZ ROW_LOOP
    
    MOV AH, 4CH
    INT 21H
MAIN ENDP
END MAIN

; Output:
; *****
; ****
; ***
; **
; *
