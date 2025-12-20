; Program: If-Then-Else Structure
; Description: Implement if-then-else logic in assembly
; Author: Amey Thakur

.MODEL SMALL
.STACK 100H

.DATA
    NUM DW 75
    MSG_PASS DB 'Result: PASS$'
    MSG_FAIL DB 'Result: FAIL$'
    THRESHOLD DW 50

.CODE
MAIN PROC
    MOV AX, @DATA
    MOV DS, AX
    
    ; IF (NUM >= THRESHOLD) THEN PASS ELSE FAIL
    MOV AX, NUM
    CMP AX, THRESHOLD
    
    JGE PASS_BLOCK   ; If NUM >= 50, jump to PASS
    
    ; ELSE block (FAIL)
    LEA DX, MSG_FAIL
    JMP ENDIF
    
PASS_BLOCK:
    ; THEN block (PASS)
    LEA DX, MSG_PASS
    
ENDIF:
    ; Display result
    MOV AH, 09H
    INT 21H
    
    MOV AH, 4CH      ; Exit to DOS
    INT 21H
MAIN ENDP
END MAIN
