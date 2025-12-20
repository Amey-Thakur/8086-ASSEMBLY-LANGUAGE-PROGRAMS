; Program: File Operations - Read from File
; Description: Read data from a file using DOS interrupt
; Author: Amey Thakur

.MODEL SMALL
.STACK 100H

.DATA
    FILENAME DB 'INPUT.TXT', 0
    BUFFER DB 256 DUP('$')
    HANDLE DW ?
    MSG_CONTENT DB 'File content:', 0DH, 0AH, '$'
    MSG_ERROR DB 'Error reading file!$'

.CODE
MAIN PROC
    MOV AX, @DATA
    MOV DS, AX
    
    ; Open file for reading (INT 21H, AH=3DH)
    MOV AH, 3DH
    MOV AL, 0        ; Read-only mode
    LEA DX, FILENAME
    INT 21H
    JC ERROR
    MOV HANDLE, AX
    
    ; Read from file (INT 21H, AH=3FH)
    MOV AH, 3FH
    MOV BX, HANDLE
    MOV CX, 255      ; Max bytes to read
    LEA DX, BUFFER
    INT 21H
    JC ERROR
    
    ; Close file
    MOV AH, 3EH
    MOV BX, HANDLE
    INT 21H
    
    ; Display content header
    LEA DX, MSG_CONTENT
    MOV AH, 09H
    INT 21H
    
    ; Display file content
    LEA DX, BUFFER
    MOV AH, 09H
    INT 21H
    JMP EXIT
    
ERROR:
    LEA DX, MSG_ERROR
    MOV AH, 09H
    INT 21H
    
EXIT:
    MOV AH, 4CH      ; Exit to DOS
    INT 21H
MAIN ENDP
END MAIN
