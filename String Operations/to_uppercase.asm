; Program: Convert String to Uppercase
; Description: Convert lowercase letters to uppercase
; Author: Amey Thakur

.MODEL SMALL
.STACK 100H

.DATA
    STR1 DB 'hello world', '$'
    NEWLINE DB 0DH, 0AH, '$'
    MSG1 DB 'Original: $'
    MSG2 DB 'Uppercase: $'

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
    
    ; Convert to uppercase
    LEA SI, STR1
CONVERT_LOOP:
    MOV AL, [SI]
    CMP AL, '$'
    JE DISPLAY
    
    CMP AL, 'a'      ; Check if lowercase
    JB NEXT
    CMP AL, 'z'
    JA NEXT
    
    SUB AL, 20H      ; Convert to uppercase (a=61H, A=41H)
    MOV [SI], AL
    
NEXT:
    INC SI
    JMP CONVERT_LOOP
    
DISPLAY:
    ; Display uppercase
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
