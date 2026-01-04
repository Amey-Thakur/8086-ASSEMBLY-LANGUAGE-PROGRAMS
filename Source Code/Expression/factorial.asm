; =============================================================================
; TITLE: Factorial Calculation (Recursion)
; DESCRIPTION: Computes the factorial of a number (N!) using value-passing 
;              recursion. Demonstrates stack frame management relative to 
;              procedures in 8086 assembly.
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
    INPUT_N    DW 5                     ; Calculate 5! = 120
    RESULT_LO  DW ?                     ; Lower 16-bits
    RESULT_HI  DW ?                     ; Upper 16-bits (for > 65535)

; -----------------------------------------------------------------------------
; CODE SEGMENT
; -----------------------------------------------------------------------------
.CODE
MAIN PROC
    ; --- Step 1: Initialize Data Segment ---
    MOV AX, @DATA
    MOV DS, AX
    
    ; --- Step 2: Prepare Recursion ---
    MOV AX, 1                           ; Initialize Accumulator
    MOV BX, INPUT_N                     ; Load N
    
    ; Check Base Case 0! = 1
    CMP BX, 0
    JE L_STORE_RESULT
    
    CALL CALC_FACTORIAL
    
L_STORE_RESULT:
    MOV RESULT_LO, AX
    MOV RESULT_HI, DX
    
    ; --- Step 3: Termination ---
    MOV AH, 4CH
    INT 21H
MAIN ENDP

; -----------------------------------------------------------------------------
; PROCEDURE: CALC_FACTORIAL
; INPUT:  BX = N
; OUTPUT: DX:AX = Result
; LOGIC:  Recursive Call until BX=1. Then Unwind multiplying AX * BX.
; -----------------------------------------------------------------------------
CALC_FACTORIAL PROC
    ; Base Case: If BX == 1, Return
    CMP BX, 1
    JE L_BASE_RET
    
    PUSH BX                             ; Save current N
    DEC BX                              ; N = N - 1
    CALL CALC_FACTORIAL                 ; Recursive Call
    
    POP BX                              ; Restore N (Unwinding)
    MUL BX                              ; AX = AX * BX (Result * N)
    RET
    
L_BASE_RET:
    MOV AX, 1                           ; 1! = 1
    MOV DX, 0
    RET
CALC_FACTORIAL ENDP

END MAIN

; =============================================================================
; TECHNICAL NOTES & ARCHITECTURAL INSIGHTS
; =============================================================================
; 1. RECURSION ON THE STACK:
;    Each CALL pushes the Return Address (IP).
;    Each PUSH BX saves the state of 'N' for that depth.
;    Stack Depth = N * 2 bytes (BX) + N * 2 bytes (IP) = 4N bytes overhead.
;
; 2. MULTIPLICATION LIMITS:
;    - MUL BX multiplies AX by BX. Result is in DX:AX (32-bit).
;    - 8! = 40,320 (Fits in AX).
;    - 9! = 362,880 (Requires DX:AX).
;    This implementation supports results up to DX:AX limits, though we assume 
;    input <= 8 for simple 16-bit logic in MAIN display if we added one.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
