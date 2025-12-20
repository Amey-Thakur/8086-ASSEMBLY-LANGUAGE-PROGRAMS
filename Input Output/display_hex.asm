; Program: Display Number in Hexadecimal
; Description: Convert and display a number in hexadecimal format
; Author: Amey Thakur

.MODEL SMALL
.STACK 100H

.DATA
    NUM DW 0ABCDH
    MSG DB 'Hex: $'

.CODE
MAIN PROC
    MOV AX, @DATA
    MOV DS, AX
    
    LEA DX, MSG
    MOV AH, 09H
    INT 21H
    
    MOV AX, NUM
    CALL PRINT_HEX
    
    ; Print 'H' suffix
    MOV DL, 'H'
    MOV AH, 02H
    INT 21H
    
    MOV AH, 4CH
    INT 21H
MAIN ENDP

; Print AX as 4-digit hex
PRINT_HEX PROC
    PUSH AX
    PUSH BX
    PUSH CX
    
    MOV BX, AX
    MOV CX, 4        ; 4 hex digits
    
ROTATE_LOOP:
    ROL BX, 4        ; Rotate left 4 bits
    MOV AL, BL
    AND AL, 0FH      ; Mask lower nibble
    
    CMP AL, 9
    JA HEX_LETTER
    ADD AL, '0'      ; 0-9
    JMP PRINT_DIGIT
    
HEX_LETTER:
    ADD AL, 'A' - 10 ; A-F
    
PRINT_DIGIT:
    MOV DL, AL
    MOV AH, 02H
    INT 21H
    
    LOOP ROTATE_LOOP
    
    POP CX
    POP BX
    POP AX
    RET
PRINT_HEX ENDP

END MAIN
