; Program: For Loop Structure
; Description: Implement for loop logic in assembly
; Author: Amey Thakur

.MODEL SMALL
.STACK 100H

.DATA
    MSG DB 'Multiplication Table of 5:', 0DH, 0AH, '$'
    NEWLINE DB 0DH, 0AH, '$'
    TIMES_STR DB ' x 5 = $'
    NUM DW 5

.CODE
MAIN PROC
    MOV AX, @DATA
    MOV DS, AX
    
    ; Display header
    LEA DX, MSG
    MOV AH, 09H
    INT 21H
    
    ; FOR i = 1 TO 10
    MOV CX, 10       ; Loop counter
    MOV BX, 1        ; i = 1
    
FOR_LOOP:
    PUSH CX
    
    ; Print i
    MOV AX, BX
    CALL PRINT_NUM
    
    ; Print " x 5 = "
    LEA DX, TIMES_STR
    MOV AH, 09H
    INT 21H
    
    ; Calculate and print i * 5
    MOV AX, BX
    MUL NUM
    CALL PRINT_NUM
    
    ; Newline
    LEA DX, NEWLINE
    MOV AH, 09H
    INT 21H
    
    INC BX           ; i++
    POP CX
    LOOP FOR_LOOP
    
    MOV AH, 4CH      ; Exit to DOS
    INT 21H
MAIN ENDP

; Print number in AX
PRINT_NUM PROC
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX
    
    MOV BX, 10
    XOR CX, CX
    
DIVIDE_LOOP:
    XOR DX, DX
    DIV BX
    PUSH DX
    INC CX
    CMP AX, 0
    JNE DIVIDE_LOOP
    
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
