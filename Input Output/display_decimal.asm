; Program: Display Number in Decimal
; Description: Convert and display a 16-bit number in decimal format
; Author: Amey Thakur

.MODEL SMALL
.STACK 100H

.DATA
    NUM DW 12345
    MSG DB 'Number: $'

.CODE
MAIN PROC
    MOV AX, @DATA
    MOV DS, AX
    
    LEA DX, MSG
    MOV AH, 09H
    INT 21H
    
    MOV AX, NUM
    CALL PRINT_DECIMAL
    
    MOV AH, 4CH
    INT 21H
MAIN ENDP

; Print AX as decimal number
PRINT_DECIMAL PROC
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX
    
    XOR CX, CX       ; Digit counter
    MOV BX, 10       ; Divisor
    
DIVIDE_LOOP:
    XOR DX, DX       ; Clear high word for division
    DIV BX           ; AX = quotient, DX = remainder
    PUSH DX          ; Save digit
    INC CX           ; Count digits
    CMP AX, 0
    JNE DIVIDE_LOOP
    
PRINT_LOOP:
    POP DX           ; Get digit
    ADD DL, '0'      ; Convert to ASCII
    MOV AH, 02H
    INT 21H
    LOOP PRINT_LOOP
    
    POP DX
    POP CX
    POP BX
    POP AX
    RET
PRINT_DECIMAL ENDP

END MAIN
