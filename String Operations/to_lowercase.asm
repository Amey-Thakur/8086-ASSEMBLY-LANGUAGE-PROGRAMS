; Program: Convert String to Lowercase
; Description: Convert uppercase letters to lowercase
; Author: Amey Thakur

.MODEL SMALL
.STACK 100H

.DATA
    STR1 DB 'HELLO WORLD', '$'
    NEWLINE DB 0DH, 0AH, '$'
    MSG1 DB 'Original: $'
    MSG2 DB 'Lowercase: $'

.CODE
MAIN PROC
    MOV AX, @DATA
    MOV DS, AX
    
    ; Display original
    LEA DX, MSG1
    MOV AH, 09H
    INT 21H
    
    LEA DX, STR1
    MOV AH, 09H
    INT 21H
    
    LEA DX, NEWLINE
    MOV AH, 09H
    INT 21H
    
    ; Convert to lowercase
    LEA SI, STR1
CONVERT_LOOP:
    MOV AL, [SI]
    CMP AL, '$'
    JE DISPLAY
    
    CMP AL, 'A'      ; Check if uppercase
    JB NEXT
    CMP AL, 'Z'
    JA NEXT
    
    ADD AL, 20H      ; Convert to lowercase (A=41H, a=61H)
    MOV [SI], AL
    
NEXT:
    INC SI
    JMP CONVERT_LOOP
    
DISPLAY:
    ; Display lowercase
    LEA DX, MSG2
    MOV AH, 09H
    INT 21H
    
    LEA DX, STR1
    MOV AH, 09H
    INT 21H
    
    MOV AH, 4CH      ; Exit to DOS
    INT 21H
MAIN ENDP
END MAIN
