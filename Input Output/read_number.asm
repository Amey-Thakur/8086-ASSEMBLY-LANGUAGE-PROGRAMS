; Program: Read Number from Keyboard
; Description: Read a multi-digit decimal number from keyboard
; Author: Amey Thakur

.MODEL SMALL
.STACK 100H

.DATA
    PROMPT DB 'Enter a number: $'
    RESULT_MSG DB 0DH, 0AH, 'You entered: $'
    NEWLINE DB 0DH, 0AH, '$'
    NUMBER DW 0

.CODE
MAIN PROC
    MOV AX, @DATA
    MOV DS, AX
    
    LEA DX, PROMPT
    MOV AH, 09H
    INT 21H
    
    CALL READ_NUMBER
    MOV NUMBER, AX
    
    LEA DX, RESULT_MSG
    MOV AH, 09H
    INT 21H
    
    MOV AX, NUMBER
    CALL PRINT_DECIMAL
    
    MOV AH, 4CH
    INT 21H
MAIN ENDP

; Read decimal number from keyboard, result in AX
READ_NUMBER PROC
    PUSH BX
    PUSH CX
    PUSH DX
    
    XOR BX, BX       ; Accumulator
    
READ_LOOP:
    MOV AH, 01H      ; Read character with echo
    INT 21H
    
    CMP AL, 0DH      ; Enter key?
    JE READ_DONE
    
    CMP AL, '0'      ; Validate digit
    JB READ_LOOP
    CMP AL, '9'
    JA READ_LOOP
    
    SUB AL, '0'      ; Convert ASCII to number
    XOR AH, AH
    
    ; BX = BX * 10 + digit
    PUSH AX
    MOV AX, BX
    MOV CX, 10
    MUL CX           ; AX = BX * 10
    MOV BX, AX
    POP AX
    ADD BX, AX       ; BX = BX * 10 + digit
    
    JMP READ_LOOP
    
READ_DONE:
    MOV AX, BX
    
    POP DX
    POP CX
    POP BX
    RET
READ_NUMBER ENDP

; Print AX as decimal (same as before)
PRINT_DECIMAL PROC
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
PRINT_DECIMAL ENDP

END MAIN
