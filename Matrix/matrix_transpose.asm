; Program: Matrix Transpose
; Description: Transpose a 3x3 matrix
; Author: Amey Thakur
; Keywords: 8086 matrix transpose, 2D array

.MODEL SMALL
.STACK 100H

.DATA
    MATRIX DB 1, 2, 3
           DB 4, 5, 6
           DB 7, 8, 9
    
    RESULT DB 9 DUP(0)
    
    SIZE_N EQU 3
    MSG DB 'Matrix transposed$'

.CODE
MAIN PROC
    MOV AX, @DATA
    MOV DS, AX
    
    XOR SI, SI       ; Source index
    MOV CX, SIZE_N   ; Row counter
    MOV BL, 0        ; Source row
    
ROW_LOOP:
    PUSH CX
    MOV CX, SIZE_N   ; Column counter
    XOR BH, BH       ; Column index
    
COL_LOOP:
    ; Calculate source index: row * SIZE_N + col
    MOV AL, BL
    MOV DL, SIZE_N
    MUL DL
    ADD AL, BH
    MOV SI, AX
    
    ; Get element
    MOV AL, MATRIX[SI]
    
    ; Calculate destination index: col * SIZE_N + row (transposed)
    MOV DL, BH
    MOV AH, SIZE_N
    XCHG AL, DL
    MUL AH
    ADD AL, BL
    MOV DI, AX
    
    ; Store transposed element
    MOV RESULT[DI], DL
    
    INC BH           ; Next column
    LOOP COL_LOOP
    
    INC BL           ; Next row
    POP CX
    LOOP ROW_LOOP
    
    ; Original:       Transposed:
    ; 1 2 3          1 4 7
    ; 4 5 6    =>    2 5 8
    ; 7 8 9          3 6 9
    
    LEA DX, MSG
    MOV AH, 09H
    INT 21H
    
    MOV AH, 4CH
    INT 21H
MAIN ENDP
END MAIN
