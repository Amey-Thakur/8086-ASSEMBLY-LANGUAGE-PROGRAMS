; Program: String Reverse
; Description: Reverse a string in place
; Author: Amey Thakur

.MODEL SMALL
.STACK 100H

.DATA
    STR1 DB 'ASSEMBLY', '$'
    LEN EQU 8
    NEWLINE DB 0DH, 0AH, '$'
    MSG1 DB 'Original: $'
    MSG2 DB 'Reversed: $'

.CODE
MAIN PROC
    MOV AX, @DATA
    MOV DS, AX
    
    ; Display original message
    LEA DX, MSG1
    MOV AH, 09H
    INT 21H
    
    LEA DX, STR1
    MOV AH, 09H
    INT 21H
    
    LEA DX, NEWLINE
    MOV AH, 09H
    INT 21H
    
    ; Reverse the string
    LEA SI, STR1          ; Start pointer
    LEA DI, STR1
    ADD DI, LEN - 1       ; End pointer
    
    MOV CX, LEN / 2
REVERSE_LOOP:
    MOV AL, [SI]
    MOV BL, [DI]
    MOV [SI], BL
    MOV [DI], AL
    INC SI
    DEC DI
    LOOP REVERSE_LOOP
    
    ; Display reversed message
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
