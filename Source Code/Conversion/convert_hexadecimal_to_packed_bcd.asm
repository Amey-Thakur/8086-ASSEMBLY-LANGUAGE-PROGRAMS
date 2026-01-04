; =============================================================================
; TITLE: Hexadecimal to Packed BCD Conversion (Repeated Subtraction)
; DESCRIPTION: This program converts a 16-bit hexadecimal number into its 
;              equivalent BCD (Binary Coded Decimal) representation. It 
;              utilizes the "Repeated Subtraction" method to extract decimal 
;              digits from Most Significant to Least Significant.
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
    ; Input Hex value: FFFFH (Equivalent to decimal 65,535)
    VAL_HEX       DW 0FFFFH             
    
    ; Output BCD Array (5 memory locations for digits 6, 5, 5, 3, 5)
    VAL_BCD_ARRAY DB 5 DUP(0)           

; -----------------------------------------------------------------------------
; CODE SEGMENT
; -----------------------------------------------------------------------------
.CODE
MAIN PROC
    ; --- Step 1: Initialize Data Segment ---
    MOV AX, @DATA
    MOV DS, AX
    
    ; --- Step 2: Initialize Pointers & Workings ---
    LEA SI, VAL_BCD_ARRAY               ; Point to BCD target
    MOV AX, VAL_HEX                     ; Load the source number
    
    ; --- Step 3: Extract Digits via Positonal Weights ---
    ; Algorithm: Subtract weight until number becomes negative, then restore.
    
    ; Case 1: Ten-thousands position
    MOV CX, 10000                       ; Weight = 10,000
    CALL SUB_EXTRACT_DIGIT
    
    ; Case 2: Thousands position
    MOV CX, 1000                        ; Weight = 1,000
    CALL SUB_EXTRACT_DIGIT
    
    ; Case 3: Hundreds position
    MOV CX, 100                         ; Weight = 100
    CALL SUB_EXTRACT_DIGIT
    
    ; Case 4: Tens position
    MOV CX, 10                          ; Weight = 10
    CALL SUB_EXTRACT_DIGIT
    
    ; Case 5: Units position
    ; The residual value in AX after all subtractions is the units digit.
    MOV [SI], AL                        
    
    ; --- Step 4: Finalize & Shutdown ---
    MOV AH, 4CH
    INT 21H
MAIN ENDP

; -----------------------------------------------------------------------------
; SUBROUTINE: SUB_EXTRACT_DIGIT
; DESCRIPTION: Extracts a decimal digit by counting how many times a power 
;              of 10 can be subtracted from the remainder.
; INPUT: AX = Remainder, CX = Positional Weight
; OUTPUT: BCD Digit stored at [SI], SI incremented, AX = New Remainder
; -----------------------------------------------------------------------------
SUB_EXTRACT_DIGIT PROC NEAR
    MOV BH, 0FFH                        ; Start counter at -1 (pre-increment logic)
    
L_SUB_LOOP:
    INC BH                              ; Count the successful subtraction
    SUB AX, CX                          ; Subtract weight from remainder
    JNC L_SUB_LOOP                      ; If no borrow (AX >= 0), repeat
    
    ; Underflow correction
    ADD AX, CX                          ; Restore the remainder (add back the weight)
    MOV [SI], BH                        ; Store the count (the BCD digit)
    INC SI                              ; Move to next BCD array slot
    RET
SUB_EXTRACT_DIGIT ENDP

END MAIN

; =============================================================================
; TECHNICAL NOTES & ARCHITECTURAL INSIGHTS
; =============================================================================
; 1. REPEATED SUBTRACTION VS SUCCESSIVE DIVISION:
;    While 'DIV' instructions are cleaner, they are computationally 'expensive' 
;    (many clock cycles). Repeated subtraction is a viable alternative for 
;    extracting digits when the divisor is large (like 10,000).
;
; 2. THE POSITIONAL WEIGHT HIERARCHY:
;    We process from the largest weight (10,000 for a 16-bit unsigned number 
;    Max 65535) down to the smallest. This matches the way BCD is typically 
;    read left-to-right.
;
; 3. PRECISION RECOVERY (THE UNDERFLOW PATTERN):
;    The JNC (Jump if No Carry) loop eventually fails when AX becomes negative. 
;    At that point, 'BH' holds one count too many and 'AX' is in a 'borrow' state. 
;    Adding CX back once restores AX to the correct functional remainder for 
;    the next lower positional weight.
;
; 4. BCD STORAGE FORMAT:
;    The result is stored as "Unpacked BCD", where each byte contains one 
;    decimal digit. To convert this to "Packed BCD", one would need to shift 
;    and OR the nibbles together (e.g., 6 and 5 become 65H).
;
; 5. REGISTER USAGE:
;    - AX: The running numeric value (decreases per call).
;    - CX: The constant power-of-ten for the current call.
;    - SI: The pointer into the BCD result array.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
