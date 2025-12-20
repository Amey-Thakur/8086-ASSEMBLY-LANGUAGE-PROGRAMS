; Program: Selection Sort
; Description: Sort an array using selection sort algorithm
; Author: Amey Thakur

.MODEL SMALL
.STACK 100H

.DATA
    ARR DB 64, 25, 12, 22, 11
    LEN EQU 5
    MSG DB 'Array sorted using Selection Sort$'

.CODE
MAIN PROC
    MOV AX, @DATA
    MOV DS, AX
    
    ; Selection Sort
    MOV CX, LEN - 1  ; Outer loop counter (n-1 passes)
    XOR SI, SI       ; i = 0
    
OUTER_LOOP:
    PUSH CX
    MOV DI, SI       ; min_idx = i
    MOV BX, SI
    INC BX           ; j = i + 1
    
    ; Find minimum in unsorted part
    MOV CX, LEN
    SUB CX, SI
    DEC CX           ; Inner loop count
    
FIND_MIN:
    MOV AL, ARR[BX]
    CMP AL, ARR[DI]
    JAE NOT_SMALLER
    MOV DI, BX       ; Update min_idx
NOT_SMALLER:
    INC BX
    LOOP FIND_MIN
    
    ; Swap ARR[i] and ARR[min_idx]
    CMP DI, SI
    JE NO_SWAP
    MOV AL, ARR[SI]
    MOV BL, ARR[DI]
    MOV ARR[SI], BL
    MOV ARR[DI], AL
    
NO_SWAP:
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
