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

; -----------------------------------------------------------------------------
; CODE SEGMENT
; -----------------------------------------------------------------------------
CODE SEGMENT
    ASSUME CS:CODE
    
    ; --- Step 1: Initialize Data Segment ---
    ; We manually set the DS (Data Segment) register to point to the base address 2000H.
    ; This allows us to access physical memory starting at 20000H (2000H * 10H).
    MOV AX, 2000H
    MOV DS, AX
    
    ; --- Step 2: Set up Pointers and Counters ---
    ; SI (Source Index) will serve as our array pointer, starting at offset 0000H.
    ; CX (Count Register) is initialized to 10 (0AH), the number of bytes to add.
    ; AX is zeroed out to act as our 16-bit accumulator.
    MOV SI, 0000H                       ; SI = 0000H (Base offset)
    MOV CX, 000AH                       ; CX = 10 (Loop counter)
    MOV AX, 0000H                       ; AL = Sum Low, AH = Sum High (Carry)
    
    ; --- Step 3: Core Addition Loop ---
ADD_LOOP:   
    ; ADD adds the value at memory address [DS:SI] to the 8-bit register AL.
    ; If the addition results in a value > 255, the Carry Flag (CF) is set to 1.
    ADD AL, [SI]                        
    
    ; JNC (Jump if No Carry) checks the Carry Flag.
    ; If CF is 0, we skip the increment of the high byte (AH).
    JNC SKIP_CARRY                      
    
    ; If CF is 1, it means we have an overflow from the lower 8 bits.
    ; We manually propagate this overflow by incrementing AH (the upper 8 bits).
    INC AH                              
    
SKIP_CARRY:   
    ; Increment the pointer SI to point to the next byte in the sequence.
    INC SI                              
    
    ; LOOP decrements CX and jumps back to ADD_LOOP if CX is not equal to zero.
    LOOP ADD_LOOP                       
    
    ; --- Step 4: Store results ---
    ; After the loop, AX contains the final 16-bit sum.
    ; We store this result at the memory location immediately following the array.
    MOV [SI], AX                        
    
    ; --- Step 5: Termination ---
    ; HLT stops the CPU until an interrupt occurs.
    HLT                                 
    
CODE ENDS

; =============================================================================
; TECHNICAL NOTES & ARCHITECTURAL INSIGHTS
; =============================================================================
; 1. PHYSICAL ADDRESSING: 
;    The 8086 generates a 20-bit address using a 16-bit segment and 16-bit offset.
;    Formula: Physical Address = (Segment Register * 0x10) + Offset
;    Example: 2000:0000 => 20000H + 0000H = 20000H.
;
; 2. CARRY PROPAGATION:
;    Standard 8-bit addition (ADD AL, mem) only updates the 8-bit register. 
;    The manual "JNC/INC AH" logic mimics how a 16-bit ADC (Add with Carry) 
;    instruction works, providing a clear view of how overflows are managed 
;    at the hardware level.
;
; 3. ACCUMULATOR USAGE:
;    AX is treated here as a 16-bit accumulator split into AH (High) and AL (Low).
;    AL stores the partial sum, while AH counts the total number of overflows 
;    (carries) generated during the 10 additions.
;
; 4. LITTLE-ENDIAN STORAGE:
;    When 'MOV [SI], AX' is executed, the 8086 architecture stores the Low Byte 
;    (AL) at memory address SI and the High Byte (AH) at SI+1.
;
; 5. LOOP INSTRUCTION:
;    The LOOP instruction is a shorthand for 'DEC CX' followed by 'JNZ label'. 
;    It is a fundamental tool for iterating through arrays in x86 assembly.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =

END
