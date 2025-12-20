;=============================================================================
; Program:     DAA (Decimal Adjust for Addition) Demo
; Description: Demonstrates DAA instruction to correct BCD addition result.
;              BCD stores each decimal digit in a nibble (4 bits).
; 
; Author:      Amey Thakur
; Repository:  https://github.com/Amey-Thakur/8086-ASSEMBLY-LANGUAGE-PROGRAMS
; License:     MIT License
;=============================================================================

.MODEL SMALL
.STACK 200

;-----------------------------------------------------------------------------
; DATA SEGMENT
; BCD numbers: 27H = 27 decimal, 35H = 35 decimal
; Expected: 27 + 35 = 62 (should display 62H after DAA)
;-----------------------------------------------------------------------------
.DATA
    num1 DB 27H                         ; First BCD number (27 decimal)
    num2 DB 35H                         ; Second BCD number (35 decimal)

;-----------------------------------------------------------------------------
; CODE SEGMENT
;-----------------------------------------------------------------------------
.CODE
.STARTUP
    ;-------------------------------------------------------------------------
    ; Perform BCD Addition
    ;-------------------------------------------------------------------------
    MOV AL, num1                        ; Load first BCD number (27H)
    ADD AL, num2                        ; AL = 27H + 35H = 5CH (92 in hex)
    
    ; Without DAA: 5CH = 92 (incorrect BCD)
    ; Expected result: 62H = 62 (correct BCD)
    
    ;-------------------------------------------------------------------------
    ; Decimal Adjust for Addition
    ; DAA converts binary sum to valid BCD format
    ;-------------------------------------------------------------------------
    DAA                                 ; AL = 62H (correct BCD result)
    
.EXIT
END

;=============================================================================
; DAA INSTRUCTION DETAILS:
; - Works only with AL register
; - Adjusts result after adding two packed BCD numbers
; - If lower nibble > 9 or AF = 1: Add 6 to lower nibble
; - If upper nibble > 9 or CF = 1: Add 60H to AL
;
; Example:
;   27H + 35H = 5CH (binary addition)
;   Lower nibble: C > 9, so add 6 -> 5CH + 06H = 62H
;   Result: 62H = 62 decimal (correct!)
;=============================================================================
