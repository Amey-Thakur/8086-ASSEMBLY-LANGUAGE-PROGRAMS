; =============================================================================
; TITLE: Addition of Byte Array from Memory
; DESCRIPTION: This program calculates the 16-bit sum of a series of ten 8-bit 
;              unsigned integers stored in consecutive memory locations. It 
;              demonstrates memory segmentation, indirect addressing, and 
;              manual carry propagation.
; AUTHOR: Amey Thakur (https://github.com/Amey-Thakur)
; REPOSITORY: https://github.com/Amey-Thakur/8086-ASSEMBLY-LANGUAGE-PROGRAMS
; LICENSE: MIT License
; =============================================================================

.MODEL SMALL
.STACK 100H

; -----------------------------------------------------------------------------
; CODE SEGMENT
; -----------------------------------------------------------------------------
.CODE
MAIN PROC
    ; --- Step 1: Initialize Data Segment ---
    ; We manually set the DS register to point to the base address 2000H.
    MOV AX, 2000H
    MOV DS, AX
    
    ; --- Step 2: Set up Pointers and Counters ---
    MOV SI, 0000H                       ; SI = 0000H (Base offset)
    MOV CX, 000AH                       ; CX = 10 (Loop counter)
    MOV AX, 0000H                       ; AL = Sum Low, AH = Sum High (Carry)
    
    ; --- Step 3: Core Addition Loop ---
L_ADD_LOOP:   
    ADD AL, [SI]                        
    
    ; Manual Carry Propagation: If CF is 1, increment the high byte of sum.
    JNC L_SKIP_CARRY                      
    INC AH                              
    
L_SKIP_CARRY:   
    INC SI                              
    LOOP L_ADD_LOOP                     
    
    ; --- Step 4: Store results ---
    MOV [SI], AX                        
    
    ; --- Step 5: Termination ---
    MOV AH, 4CH
    INT 21H
MAIN ENDP

END MAIN

; =============================================================================
; TECHNICAL NOTES & ARCHITECTURAL INSIGHTS
; =============================================================================
; 1. PHYSICAL ADDRESSING: 
;    Formula: Physical Address = (Segment Register * 0x10) + Offset
;    Example: 2000:0000 => 20000H + 0000H = 20000H.
;
; 2. CARRY PROPAGATION:
;    Standard 8-bit addition (ADD AL, mem) only updates the 8-bit register. 
;    The manual "JNC/INC AH" logic mimics how a 16-bit ADC (Add with Carry) 
;    instruction works.
;
; 3. ACCUMULATOR USAGE:
;    AX is treated here as a 16-bit accumulator split into AH (High) and AL (Low).
;    AL stores the partial sum, while AH counts the carries.
;
; 4. LITTLE-ENDIAN STORAGE:
;    The 8086 architecture stores the Low Byte (AL) first in memory, followed 
;    by the High Byte (AH).
;
; 5. LOOP INSTRUCTION:
;    The LOOP instruction is a shorthand for 'DEC CX' followed by 'JNZ label'. 
;    It is a fundamental tool for iterating through arrays.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =

