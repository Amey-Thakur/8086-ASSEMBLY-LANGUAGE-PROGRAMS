;=============================================================================
; Program:     Addition of Two 16-bit Numbers
; Description: Demonstrates 16-bit addition of word-sized operands.
;              Also shows 8-bit addition for comparison.
; 
; Author:      Amey Thakur
; Repository:  https://github.com/Amey-Thakur/8086-ASSEMBLY-LANGUAGE-PROGRAMS
; License:     MIT License
;=============================================================================

;-----------------------------------------------------------------------------
; DATA SEGMENT
;-----------------------------------------------------------------------------
DATA SEGMENT
    num1 DB 05H                         ; 8-bit number 1
    num2 DB 06H                         ; 8-bit number 2
    num3 DW 1234H                       ; 16-bit number 1 (4660 decimal)
    num4 DW 0002H                       ; 16-bit number 2 (2 decimal)
    sum DB ?                            ; 8-bit sum result
    sum2 DW ?                           ; 16-bit sum result
DATA ENDS   

ASSUME CS:CODE, DS:DATA

;-----------------------------------------------------------------------------
; CODE SEGMENT
;-----------------------------------------------------------------------------
CODE SEGMENT
    START: 
           ; Initialize Data Segment
           MOV AX, DATA
           MOV DS, AX                   ; Set up data segment
    
           ;-----------------------------------------------------------------
           ; 8-bit Addition: num1 + num2
           ;-----------------------------------------------------------------
           MOV AL, num1                 ; Load first 8-bit number
           ADD AL, num2                 ; AL = AL + num2 (05H + 06H = 0BH)
           MOV sum, AL                  ; Store 8-bit result
    
           ;-----------------------------------------------------------------
           ; 16-bit Addition: num3 + num4
           ;-----------------------------------------------------------------
           MOV CX, num3                 ; Load first 16-bit number
           ADD CX, num4                 ; CX = CX + num4 (1234H + 0002H = 1236H)
           MOV sum2, CX                 ; Store 16-bit result
    
           ;-----------------------------------------------------------------
           ; Program Termination
           ;-----------------------------------------------------------------
           MOV AH, 4CH
           INT 21H
    
CODE ENDS
END START

;=============================================================================
; NOTES:
; - 8-bit addition: Uses AL, AH, BL, BH, CL, CH, DL, DH registers
; - 16-bit addition: Uses AX, BX, CX, DX, SI, DI registers
; - CF (Carry Flag) is set if result overflows the register size
; - For 32-bit addition, use ADC (Add with Carry) for high word
;=============================================================================
