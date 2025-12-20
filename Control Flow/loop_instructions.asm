; Program: Loop Instructions
; Description: Demonstrate LOOP, LOOPE, LOOPNE instructions
; Author: Amey Thakur

.MODEL SMALL
.STACK 100H

.DATA
    MSG1 DB 'Counting: $'
    NEWLINE DB 0DH, 0AH, '$'

.CODE
MAIN PROC
    MOV AX, @DATA
    MOV DS, AX
    
    ; Display message
    LEA DX, MSG1
    MOV AH, 09H
    INT 21H
    
    ; Simple LOOP - count from 1 to 9
    MOV CX, 9        ; Loop counter
    MOV BL, '1'      ; Starting character
    
COUNT_LOOP:
    MOV DL, BL
    MOV AH, 02H
    INT 21H
    
    MOV DL, ' '      ; Space separator
    MOV AH, 02H
    INT 21H
    
    INC BL           ; Next digit
    LOOP COUNT_LOOP  ; Decrement CX, loop if not zero
    
    ; Newline
    LEA DX, NEWLINE
    MOV AH, 09H
    INT 21H
    
    MOV AH, 4CH      ; Exit to DOS
    INT 21H
MAIN ENDP
END MAIN

; Loop Instruction Reference:
; LOOP label    - Decrement CX, jump if CX != 0
; LOOPE/LOOPZ   - Decrement CX, jump if CX != 0 AND ZF = 1
; LOOPNE/LOOPNZ - Decrement CX, jump if CX != 0 AND ZF = 0
