;=============================================================================
; Program:     Shift Right (SHR) Operation
; Description: Shift bits right by specified count.
;              Each right shift divides the number by 2 (unsigned).
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
    NUM1 DB 20H                         ; Number: 00100000 (32)
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
    ; Perform Shift Right Operation
    ; SHR shifts bits right, fills vacated bits with 0
    ; LSB (rightmost bit) goes to Carry Flag
    ; Each shift right = divide by 2 (unsigned)
    ;-------------------------------------------------------------------------
    MOV AL, NUM1                        ; AL = 00100000 (32)
    MOV CL, SHIFT_COUNT                 ; CL = shift count
    SHR AL, CL                          ; Shift right by CL positions
    MOV RESULT, AL                      ; Result = 00001000 (8 = 32 / 2^2)
    
    ;-------------------------------------------------------------------------
    ; Program Termination
    ;-------------------------------------------------------------------------
    MOV AH, 4CH                         ; DOS: Terminate program
    INT 21H
MAIN ENDP
END MAIN

;=============================================================================
; SHR (SHIFT RIGHT) NOTES:
; - SHR is for UNSIGNED numbers (fills MSB with 0)
; - SAR (Shift Arithmetic Right) is for SIGNED numbers (preserves sign)
; - Each shift divides by 2
; - LSB goes to Carry Flag (CF)
; - MSB is filled with 0
; 
; Visual Example:
;   Before SHR 1: [0][0][1][0][0][0][0][0] = 32
;   After SHR 1:  [0][0][0][1][0][0][0][0] = 16
;   CF gets the LSB that was shifted out
; 
; Fast division by powers of 2:
;   SHR AL, 1  ; AL = AL / 2
;   SHR AL, 3  ; AL = AL / 8 (2^3)
;=============================================================================
