; Program: Stack Implementation (Using Array)
; Description: Implement a stack data structure using an array
; Author: Amey Thakur

.MODEL SMALL
.STACK 100H

.DATA
    STACK_ARR DB 10 DUP(0)
    TOP DW -1
    MAX_SIZE EQU 10
    MSG_PUSH DB 'Element pushed$'
    MSG_POP DB 'Element popped$'
    MSG_FULL DB 'Stack Overflow!$'
    MSG_EMPTY DB 'Stack Underflow!$'
    NEWLINE DB 0DH, 0AH, '$'

.CODE
; Push Procedure
; Input: AL = element to push
STACK_PUSH PROC
    CMP TOP, MAX_SIZE - 1
    JGE STACK_OVERFLOW
    
    INC TOP
    MOV BX, TOP
    MOV STACK_ARR[BX], AL
    
    LEA DX, MSG_PUSH
    MOV AH, 09H
    INT 21H
    LEA DX, NEWLINE
    MOV AH, 09H
    INT 21H
    RET
    
STACK_OVERFLOW:
    LEA DX, MSG_FULL
    MOV AH, 09H
    INT 21H
    LEA DX, NEWLINE
    MOV AH, 09H
    INT 21H
    RET
STACK_PUSH ENDP

; Pop Procedure
; Output: AL = element popped
STACK_POP PROC
    CMP TOP, -1
    JLE STACK_UNDERFLOW
    
    MOV BX, TOP
    MOV AL, STACK_ARR[BX]
    DEC TOP
    
    LEA DX, MSG_POP
    MOV AH, 09H
    INT 21H
    LEA DX, NEWLINE
    MOV AH, 09H
    INT 21H
    RET
    
STACK_UNDERFLOW:
    LEA DX, MSG_EMPTY
    MOV AH, 09H
    INT 21H
    LEA DX, NEWLINE
    MOV AH, 09H
    INT 21H
    RET
STACK_POP ENDP

MAIN PROC
    MOV AX, @DATA
    MOV DS, AX
    
    ; Push elements
    MOV AL, 10
    CALL STACK_PUSH
    MOV AL, 20
    CALL STACK_PUSH
    MOV AL, 30
    CALL STACK_PUSH
    
    ; Pop element
    CALL STACK_POP
    
    MOV AH, 4CH      ; Exit to DOS
    INT 21H
MAIN ENDP
END MAIN
