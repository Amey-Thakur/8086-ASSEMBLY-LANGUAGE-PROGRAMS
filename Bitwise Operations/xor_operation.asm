;=============================================================================
; Program:     Bitwise XOR Operation
; Description: Perform XOR (Exclusive OR) operation on two 8-bit numbers.
;              XOR returns 1 when bits are different.
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
    NUM1 DB 0AAH                        ; First number:  10101010 (170)
    NUM2 DB 55H                         ; Second number: 01010101 (85)
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
    ; Perform XOR Operation
    ; XOR Truth Table:
    ;   0 XOR 0 = 0
    ;   0 XOR 1 = 1
    ;   1 XOR 0 = 1
    ;   1 XOR 1 = 0
    ;-------------------------------------------------------------------------
    MOV AL, NUM1                        ; AL = 10101010
    XOR AL, NUM2                        ; AL = 10101010 XOR 01010101
    MOV RESULT, AL                      ; Result = 11111111 (FFH = 255)
    
    ;-------------------------------------------------------------------------
    ; Program Termination
    ;-------------------------------------------------------------------------
    MOV AH, 4CH                         ; DOS: Terminate program
    INT 21H
MAIN ENDP
END MAIN

;=============================================================================
; XOR OPERATION USES:
; - Toggle bits: Flip specific bits (XOR with 1 toggles)
; - Clear register: XOR AX, AX (faster than MOV AX, 0)
; - Swap values: A=A^B, B=A^B, A=A^B (swap without temp)
; - Encryption: Simple XOR cipher
; - Check equality: A XOR A = 0
; 
; Example: Toggle case of ASCII letter
;   MOV AL, 'A'     ; AL = 41H (uppercase A)
;   XOR AL, 20H     ; AL = 61H (lowercase a)
;   XOR AL, 20H     ; AL = 41H (back to uppercase)
;=============================================================================
