; Program: File Operations - Delete File
; Description: Delete a file using DOS interrupt
; Author: Amey Thakur

.MODEL SMALL
.STACK 100H

.DATA
    FILENAME DB 'DELETE_ME.TXT', 0
    MSG_SUCCESS DB 'File deleted successfully!$'
    MSG_ERROR DB 'Error deleting file!$'

.CODE
MAIN PROC
    MOV AX, @DATA
    MOV DS, AX
    
    ; Delete file (INT 21H, AH=41H)
    MOV AH, 41H
    LEA DX, FILENAME
    INT 21H
    
    JC ERROR
    
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
