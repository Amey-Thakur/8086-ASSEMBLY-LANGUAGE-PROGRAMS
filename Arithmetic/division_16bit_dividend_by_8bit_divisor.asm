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

.MODEL SMALL
.STACK 100H

; -----------------------------------------------------------------------------
; DATA SEGMENT
; -----------------------------------------------------------------------------
.DATA
    ; Dividend (16-bit Word): 6827H = 26,663 decimal
    VAL_DIVIDEND DW 6827H               
    
    ; Divisor (8-bit Byte): 0FEH = 254 decimal
    VAL_DIVISOR  DB 0FEH                
    
    ; Buffers to store results
    RES_QUO      DB ?                   ; Quotient (Expected: 69H = 105)
    RES_REM      DB ?                   ; Remainder (Expected: 0D5H = 213)

; -----------------------------------------------------------------------------
; CODE SEGMENT
; -----------------------------------------------------------------------------
.CODE
MAIN PROC
    ; --- Step 1: Initialization ---
    MOV AX, @DATA
    MOV DS, AX
    
    ; --- Step 2: Prepare Operands ---
    ; For an 8-bit divisor, the 8086 hardware REQUIRES the dividend in AX.
    MOV AX, VAL_DIVIDEND                
    MOV BL, VAL_DIVISOR                 
    
    ; --- Step 3: Perform Unsigned Division ---
    ; Calculation: 26663 / 254 = 105 (69H) with remainder 213 (D5H).
    DIV BL                              
    
    ; --- Step 4: Store Results ---
    MOV RES_QUO, AL                     ; Quotient is in AL
    MOV RES_REM, AH                     ; Remainder is in AH
    
    ; --- Step 5: Clean Exit ---
    MOV AH, 4CH
    INT 21H
MAIN ENDP

END MAIN

; =============================================================================
; TECHNICAL NOTES & ARCHITECTURAL INSIGHTS
; =============================================================================
; 1. DIV OPERAND SIZES:
;    The 8086 handles division in two distinct modes:
;    - Mode A (8-bit divisor): AX / Reg8 -> AL (Quotient), AH (Remainder)
;    - Mode B (16-bit divisor): DX:AX / Reg16 -> AX (Quotient), DX (Remainder)
;
; 2. DIVIDE ERROR (INTERRUPT 0):
;    The processor triggers a "Divide-by-Zero" interrupt (Type 0) if:
;    - The divisor is 0.
;    - The quotient is too large to fit in the target register (Overflow).
;
; 3. SIGNED vs UNSIGNED:
;    - 'DIV' is strictly for unsigned (positive) numbers.
;    - 'IDIV' must be used for signed (Two's Complement) arithmetic.
;
; 4. REGISTER PRESERVATION:
;    The DIV instruction destroys original AX (and DX for 16-bit DIV) values.
;
; 5. EXAMPLE VERIFICATION:
;    Dividend (26,663) = (Quotient [105] * Divisor [254]) + Remainder [213]
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
