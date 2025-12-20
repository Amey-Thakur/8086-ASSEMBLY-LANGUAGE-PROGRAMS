; Program: Unconditional Jump (JMP)
; Description: Demonstrate unconditional jump instruction
; Author: Amey Thakur

.MODEL SMALL
.STACK 100H

.DATA
    MSG1 DB 'Step 1: Before jump$'
    MSG2 DB 0DH, 0AH, 'Step 2: Skipped by jump$'
    MSG3 DB 0DH, 0AH, 'Step 3: After jump target$'

.CODE
MAIN PROC
    MOV AX, @DATA
    MOV DS, AX
    
    ; Display Step 1
    LEA DX, MSG1
    MOV AH, 09H
    INT 21H
    
    JMP SKIP_STEP2   ; Unconditional jump
    
    ; This won't execute
    LEA DX, MSG2
    MOV AH, 09H
    INT 21H
    
SKIP_STEP2:
    ; Display Step 3
    LEA DX, MSG3
    MOV AH, 09H
    INT 21H
    
    MOV AH, 4CH      ; Exit to DOS
    INT 21H
MAIN ENDP
END MAIN
