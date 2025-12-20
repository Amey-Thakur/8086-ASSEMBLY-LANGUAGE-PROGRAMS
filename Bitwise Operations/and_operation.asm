;=============================================================================
; Program:     Bitwise AND Operation
; Description: Perform AND operation on two 8-bit numbers.
;              AND returns 1 only when both bits are 1.
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
    NUM1 DB 0FH                         ; First number:  00001111 (15)
    NUM2 DB 0F0H                        ; Second number: 11110000 (240)
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
    ; Perform AND Operation
    ; AND Truth Table:
    ;   0 AND 0 = 0
    ;   0 AND 1 = 0
    ;   1 AND 0 = 0
    ;   1 AND 1 = 1
    ;-------------------------------------------------------------------------
    MOV AL, NUM1                        ; AL = 00001111
    AND AL, NUM2                        ; AL = 00001111 AND 11110000
    MOV RESULT, AL                      ; Result = 00000000 (0)
    
    ;-------------------------------------------------------------------------
    ; Program Termination
    ;-------------------------------------------------------------------------
    MOV AH, 4CH                         ; DOS: Terminate program
    INT 21H
MAIN ENDP
END MAIN

;=============================================================================
; AND OPERATION USES:
; - Masking: Clear specific bits (AND with 0 clears the bit)
; - Testing: Check if specific bits are set
; - Extracting: Get specific bits from a value
; 
; Example: Extract lower nibble
;   MOV AL, 5BH     ; AL = 01011011
;   AND AL, 0FH     ; AL = 00001011 (lower nibble only)
;=============================================================================
