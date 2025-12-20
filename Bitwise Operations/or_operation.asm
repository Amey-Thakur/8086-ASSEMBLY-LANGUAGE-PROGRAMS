;=============================================================================
; Program:     Bitwise OR Operation
; Description: Perform OR operation on two 8-bit numbers.
;              OR returns 1 when at least one bit is 1.
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
    ; Perform OR Operation
    ; OR Truth Table:
    ;   0 OR 0 = 0
    ;   0 OR 1 = 1
    ;   1 OR 0 = 1
    ;   1 OR 1 = 1
    ;-------------------------------------------------------------------------
    MOV AL, NUM1                        ; AL = 00001111
    OR AL, NUM2                         ; AL = 00001111 OR 11110000
    MOV RESULT, AL                      ; Result = 11111111 (FFH = 255)
    
    ;-------------------------------------------------------------------------
    ; Program Termination
    ;-------------------------------------------------------------------------
    MOV AH, 4CH                         ; DOS: Terminate program
    INT 21H
MAIN ENDP
END MAIN

;=============================================================================
; OR OPERATION USES:
; - Setting bits: Set specific bits (OR with 1 sets the bit)
; - Combining flags: Merge multiple bit flags
; - Converting to uppercase: OR char with 20H
; 
; Example: Set bit 7
;   MOV AL, 01H     ; AL = 00000001
;   OR AL, 80H      ; AL = 10000001 (bit 7 now set)
;=============================================================================
