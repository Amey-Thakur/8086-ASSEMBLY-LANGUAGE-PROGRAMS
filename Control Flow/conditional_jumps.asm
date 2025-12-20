; Program: Conditional Jumps - All Types
; Description: Demonstrate all conditional jump instructions
; Author: Amey Thakur

.MODEL SMALL
.STACK 100H

.DATA
    MSG_EQ DB 'Numbers are equal$'
    MSG_NE DB 'Numbers are not equal$'
    MSG_GT DB 'First is greater$'
    MSG_LT DB 'First is less$'
    NEWLINE DB 0DH, 0AH, '$'
    NUM1 DW 50
    NUM2 DW 30

.CODE
MAIN PROC
    MOV AX, @DATA
    MOV DS, AX
    
    MOV AX, NUM1
    CMP AX, NUM2
    
    ; JE/JZ - Jump if Equal/Zero
    JE EQUAL
    
    ; JNE/JNZ - Jump if Not Equal/Not Zero
    JNE NOT_EQUAL
    
EQUAL:
    LEA DX, MSG_EQ
    JMP DISPLAY
    
NOT_EQUAL:
    ; Check if greater or less (signed)
    MOV AX, NUM1
    CMP AX, NUM2
    
    ; JG/JNLE - Jump if Greater (signed)
    JG GREATER
    
    ; JL/JNGE - Jump if Less (signed)
    JL LESS
    
GREATER:
    LEA DX, MSG_GT
    JMP DISPLAY
    
LESS:
    LEA DX, MSG_LT
    
DISPLAY:
    MOV AH, 09H
    INT 21H
    
    MOV AH, 4CH      ; Exit to DOS
    INT 21H
MAIN ENDP
END MAIN

; Conditional Jump Reference:
; JE/JZ   - Jump if Equal/Zero
; JNE/JNZ - Jump if Not Equal/Not Zero
; JG/JNLE - Jump if Greater (signed)
; JGE/JNL - Jump if Greater or Equal (signed)
; JL/JNGE - Jump if Less (signed)
; JLE/JNG - Jump if Less or Equal (signed)
; JA/JNBE - Jump if Above (unsigned)
; JAE/JNB - Jump if Above or Equal (unsigned)
; JB/JNAE - Jump if Below (unsigned)
; JBE/JNA - Jump if Below or Equal (unsigned)
; JC      - Jump if Carry
; JNC     - Jump if No Carry
; JO      - Jump if Overflow
; JNO     - Jump if No Overflow
; JS      - Jump if Sign (negative)
; JNS     - Jump if No Sign (positive)
; JP/JPE  - Jump if Parity Even
; JNP/JPO - Jump if Parity Odd
