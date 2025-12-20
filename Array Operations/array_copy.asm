; Program: Copy Array
; Description: Copy contents of one array to another
; Author: Amey Thakur

.MODEL SMALL
.STACK 100H

.DATA
    SRC DB 11H, 22H, 33H, 44H, 55H
    DST DB 5 DUP(0)
    LEN EQU 5

.CODE
MAIN PROC
    MOV AX, @DATA
    MOV DS, AX
    MOV ES, AX
    
    LEA SI, SRC      ; Source pointer
    LEA DI, DST      ; Destination pointer
    MOV CX, LEN      ; Count
    
    CLD              ; Clear direction flag (forward)
    REP MOVSB        ; Copy bytes
    
    MOV AH, 4CH      ; Exit to DOS
    INT 21H
MAIN ENDP
END MAIN
