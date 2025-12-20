;=============================================================================
; Program:     Check Even or Odd
; Description: Check whether a number is even or odd using division.
;              Even numbers have remainder 0 when divided by 2.
; 
; Author:      Amey Thakur
; Repository:  https://github.com/Amey-Thakur/8086-ASSEMBLY-LANGUAGE-PROGRAMS
; License:     MIT License
;=============================================================================

;-----------------------------------------------------------------------------
; MACRO: Display String
;-----------------------------------------------------------------------------
DISPLAY MACRO MSG
    MOV AH, 9
    LEA DX, MSG
    INT 21H
ENDM

;-----------------------------------------------------------------------------
; DATA SEGMENT
;-----------------------------------------------------------------------------
DATA SEGMENT
    MSG1 DB 10, 13, 'Enter number here: $'
    MSG2 DB 10, 13, 'Entered value is EVEN$'
    MSG3 DB 10, 13, 'Entered value is ODD$'
DATA ENDS

;-----------------------------------------------------------------------------
; CODE SEGMENT
;-----------------------------------------------------------------------------
CODE SEGMENT
    ASSUME CS:CODE, DS:DATA
    
START:
    ; Initialize Data Segment
    MOV AX, DATA
    MOV DS, AX
    
    ; Prompt for input
    DISPLAY MSG1
    
    ; Read single digit from user
    MOV AH, 1
    INT 21H
    
    ;-------------------------------------------------------------------------
    ; Check Even/Odd
    ; Divide by 2: if remainder (AH) = 0, number is even
    ;-------------------------------------------------------------------------
    MOV AH, 0                           ; Clear high byte
CHECK:
    MOV DL, 2
    DIV DL                              ; AL = quotient, AH = remainder
    CMP AH, 0                           ; Compare remainder with 0
    JNE ODD                             ; If not zero, number is odd
    
EVEN:
    DISPLAY MSG2
    JMP DONE
    
ODD:
    DISPLAY MSG3
    
DONE:
    ; Exit to DOS
    MOV AH, 4CH
    INT 21H
CODE ENDS
END START

;=============================================================================
; EVEN/ODD CHECK NOTES:
; - Even: Divisible by 2 (remainder = 0)
; - Odd: Not divisible by 2 (remainder = 1)
; - Alternative method: TEST AL, 1 (check LSB)
;   If LSB = 0, even; if LSB = 1, odd
;=============================================================================
