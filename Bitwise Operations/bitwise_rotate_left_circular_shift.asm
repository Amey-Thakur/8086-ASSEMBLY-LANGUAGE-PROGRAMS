; =============================================================================
; TITLE: Bitwise Left Circular Rotation (ROL)
; DESCRIPTION: This program demonstrates the 8086 'ROL' (Rotate Left) 
;              instruction. Unlike logical shifts which discard data, 
;              rotation preserves all bits by wrapping the Most Significant 
;              Bit (MSB) around to the Least Significant Bit (LSB).
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
    ; Bit 7 (MSB) and Bit 0 (LSB) are set.
    SEED_VAL DB 81H                         
    
    ; Setup rotation parameters
    ROT_COUNT DB 2                   
    
    ; Storage for the final rotated state
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
    
    ; --- Step 3: Execute Left Rotation ---
    ; On the 8086, multi-bit rotations require the count in the CL register.
    MOV CL, ROT_COUNT                
    ROL AL, CL                          ; Rotate AL left by 2 positions
    
    ; Visual Execution Trace:
    ; Start: [1]000 0001  (81H)
    ; 1st:   0000 001[1]  (03H) -> MSB '1' moved to LSB and Carry Flag
    ; 2nd:   0000 011[0]  (06H) -> MSB '0' moved to LSB and Carry Flag
    
    ; --- Step 4: Persist Results ---
    MOV ROT_RESULT, AL                  ; Result = 06H
    
    ; --- Step 5: Shutdown ---
    MOV AH, 4CH                         
    INT 21H
MAIN ENDP

END MAIN

; =============================================================================
; TECHNICAL NOTES & ARCHITECTURAL INSIGHTS
; =============================================================================
; 1. CIRCULAR BIT PRESERVATION:
;    The ROL instruction is a "non-lossy" operation. While SHL fills vacated 
;    bits with zeros, ROL takes the bit shifted out of position 7 and 
;    re-inserts it into position 0. This makes it ideal for iterative 
;    processing of every bit in a word.
;
; 2. CARRY FLAG (CF) INTERACTION:
;    In a ROL operation, the bit that is rotated from the MSB to the LSB is 
;    ALSO copied into the Carry Flag. This allows a programmer to test the 
;    MSB state using conditional jumps (JC/JNC) without losing the original 
;    bit data.
;
; 3. ROL vs RCL:
;    - ROL (Rotate Left): Rotates the 8 bits of the register. CF is just a 
;      copy of the MSB.
;    - RCL (Rotate Carry Left): Rotates a 9-bit quantity consisting of the 
;      8 register bits PLUS the Carry Flag. Data moves: CF -> LSB -> ... -> MSB -> CF.
;
; 4. OVERFLOW FLAG (OF) BEHAVIOR:
;    For a 1-bit rotation (count = 1), the OF is set if the rotation changes 
;    the MSB (sign bit). For multi-bit rotations (count > 1), the OF state 
;    is technically undefined on some X86 variants, though often it remains 
;    based on the last bit moved.
;
; 5. PERFORMANCE & UTILIZATION:
;    Rotation is commonly used in hashing algorithms, cryptography (e.g., 
;    shifting keys), and for converting between big-endian and little-endian 
;    formats in 16 or 32-bit registers.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
