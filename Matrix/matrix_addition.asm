; Program: Matrix Addition
; Description: Add two 3x3 matrices
; Author: Amey Thakur
; Keywords: 8086 matrix, matrix addition, 2D array

.MODEL SMALL
.STACK 100H

.DATA
    MATRIX_A DB 1, 2, 3
             DB 4, 5, 6
             DB 7, 8, 9
    
    MATRIX_B DB 9, 8, 7
             DB 6, 5, 4
             DB 3, 2, 1
    
    MATRIX_C DB 9 DUP(0)  ; Result matrix
    
    SIZE_N EQU 3         ; Matrix dimension
    MSG DB 'Matrix addition complete$'

.CODE
MAIN PROC
    MOV AX, @DATA
    MOV DS, AX
    
    LEA SI, MATRIX_A
    LEA DI, MATRIX_B
    LEA BX, MATRIX_C
    
    MOV CX, SIZE_N * SIZE_N  ; Total elements
    
ADD_LOOP:
    MOV AL, [SI]     ; Get element from A
    ADD AL, [DI]     ; Add element from B
    MOV [BX], AL     ; Store in C
    
    INC SI
    INC DI
    INC BX
    LOOP ADD_LOOP
    
    ; Result in MATRIX_C:
    ; 10, 10, 10
    ; 10, 10, 10
    ; 10, 10, 10
    
    LEA DX, MSG
    MOV AH, 09H
    INT 21H
    
    MOV AH, 4CH
    INT 21H
MAIN ENDP
END MAIN
