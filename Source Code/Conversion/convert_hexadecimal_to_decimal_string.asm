; =============================================================================
; TITLE: Hexadecimal to Decimal String Conversion (Radix Extraction)
; DESCRIPTION: This program converts a 16-bit binary (hexadecimal) value into 
;              a human-readable decimal string. It demonstrates the use of the 
;              "Successive Division" algorithm combined with a Stack to 
;              correct digit order.
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
    ; Input Hex value: 1234H (Equivalent to decimal 4660)
    VAL_HEX_DATA  DW 1234H             
    
    ; Buffer to store the formatted ASCII string
    STR_RESULT    DB 10 DUP('$')       

; -----------------------------------------------------------------------------
; CODE SEGMENT
; -----------------------------------------------------------------------------
.CODE
MAIN PROC
    ; --- Step 1: Initialize Data Segment ---
    MOV AX, @DATA
    MOV DS, AX
    
    ; --- Step 2: Conversion Logic ---
    MOV AX, VAL_HEX_DATA                ; Load numeric value
    LEA SI, STR_RESULT                  ; Point to target buffer
    CALL SUB_HEX_TO_DEC_STR             ; Perform conversion
    
    ; --- Step 3: Display Result ---
    LEA DX, STR_RESULT
    MOV AH, 09H                         ; DOS Display String
    INT 21H
    
    ; --- Step 4: Shutdown ---
    MOV AH, 4CH
    INT 21H
MAIN ENDP

; -----------------------------------------------------------------------------
; SUBROUTINE: SUB_HEX_TO_DEC_STR
; DESCRIPTION: Successive division by 10 to extract decimal digits.
; INPUT: AX = numeric value, SI = target string buffer
; OUTPUT: $[SI] contains ASCII decimal string
; -----------------------------------------------------------------------------
SUB_HEX_TO_DEC_STR PROC NEAR
    MOV CX, 0                           ; Digit counter
    MOV BX, 10                          ; Radix divisor
    
L_EXTRACT_LOOP:
    XOR DX, DX                          ; Clear for 32-bit (DX:AX) division
    DIV BX                              ; AX = Quotient, DX = Remainder
    
    ; Convert digit (0-9) to ASCII ('0'-'9')
    ADD DL, '0'                         
    PUSH DX                             ; Push to stack (reverses the order)
    INC CX                              ; Track digit count
    
    CMP AX, 0                           ; Is there more to divide?
    JNE L_EXTRACT_LOOP                  
    
    ; --- Pop and Store Phase ---
L_STORE_LOOP:
    POP AX                              ; Retrieve most significant digit first
    MOV [SI], AL                        ; Store in buffer
    INC SI                              ; Advance string pointer
    LOOP L_STORE_LOOP                   
    
    RET
SUB_HEX_TO_DEC_STR ENDP

END MAIN

; =============================================================================
; TECHNICAL NOTES & ARCHITECTURAL INSIGHTS
; =============================================================================
; 1. RADIX EXTRACTION MECHANICS:
;    Repeatedly dividing a number by its radix (Base-10 in this case) peels off 
;    the digits starting from the Least Significant Digit (LSD). 
;    Calculation for 4660:
;    - 4660 / 10 = 466 R 0 (LSD)
;    - 466  / 10 = 46  R 6
;    - 46   / 10 = 4   R 6
;    - 4    / 10 = 0   R 4 (MSD)
;
; 2. THE STACK AS A REVERSER:
;    Since digits are extracted LSD-to-MSD (0, 6, 6, 4), but strings are read 
;    MSD-to-LSD ("4660"), we use the Stack (LIFO) to catch the digits and 
;    reorder them correctly for display.
;
; 3. ASCII ENCODING:
;    The CPU works with raw binary values. Adding 30H ('0') is the standard 
;    way to convert a scalar value (0-9) into its printable ASCII equivalent.
;
; 4. ZERO TERMINATION:
;    This implementation relies on the '$' pre-filled buffer for DOS string 
;    services. In C-style programming, one would instead append a Null (00H) 
;    at the end.
;
; 5. REGISTER CONSIDERATIONS:
;    The 'DIV' instruction modifies DX to store the remainder. If DX is not 
;    cleared (XOR DX, DX) before each division, the CPU will attempt to divide 
;    a much larger 32-bit number, likely resulting in a "Divide by Zero" 
;    exception or an overflow.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
