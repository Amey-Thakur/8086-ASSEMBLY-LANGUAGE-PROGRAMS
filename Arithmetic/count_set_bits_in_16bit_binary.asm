; =============================================================================
; TITLE: 16-bit Set Bit Counter (Population Count)
; DESCRIPTION: This program calculates the number of bits set to '1' in a 16-bit 
;              binary number. It demonstrates efficient bit manipulation 
;              using rotation and carry flag analysis.
; AUTHOR: Amey Thakur (https://github.com/Amey-Thakur)
; REPOSITORY: https://github.com/Amey-Thakur/8086-ASSEMBLY-LANGUAGE-PROGRAMS
; LICENSE: MIT License
; =============================================================================

; -----------------------------------------------------------------------------
; DATA SEGMENT
; -----------------------------------------------------------------------------
DATA SEGMENT
    ; Input word (e.g., 1010 1010 1111 0000 = AA F0H)
    TEST_DATA DW 0AAF0H                 
    
    ; Display Messages
    MSG_START DB 10,13, "Counting set bits in 16-bit word...", 10,13, "$"
    MSG_RESULT DB 10,13, "Total bits set to 1: $"
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
    
    ; --- Step 2: Print Introduction ---
    LEA DX, MSG_START
    MOV AH, 09H
    INT 21H
    
    ; --- Step 3: Setup Registers for Counting ---
    ; AX will hold our data, BX will track the '1's, CX is loop counter.
    MOV AX, TEST_DATA                   ; Load 16-bit data
    MOV BX, 0000H                       ; Clear bit-counter (result)
    MOV CX, 0010H                       ; Initialize loop counter to 16 (bits)
    
    ; --- Step 4: Bit Rotation and Carry Analysis ---
COUNT_LOOP: 
    ; ROL (Rotate Left) moves the Most Significant Bit (MSB) into the 
    ; Carry Flag (CF) and also wraps it around to the Least Significant Bit.
    ROL AX, 1                           
    
    ; JNC (Jump if No Carry) skips the counter increment if CF is 0 (bit was 0).
    JNC BIT_IS_ZERO                     
    
    ; If CF = 1, we found a set bit!
    INC BX                              
    
BIT_IS_ZERO:  
    ; LOOP decrements CX and repeats until all 16 bits are checked.
    LOOP COUNT_LOOP                     
    
    ; --- Step 5: Display the Final Count ---
    LEA DX, MSG_RESULT
    MOV AH, 09H
    INT 21H
    
    ; Conversion for display (assuming result <= 9 for simplicity in this demo)
    ; For counts > 9, a more robust binary-to-decimal routine would be needed.
    MOV DX, BX                          
    ADD DL, 30H                         ; Convert result to ASCII
    MOV AH, 02H                         ; Print character function
    INT 21H
    
    ; --- Step 6: Program Termination ---
    MOV AH, 4CH
    INT 21H 
        
CODE ENDS

; =============================================================================
; TECHNICAL NOTES & ARCHITECTURAL INSIGHTS
; =============================================================================
; 1. ROL vs SHL:
;    - SHL (Shift Left): Moves MSB to Carry and fills LSB with 0. 
;      This destroys the original number value.
;    - ROL (Rotate Left): Moves MSB to Carry and also to LSB. 
;      After 16 rotations, the original number in AX is perfectly restored.
;
; 2. THE CARRY FLAG (CF):
;    In the 8086, rotation and shift instructions are the primary way to 
;    interface bit-level data with the status flags.
;
; 3. POPULATION COUNT (HAMMING WEIGHT):
;    This algorithm is the software implementation of "Hamming Weight," 
;    a metric used extensively in cryptography and error-correction codes.
;
; 4. PERFORMANCE:
;    - ROL (immediate): 2 clock cycles per bit.
;    - LOOP: 17 clock cycles (if taken).
;    - Total bit-processing time is approximately 20-25 cycles per bit.
;
; 5. SCALABILITY:
;    This logic can be easily extended to 32-bit or 64-bit counts by changing 
;    the register (e.g., EAX in later 80x86) and loop counter.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =

END START

;=============================================================================
; NOTES:
; - ROL (Rotate Left): Shifts bits left, MSB goes to CF and LSB
; - JNC (Jump if No Carry): Skips increment when bit was 0
; - Algorithm: Rotate 8 times, count each 1 that goes into CF
; - Example: 7 (0111 binary) has 3 ones
;=============================================================================
