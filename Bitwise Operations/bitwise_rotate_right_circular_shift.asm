; =============================================================================
; TITLE: Bitwise Right Circular Rotation (ROR)
; DESCRIPTION: This program demonstrates the 8086 'ROR' (Rotate Right) 
;              instruction. It demonstrates how bits shifted out of the 
;              Least Significant Bit (LSB) re-enter the register at the 
;              Most Significant Bit (MSB), maintaining data integrity.
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
    ; Initial Value: 1000 0001 (81H / 129 decimal)
    ; In binary: [1]000 000[1]
    SEED_VAL DB 81H                         
    
    ; Setup rotation parameters
    ROT_COUNT DB 2                   
    
    ; Result storage
    ROT_RESULT DB ?                         

; -----------------------------------------------------------------------------
; CODE SEGMENT
; -----------------------------------------------------------------------------
.CODE
MAIN PROC
    ; --- Step 1: Initialize Data Segment ---
    MOV AX, @DATA
    MOV DS, AX
    
    ; --- Step 2: Load Working Register ---
    MOV AL, SEED_VAL                    ; AL = 1000 0001
    
    ; --- Step 3: Execute Right Rotation ---
    ; Note: For rotations > 1 bit, the count must be provided in the CL register.
    MOV CL, ROT_COUNT                
    ROR AL, CL                          ; Rotate AL right by 2 positions
    
    ; Visual Execution Trace:
    ; Start: 1000 000[1]  (81H)
    ; 1st:   [1]100 0000  (C0H) -> LSB '1' moved to MSB and Carry Flag
    ; 2nd:   [0]110 0000  (60H) -> LSB '0' moved to MSB and Carry Flag
    
    ; --- Step 4: Persist Results ---
    ; Final Result in AL = 0110 0000 (60H)
    MOV ROT_RESULT, AL                      
    
    ; --- Step 5: Termination ---
    MOV AH, 4CH                         
    INT 21H
MAIN ENDP

END MAIN

; =============================================================================
; TECHNICAL NOTES & ARCHITECTURAL INSIGHTS
; =============================================================================
; 1. BIT PRESERVATION (ROTATION):
;    The ROR instruction ensures that no data bits are lost during the 
;    operation. The LSB (Bit 0) "wraps around" to fill the newly empty 
;    MSB (Bit 7). This distinguishes rotation from logical shifts (SHR), 
;    which simply fill the MSB with zero.
;
; 2. CARRY FLAG (CF) INTERACTION:
;    During each single-bit rotation, the bit that is moved from LSB to MSB 
;    is ALSO copied into the Carry Flag. This allows the CPU to branch based 
;    on the state of the "discarded" bit using JC or JNC instructions.
;
; 3. ROR vs RCR:
;    - ROR (Rotate Right): The LSB re-enters the MSB directly. CF is a mirror 
;      of the LSB.
;    - RCR (Rotate Carry Right): The Carry Flag itself is part of the rotation 
;      chain. Data moves: CF -> MSB -> ... -> LSB -> CF. This is a 9-bit 
;      rotation (for an 8-bit register).
;
; 4. MATHEMATICAL UTILITY:
;    Rotation is not directly equivalent to division (unlike SHR), but it is 
;    essential for algorithms that treat a byte or word as a circular buffer, 
;    such as encryption subroutines (S-boxes) or CRC calculations.
;
; 5. 8086 INSTRUCTION CONSTRAINTS:
;    On the original 8086/8088, the shift/rotate count could only be 1 (as an 
;    immediate) or CL (as a register). Later processors (80286+) allowed any 
;    immediate byte for count, but for backward compatibility, using CL is 
;    the "gold standard" approach.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
