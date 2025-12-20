; Program: DOS Interrupt 21H - Read Character
; Description: Read a character from keyboard using INT 21H, AH=01H
; Author: Amey Thakur

.MODEL SMALL
.STACK 100H

.DATA
    MSG1 DB 'Press any key: $'
    MSG2 DB 0DH, 0AH, 'You pressed: $'
    CHAR DB ?

.CODE
MAIN PROC
    MOV AX, @DATA
    MOV DS, AX
    
    ; Display prompt
    LEA DX, MSG1
    MOV AH, 09H
    INT 21H
    
    ; Read character with echo
    MOV AH, 01H      ; DOS function: read character with echo
    INT 21H          ; AL = character read
    MOV CHAR, AL     ; Store character
    
    ; Display message
    LEA DX, MSG2
    MOV AH, 09H
    INT 21H
    
    ; Display the character again
    MOV DL, CHAR
    MOV AH, 02H
    INT 21H
    
    MOV AH, 4CH      ; Exit to DOS
    INT 21H
MAIN ENDP
END MAIN
