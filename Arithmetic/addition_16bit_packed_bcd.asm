; =============================================================================
; TITLE: 16-bit Packed BCD Addition using DAA
; DESCRIPTION: This program demonstrates how to add two 16-bit Packed BCD 
;              (Binary Coded Decimal) numbers. It highlights the use of the 
;              DAA (Decimal Adjust after Addition) instruction to correct 
;              hexadecimal results into human-readable decimal digits.
; AUTHOR: Amey Thakur (https://github.com/Amey-Thakur)
; REPOSITORY: https://github.com/Amey-Thakur/8086-ASSEMBLY-LANGUAGE-PROGRAMS
; LICENSE: MIT License
; =============================================================================

; -----------------------------------------------------------------------------
; DATA SEGMENT
; -----------------------------------------------------------------------------
DATA SEGMENT
    ; Packed BCD: 4 bits represent one decimal digit (0-9).
    ; Example: 9348H in memory represents the decimal number 9348.
    BCD_VAL1  DW 9348H                  ; First operand  (9348)
    BCD_VAL2  DW 1845H                  ; Second operand (1845)
    
    BCD_SUM   DW ?                      ; Buffer for 16-bit BCD result
    BCD_CARRY DW 0000H                  ; Carry flag (for result > 9999)
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
    
    ; --- Step 2: Load Operands ---
    ; We load our 16-bit BCD values into general-purpose registers.
    MOV AX, BCD_VAL1                    ; AX = 9348H
    MOV BX, BCD_VAL2                    ; BX = 1845H
    
    ; --- Step 3: Add Lower Bytes with Decimal Adjustment ---
    ; Problem: Standard ADD performs binary addition. 
    ; 48H + 45H = 8DH (not valid BCD as 'D' > 9).
    ADD AL, BL                          ; AL = 48H + 45H = 8DH
    
    ; DAA (Decimal Adjust after Addition) fixes the nibbles in AL.
    ; It checks if a nibble > 9 or if a carry occurred (AF/CF).
    ; 8DH -> D > 9, so DAA adds 06H to the low nibble.
    ; Final AL = 93H (representing 93 in BCD).
    DAA                                 
    MOV CL, AL                          ; Store adjusted low byte in CL
    
    ; --- Step 4: Add Upper Bytes with Carry Propagation ---
    ; We move the high byte of the first operand into AL for adjustment.
    ; ADC (Add with Carry) includes the carry generated from the previous DAA.
    MOV AL, AH                          ; AL = 93H
    ADC AL, BH                          ; AL = 93H + 18H + Carry
    
    ; Adjust the high byte to ensure each nibble is a valid digit (0-9).
    DAA                                 
    MOV CH, AL                          ; Store adjusted high byte in CH
    
    ; --- Step 5: Handle Final Overflow ---
    ; If the 16-bit addition exceeds 9999, the Carry Flag will be set.
    JNC SAVE_RESULT                     ; If CF=0, jump to save
    MOV BCD_CARRY, 0001H                ; If CF=1, store the final carry
    
SAVE_RESULT:
    ; CX now contains the 4 adjusted decimal digits (BCD).
    MOV BCD_SUM, CX                     
    
    ; --- Step 6: Debugging Breakpoint ---
    ; INT 3 is a software interrupt used for debugging.
    INT 03H
    
    ; --- Step 7: DOS Termination ---
    MOV AH, 4CH
    INT 21H

CODE ENDS

; =============================================================================
; TECHNICAL NOTES & ARCHITECTURAL INSIGHTS
; =============================================================================
; 1. PACKED BCD vs UNPACKED BCD:
;    - Packed BCD: Two decimal digits per byte (e.g., 0x93 = 93).
;    - Unpacked BCD: One decimal digit per byte (e.g., 0x09 0x03 = 93).
;
; 2. THE DAA LOGIC (Hardware Level):
;    DAA operates exclusively on the AL register. It follows these rules:
;    - If (Low Nibble of AL > 9) OR (Auxiliary Carry AF = 1):
;        AL = AL + 06H, AF = 1
;    - If (High Nibble of AL > 9) OR (Carry Flag CF = 1):
;        AL = AL + 60H, CF = 1
;
; 3. AUXILIARY CARRY (AF):
;    The AF flag tracks carries from bit 3 to bit 4 (nibble level). This is 
;    the "secret sauce" that allows DAA to know when a decimal overflow 
;    occurred within a single byte.
;
; 4. LIMITATIONS:
;    DAA does NOT work for subtraction (use DAS) or multiplication/division.
;    It is strictly designed for the result of an ADD or ADC instruction.
;
; 5. EXAMPLE TRACE:
;    9348 + 1845 = 11193 decimal.
;    Binary result (Hex): AC8DH.
;    After DAA (Lower): 93H.
;    After DAA (Upper): 11H (with Carry).
;    Final result: Carry=1, Sum=1193H.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =

END START
