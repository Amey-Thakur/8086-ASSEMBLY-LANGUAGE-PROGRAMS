; Program: Memory Fill
; Description: Fill a block of memory with a specific value
; Author: Amey Thakur

.MODEL SMALL
.STACK 100H

.DATA
    BUFFER DB 20 DUP(?)
    BUFFER_LEN EQU 20
    FILL_CHAR DB '*'
    MSG DB 'Memory filled!$'

.CODE
MAIN PROC
    MOV AX, @DATA
    MOV DS, AX
    MOV ES, AX
    
    ; Use REP STOSB for efficient block fill
    LEA DI, BUFFER
    MOV AL, FILL_CHAR
    MOV CX, BUFFER_LEN
    
    CLD              ; Clear direction flag
    REP STOSB        ; Store AL to ES:DI, CX times
    
    ; Display success message
    LEA DX, MSG
    MOV AH, 09H
    INT 21H
    
    MOV AH, 4CH      ; Exit to DOS
    INT 21H
MAIN ENDP
END MAIN
