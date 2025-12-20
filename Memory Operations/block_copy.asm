; Program: Memory Block Copy
; Description: Copy a block of memory from one location to another
; Author: Amey Thakur

.MODEL SMALL
.STACK 100H

.DATA
    SOURCE DB 'Hello, World!', 0
    SOURCE_LEN EQU $ - SOURCE
    DEST DB 20 DUP(0)
    MSG DB 'Memory block copied!$'

.CODE
MAIN PROC
    MOV AX, @DATA
    MOV DS, AX
    MOV ES, AX
    
    ; Use REP MOVSB for efficient block copy
    LEA SI, SOURCE
    LEA DI, DEST
    MOV CX, SOURCE_LEN
    
    CLD              ; Clear direction flag (forward)
    REP MOVSB        ; Copy CX bytes from DS:SI to ES:DI
    
    ; Display success message
    LEA DX, MSG
    MOV AH, 09H
    INT 21H
    
    MOV AH, 4CH      ; Exit to DOS
    INT 21H
MAIN ENDP
END MAIN
