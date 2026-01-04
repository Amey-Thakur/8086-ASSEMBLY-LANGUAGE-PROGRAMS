; =============================================================================
; TITLE: Bitwise Logical NOT Operation (One's Complement)
; DESCRIPTION: This program demonstrates the 8086 'NOT' instruction, which 
;              performs a bitwise logical negation. This operation inverts 
;              every bit in the operand (0 becomes 1, and 1 becomes 0), effectively 
;              calculating the One's Complement of a value.
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
    ; Original value: 0000 1111 (0FH / 15 decimal)
    ORIG_VAL DB 0FH                     
    
    ; Buffer for negation result
    NOT_RES  DB ?                         

; -----------------------------------------------------------------------------
; CODE SEGMENT
; -----------------------------------------------------------------------------
.CODE
MAIN PROC
    ; --- Step 1: Initialize Data Segment ---
    MOV AX, @DATA
    MOV DS, AX
    
    ; --- Step 2: Load Target Value ---
    MOV AL, ORIG_VAL                    ; AL = 0000 1111
    
    ; --- Step 3: Execute Bitwise NOT ---
    ; Truth Table for NOT:
    ; Input 0 -> Output 1
    ; Input 1 -> Output 0
    
    NOT AL                              ; Invert all bits in AL
    
    ; Calculation Trace:
    ; Input:  0 0 0 0 1 1 1 1  (0FH)
    ; Output: 1 1 1 1 0 0 0 0  (F0H)
    
    ; --- Step 4: Persist Results ---
    MOV NOT_RES, AL                     
    
    ; --- Step 5: Termination ---
    MOV AH, 4CH                         
    INT 21H
MAIN ENDP

END MAIN

; =============================================================================
; TECHNICAL NOTES & ARCHITECTURAL INSIGHTS
; =============================================================================
; 1. ONE'S COMPLEMENT LOGIC:
;    The NOT instruction is a unary operation (takes one operand). It is the 
;    fundamental building block for calculating One's Complement. To derive 
;    the Two's Complement (used for signed arithmetic), one would follow 
;    NOT with an 'INC' (Increment) instruction.
;
; 2. FLAG BEHAVIOR (CRITICAL):
;    Unlike most arithmetic and logic instructions (AND, OR, XOR, ADD), the 
;    NOT instruction does NOT affect any status flags in the 8086. 
;    - The Zero Flag (ZF), Sign Flag (SF), and Carry Flag (CF) remain exactly 
;      as they were before the NOT execution.
;    - If a program needs to check the result for zero or sign, an explicit 
;      comparison (CMP) or a TEST instruction must follow.
;
; 3. NEG vs NOT:
;    - NOT: Bitwise inversion (Logical negation).
;    - NEG: Arithmetic negation (calculates Two's Complement: 0 - Value). 
;      NEG DOES affect flags, including setting the Carry Flag if the 
;      input is not zero.
;
; 4. BIT REVERSAL vs BIT INVERSION:
;    Beginners often confuse inversion (NOT) with reversal (swapping bit 
;    positions). NOT merely flips the state of each independent bit without 
;    moving them.
;
; 5. ELECTRICAL PERSPECTIVE:
;    At the hardware level, the NOT instruction corresponds to a series of 
;    parallel CMOS Inverters. It is one of the most electrically simple and 
;    fastest instructions the CPU can execute.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
