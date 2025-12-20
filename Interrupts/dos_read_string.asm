; Program: DOS Interrupt 21H - Read String
; Description: Read a string from keyboard using INT 21H, AH=0AH
; Author: Amey Thakur

.MODEL SMALL
.STACK 100H

.DATA
    PROMPT DB 'Enter your name: $'
    BUFFER DB 50           ; Max length
           DB ?            ; Actual length (filled by DOS)
           DB 50 DUP('$')  ; Buffer for input
    NEWLINE DB 0DH, 0AH, '$'
    MSG DB 'Hello, $'

.CODE
MAIN PROC
    MOV AX, @DATA
    MOV DS, AX
    
    ; Display prompt
    LEA DX, PROMPT
    MOV AH, 09H
    INT 21H
    
    ; Read string
    LEA DX, BUFFER
    MOV AH, 0AH      ; DOS function: buffered input
    INT 21H
    
    ; New line
    LEA DX, NEWLINE
    MOV AH, 09H
    INT 21H
    
    ; Display greeting
    LEA DX, MSG
    MOV AH, 09H
    INT 21H
    
    ; Display the name (starts at BUFFER+2)
    LEA DX, BUFFER+2
    MOV AH, 09H
    INT 21H
    
    MOV AH, 4CH      ; Exit to DOS
    INT 21H
MAIN ENDP
END MAIN
