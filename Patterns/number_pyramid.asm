; Program: Print Number Pyramid
; Description: Print a pyramid with numbers
; Author: Amey Thakur

.MODEL SMALL
.STACK 100H

.DATA
    ROWS DB 5
    MSG DB 'Number Pyramid:', 0DH, 0AH, '$'

.CODE
MAIN PROC
    MOV AX, @DATA
    MOV DS, AX
    
    LEA DX, MSG
    MOV AH, 09H
    INT 21H
    
    MOV CL, ROWS
    MOV BL, 1        ; Current row number
    
ROW_LOOP:
    PUSH CX
    
    ; Print leading spaces
    MOV AL, ROWS
    SUB AL, BL
    MOV CL, AL
    CMP CL, 0
    JE PRINT_NUMS
    
SPACE_LOOP:
    MOV DL, ' '
    MOV AH, 02H
    INT 21H
    DEC CL
    JNZ SPACE_LOOP
    
PRINT_NUMS:
    ; Print numbers
    MOV CL, BL
    MOV DL, '1'
    
NUM_LOOP:
    MOV AH, 02H
    INT 21H
    INC DL
    DEC CL
    JNZ NUM_LOOP
    
    ; New line
    MOV DL, 0DH
    MOV AH, 02H
    INT 21H
    MOV DL, 0AH
    MOV AH, 02H
    INT 21H
    
    INC BL
    POP CX
    DEC CL
    JNZ ROW_LOOP
    
    MOV AH, 4CH
    INT 21H
MAIN ENDP
END MAIN
