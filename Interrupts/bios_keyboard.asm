; Program: BIOS Interrupt 16H - Keyboard Input
; Description: Read keyboard using INT 16H
; Author: Amey Thakur

.MODEL SMALL
.STACK 100H

.DATA
    MSG1 DB 'Press any key (no echo): $'
    MSG2 DB 0DH, 0AH, 'Scan code: $'
    MSG3 DB 0DH, 0AH, 'ASCII code: $'

.CODE
MAIN PROC
    MOV AX, @DATA
    MOV DS, AX
    
    ; Display prompt
    LEA DX, MSG1
    MOV AH, 09H
    INT 21H
    
    ; Wait for key using BIOS
    MOV AH, 00H      ; BIOS function: wait for key
    INT 16H          ; AH = scan code, AL = ASCII code
    
    PUSH AX          ; Save key codes
    
    ; Display scan code message
    LEA DX, MSG2
    MOV AH, 09H
    INT 21H
    
    ; Display scan code (in AH)
    POP AX
    PUSH AX
    MOV AL, AH
    CALL PRINT_HEX
    
    ; Display ASCII code message
    LEA DX, MSG3
    MOV AH, 09H
    INT 21H
    
    ; Display ASCII code
    POP AX
    CALL PRINT_HEX
    
    MOV AH, 4CH      ; Exit to DOS
    INT 21H
MAIN ENDP

; Procedure to print AL as hex
PRINT_HEX PROC
    PUSH AX
    MOV AH, AL
    SHR AL, 4
    CALL PRINT_DIGIT
    MOV AL, AH
    AND AL, 0FH
    CALL PRINT_DIGIT
    POP AX
    RET
PRINT_HEX ENDP

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
