;=============================================================================
; Program:     Matrix Addition (3x3)
; Description: Demonstrate element-wise addition of two 3x3 matrices 
;              stored in row-major order.
; 
; Author:      Amey Thakur
; Repository:  https://github.com/Amey-Thakur/8086-ASSEMBLY-LANGUAGE-PROGRAMS
; License:     MIT License
;=============================================================================

.MODEL SMALL
.STACK 100H

;-----------------------------------------------------------------------------
; DATA SEGMENT
;-----------------------------------------------------------------------------
.DATA
    ; Matrix A (3x3) - Row Major Storage
    MATRIX_A DB 1, 2, 3
             DB 4, 5, 6
             DB 7, 8, 9
    
    ; Matrix B (3x3)
    MATRIX_B DB 9, 8, 7
             DB 6, 5, 4
             DB 3, 2, 1
    
    ; Matrix C (Resultant)
    MATRIX_C DB 9 DUP(0)
    
    DIM      EQU 3                       ; Dimension (N)
    MSG      DB 'Matrix Addition completed. Result stored in memory.$'

;-----------------------------------------------------------------------------
; CODE SEGMENT
;-----------------------------------------------------------------------------
.CODE
MAIN PROC
    ; Initialize Data Segment
    MOV AX, @DATA
    MOV DS, AX
    
    ; Pointers for the three matrices
    LEA SI, MATRIX_A                    ; Source Index 1
    LEA DI, MATRIX_B                    ; Destination Index (used as Source 2)
    LEA BX, MATRIX_C                    ; Base Register (Result pointer)
    
    ; Total elements in a 3x3 matrix = 9
    MOV CX, DIM * DIM
    
;-------------------------------------------------------------------------
; ELEMENT-WISE ADDITION LOOP
; Logic: C[i] = A[i] + B[i]
; Since matrices are flat arrays in memory, a single loop handles all indices.
;-------------------------------------------------------------------------
ADD_LOOP:
    MOV AL, [SI]                        ; Fetch element from A
    ADD AL, [DI]                        ; Add element from B
    MOV [BX], AL                        ; Store sum in C
    
    INC SI                              ; Point to next element in A
    INC DI                              ; Point to next element in B
    INC BX                              ; Point to next element in C
    LOOP ADD_LOOP                       ; Repeat 9 times
    
    ; Display status
    LEA DX, MSG
    MOV AH, 09H
    INT 21H
    
    ; Exit
    MOV AH, 4CH
    INT 21H
MAIN ENDP
END MAIN

;=============================================================================
; MATRIX MEMORY NOTES:
; - Row-Major Order: Matrix is stored row by row (A[0][0], A[0][1]...).
; - Adding two matrices of the same size is essentially a linear vector addition.
; - Expected Result (all 10s):
;   10, 10, 10
;   10, 10, 10
;   10, 10, 10
;=============================================================================
