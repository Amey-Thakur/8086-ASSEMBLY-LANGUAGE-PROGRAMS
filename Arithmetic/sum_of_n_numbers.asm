;=============================================================================
; Program:     Sum of N 8-bit Numbers in Array
; Description: Calculate sum of 10 numbers stored in an array.
;              Demonstrates array traversal and accumulator pattern.
; 
; Author:      Amey Thakur
; Repository:  https://github.com/Amey-Thakur/8086-ASSEMBLY-LANGUAGE-PROGRAMS
; License:     MIT License
;=============================================================================

;-----------------------------------------------------------------------------
; DATA SEGMENT
;-----------------------------------------------------------------------------
DATA SEGMENT
    arr DB 1,2,3,4,5,6,7,8,9,10         ; Array of 10 numbers (sum = 55)
DATA ENDS                    

;-----------------------------------------------------------------------------
; CODE SEGMENT
;-----------------------------------------------------------------------------
CODE SEGMENT
    ASSUME DS:DATA, CS:CODE
    
    START:
        ; Initialize Data Segment
        MOV AX, DATA
        MOV DS, AX
        
        ;---------------------------------------------------------------------
        ; Initialize Registers
        ;---------------------------------------------------------------------
        MOV CL, 10                      ; Loop counter (10 elements)
        LEA BX, arr                     ; BX points to array start
        MOV AH, 00                      ; Clear high byte of result
        MOV AL, 00                      ; Clear accumulator
        
        ;---------------------------------------------------------------------
        ; Sum Loop - Add each element to accumulator
        ;---------------------------------------------------------------------
    L1:
        ADD AL, BYTE PTR[BX]            ; Add current element to AL
        INC BX                          ; Point to next element
        DEC CL                          ; Decrement counter
        CMP CL, 00                      ; Check if done
        JNZ L1                          ; If not zero, continue loop
        
        ; Result: AL = 55 (1+2+3+4+5+6+7+8+9+10)
        
        ;---------------------------------------------------------------------
        ; Program Termination
        ;---------------------------------------------------------------------
        MOV AH, 4CH
        INT 21H
        
CODE ENDS 

END START

;=============================================================================
; NOTES:
; - Array traversal using register indirect addressing [BX]
; - BYTE PTR specifies byte-sized memory operand
; - For larger sums, check for carry and use 16-bit accumulator
;=============================================================================
