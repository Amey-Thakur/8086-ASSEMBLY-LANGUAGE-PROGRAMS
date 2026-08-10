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

    ; Labels for the report at the end of the program.
    RPT_HEAD DB 0DH, 0AH, 'Results:', 0DH, 0AH, '$'
    RPT_NL   DB 0DH, 0AH, '$'
    RPT_N_VAL_N DB '  VAL_N = ', '$'
    RPT_N_RES_FINAL_SUM DB '  RES_FINAL_SUM = ', '$'
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
    
    ; -------------------------------------------------------------------------
    ; WHAT THIS PROGRAM COMPUTED
    ;
    ; The work above leaves its answers in the variables below. Printing them
    ; is what makes the program demonstrate itself rather than needing a
    ; debugger to be believed.
    ; -------------------------------------------------------------------------
    LEA DX, RPT_HEAD
    CALL RPT_SAY

    LEA DX, RPT_N_VAL_N
    CALL RPT_SAY
    XOR AX, AX
    MOV AL, VAL_N
    CALL RPT_DECIMAL
    LEA DX, RPT_NL
    CALL RPT_SAY

    LEA DX, RPT_N_RES_FINAL_SUM
    CALL RPT_SAY
    XOR AX, AX
    MOV AL, RES_FINAL_SUM
    CALL RPT_DECIMAL
    LEA DX, RPT_NL
    CALL RPT_SAY

    MOV AH, 4CH
    INT 21H
MAIN ENDP

; -----------------------------------------------------------------------------
; RPT_DECIMAL
;
; Prints the unsigned value in AX as decimal. Named apart from any helper the
; program already had, so adding this report cannot clash with it.
;
; The digits come out of the division lowest first, which is the wrong order to
; print them in, so they are pushed and then popped back off.
; -----------------------------------------------------------------------------
RPT_DECIMAL PROC
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX

    XOR CX, CX
    MOV BX, 10

RPT_SPLIT:
    XOR DX, DX
    DIV BX
    PUSH DX
    INC CX
    CMP AX, 0
    JNE RPT_SPLIT

RPT_EMIT:
    POP DX
    ADD DL, '0'
    MOV AH, 02H
    INT 21H
    LOOP RPT_EMIT

    POP DX
    POP CX
    POP BX
    POP AX
    RET
RPT_DECIMAL ENDP

; -----------------------------------------------------------------------------
; RPT_SAY
;
; Prints the dollar terminated string at DS:DX without disturbing AX, which
; matters because the caller usually has the value it is about to print there.
; -----------------------------------------------------------------------------
RPT_SAY PROC
    PUSH AX
    MOV AH, 09H
    INT 21H
    POP AX
    RET
RPT_SAY ENDP


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

