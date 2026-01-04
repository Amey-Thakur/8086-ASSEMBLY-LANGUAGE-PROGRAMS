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

.MODEL SMALL
.STACK 100H

; -----------------------------------------------------------------------------
; DATA SEGMENT
; -----------------------------------------------------------------------------
.DATA
    ; Packed BCD: 4 bits represent one decimal digit (0-9).
    ; Example: 9348H in memory represents the decimal number 9348.
    VAL_BCD1  DW 9348H                  ; First operand  (9348)
    VAL_BCD2  DW 1845H                  ; Second operand (1845)
    
    RES_SUM   DW ?                      ; Buffer for 16-bit BCD result
    RES_CARRY DW 0000H                  ; Carry flag (for result > 9999)

; -----------------------------------------------------------------------------
; CODE SEGMENT
; -----------------------------------------------------------------------------
.CODE
MAIN PROC
    ; --- Step 1: Initialize Data Segment ---
    MOV AX, @DATA
    MOV DS, AX
    
    ; --- Step 2: Load Operands ---
    MOV AX, VAL_BCD1                    
    MOV BX, VAL_BCD2                    
    
    ; --- Step 3: Add Lower Bytes with Decimal Adjustment ---
    ; 48H + 45H = 8DH (not valid BCD). DAA correction follows.
    ADD AL, BL                          
    DAA                                 
    MOV CL, AL                          ; Store adjusted low byte in CL
    
    ; --- Step 4: Add Upper Bytes with Carry Propagation ---
    ; ADC (Add with Carry) includes the carry generated from the previous DAA.
    MOV AL, AH                          
    ADC AL, BH                          
    DAA                                 
    MOV CH, AL                          ; Store adjusted high byte in CH
    
    ; --- Step 5: Handle Final Overflow ---
    JNC L_SAVE_RESULT                     
    MOV RES_CARRY, 0001H                
    
L_SAVE_RESULT:
    MOV RES_SUM, CX                     
    
    ; --- Step 6: Debugging Breakpoint ---
    INT 03H
    
    ; --- Step 7: DOS Termination ---
    MOV AH, 4CH
    INT 21H
MAIN ENDP

END MAIN

; =============================================================================
; TECHNICAL NOTES & ARCHITECTURAL INSIGHTS
; =============================================================================
; 1. PACKED BCD vs UNPACKED BCD:
;    - Packed BCD: Two decimal digits per byte (e.g., 0x93 = 93).
;    - Unpacked BCD: One decimal digit per byte (e.g., 0x09 0x03 = 93).
;
; 2. THE DAA LOGIC (Hardware Level):
;    DAA operates exclusively on the AL register. It checks if a nibble > 9 
;    or if a carry (AF/CF) occurred, adding 0x06 or 0x60 accordingly to 
;    return the value to valid BCD range.
;
; 3. AUXILIARY CARRY (AF):
;    The AF flag tracks carries from bit 3 to bit 4 (nibble level). This is 
;    the mechanism that allows DAA to detect decimal overflows within a byte.
;
; 4. LIMITATIONS:
;    DAA does NOT work for subtraction (use DAS) or multiplication/division.
;    It is strictly designed for the result of an ADD or ADC instruction.
;
; 5. EXAMPLE TRACE:
;    9348 + 1845 = 11193 decimal.
;    Hex Sum: AC8DH. Lower DAA fixes 8DH to 93H. Upper ADC/DAA fixes 
;    the overflow into a 5th digit (Carry).
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =

