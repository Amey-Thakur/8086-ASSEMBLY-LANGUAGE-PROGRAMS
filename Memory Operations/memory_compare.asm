; Program: Memory Compare
; Description: Compare two blocks of memory
; Author: Amey Thakur

.MODEL SMALL
.STACK 100H

.DATA
    STR1 DB 'Hello', 0
    STR2 DB 'Hello', 0
    LEN EQU 5
    MSG_EQUAL DB 'Memory blocks are EQUAL$'
    MSG_NOT_EQUAL DB 'Memory blocks are NOT equal$'

.CODE
MAIN PROC
    MOV AX, @DATA
    MOV DS, AX
    MOV ES, AX
    
    ; Use REPE CMPSB to compare blocks
    LEA SI, STR1
    LEA DI, STR2
    MOV CX, LEN
    
    CLD              ; Clear direction flag
    REPE CMPSB       ; Compare while equal
    
    JNE NOT_EQUAL    ; If not equal, jump
    
    LEA DX, MSG_EQUAL
    JMP DISPLAY
    
NOT_EQUAL:
    LEA DX, MSG_NOT_EQUAL
    
DISPLAY:
    MOV AH, 09H
    INT 21H
    
    MOV AH, 4CH      ; Exit to DOS
    INT 21H
MAIN ENDP
END MAIN
