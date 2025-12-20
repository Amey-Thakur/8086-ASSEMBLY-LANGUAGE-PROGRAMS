;=============================================================================
; Program:     Armstrong Number Check
; Description: Check if a 16-bit number is an Armstrong number.
;              For a 3-digit number, Armstrong property means:
;              Number = (Digit1^3) + (Digit2^3) + (Digit3^3)
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
    NUM DW 153                           ; 153 = 1^3 + 5^3 + 3^3 = 1 + 125 + 27
    SUM DW 0                             ; To store the calculated sum of cubes
    MSG_YES DB 'Number is an ARMSTRONG number!$'
    MSG_NO  DB 'Number is NOT an Armstrong number.$'

;-----------------------------------------------------------------------------
; CODE SEGMENT
;-----------------------------------------------------------------------------
.CODE
MAIN PROC
    ; Initialize Data Segment
    MOV AX, @DATA
    MOV DS, AX
    
    MOV AX, NUM                         ; AX holds the quotient (starting with original)
    MOV BX, 10                          ; Divisor to extract base-10 digits
    
;-------------------------------------------------------------------------
; DIGIT EXTRACTION AND CUBE SUMMATION
;-------------------------------------------------------------------------
EXTRACT_DIGIT:
    CMP AX, 0                           ; Are we out of digits?
    JE VERIFY_RESULT
    
    XOR DX, DX                          ; Clear DX for 32/16 division
    DIV BX                              ; AX = Quotient (remaining digits), DX = Digit
    
    PUSH AX                             ; Save remaining digits for next iteration
    
    ; Logic: Calculate DX * DX * DX (Cube of the digit)
    MOV AX, DX
    MUL DX                              ; AX = DX^2
    MUL DX                              ; AX = DX^3 (DX is max 9, so AX max 729)
    
    ADD SUM, AX                         ; Add current cube to running total
    
    POP AX                              ; Restore remaining digits to AX
    JMP EXTRACT_DIGIT
    
;-------------------------------------------------------------------------
; FINAL COMPARISON
;-------------------------------------------------------------------------
VERIFY_RESULT:
    MOV AX, SUM
    CMP AX, NUM                         ; Does Sum of Cubes equal Original Number?
    JE SUCCESS
    
    LEA DX, MSG_NO
    JMP DISPLAY_AND_EXIT
    
SUCCESS:
    LEA DX, MSG_YES
    
DISPLAY_AND_EXIT:
    MOV AH, 09H                         ; DOS: Print string
    INT 21H
    
    ; Termination
    MOV AH, 4CH
    INT 21H
MAIN ENDP
END MAIN

;=============================================================================
; ARMSTRONG NUMBER REFERENCE:
; - Definition: An n-digit number that is equal to the sum of the nth powers
;   of its digits.
; - Common 3-digit examples: 153, 370, 371, 407.
; - This implementation specifically targets the cube logic for 3 digits.
;=============================================================================
