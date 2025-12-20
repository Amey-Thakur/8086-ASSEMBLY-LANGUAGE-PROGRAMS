;=============================================================================
; Program:     16-bit BCD Addition with DAA
; Description: Adds two 16-bit BCD (Binary Coded Decimal) numbers using
;              DAA (Decimal Adjust for Addition) instruction.
; 
; Author:      Amey Thakur
; Repository:  https://github.com/Amey-Thakur/8086-ASSEMBLY-LANGUAGE-PROGRAMS
; License:     MIT License
;=============================================================================

;-----------------------------------------------------------------------------
; DATA SEGMENT
; BCD numbers: Each nibble represents a decimal digit (0-9)
; Example: 9348H = 9348 in BCD = 9348 decimal
;-----------------------------------------------------------------------------
DATA SEGMENT
    var1 DW 9348H                       ; First BCD number (9348 decimal)
    var2 DW 1845H                       ; Second BCD number (1845 decimal)
    result DW ?                         ; BCD sum result (11193)
    carry DW 00H                        ; Carry indicator
DATA ENDS

;-----------------------------------------------------------------------------
; CODE SEGMENT
;-----------------------------------------------------------------------------
CODE SEGMENT
    ASSUME CS:CODE, DS:DATA
    
    START: 
           ; Initialize Data Segment
           MOV AX, DATA
           MOV DS, AX
           
           ;-----------------------------------------------------------------
           ; Load BCD Operands
           ;-----------------------------------------------------------------
           MOV AX, var1                 ; AX = 9348H (BCD)
           MOV BX, var2                 ; BX = 1845H (BCD)
           
           ;-----------------------------------------------------------------
           ; Add Lower Bytes with DAA
           ; DAA adjusts AL after BCD addition
           ;-----------------------------------------------------------------
           ADD AL, BL                   ; Add lower bytes: 48H + 45H = 8DH
           DAA                          ; Decimal Adjust: 8DH -> 93H (93 BCD)
           MOV CL, AL                   ; Save adjusted lower byte
           
           ;-----------------------------------------------------------------
           ; Add Upper Bytes with DAA
           ; Note: DAA only works with AL register
           ;-----------------------------------------------------------------
           MOV AL, AH                   ; Move upper byte to AL
           ADC AL, BH                   ; Add with carry: 93H + 18H + C = ?
           DAA                          ; Decimal Adjust for upper byte
           MOV CH, AL                   ; Save adjusted upper byte
           
           ;-----------------------------------------------------------------
           ; Check for Final Carry
           ;-----------------------------------------------------------------
           JNC SKIP                     ; Jump if no carry
           MOV carry, 01H               ; Set carry indicator
           
    SKIP:  
           MOV result, CX               ; Store BCD result
           
           ;-----------------------------------------------------------------
           ; Breakpoint for Debugging
           ;-----------------------------------------------------------------
           INT 03H
           
           END START
CODE ENDS

;=============================================================================
; NOTES:
; - BCD (Binary Coded Decimal): Each nibble = one decimal digit (0-9)
; - DAA (Decimal Adjust for Addition): Corrects AL after BCD addition
; - DAA adds 6 if lower nibble > 9 or AF = 1
; - DAA adds 60H if upper nibble > 9 or CF = 1
; - 9348 + 1845 = 11193 (with carry = 1, result = 1193H)
;=============================================================================
