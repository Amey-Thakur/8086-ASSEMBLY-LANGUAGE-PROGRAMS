; =============================================================================
; TITLE: Summation of the First 'N' Natural Numbers
; DESCRIPTION: This program calculates the sum of the first N natural numbers 
;              (1 + 2 + 3 + ... + N) iteratively. It demonstrates the use of 
;              the 8086 LOOP instruction, register-based accumulation, and 
;              handling of 8-bit unsigned integer limits.
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
    VAL_N         DB 10                 ; Input: (Sum from 1 to 10)
    RES_FINAL_SUM DB ?                  ; Buffer for final result

; -----------------------------------------------------------------------------
; CODE SEGMENT
; -----------------------------------------------------------------------------
.CODE
MAIN PROC
    ; --- Step 1: Initialize Data Segment ---
    MOV AX, @DATA
    MOV DS, AX
    
    ; --- Step 2: Setup Loop and Accumulator ---
    MOV CH, 00H                         
    MOV CL, VAL_N                       
    MOV AL, 00H                         ; Clear accumulator
    
    ; --- Step 3: Iterative Summation Loop ---
L_SUM_LOOP:
    ADD AL, CL                          
    LOOP L_SUM_LOOP                     
    
    ; --- Step 4: Store Result ---
    MOV RES_FINAL_SUM, AL                   
    
    ; --- Step 5: Clean Exit ---
    MOV AH, 4CH
    INT 21H
MAIN ENDP

END MAIN

; =============================================================================
; TECHNICAL NOTES & ARCHITECTURAL INSIGHTS
; =============================================================================
; 1. THE LOOP INSTRUCTION:
;    The 'LOOP' instruction is a specialized micro-coded instruction that 
;    uses CX as an implicit counter. It decrements CX and jumps if not zero.
;
; 2. ARITHMETIC SERIES:
;    Sum = (N * (N+1)) / 2. Iterative loops provide a clear demonstration 
;    of register accumulation patterns.
;
; 3. OVERFLOW CAUTION:
;    Summing up to N=22 fits in an 8-bit register. For N > 22, the result 
;    exceeds 255. In such cases, use a 16-bit register like AX for the total.
;
; 4. REGISTER UTILIZATION:
;    - AL: Accumulator for the running total.
;    - CL: Current natural number (iterator).
;    - CX: Hardware loop control register.
;
; 5. PERFORMANCE:
;    The LOOP instruction takes significantly more cycles than a simple 
;    JNZ on original hardware but provides code compactness.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =

