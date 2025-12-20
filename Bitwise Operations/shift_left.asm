;=============================================================================
; Program:     Shift Left (SHL) Operation
; Description: Shift bits left by specified count.
;              Each left shift multiplies the number by 2.
; 
; Author:      Amey Thakur
; Repository:  https://github.com/Amey-Thakur/8086-ASSEMBLY-LANGUAGE-PROGRAMS
; License:     MIT License
;=============================================================================

.MODEL SMALL
.STACK 100H

;-----------------------------------------------------------------------------
; DATA SEGMENT
;-----------------------------------------------------------------------------
.DATA
    NUM1 DB 08H                         ; Number: 00001000 (8)
    SHIFT_COUNT DB 2                    ; Shift by 2 positions
    RESULT DB ?                         ; Result storage

;-----------------------------------------------------------------------------
; CODE SEGMENT
;-----------------------------------------------------------------------------
.CODE
MAIN PROC
    ; Initialize Data Segment
    MOV AX, @DATA
    MOV DS, AX
    
    ;-------------------------------------------------------------------------
    ; Perform Shift Left Operation
    ; SHL shifts bits left, fills vacated bits with 0
    ; MSB (leftmost bit) goes to Carry Flag
    ; Each shift left = multiply by 2
    ;-------------------------------------------------------------------------
    MOV AL, NUM1                        ; AL = 00001000 (8)
    MOV CL, SHIFT_COUNT                 ; CL = shift count (must use CL for count > 1)
    SHL AL, CL                          ; Shift left by CL positions
    MOV RESULT, AL                      ; Result = 00100000 (32 = 8 * 2^2)
    
    ;-------------------------------------------------------------------------
    ; Program Termination
    ;-------------------------------------------------------------------------
    MOV AH, 4CH                         ; DOS: Terminate program
    INT 21H
MAIN ENDP
END MAIN

;=============================================================================
; SHL (SHIFT LEFT) NOTES:
; - SHL and SAL (Shift Arithmetic Left) are identical
; - Each shift multiplies by 2
; - MSB goes to Carry Flag (CF)
; - LSB is filled with 0
; 
; Visual Example:
;   Before SHL 1: [0][0][0][0][1][0][0][0] = 8
;   After SHL 1:  [0][0][0][1][0][0][0][0] = 16
;   CF gets the MSB that was shifted out
; 
; Fast multiplication by powers of 2:
;   SHL AL, 1  ; AL = AL * 2
;   SHL AL, 3  ; AL = AL * 8 (2^3)
;=============================================================================
