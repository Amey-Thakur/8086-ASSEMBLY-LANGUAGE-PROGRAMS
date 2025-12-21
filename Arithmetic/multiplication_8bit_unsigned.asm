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

; -----------------------------------------------------------------------------
; DATA SEGMENT
; -----------------------------------------------------------------------------
DATA SEGMENT
    ; Inputs (8-bit bytes)
    VAL8_1 DB 0EDH                      ; 237 decimal
    VAL8_2 DB 99H                       ; 153 decimal
    
    ; Output (16-bit Product)
    PRODUCT DW ?                        ; 237 * 153 = 36261 (8DA5H)
DATA ENDS          

; -----------------------------------------------------------------------------
; CODE SEGMENT
; -----------------------------------------------------------------------------
CODE SEGMENT
    ASSUME CS:CODE, DS:DATA

START: 
    ; --- Step 1: Initialize Data Segment ---
    MOV AX, DATA
    MOV DS, AX
    
    ; --- Step 2: Load Operands ---
    ; For 8-bit multiplication, the first operand MUST be in the AL register.
    MOV AL, VAL8_1                      
    MOV BL, VAL8_2                      
    
    ; --- Step 3: Perform Unsigned Multiplication ---
    ; Instruction Logic for 'MUL BL':
    ; 1. The 8-bit value in AL is multiplied by the 8-bit value in BL.
    ; 2. The result can be up to 16 bits long (255 * 255 = 65025).
    ; 3. The product is automatically stored in the full AX register.
    ;    (AH = High 8 bits, AL = Low 8 bits)
    MUL BL                              
    
    ; --- Step 4: Store Result ---
    MOV PRODUCT, AX                     
    
    ; --- Step 5: Finalize ---
    MOV AH, 4CH
    INT 21H
            
CODE ENDS

; =============================================================================
; TECHNICAL NOTES & ARCHITECTURAL INSIGHTS
; =============================================================================
; 1. MUL OPERAND MATCHING:
;    The 8086 supports two multiplication modes based on operand size:
;    - Byte Multiplication: AL * Reg8 -> AX (Result)
;    - Word Multiplication: AX * Reg16 -> DX:AX (Result)
;
; 2. THE CARRY & OVERFLOW FLAGS (CF/OF):
;    Mul is unique in its flag handling. After 'MUL BL':
;    - If the product fits within the lower half (AL) and AH is zero, 
;      CF and OF are cleared (0).
;    - If the product requires the upper half (AH), CF and OF are set (1).
;    - This provides a quick way to check if a multi-word result was generated.
;
; 3. ACCUMULATOR BOTTLENECK:
;    In the 8086, multiplication is rigid; one operand is always implicitly 
;    tied to the accumulator (AL or AX). Later processors relaxed this 
;    restriction.
;
; 4. SIGNED MULTIPLICATION:
;    Use the 'IMUL' instruction if the operands represent signed numbers 
;    (negative values), as the binary logic for signed products is different.
;
; 5. PERFORMANCE:
;    Multiplication is a cycle-heavy operation compared to addition. On an 
;    original 8086, 'MUL BL' can take between 70 to 77 clock cycles.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =

END START

;=============================================================================
; NOTES:
; - MUL performs unsigned multiplication
; - For 8-bit multiplication: AX = AL * operand
; - For 16-bit multiplication: DX:AX = AX * operand
; - Use IMUL for signed multiplication
;=============================================================================
