; Program: Switch-Case (Jump Table) Structure
; Description: Implement switch-case using jump table
; Author: Amey Thakur

.MODEL SMALL
.STACK 100H

.DATA
    MENU DB 'Select option (1-4):', 0DH, 0AH
         DB '1. Add', 0DH, 0AH
         DB '2. Subtract', 0DH, 0AH
         DB '3. Multiply', 0DH, 0AH
         DB '4. Divide', 0DH, 0AH, '$'
    
    MSG_ADD DB 'You selected: Addition$'
    MSG_SUB DB 'You selected: Subtraction$'
    MSG_MUL DB 'You selected: Multiplication$'
    MSG_DIV DB 'You selected: Division$'
    MSG_INV DB 'Invalid option!$'
    
    JUMP_TABLE DW CASE_1, CASE_2, CASE_3, CASE_4

.CODE
MAIN PROC
    MOV AX, @DATA
    MOV DS, AX
    
    ; Display menu
    LEA DX, MENU
    MOV AH, 09H
    INT 21H
    
    ; Read choice
    MOV AH, 01H
    INT 21H
    
    ; Convert ASCII to number (0-based index)
    SUB AL, '1'
    
    ; Validate input (0-3)
    CMP AL, 4
    JAE INVALID
    
    ; Use jump table
    XOR AH, AH
    SHL AX, 1        ; Multiply by 2 (word offset)
    MOV BX, AX
    JMP JUMP_TABLE[BX]
    
CASE_1:
    LEA DX, MSG_ADD
    JMP DISPLAY
    
CASE_2:
    LEA DX, MSG_SUB
    JMP DISPLAY
    
CASE_3:
    LEA DX, MSG_MUL
    JMP DISPLAY
    
CASE_4:
    LEA DX, MSG_DIV
    JMP DISPLAY
    
INVALID:
    LEA DX, MSG_INV
    
DISPLAY:
    MOV AH, 09H
    INT 21H
    
    MOV AH, 4CH      ; Exit to DOS
    INT 21H
MAIN ENDP
END MAIN
