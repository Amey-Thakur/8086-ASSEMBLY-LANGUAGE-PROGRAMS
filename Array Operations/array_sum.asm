;=============================================================================
; Program:     Sum of Array Elements
; Description: Calculate the sum of all elements in an array.
;              Demonstrates array traversal and accumulator pattern.
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
    ARR DB 10H, 20H, 30H, 40H, 50H     ; Array: 16+32+48+64+80 = 240 (F0H)
    LEN EQU 5                           ; Number of elements
    SUM DW ?                            ; Sum result (16-bit for larger sums)

;-----------------------------------------------------------------------------
; CODE SEGMENT
;-----------------------------------------------------------------------------
.CODE
MAIN PROC
    ; Initialize Data Segment
    MOV AX, @DATA
    MOV DS, AX
    
    ;-------------------------------------------------------------------------
    ; Initialize Loop Variables
    ;-------------------------------------------------------------------------
    LEA SI, ARR                         ; SI points to array start
    MOV CL, LEN                         ; Loop counter
    XOR AX, AX                          ; Clear accumulator (AX = 0)
    
    ;-------------------------------------------------------------------------
    ; Sum Loop - Add each element to accumulator
    ;-------------------------------------------------------------------------
SUM_LOOP:
    MOV BL, [SI]                        ; Load current element (8-bit)
    XOR BH, BH                          ; Clear high byte for 16-bit addition
    ADD AX, BX                          ; Add element to running sum
    INC SI                              ; Point to next element
    DEC CL                              ; Decrement counter
    JNZ SUM_LOOP                        ; Continue if not done
    
    ;-------------------------------------------------------------------------
    ; Store Result
    ; Sum: 10H + 20H + 30H + 40H + 50H = F0H (240 decimal)
    ;-------------------------------------------------------------------------
    MOV SUM, AX                         ; Store 16-bit sum
    
    ;-------------------------------------------------------------------------
    ; Program Termination
    ;-------------------------------------------------------------------------
    MOV AH, 4CH                         ; DOS: Terminate program
    INT 21H
MAIN ENDP
END MAIN

;=============================================================================
; NOTES:
; - Using 16-bit accumulator (AX) prevents overflow for larger sums
; - XOR BH, BH clears high byte when adding 8-bit values to 16-bit register
; - Maximum sum of five 8-bit values: 255 * 5 = 1275 (fits in 16 bits)
;=============================================================================
