; Program: BIOS Interrupt 1AH - Get System Time
; Description: Get system time using INT 1AH, AH=00H
; Author: Amey Thakur

.MODEL SMALL
.STACK 100H

.DATA
    MSG DB 'System ticks since midnight: $'
    NEWLINE DB 0DH, 0AH, '$'

.CODE
MAIN PROC
    MOV AX, @DATA
    MOV DS, AX
    
    ; Display message
    LEA DX, MSG
    MOV AH, 09H
    INT 21H
    
    ; Get system time
    MOV AH, 00H      ; BIOS function: get system time
    INT 1AH          ; CX:DX = tick count since midnight
    
    ; Display CX (high word)
    MOV AX, CX
    CALL PRINT_HEX_WORD
    
    ; Display DX (low word)
    MOV AX, DX
    CALL PRINT_HEX_WORD
    
    ; Note: 18.2 ticks per second
    
    MOV AH, 4CH      ; Exit to DOS
    INT 21H
MAIN ENDP

PRINT_HEX_WORD PROC
    PUSH AX
    MOV AL, AH
    CALL PRINT_HEX_BYTE
    POP AX
    CALL PRINT_HEX_BYTE
    RET
PRINT_HEX_WORD ENDP

PRINT_HEX_BYTE PROC
    PUSH AX
    SHR AL, 4
    CALL PRINT_DIGIT
    POP AX
    AND AL, 0FH
    CALL PRINT_DIGIT
    RET
PRINT_HEX_BYTE ENDP

PRINT_DIGIT PROC
    CMP AL, 9
    JA HEX_LETTER
    ADD AL, '0'
    JMP PRINT_IT
HEX_LETTER:
    ADD AL, 'A' - 10
PRINT_IT:
    MOV DL, AL
    MOV AH, 02H
    INT 21H
    RET
PRINT_DIGIT ENDP

END MAIN
