; Program: Delete Element from Array
; Description: Delete an element at a specified position in array
; Author: Amey Thakur

.MODEL SMALL
.STACK 100H

.DATA
    ARR DB 10H, 20H, 30H, 40H, 50H
    LEN EQU 5
    POS EQU 2        ; Position to delete (0-indexed)

.CODE
MAIN PROC
    MOV AX, @DATA
    MOV DS, AX
    
    ; Shift elements left from position+1 to end
    LEA SI, ARR
    ADD SI, POS + 1  ; Point to element after deletion position
    LEA DI, ARR
    ADD DI, POS      ; Point to deletion position
    
    MOV CX, LEN - 1
    SUB CX, POS      ; Number of elements to shift
    
SHIFT_LOOP:
    MOV AL, [SI]
    MOV [DI], AL
    INC SI
    INC DI
    LOOP SHIFT_LOOP
    
    ; Clear last element
    MOV BYTE PTR [DI], 0
    
    MOV AH, 4CH      ; Exit to DOS
    INT 21H
MAIN ENDP
END MAIN
