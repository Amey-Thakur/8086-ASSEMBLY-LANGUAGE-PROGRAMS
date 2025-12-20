; Program: Simple Calculator
; Description: Basic calculator with add, subtract, multiply, divide
; Author: Amey Thakur
; Keywords: 8086 calculator, assembly calculator, basic calculator

.MODEL SMALL
.STACK 100H

.DATA
    MENU DB 0DH, 0AH, '=== 8086 Calculator ===', 0DH, 0AH
         DB '1. Add', 0DH, 0AH
         DB '2. Subtract', 0DH, 0AH
         DB '3. Multiply', 0DH, 0AH
         DB '4. Divide', 0DH, 0AH
         DB '5. Exit', 0DH, 0AH
         DB 'Choice: $'
    
    MSG_NUM1 DB 0DH, 0AH, 'Enter first number: $'
    MSG_NUM2 DB 0DH, 0AH, 'Enter second number: $'
    MSG_RESULT DB 0DH, 0AH, 'Result: $'
    MSG_DIV_BY_ZERO DB 0DH, 0AH, 'Error: Division by zero!$'
    NEWLINE DB 0DH, 0AH, '$'
    
    NUM1 DW ?
    NUM2 DW ?
    RESULT DW ?

.CODE
MAIN PROC
    MOV AX, @DATA
    MOV DS, AX

MENU_LOOP:
    ; Display menu
    LEA DX, MENU
    MOV AH, 09H
    INT 21H
    
    ; Read choice
    MOV AH, 01H
    INT 21H
    
    CMP AL, '5'
    JE EXIT_PROG
    
    CMP AL, '1'
    JB MENU_LOOP
    CMP AL, '4'
    JA MENU_LOOP
    
    PUSH AX          ; Save choice
    
    ; Get first number
    LEA DX, MSG_NUM1
    MOV AH, 09H
    INT 21H
    CALL READ_NUM
    MOV NUM1, AX
    
    ; Get second number
    LEA DX, MSG_NUM2
    MOV AH, 09H
    INT 21H
    CALL READ_NUM
    MOV NUM2, AX
    
    POP AX           ; Restore choice
    
    ; Perform operation
    CMP AL, '1'
    JE DO_ADD
    CMP AL, '2'
    JE DO_SUB
    CMP AL, '3'
    JE DO_MUL
    CMP AL, '4'
    JE DO_DIV
    JMP MENU_LOOP
    
DO_ADD:
    MOV AX, NUM1
    ADD AX, NUM2
    MOV RESULT, AX
    JMP SHOW_RESULT
    
DO_SUB:
    MOV AX, NUM1
    SUB AX, NUM2
    MOV RESULT, AX
    JMP SHOW_RESULT
    
DO_MUL:
    MOV AX, NUM1
    MUL NUM2
    MOV RESULT, AX
    JMP SHOW_RESULT
    
DO_DIV:
    CMP NUM2, 0
    JE DIV_ZERO
    MOV AX, NUM1
    XOR DX, DX
    DIV NUM2
    MOV RESULT, AX
    JMP SHOW_RESULT
    
DIV_ZERO:
    LEA DX, MSG_DIV_BY_ZERO
    MOV AH, 09H
    INT 21H
    JMP MENU_LOOP
    
SHOW_RESULT:
    LEA DX, MSG_RESULT
    MOV AH, 09H
    INT 21H
    MOV AX, RESULT
    CALL PRINT_NUM
    JMP MENU_LOOP
    
EXIT_PROG:
    MOV AH, 4CH
    INT 21H
MAIN ENDP

; Read decimal number, result in AX
READ_NUM PROC
    PUSH BX
    PUSH CX
    XOR BX, BX
READ_LOOP:
    MOV AH, 01H
    INT 21H
    CMP AL, 0DH
    JE READ_DONE
    SUB AL, '0'
    XOR AH, AH
    PUSH AX
    MOV AX, BX
    MOV CX, 10
    MUL CX
    MOV BX, AX
    POP AX
    ADD BX, AX
    JMP READ_LOOP
READ_DONE:
    MOV AX, BX
    POP CX
    POP BX
    RET
READ_NUM ENDP

; Print decimal number in AX
PRINT_NUM PROC
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX
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
