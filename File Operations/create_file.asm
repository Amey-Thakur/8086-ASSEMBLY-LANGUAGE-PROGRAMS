; Program: File Operations - Create File
; Description: Create a new file using DOS interrupt
; Author: Amey Thakur

.MODEL SMALL
.STACK 100H

.DATA
    FILENAME DB 'TEST.TXT', 0
    HANDLE DW ?
    MSG_SUCCESS DB 'File created successfully!$'
    MSG_ERROR DB 'Error creating file!$'

.CODE
MAIN PROC
    MOV AX, @DATA
    MOV DS, AX
    
    ; Create file (INT 21H, AH=3CH)
    MOV AH, 3CH
    MOV CX, 0        ; Normal file attributes
    LEA DX, FILENAME
    INT 21H
    
    JC ERROR         ; Jump if error (carry set)
    
    ; Save file handle
    MOV HANDLE, AX
    
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
