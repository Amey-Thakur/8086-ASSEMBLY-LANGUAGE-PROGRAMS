;=============================================================================
; Program:     Integer Square Root
; Description: Calculate the integer part of the square root of a 16-bit
;              unsigned number using the iterative 'Square Search' method.
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
    NUM DW 144                          ; Input: Find sqrt of 144
    ROOT DW ?                           ; Storage for final result (12)
    MSG DB 'Integer Square Root calculated.$'

;-----------------------------------------------------------------------------
; CODE SEGMENT
;-----------------------------------------------------------------------------
.CODE
MAIN PROC
    ; Initialize DS
    MOV AX, @DATA
    MOV DS, AX
    
    MOV BX, NUM                         ; BX stores the target number
    MOV CX, 1                           ; Iterative counter 'n'
    
;-------------------------------------------------------------------------
; ITERATIVE SEARCH: Find largest n where (n * n) <= target
;-------------------------------------------------------------------------
FIND_ROOT:
    MOV AX, CX
    MUL CX                              ; AX = CX^2
    
    ; Check if we exceeded the target
    CMP AX, BX
    JA TARGET_EXCEEDED                 ; If n^2 > NUM, (n-1) was the root
    
    MOV ROOT, CX                        ; Save current valid integer root
    INC CX                              ; Test next value
    
    ; Prevent infinite loop for large numbers (CX > 255 for 16-bit range)
    CMP CX, 256
    JE TARGET_EXCEEDED
    
    JMP FIND_ROOT
    
TARGET_EXCEEDED:
    ; Status display
    LEA DX, MSG
    MOV AH, 09H
    INT 21H
    
    ; Result is now in ROOT memory location
    
    ; Exit
    MOV AH, 4CH
    INT 21H
MAIN ENDP
END MAIN

;=============================================================================
; SQUARE ROOT NOTES:
; - This is an O(sqrt(N)) algorithm.
; - For a 16-bit input (max 65535), the max possible root is 255.
; - More efficient algorithms like "Newton-Raphson" or "Binary Search" 
;   exist for large ranges, but this linear search is simplest for 8086 logic.
;=============================================================================
