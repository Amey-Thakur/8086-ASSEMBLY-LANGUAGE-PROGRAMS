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

; -----------------------------------------------------------------------------
; DATA SEGMENT
; -----------------------------------------------------------------------------
DATA SEGMENT
    ; Input: The value of 'N' (sum from 1 to 10)
    N_VALUE DB 10                       
    
    ; Output: Buffer for the final sum
    ; Note: For N=10, Sum=55 (37H). For N=22, Sum=253 (Fits in 8-bit).
    FINAL_SUM DB ?                      
DATA ENDS                    

; -----------------------------------------------------------------------------
; CODE SEGMENT
; -----------------------------------------------------------------------------
CODE SEGMENT
    ASSUME DS:DATA, CS:CODE
    
START:
    ; --- Step 1: Initialize Data Segment ---
    MOV AX, DATA
    MOV DS, AX
    
    ; --- Step 2: Setup Loop and Accumulator ---
    ; We will use CX for the loop counter and AL as the accumulator.
    MOV CH, 00H                         ; Clear high byte of CX
    MOV CL, N_VALUE                     ; Initialize loop counter with N
    
    MOV AL, 00H                         ; Clear accumulator (Running Sum = 0)
    
    ; --- Step 3: Iterative Summation Loop ---
    ; Formula implemented: Sum = Sum + CL
    ; We add CL to the sum, then LOOP automatically decrements CX.
SUM_LOOP:
    ADD AL, CL                          ; AL = Current Sum + Current N
    
    ; LOOP instruction performs:
    ; 1. CX = CX - 1
    ; 2. If CX != 0, Jump to SUM_LOOP
    LOOP SUM_LOOP                       
    
    ; --- Step 4: Store Result ---
    MOV FINAL_SUM, AL                   
    
    ; --- Step 5: Clean Exit ---
    MOV AH, 4CH
    INT 21H
        
CODE ENDS 

; =============================================================================
; TECHNICAL NOTES & ARCHITECTURAL INSIGHTS
; =============================================================================
; 1. THE LOOP INSTRUCTION:
;    The 'LOOP' instruction is a specialized micro-coded instruction in the 
;    8086 that specifically uses CX (or ECX in 32-bit) as an implicit counter. 
;    It is functionally equivalent to:
;       DEC CX
;       JNZ label
;    However, it is more concise in machine code.
;
; 2. ARITHMETIC SERIES:
;    Mathematically, the sum of first N numbers is (N * (N+1)) / 2. 
;    While an iterative loop is slower than the formula, it demonstrates 
;    fundamental branching and register accumulation patterns.
;
; 3. OVERFLOW CAUTION:
;    This implementation uses 8-bit AL for the sum. If (N * (N+1)) / 2 
;    exceeds 255 (which happens when N > 22), the result will "wrap around" 
;    due to overflow. For larger N, a 16-bit register (AX) should be used.
;
; 4. REGISTER UTILIZATION:
;    - AL: Accumulator for the running total.
;    - CL: Current natural number being added (acting as the iterator).
;    - CX: The hardware loop control register.
;
; 5. PERFORMANCE:
;    The LOOP instruction takes 17 clock cycles when the jump is taken and 
;    5 cycles when it falls through.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =

END START

;=============================================================================
; NOTES:
; - Array traversal using register indirect addressing [BX]
; - BYTE PTR specifies byte-sized memory operand
; - For larger sums, check for carry and use 16-bit accumulator
;=============================================================================
