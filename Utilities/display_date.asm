; Program: Display Current Date
; Description: Get and display system date using DOS interrupt
; Author: Amey Thakur
; Keywords: 8086 date, system date, DOS date

.MODEL SMALL
.STACK 100H

.DATA
    MSG DB 'Current Date: $'
    SLASH DB '/$'
    NEWLINE DB 0DH, 0AH, '$'

.CODE
MAIN PROC
    MOV AX, @DATA
    MOV DS, AX
    
    ; Display message
    LEA DX, MSG
    MOV AH, 09H
    INT 21H
    
    ; Get system date (INT 21H, AH=2AH)
    ; Returns: CX = year, DH = month, DL = day, AL = day of week
    MOV AH, 2AH
    INT 21H
    
    PUSH CX          ; Save year
    
    ; Display day
    XOR AH, AH
    MOV AL, DL
    CALL PRINT_NUM
    
    ; Slash
    LEA DX, SLASH
    MOV AH, 09H
    INT 21H
    
    ; Display month
    XOR AH, AH
    MOV AL, DH
    CALL PRINT_NUM
    
    ; Slash
    LEA DX, SLASH
    MOV AH, 09H
    INT 21H
    
    ; Display year
    POP AX           ; Year in AX
    CALL PRINT_NUM
    
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
