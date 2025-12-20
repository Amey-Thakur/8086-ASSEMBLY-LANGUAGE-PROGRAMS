; Program: Scan Memory for Value
; Description: Search for a specific value in memory
; Author: Amey Thakur

.MODEL SMALL
.STACK 100H

.DATA
    BUFFER DB 10, 20, 30, 40, 50, 60, 70, 80, 90, 100
    BUFFER_LEN EQU 10
    SEARCH_VAL DB 50
    MSG_FOUND DB 'Value found at position: $'
    MSG_NOT_FOUND DB 'Value not found!$'

.CODE
MAIN PROC
    MOV AX, @DATA
    MOV DS, AX
    MOV ES, AX
    
    ; Use REPNE SCASB to scan for value
    LEA DI, BUFFER
    MOV AL, SEARCH_VAL
    MOV CX, BUFFER_LEN
    
    CLD              ; Clear direction flag
    REPNE SCASB      ; Scan until equal or CX=0
    
    JNE NOT_FOUND    ; If not found, jump
    
    ; Calculate position
    MOV AX, BUFFER_LEN
    SUB AX, CX       ; Position = LEN - remaining CX
    
    LEA DX, MSG_FOUND
    MOV AH, 09H
    INT 21H
    
    ; Display position
    ADD AL, '0'
    MOV DL, AL
    MOV AH, 02H
    INT 21H
    JMP EXIT
    
NOT_FOUND:
    LEA DX, MSG_NOT_FOUND
    MOV AH, 09H
    INT 21H
    
EXIT:
    MOV AH, 4CH      ; Exit to DOS
    INT 21H
MAIN ENDP
END MAIN
