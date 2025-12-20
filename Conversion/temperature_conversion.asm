; Program: Temperature Conversion
; Description: Convert Celsius to Fahrenheit and vice versa
; Author: Amey Thakur
; Keywords: 8086 temperature, celsius fahrenheit, conversion

.MODEL SMALL
.STACK 100H

.DATA
    CELSIUS DW 25
    FAHRENHEIT DW ?
    MSG1 DB 'Celsius to Fahrenheit: $'
    MSG2 DB 0DH, 0AH, 'Fahrenheit to Celsius: $'
    NEWLINE DB 0DH, 0AH, '$'
    ; Formula: F = (C * 9/5) + 32
    ; Formula: C = (F - 32) * 5/9

.CODE
MAIN PROC
    MOV AX, @DATA
    MOV DS, AX
    
    ; === Celsius to Fahrenheit ===
    LEA DX, MSG1
    MOV AH, 09H
    INT 21H
    
    ; F = (C * 9 / 5) + 32
    MOV AX, CELSIUS  ; AX = 25
    MOV BX, 9
    MUL BX           ; AX = 25 * 9 = 225
    MOV BX, 5
    XOR DX, DX
    DIV BX           ; AX = 225 / 5 = 45
    ADD AX, 32       ; AX = 45 + 32 = 77
    MOV FAHRENHEIT, AX
    
    ; Display result
    CALL PRINT_NUM   ; Print 77
    MOV DL, 'F'
    MOV AH, 02H
    INT 21H
    
    ; === Fahrenheit to Celsius ===
    LEA DX, MSG2
    MOV AH, 09H
    INT 21H
    
    ; C = (F - 32) * 5 / 9
    MOV AX, FAHRENHEIT  ; AX = 77
    SUB AX, 32          ; AX = 45
    MOV BX, 5
    MUL BX              ; AX = 225
    MOV BX, 9
    XOR DX, DX
    DIV BX              ; AX = 25
    
    CALL PRINT_NUM      ; Print 25
    MOV DL, 'C'
    MOV AH, 02H
    INT 21H
    
    MOV AH, 4CH
    INT 21H
MAIN ENDP

; Print AX as decimal
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
