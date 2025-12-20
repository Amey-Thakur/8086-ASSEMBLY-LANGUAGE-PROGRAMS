;=============================================================================
; Program:     Multiplication of Two 8-bit Numbers
; Description: Multiplies two 8-bit unsigned numbers and stores 16-bit result.
;              Demonstrates the MUL instruction for unsigned multiplication.
; 
; Author:      Amey Thakur
; Repository:  https://github.com/Amey-Thakur/8086-ASSEMBLY-LANGUAGE-PROGRAMS
; License:     MIT License
;=============================================================================

;-----------------------------------------------------------------------------
; DATA SEGMENT
;-----------------------------------------------------------------------------
DATA SEGMENT
    var1 DB 0EDH                        ; First operand (237 decimal)
    var2 DB 99H                         ; Second operand (153 decimal)
    res DW ?                            ; Result (16-bit for 8-bit x 8-bit)
DATA ENDS          

ASSUME CS:CODE, DS:DATA

;-----------------------------------------------------------------------------
; CODE SEGMENT
; MUL instruction: For 8-bit operands, result is stored in AX
;                  AX = AL * operand
;-----------------------------------------------------------------------------
CODE SEGMENT
    START: 
           ; Initialize Data Segment
           MOV AX, DATA
           MOV DS, AX
           
           ;-----------------------------------------------------------------
           ; Load Operands
           ;-----------------------------------------------------------------
           MOV AL, var1                 ; Load first operand into AL
           MOV BL, var2                 ; Load second operand into BL
           
           ;-----------------------------------------------------------------
           ; Perform Unsigned Multiplication
           ; MUL BL: AX = AL * BL
           ; Result: 0EDH * 99H = 8E55H (36,437 decimal)
           ;-----------------------------------------------------------------
           MUL BL                       ; AX = AL * BL (unsigned)
           
           ;-----------------------------------------------------------------
           ; Store Result
           ;-----------------------------------------------------------------
           MOV res, AX                  ; Store 16-bit product
           
           ;-----------------------------------------------------------------
           ; Program Termination
           ;-----------------------------------------------------------------
           MOV AH, 4CH
           INT 21H
           
CODE ENDS
END START

;=============================================================================
; NOTES:
; - MUL performs unsigned multiplication
; - For 8-bit multiplication: AX = AL * operand
; - For 16-bit multiplication: DX:AX = AX * operand
; - Use IMUL for signed multiplication
;=============================================================================
