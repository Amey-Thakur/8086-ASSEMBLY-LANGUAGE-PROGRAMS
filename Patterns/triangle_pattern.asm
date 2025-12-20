; Program: Print Triangle Pattern
; Description: Print a right-angled triangle pattern using asterisks
; Author: Amey Thakur
; Keywords: 8086 pattern, star pattern, triangle pattern assembly

.MODEL SMALL
.STACK 100H

.DATA
    ROWS DB 5        ; Number of rows
    MSG DB 'Triangle Pattern:', 0DH, 0AH, '$'

.CODE
MAIN PROC
    MOV AX, @DATA
    MOV DS, AX
    
    ; Display message
    LEA DX, MSG
    MOV AH, 09H
    INT 21H
    
    MOV CL, ROWS     ; Row counter
    MOV BL, 1        ; Stars per row
    
ROW_LOOP:
    PUSH CX
    MOV CL, BL       ; Stars to print
    
STAR_LOOP:
    MOV DL, '*'
    MOV AH, 02H
    INT 21H
    DEC CL
    JNZ STAR_LOOP
    
    ; New line
    MOV DL, 0DH
    MOV AH, 02H
    INT 21H
    MOV DL, 0AH
    MOV AH, 02H
    INT 21H
    
    INC BL           ; More stars next row
    POP CX
    DEC CL
    JNZ ROW_LOOP
    
    MOV AH, 4CH
    INT 21H
MAIN ENDP
END MAIN

; Output:
; *
; **
; ***
; ****
; *****
