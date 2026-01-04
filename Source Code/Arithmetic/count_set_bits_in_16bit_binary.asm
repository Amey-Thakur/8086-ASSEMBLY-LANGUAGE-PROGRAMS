; =============================================================================
; TITLE: 16-bit Set Bit Counter (Population Count)
; DESCRIPTION: This program calculates the number of bits set to '1' in a 16-bit 
;              binary number. It demonstrates efficient bit manipulation 
;              using rotation and carry flag analysis.
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
    VAL_TEST_DATA DW 0AAF0H                 
    
    MSG_START     DB 0DH, 0AH, "Counting set bits...", 0DH, 0AH, "$"
    MSG_RESULT    DB 0DH, 0AH, "Total set bits (Hamming Weight): $"

; -----------------------------------------------------------------------------
; CODE SEGMENT
; -----------------------------------------------------------------------------
.CODE
MAIN PROC
    ; --- Step 1: Initialize Data Segment ---
    MOV AX, @DATA
    MOV DS, AX
    
    ; --- Step 2: Print Introduction ---
    LEA DX, MSG_START
    MOV AH, 09H
    INT 21H
    
    ; --- Step 3: Setup Registers for Counting ---
    MOV AX, VAL_TEST_DATA               
    MOV BX, 0000H                       ; Bit-counter
    MOV CX, 0010H                       ; 16 bits to check
    
    ; --- Step 4: Bit Rotation and Carry Analysis ---
L_COUNT_LOOP: 
    ROL AX, 1                           ; Rotate MSB into Carry
    JNC L_BIT_IS_ZERO                     
    INC BX                              
    
L_BIT_IS_ZERO:  
    LOOP L_COUNT_LOOP                     
    
    ; --- Step 5: Display Result ---
    LEA DX, MSG_RESULT
    MOV AH, 09H
    INT 21H
    
    ; ASCII conversion for single digit (0-9)
    MOV DX, BX                          
    ADD DL, '0'                         
    MOV AH, 02H                         
    INT 21H
    
    ; --- Step 6: Shutdown ---
    MOV AH, 4CH
    INT 21H 
MAIN ENDP

END MAIN

; =============================================================================
; TECHNICAL NOTES & ARCHITECTURAL INSIGHTS
; =============================================================================
; 1. ROL vs SHL:
;    - SHL (Shift Left) destroys the original number by filling with zeros.
;    - ROL (Rotate Left) preserves the number; after 16 rotations, AX returns 
;      to its initial state.
;
; 2. THE CARRY FLAG (CF):
;    Rotation and shift instructions are the primary way to interface bit-level 
;    data with hardware status flags in the 8086.
;
; 3. POPULATION COUNT (HAMMING WEIGHT):
;    This algorithm calculates the "Hamming Weight," essential for 
;    error-correction codes and parity checks.
;
; 4. PERFORMANCE:
;    ROL (immediate) takes 2 cycles, while LOOP takes 17 cycles. The 
;    branching logic adds variability based on bit distribution.
;
; 5. SCALABILITY:
;    This pattern is easily adapted for 32-bit registers (EAX) on 386+ 
;    processors by increasing the loop counter to 32.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =

