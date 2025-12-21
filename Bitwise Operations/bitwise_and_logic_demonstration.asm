; =============================================================================
; TITLE: Bitwise Logical AND Operation (Masking & Intersection)
; DESCRIPTION: This program demonstrates the 8086 'AND' instruction, which 
;              performs a bitwise logical intersection between two 8-bit 
;              operands. It illustrates how AND can be used to isolate specific 
;              bit-fields or "mask out" unwanted data.
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
    ; Operands for bitwise logic
    VALUE_A  DB 0FH                     ; 0000 1111 (Lower Nibble set)
    VALUE_B  DB 0F0H                    ; 1111 0000 (Upper Nibble set)
    
    ; Variable to store the intersection result
    AND_RES  DB ?                         

; -----------------------------------------------------------------------------
; CODE SEGMENT
; -----------------------------------------------------------------------------
.CODE
MAIN PROC
    ; --- Step 1: Initialize Data Segment ---
    MOV AX, @DATA
    MOV DS, AX
    
    ; --- Step 2: Load Operands ---
    MOV AL, VALUE_A                     ; AL = 0000 1111
    
    ; --- Step 3: Execute Bitwise AND ---
    ; Truth Table for AND:
    ; A=0, B=0 -> 0 | A=1, B=0 -> 0
    ; A=0, B=1 -> 0 | A=1, B=1 -> 1
    
    AND AL, VALUE_B                     ; AL = (0000 1111) AND (1111 0000)
    
    ; Calculation Result:
    ;   0000 1111
    ; & 1111 0000
    ; -----------
    ;   0000 0000 -> 00H
    
    ; --- Step 4: Persist Result and Reflect Flags ---
    MOV AND_RES, AL                     
    
    ; --- Step 5: Termination ---
    MOV AH, 4CH                         
    INT 21H
MAIN ENDP

END MAIN

; =============================================================================
; TECHNICAL NOTES & ARCHITECTURAL INSIGHTS
; =============================================================================
; 1. BITWISE MASKING:
;    The AND instruction is primarily used for masking. To "clear" or "mask out" 
;    bits, you AND them with 0. To "keep" bits, you AND them with 1.
;    Example: AND AL, 0FH will preserve the lower 4 bits and zero the upper 4.
;
; 2. FLAG REGISTER INTERACTIONS:
;    The AND instruction affects several status flags in the 8086:
;    - Carry Flag (CF) & Overflow Flag (OF): Always cleared (reset to 0).
;    - Zero Flag (ZF): Set if the result is 0 (as in this program).
;    - Sign Flag (SF): Set if the Most Significant Bit (MSB) of the result is 1.
;    - Parity Flag (PF): Set if the lower 8 bits of the result have even parity.
;
; 3. PERFORMANCE:
;    Bitwise operations are "single-cycle" or "near-single-cycle" instructions 
;    on the 8086 Execution Unit (EU), making them significantly faster than 
;    multiplication or division.
;
; 4. REGISTER USAGE:
;    AND can be performed between registers, or between a register and memory. 
;    Direct memory-to-memory AND is not supported; one operand must be a register.
;
; 5. PARITY COMPUTATION:
;    Unlike some higher-level languages, assembly allows for direct parity 
;    checking via PF. This is often used in low-level communication protocols 
;    to verify data integrity.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
