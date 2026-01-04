; =============================================================================
; TITLE: Bitwise Logical OR Operation (Union & Flag Setting)
; DESCRIPTION: This program demonstrates the 8086 'OR' instruction, which 
;              performs a bitwise logical union between two 8-bit operands. 
;              It illustrates how OR can be used to set specific bits within 
;              a register while keeping other bits unchanged.
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
    ; Operands for bitwise union
    VAL_1    DB 0FH                     ; 0000 1111 (Lower nibble)
    VAL_2    DB 0F0H                    ; 1111 0000 (Upper nibble)
    
    ; Variable to capture the combined result
    UNION_RES DB ?                         

; -----------------------------------------------------------------------------
; CODE SEGMENT
; -----------------------------------------------------------------------------
.CODE
MAIN PROC
    ; --- Step 1: Initialize Data Segment ---
    MOV AX, @DATA
    MOV DS, AX
    
    ; --- Step 2: Load First Operand ---
    MOV AL, VAL_1                       ; AL = 0000 1111
    
    ; --- Step 3: Execute Bitwise OR ---
    ; Truth Table for OR:
    ; A=0, B=0 -> 0 | A=1, B=0 -> 1
    ; A=0, B=1 -> 1 | A=1, B=1 -> 1
    
    OR AL, VAL_2                        ; AL = (0000 1111) OR (1111 0000)
    
    ; Calculation Logic:
    ;   0000 1111
    ; | 1111 0000
    ; -----------
    ;   1111 1111 -> FFH (255)
    
    ; --- Step 4: Persist Result ---
    MOV UNION_RES, AL                     
    
    ; --- Step 5: Shutdown ---
    MOV AH, 4CH                         
    INT 21H
MAIN ENDP

END MAIN

; =============================================================================
; TECHNICAL NOTES & ARCHITECTURAL INSIGHTS
; =============================================================================
; 1. SETTING BITS (SUPERPOSITION):
;    The OR instruction is the primary tool for "setting" bits to 1. By ORing 
;    a register with a bitmask, any bit corresponding to a '1' in the mask 
;    will be forced to '1' in the result, regardless of its previous state.
;
; 2. REGISTER-PERSISTENCE:
;    Wait, bits that are '0' in the mask leave the corresponding register bits 
;    unchanged. This property is vital for combining different independent 
;    status flags into a single control register.
;
; 3. FLAG REGISTER IMPACT (8086):
;    Executing an OR operation affects the status register:
;    - Carry Flag (CF) & Overflow Flag (OF): Always cleared to 0.
;    - Zero Flag (ZF): Set if the result is 0 (unlikely if setting bits).
;    - Sign Flag (SF): Set if the highest bit (Bit 7) is 1.
;    - Parity Flag (PF): Set for an even number of '1' bits in the result.
;
; 4. CASE TRANSITIONS (ASCII):
;    For ASCII characters, ORing a character with 20H (0010 0000) will 
;    guarantee it is lowercase, as Bit 5 distinguishes upper and lower case 
;    in the ASCII table.
;
; 5. HARDWARE EXECUTION:
;    OR is implemented using a set of parallel OR gates. It is an extremely 
;    efficient instruction, providing the maximum throughput possible on the 
;    8086's ALU.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
