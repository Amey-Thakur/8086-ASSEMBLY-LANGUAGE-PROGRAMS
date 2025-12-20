;=============================================================================
; Program:     Bitwise NOT Operation
; Description: Perform NOT (1's complement) operation on an 8-bit number.
;              NOT inverts all bits (0 becomes 1, 1 becomes 0).
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
    NUM1 DB 0FH                         ; Number: 00001111 (15)
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
    ; Perform NOT Operation (1's Complement)
    ; NOT Truth Table:
    ;   NOT 0 = 1
    ;   NOT 1 = 0
    ;-------------------------------------------------------------------------
    MOV AL, NUM1                        ; AL = 00001111
    NOT AL                              ; AL = NOT 00001111
    MOV RESULT, AL                      ; Result = 11110000 (F0H = 240)
    
    ;-------------------------------------------------------------------------
    ; Program Termination
    ;-------------------------------------------------------------------------
    MOV AH, 4CH                         ; DOS: Terminate program
    INT 21H
MAIN ENDP
END MAIN

;=============================================================================
; NOT OPERATION USES:
; - 1's Complement: Invert all bits
; - 2's Complement: NOT + 1 (negate signed number)
; - Bit inversion: Create inverse mask
; 
; Example: Finding 2's complement (negative number)
;   MOV AL, 5       ; AL = 00000101 (5)
;   NOT AL          ; AL = 11111010 (1's complement)
;   INC AL          ; AL = 11111011 (2's complement = -5)
; 
; Note: NOT does not affect any flags
;       NEG instruction = NOT + 1 and sets flags
;=============================================================================
