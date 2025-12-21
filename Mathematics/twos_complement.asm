; =============================================================================
; TITLE: Two's Complement (Negation)
; DESCRIPTION: Demonstrate how to negate a signed 16-bit integer using 
;              the Two's Complement arithmetic method.
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
    NUM     DW 25                       ; Positive number
    NEG_NUM DW ?                        ; Expected: -25 (in Two's Comp)
    MSG     DB 'Negation completed successfully.$'

; -----------------------------------------------------------------------------
; CODE SEGMENT
; -----------------------------------------------------------------------------
.CODE
MAIN PROC
    ; Environment Setup
    MOV AX, @DATA
    MOV DS, AX
    
    ; -------------------------------------------------------------------------
    ; THE 'NEG' INSTRUCTION
    ; This is the standard 8086 instruction to find Two's Complement.
    ; Operation: Dest = (NOT Dest) + 1
    ; -------------------------------------------------------------------------
    MOV AX, NUM
    NEG AX                              ; Atomically perform 2's complement
    MOV NEG_NUM, AX                     ; Store result
    
    ; -------------------------------------------------------------------------
    ; MANUAL ALTERNATIVE (Same result):
    ; MOV AX, NUM
    ; NOT AX                            ; Perform One's Complement (flip bits)
    ; INC AX                            ; Add 1
    ; -------------------------------------------------------------------------
    
    ; Output status message
    LEA DX, MSG
    MOV AH, 09H
    INT 21H
    
    ; Program termination
    MOV AH, 4CH
    INT 21H
MAIN ENDP
END MAIN

; =============================================================================
; TECHNICAL NOTES
; =============================================================================
; 1. TWO'S COMPLEMENT:
;    - In Two's Complement, the MSB acts as the sign bit (1 for Negative).
;    - Range for 16-bit signed: -32,768 to +32,767.
;    - Value +25 in Hex: 0019h
;    - Value -25 in Hex: FF E7h (NOT 0019h = FF E6h, +1 = FF E7h)
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
