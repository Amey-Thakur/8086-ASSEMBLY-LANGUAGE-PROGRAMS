; =============================================================================
; TITLE: 16-bit Dividend by 8-bit Divisor (Unsigned)
; DESCRIPTION: This program demonstrates how to use the DIV instruction in the 
;              Intel 8086 to perform unsigned integer division. It specifically 
;              shows the implicit register usage and result placement for 
;              8-bit divisors.
; AUTHOR: Amey Thakur (https://github.com/Amey-Thakur)
; REPOSITORY: https://github.com/Amey-Thakur/8086-ASSEMBLY-LANGUAGE-PROGRAMS
; LICENSE: MIT License
; =============================================================================

; -----------------------------------------------------------------------------
; DATA SEGMENT
; -----------------------------------------------------------------------------
DATA SEGMENT
    ; Dividend (16-bit Word): 6827H = 26,663 decimal
    VAL_DIVIDEND DW 6827H               
    
    ; Divisor (8-bit Byte): 0FEH = 254 decimal
    VAL_DIVISOR  DB 0FEH                
    
    ; Buffers to store results
    RESULT_QUO   DB ?                   ; Quotient (Expected: 69H = 105)
    RESULT_REM   DB ?                   ; Remainder (Expected: 0D5H = 213)
DATA ENDS          

; -----------------------------------------------------------------------------
; CODE SEGMENT
; -----------------------------------------------------------------------------
CODE SEGMENT
    ASSUME CS:CODE, DS:DATA

START: 
    ; --- Step 1: Initialization ---
    MOV AX, DATA
    MOV DS, AX
    
    ; --- Step 2: Prepare Operands ---
    ; For an 8-bit divisor, the 8086 hardware REQUIRES the dividend to be in AX.
    MOV AX, VAL_DIVIDEND                
    MOV BL, VAL_DIVISOR                 
    
    ; --- Step 3: Perform Unsigned Division ---
    ; Execution Logic of 'DIV BL':
    ; 1. The 16-bit value in AX is divided by the 8-bit value in BL.
    ; 2. The 8-bit QUOTIENT is stored in AL.
    ; 3. The 8-bit REMAINDER is stored in AH.
    ; Calculation: 26663 / 254 = 105 (69H) with remainder 213 (D5H).
    DIV BL                              
    
    ; --- Step 4: Store results in Memory ---
    MOV RESULT_QUO, AL                  
    MOV RESULT_REM, AH                  
    
    ; --- Step 5: Clean Exit ---
    MOV AH, 4CH
    INT 21H
            
CODE ENDS

; =============================================================================
; TECHNICAL NOTES & ARCHITECTURAL INSIGHTS
; =============================================================================
; 1. DIV OPERAND SIZES:
;    The 8086 handles division in two distinct modes:
;    - Mode A (8-bit divisor): AX / Reg8 -> AL (Quotient), AH (Remainder)
;    - Mode B (16-bit divisor): DX:AX / Reg16 -> AX (Quotient), DX (Remainder)
;
; 2. DIVIDE ERROR (INTERRUPT 0):
;    The processor will automatically trigger a "Divide-by-Zero" internal 
;    interrupt (Type 0) if:
;    - The divisor is 0.
;    - The resulting quotient is too large to fit in the target register 
;      (AL for 8-bit, AX for 16-bit).
;
; 3. SIGNED vs UNSIGNED:
;    - 'DIV' is strictly for unsigned (positive) numbers.
;    - 'IDIV' must be used for signed (Two's Complement) arithmetic.
;
; 4. REGISTER PRESERVATION:
;    Note that the DIV instruction destroys the original values in AX (and 
;    potentially DX) to store the results.
;
; 5. EXAMPLE VERIFICATION:
;    Dividend (26,663) = (Quotient * Divisor) + Remainder
;    26,663 = (105 * 254) + 213
;    26,663 = 26,450 + 213 -> Correct!
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =

END START

;=============================================================================
; NOTES:
; - DIV performs unsigned division
; - For 8-bit divisor: AX / operand -> AL=quotient, AH=remainder
; - For 16-bit divisor: DX:AX / operand -> AX=quotient, DX=remainder
; - Division by zero causes interrupt (type 0)
; - Use IDIV for signed division
;=============================================================================
