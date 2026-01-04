; =============================================================================
; TITLE: 16-bit and 8-bit Addition Demonstration
; DESCRIPTION: This program demonstrates basic arithmetic operations using 
;              both 8-bit and 16-bit operands in the Intel 8086. It covers 
;              register usage, memory-to-register transfers, and foundational 
;              binary addition mechanics.
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
    ; 8-bit variables (DB = Define Byte, 8 bits)
    VAL8_1 DB 05H                       ; Example 8-bit value 1
    VAL8_2 DB 06H                       ; Example 8-bit value 2
    SUM8   DB ?                         ; 8-bit result buffer
    
    ; 16-bit variables (DW = Define Word, 16 bits)
    VAL16_1 DW 1234H                    ; Example 16-bit value 1
    VAL16_2 DW 0055H                    ; Example 16-bit value 2
    SUM16   DW ?                        ; 16-bit result buffer

; -----------------------------------------------------------------------------
; CODE SEGMENT
; -----------------------------------------------------------------------------
.CODE
MAIN PROC
    ; --- Step 1: Initialize the Data Segment ---
    ; In the 8086 architecture, the DS register cannot be loaded directly with 
    ; an immediate value. We use AX as an intermediary.
    MOV AX, @DATA
    MOV DS, AX                   
    
    ; --- Step 2: 8-bit Addition (Byte-level) ---
    ; We use the AL (Accumulator Low) register for 8-bit operations.
    MOV AL, VAL8_1                 
    ADD AL, VAL8_2                 ; AL = 05H + 06H = 0BH
    MOV SUM8, AL                   ; Store the 8-bit result back to memory
    
    ; --- Step 3: 16-bit Addition (Word-level) ---
    ; We use the CX register as a 16-bit general-purpose accumulator here.
    MOV CX, VAL16_1                
    ADD CX, VAL16_2                ; CX = 1234H + 0055H = 1289H
    MOV SUM16, CX                  ; Store the 16-bit result back to memory
    
    ; --- Step 4: DOS Termination ---
    MOV AH, 4CH
    INT 21H
MAIN ENDP

END MAIN 

; =============================================================================
; TECHNICAL NOTES & ARCHITECTURAL INSIGHTS
; =============================================================================
; 1. REGISTER HIERARCHY: 
;    - The general-purpose registers AX, BX, CX, DX are 16-bit.
;    - Each can be split into two 8-bit registers (e.g., AH and AL).
;    - This allows for memory-efficient processing of byte-sized data.
;
; 2. OPERAND SIZE MATCHING:
;    - The Intel 8086 is a CISC processor that requires operands in an 
;      instruction (like ADD) to be of the exact same size.
;    - Illegal: 'ADD AX, BL' (16-bit + 8-bit) will result in an assembler error.
;
; 3. FLAG REGISTER (PSW) UPDATES:
;    - CARRY FLAG (CF): Set if the result exceeds the register size (Unsigned).
;    - ZERO FLAG (ZF): Set if the mathematical result is exactly zero.
;    - SIGN FLAG (SF): Set if the most significant bit (MSB) of the result is 1.
;    - OVERFLOW FLAG (OF): Set if the result is out of range for Signed arithmetic.
;
; 4. DATA ALIGNMENT:
;    - While the 8086 can access bytes at any address, 16-bit 'Word' accesses 
;      are faster when aligned to even memory addresses.
;
; 5. SEGMENT INITIALIZATION:
;    - The 'MOV DS, AX' step is critical. Without it, the program will look 
;      for variables in an undefined segment, leading to memory corruption or 
;      crashes.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =

