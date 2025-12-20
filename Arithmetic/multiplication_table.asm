; Program: Multiplication Table Generator
; Description: Generate and display multiplication table
; Author: Amey Thakur
; Keywords: 8086 multiplication table, times table

.MODEL SMALL
.STACK 100H

.DATA
    NUM DB 7         ; Multiplication table for 7
    MSG1 DB 'Multiplication Table of $'
    MSG_X DB ' x $'
    MSG_EQ DB ' = $'
    NEWLINE DB 0DH, 0AH, '$'

.CODE
MAIN PROC
    MOV AX, @DATA
    MOV DS, AX
    
    ; Display header
    LEA DX, MSG1
    MOV AH, 09H
    INT 21H
    
    MOV AL, NUM
    CALL PRINT_NUM
    
    LEA DX, NEWLINE
    MOV AH, 09H
    INT 21H
    LEA DX, NEWLINE
    MOV AH, 09H
    INT 21H
    
    ; Generate table (1 to 10)
    MOV CL, 10       ; Counter
    MOV BL, 1        ; Multiplier
    
TABLE_LOOP:
    PUSH CX
    
    ; Print NUM
    MOV AL, NUM
    CALL PRINT_NUM
    
    ; Print " x "
    LEA DX, MSG_X
    MOV AH, 09H
    INT 21H
    
    ; Print multiplier
    MOV AL, BL
    CALL PRINT_NUM
    
    ; Print " = "
    LEA DX, MSG_EQ
    MOV AH, 09H
    INT 21H
    
    ; Calculate and print result
    MOV AL, NUM
    MUL BL           ; AX = NUM * BL
    CALL PRINT_NUM
    
    ; New line
    LEA DX, NEWLINE
    MOV AH, 09H
    INT 21H
    
    INC BL
    POP CX
    DEC CL
    JNZ TABLE_LOOP
    
    MOV AH, 4CH
    INT 21H
MAIN ENDP

; Print AL as decimal
PRINT_NUM PROC
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX
    
    XOR AH, AH
    XOR CX, CX
    MOV BX, 10
    
DIV_LOOP:
    XOR DX, DX
    DIV BX
    PUSH DX
    INC CX
    CMP AX, 0
    JNE DIV_LOOP
    
PRINT_LOOP:
    POP DX
    ADD DL, '0'
    MOV AH, 02H
    INT 21H
    LOOP PRINT_LOOP
    
    POP DX
    POP CX
    POP BX
    POP AX
    RET
PRINT_NUM ENDP

END MAIN
