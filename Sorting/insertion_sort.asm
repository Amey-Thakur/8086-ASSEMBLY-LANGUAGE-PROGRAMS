; Program: Insertion Sort
; Description: Sort an array using insertion sort algorithm
; Author: Amey Thakur

.MODEL SMALL
.STACK 100H

.DATA
    ARR DB 64, 25, 12, 22, 11
    LEN EQU 5
    MSG DB 'Array sorted using Insertion Sort$'

.CODE
MAIN PROC
    MOV AX, @DATA
    MOV DS, AX
    
    ; Insertion Sort
    MOV CX, LEN - 1  ; Loop n-1 times
    MOV SI, 1        ; i = 1
    
OUTER_LOOP:
    PUSH CX
    
    MOV AL, ARR[SI]  ; key = ARR[i]
    MOV BX, SI
    DEC BX           ; j = i - 1
    
SHIFT_LOOP:
    CMP BX, 0
    JL INSERT_KEY
    CMP ARR[BX], AL
    JBE INSERT_KEY
    
    ; Shift element right
    MOV DL, ARR[BX]
    MOV ARR[BX+1], DL
    DEC BX
    JMP SHIFT_LOOP
    
INSERT_KEY:
    MOV ARR[BX+1], AL
    
    INC SI
    POP CX
    LOOP OUTER_LOOP
    
    LEA DX, MSG
    MOV AH, 09H
    INT 21H
    
    MOV AH, 4CH
    INT 21H
MAIN ENDP
END MAIN
