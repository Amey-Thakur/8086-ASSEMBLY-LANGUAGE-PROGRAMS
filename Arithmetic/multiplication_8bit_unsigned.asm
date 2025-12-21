; =============================================================================
; TITLE: 8-bit Unsigned Multiplication Demo
; DESCRIPTION: This program demonstrates the multiplication of two 8-bit unsigned 
;              integers. It illustrates how the 8086 automatically expands 
;              the product into a 16-bit register (AX) to prevent data loss 
;              from overflow.
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
    ; Inputs (8-bit bytes)
    VAL8_1 DB 0EDH                      ; 237 decimal
    VAL8_2 DB 99H                       ; 153 decimal
    
    ; Output (16-bit Product)
    PRODUCT DW ?                        ; 237 * 153 = 36261 (8DA5H)

; -----------------------------------------------------------------------------
; CODE SEGMENT
; -----------------------------------------------------------------------------
.CODE
MAIN PROC
    ; --- Step 1: Initialize Data Segment ---
    MOV AX, @DATA
    MOV DS, AX
    
    ; --- Step 2: Load Operands ---
    ; For 8-bit multiplication, the first operand MUST be in AL.
    MOV AL, VAL8_1                      
    MOV BL, VAL8_2                      
    
    ; --- Step 3: Perform Unsigned Multiplication ---
    ; Result is automatically stored in the full AX register.
    MUL BL                              
    
    ; --- Step 4: Store Result ---
    MOV PRODUCT, AX                     
    
    ; --- Step 5: Finalize ---
    MOV AH, 4CH
    INT 21H
MAIN ENDP

END MAIN

; =============================================================================
; TECHNICAL NOTES & ARCHITECTURAL INSIGHTS
; =============================================================================
; 1. MUL OPERAND MATCHING:
;    The 8086 supports two multiplication modes based on operand size:
;    - Byte Multiplication: AL * Reg8 -> AX (Result)
;    - Word Multiplication: AX * Reg16 -> DX:AX (Result)
;
; 2. THE CARRY & OVERFLOW FLAGS (CF/OF):
;    After 'MUL BL', if the product requires the upper half (AH), CF and OF 
;    are set. This allows quick overflow detection.
;
; 3. ACCUMULATOR BOTTLENECK:
;    One operand is always implicitly tied to the accumulator (AL or AX). 
;
; 4. SIGNED MULTIPLICATION:
;    Use the 'IMUL' instruction for signed (Two's Complement) products.
;
; 5. PERFORMANCE:
;    Multiplication is a cycle-heavy operation. On an original 8086, 
;    'MUL BL' can take between 70 to 77 clock cycles.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
