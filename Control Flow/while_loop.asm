; Program: While Loop Structure
; Description: Implement while loop logic in assembly
; Author: Amey Thakur

.MODEL SMALL
.STACK 100H

.DATA
    MSG DB 'Sum of 1 to 10 = $'
    SUM DW 0
    COUNT DW 1
    LIMIT DW 10

.CODE
MAIN PROC
    MOV AX, @DATA
    MOV DS, AX
    
    ; WHILE (COUNT <= LIMIT)
WHILE_START:
    MOV AX, COUNT
    CMP AX, LIMIT
    JG WHILE_END     ; Exit if COUNT > LIMIT
    
    ; Loop body: SUM = SUM + COUNT
    ADD SUM, AX
    
    ; COUNT = COUNT + 1
    INC COUNT
    
    JMP WHILE_START  ; Continue loop
    
WHILE_END:
    ; Display message
    LEA DX, MSG
    MOV AH, 09H
    INT 21H
    
    ; Display sum (55)
    MOV AX, SUM
    CALL PRINT_NUM
    
    MOV AH, 4CH      ; Exit to DOS
    INT 21H
MAIN ENDP

; Print number in AX
PRINT_NUM PROC
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX
    
    MOV BX, 10
    XOR CX, CX
    
DIVIDE_LOOP:
    XOR DX, DX
    DIV BX
    PUSH DX
    INC CX
    CMP AX, 0
    JNE DIVIDE_LOOP
    
PRINT_LOOP:
    POP DX
    ADD DL, '0'
    MOV AH, 02H
    INT 21H
    LOOP PRINT_LOOP
    
    POP DX
    POP CX
    POP BX
    POP AX
    RET
PRINT_NUM ENDP

END MAIN
