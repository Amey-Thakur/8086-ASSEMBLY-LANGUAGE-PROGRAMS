; Program: Print Alphabet (A-Z)
; Description: Display all uppercase letters A to Z
; Author: Amey Thakur
; Keywords: 8086 alphabet, print A to Z, ASCII letters

.MODEL SMALL
.STACK 100H

.DATA
    MSG1 DB 'Uppercase A-Z: $'
    MSG2 DB 0DH, 0AH, 'Lowercase a-z: $'
    NEWLINE DB 0DH, 0AH, '$'

.CODE
MAIN PROC
    MOV AX, @DATA
    MOV DS, AX
    
    ; Print uppercase A-Z
    LEA DX, MSG1
    MOV AH, 09H
    INT 21H
    
    MOV CX, 26       ; 26 letters
    MOV DL, 'A'      ; Start with A (ASCII 65)
    
UPPER_LOOP:
    MOV AH, 02H
    INT 21H
    MOV AL, DL
    INC DL           ; Next letter
    
    ; Print space
    PUSH DX
    MOV DL, ' '
    MOV AH, 02H
    INT 21H
    POP DX
    
    LOOP UPPER_LOOP
    
    ; Print lowercase a-z
    LEA DX, MSG2
    MOV AH, 09H
    INT 21H
    
    MOV CX, 26
    MOV DL, 'a'      ; Start with a (ASCII 97)
    
LOWER_LOOP:
    MOV AH, 02H
    INT 21H
    MOV AL, DL
    INC DL
    
    PUSH DX
    MOV DL, ' '
    MOV AH, 02H
    INT 21H
    POP DX
    
    LOOP LOWER_LOOP
    
    MOV AH, 4CH
    INT 21H
MAIN ENDP
END MAIN
