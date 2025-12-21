; =============================================================================
; TITLE: Bitwise Logical Shift Left (SHL) & Binary Multiplication
; DESCRIPTION: This program demonstrates the 8086 'SHL' (Shift Logical Left) 
;              instruction. It illustrates how shifting bits to the left 
;              effectively multiplies a value by powers of two while 
;              simultaneously interacting with the Carry Flag.
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
    ; Starting Value: 0000 1000 (08H / 8 decimal)
    SEED_VAL DB 08H                         
    
    ; Shift parameters (2 positions = Multiply by 4)
    SHIFT_COUNT DB 2                    
    
    ; Buffer for calculation result
    SHL_RESULT DB ?                         

; -----------------------------------------------------------------------------
; CODE SEGMENT
; -----------------------------------------------------------------------------
.CODE
MAIN PROC
    ; --- Step 1: Initialize Data Segment ---
    MOV AX, @DATA
    MOV DS, AX
    
    ; --- Step 2: Load Working Register ---
    MOV AL, SEED_VAL                    ; AL = 0000 1000
    
    ; --- Step 3: Execute Logical Left Shift ---
    ; For shifts > 1, the count MUST be placed in the CL register.
    MOV CL, SHIFT_COUNT                 
    SHL AL, CL                          ; Shift AL left by 2 positions
    
    ; Execution Trace:
    ; Initial: 0000 1000 (8)
    ; Shift 1: 0001 0000 (16)  <- MSB '0' moved to CF, LSB filled with '0'
    ; Shift 2: 0010 0000 (32)  <- MSB '0' moved to CF, LSB filled with '0'
    
    ; --- Step 4: Persist Result ---
    ; Expected: 32 decimal (20H)
    MOV SHL_RESULT, AL                      
    
    ; --- Step 5: Shutdown ---
    MOV AH, 4CH                         
    INT 21H
MAIN ENDP

END MAIN

; =============================================================================
; TECHNICAL NOTES & ARCHITECTURAL INSIGHTS
; =============================================================================
; 1. MATHEMATICAL RELATIONSHIP:
;    An N-bit logical left shift is equivalent to multiplying an unsigned 
;    integer by 2^N.
;    Example: SHL AL, 3 results in AL = AL * 8.
;
; 2. SHL vs SAL (OPERATIONAL IDENTITY):
;    On the 8086, SHL (Shift Logical Left) and SAL (Shift Arithmetic Left) 
;    are identical instructions with the same opcode. This is because 
;    shifting left affects the sign bit and the magnitude in the exact 
;    same way for both signed and unsigned integers (until overflow occurs).
;
; 3. CARRY FLAG (CF) AS OVERFLOW DETECTOR:
;    As bits shift left, the bit exiting the MSB (Bit 7) enters the Carry 
;    Flag. In the context of multiplication, a set Carry Flag after a SHL 
;    indicates that the multiplication has exceeded the register's 
;    capacity (unsigned overflow).
;
; 4. VACATED BITS:
;    Logical shifts always fill the vacated Least Significant Bits (LSB) 
;    with zeros. This is a key distinction from rotation (ROL), which 
;    fills them with the bits shifted out of the MSB.
;
; 5. PERFORMANCE ADVANTAGE:
;    SHL is significantly faster than the 'MUL' instruction. Professional 
;    assembly programmers always prefer shifts for power-of-two 
;    multiplications to minimize clock cycles.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
