;=============================================================================
; Program:     Signed Number Operations
; Description: Demonstrate signed arithmetic and comparisons.
;              Shows how to work with negative numbers in 8086 using
;              two's complement representation.
; 
; Author:      Amey Thakur
; Repository:  https://github.com/Amey-Thakur/8086-ASSEMBLY-LANGUAGE-PROGRAMS
; License:     MIT License
;=============================================================================

.MODEL SMALL
.STACK 100H

.DATA
    NUM1 DW -50      ; Negative number
    NUM2 DW 30       ; Positive number
    RESULT DW ?
    
    MSG_POS DB 'Result is positive$'
    MSG_NEG DB 'Result is negative$'
    MSG_ZERO DB 'Result is zero$'
    NEWLINE DB 0DH, 0AH, '$'

.CODE
MAIN PROC
    MOV AX, @DATA
    MOV DS, AX
    
    ; Signed addition
    MOV AX, NUM1     ; AX = -50
    ADD AX, NUM2     ; AX = -50 + 30 = -20
    MOV RESULT, AX
    
    ; Check sign using SF (Sign Flag)
    CMP AX, 0
    JG IS_POSITIVE   ; Jump if Greater (signed)
    JL IS_NEGATIVE   ; Jump if Less (signed)
    
    LEA DX, MSG_ZERO
    JMP DISPLAY
    
IS_POSITIVE:
    LEA DX, MSG_POS
    JMP DISPLAY
    
IS_NEGATIVE:
    LEA DX, MSG_NEG
    
DISPLAY:
    MOV AH, 09H
    INT 21H
    
    ; Signed comparison example
    MOV AX, NUM1
    CMP AX, NUM2
    
    ; For signed comparison:
    ; JG  - Jump if Greater
    ; JGE - Jump if Greater or Equal
    ; JL  - Jump if Less
    ; JLE - Jump if Less or Equal
    
    ; For unsigned comparison:
    ; JA  - Jump if Above
    ; JAE - Jump if Above or Equal
    ; JB  - Jump if Below
    ; JBE - Jump if Below or Equal
    
    MOV AH, 4CH
    INT 21H
MAIN ENDP
END MAIN

; Signed Number Representation (16-bit):
; Positive: 0 to 32767 (0000H to 7FFFH)
; Negative: -1 to -32768 (FFFFH to 8000H)
; 
; Two's Complement:
; -1  = FFFFH
; -50 = FFCEH
; -128 = FF80H
