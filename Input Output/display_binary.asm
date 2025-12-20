; Program: Display Number in Binary
; Description: Convert and display a number in binary format
; Author: Amey Thakur

.MODEL SMALL
.STACK 100H

.DATA
    NUM DW 0A5H      ; 10100101 in binary
    MSG DB 'Binary: $'

.CODE
MAIN PROC
    MOV AX, @DATA
    MOV DS, AX
    
    LEA DX, MSG
    MOV AH, 09H
    INT 21H
    
    MOV AX, NUM
    CALL PRINT_BINARY
    
    ; Print 'b' suffix
    MOV DL, 'b'
    MOV AH, 02H
    INT 21H
    
    MOV AH, 4CH
    INT 21H
MAIN ENDP

; Print AL as 8-bit binary
PRINT_BINARY PROC
    PUSH AX
    PUSH CX
    
    MOV CX, 8        ; 8 bits
    
BIT_LOOP:
    ROL AL, 1        ; Rotate left, MSB goes to carry
    JC PRINT_ONE
    
    MOV DL, '0'
    JMP PRINT_BIT
    
PRINT_ONE:
    MOV DL, '1'
    
PRINT_BIT:
    PUSH AX
    MOV AH, 02H
    INT 21H
    POP AX
    
    LOOP BIT_LOOP
    
    POP CX
    POP AX
    RET
PRINT_BINARY ENDP

END MAIN
