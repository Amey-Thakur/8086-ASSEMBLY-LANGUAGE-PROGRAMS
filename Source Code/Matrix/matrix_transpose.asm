; =============================================================================
; TITLE: Matrix Transpose (3x3)
; DESCRIPTION: Transpose a 3x3 matrix (swap rows with columns) using 
;              nested loops and linear index calculation.
; AUTHOR: Amey Thakur (https://github.com/Amey-Thakur)
; REPOSITORY: https://github.com/Amey-Thakur/8086-ASSEMBLY-LANGUAGE-PROGRAMS
; LICENSE: MIT License
; =============================================================================

.MODEL SMALL
.STACK 100H

; -----------------------------------------------------------------------------
; DATA SEGMENT
; -----------------------------------------------------------------------------
.DATA
    ; Source Matrix (3x3)
    MATRIX DB 1, 2, 3
           DB 4, 5, 6
           DB 7, 8, 9
    
    ; Transposed Matrix Result
    RESULT DB 9 DUP(0)
    
    DIM    EQU 3                         ; N x N
    MSG    DB 'Matrix Transpose completed successfully.$'

; -----------------------------------------------------------------------------
; CODE SEGMENT
; -----------------------------------------------------------------------------
.CODE
MAIN PROC
    ; Initialize environment
    MOV AX, @DATA
    MOV DS, AX
    
    MOV BL, 0                           ; Source Row index (i)
    MOV CX, DIM                         ; Outer Loop counter (rows)
    
    ; -------------------------------------------------------------------------
    ; OUTER LOOP: Iterate through Rows (i)
    ; -------------------------------------------------------------------------
ROW_LOOP:
    PUSH CX                             ; Save outer counter
    MOV BH, 0                           ; Source Column index (j)
    MOV CX, DIM                         ; Inner Loop counter (columns)
    
    ; -------------------------------------------------------------------------
    ; INNER LOOP: Iterate through Columns (j)
    ; -------------------------------------------------------------------------
COL_LOOP:
    ; 1. Calculate source index: SI = (i * DIM) + j
    MOV AL, BL                          ; Get row index
    MOV DL, DIM                         ; Get dimension
    MUL DL                              ; AL = i * 3
    ADD AL, BH                          ; AL = (i * 3) + j
    MOV SI, AX                          ; Offset for original element
    
    ; Load element from source
    MOV AL, MATRIX[SI]
    
    ; 2. Calculate destination index: DI = (j * DIM) + i  [Transposed]
    MOV DL, BH                          ; Get column index
    MOV AH, DIM                         ; Get dimension
    ; We need to preserve AL (the element), so use temporary math
    PUSH AX
    MOV AL, DL
    MUL AH                              ; AL = j * 3
    ADD AL, BL                          ; AL = (j * 3) + i
    MOV DI, AX                          ; Offset for result element
    POP AX                              ; Restore original element in AL
    
    ; Store into result
    MOV RESULT[DI], AL
    
    INC BH                              ; Next column (j++)
    LOOP COL_LOOP                       ; Repeat for all columns in current row
    
    INC BL                              ; Next row (i++)
    POP CX                              ; Restore row counter
    LOOP ROW_LOOP                       ; Repeat for all rows
    
    ; -------------------------------------------------------------------------
    ; Finish
    ; -------------------------------------------------------------------------
    LEA DX, MSG
    MOV AH, 09H
    INT 21H
    
    MOV AH, 4CH
    INT 21H
MAIN ENDP
END MAIN

; =============================================================================
; TECHNICAL NOTES
; =============================================================================
; 1. LOGIC:
;    - Transpose swaps Element[i][j] with Element[j][i].
;    - Memory Index calculation for Element[row][col] is: (row * Width) + col.
;    - Original:       Transposed:
;      1 2 3           1 4 7
;      4 5 6     =>    2 5 8
;      7 8 9           3 6 9
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
