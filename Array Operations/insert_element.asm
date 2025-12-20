; Program: Insert Element in Array
; Description: Insert an element at a specified position in array
; Author: Amey Thakur

.MODEL SMALL
.STACK 100H

.DATA
    ARR DB 10H, 20H, 30H, 40H, 50H, 0  ; Extra space for new element
    LEN EQU 5
    POS EQU 2        ; Position to insert (0-indexed)
    ELEM DB 25H      ; Element to insert

.CODE
MAIN PROC
    MOV AX, @DATA
    MOV DS, AX
    
    ; Shift elements right from end to position
    LEA SI, ARR
    ADD SI, LEN - 1  ; Point to last element
    LEA DI, ARR
    ADD DI, LEN      ; Point to new last position
    
    MOV CX, LEN
    SUB CX, POS      ; Number of elements to shift
    
SHIFT_LOOP:
    MOV AL, [SI]
    MOV [DI], AL
    DEC SI
    DEC DI
    LOOP SHIFT_LOOP
    
    ; Insert new element
    LEA SI, ARR
    ADD SI, POS
    MOV AL, ELEM
    MOV [SI], AL
    
    MOV AH, 4CH      ; Exit to DOS
    INT 21H
MAIN ENDP
END MAIN
