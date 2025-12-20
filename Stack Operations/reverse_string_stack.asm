; Program: Reverse String Using Stack
; Description: Reverse a string using stack (LIFO property)
; Author: Amey Thakur

.MODEL SMALL
.STACK 100H

.DATA
    STR1 DB 'HELLO', '$'
    LEN EQU 5
    NEWLINE DB 0DH, 0AH, '$'

.CODE
MAIN PROC
    MOV AX, @DATA
    MOV DS, AX
    
    ; Display original string
    LEA DX, STR1
    MOV AH, 09H
    INT 21H
    
    ; Print newline
    LEA DX, NEWLINE
    MOV AH, 09H
    INT 21H
    
    ; Push each character onto stack
    LEA SI, STR1
    MOV CX, LEN
PUSH_LOOP:
    MOV AL, [SI]
    PUSH AX
    INC SI
    LOOP PUSH_LOOP
    
    ; Pop and display (reversed order)
    MOV CX, LEN
POP_LOOP:
    POP AX
    MOV DL, AL
    MOV AH, 02H
    INT 21H
    LOOP POP_LOOP
    
    MOV AH, 4CH      ; Exit to DOS
    INT 21H
MAIN ENDP
END MAIN
