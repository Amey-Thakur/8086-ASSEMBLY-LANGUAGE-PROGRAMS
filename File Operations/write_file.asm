; Program: File Operations - Write to File
; Description: Write data to a file using DOS interrupt
; Author: Amey Thakur

.MODEL SMALL
.STACK 100H

.DATA
    FILENAME DB 'OUTPUT.TXT', 0
    CONTENT DB 'Hello from 8086 Assembly!', 0DH, 0AH
    CONTENT_LEN EQU $ - CONTENT
    HANDLE DW ?
    MSG_SUCCESS DB 'Data written to file!$'
    MSG_ERROR DB 'Error writing to file!$'

.CODE
MAIN PROC
    MOV AX, @DATA
    MOV DS, AX
    
    ; Create file
    MOV AH, 3CH
    MOV CX, 0
    LEA DX, FILENAME
    INT 21H
    JC ERROR
    MOV HANDLE, AX
    
    ; Write to file (INT 21H, AH=40H)
    MOV AH, 40H
    MOV BX, HANDLE
    MOV CX, CONTENT_LEN
    LEA DX, CONTENT
    INT 21H
    JC ERROR
    
    ; Close file
    MOV AH, 3EH
    MOV BX, HANDLE
    INT 21H
    
    LEA DX, MSG_SUCCESS
    JMP DISPLAY
    
ERROR:
    LEA DX, MSG_ERROR
    
DISPLAY:
    MOV AH, 09H
    INT 21H
    
    MOV AH, 4CH      ; Exit to DOS
    INT 21H
MAIN ENDP
END MAIN
