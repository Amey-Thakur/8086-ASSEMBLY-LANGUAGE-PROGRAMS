;=============================================================================
; Program:     Number Pyramid Pattern
; Description: Display a centered pyramid where each row contains 
;              consecutive numbers starting from 1.
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
    MAX_ROWS DB 5
    MSG      DB 'Numeric Pyramid Structure:', 0DH, 0AH, '$'

;-----------------------------------------------------------------------------
; CODE SEGMENT
;-----------------------------------------------------------------------------
.CODE
MAIN PROC
    ; Setup Data Segment
    MOV AX, @DATA
    MOV DS, AX
    
    ; Print Header
    LEA DX, MSG
    MOV AH, 09H
    INT 21H
    
    MOV BL, 1                           ; Current row number
    MOV BH, MAX_ROWS                    ; Total rows
    
;-------------------------------------------------------------------------
; OUTER ROW LOOP
;-------------------------------------------------------------------------
ROW_LOOP:
    PUSH BX
    
    ; 1. Print Leading Spaces: (MAX_ROWS - Current_Row)
    MOV AL, MAX_ROWS
    SUB AL, BL
    MOV CL, AL
    JZ START_NUMS                       ; Skip if no spaces needed
    
SPACE_LOOP:
    MOV DL, ' '
    MOV AH, 02H
    INT 21H
    LOOP SPACE_LOOP
    
;-------------------------------------------------------------------------
; 2. PRINT CONSECUTIVE NUMBERS
;-------------------------------------------------------------------------
START_NUMS:
    MOV CL, BL                          ; Numbers per row = row number
    MOV DL, '1'                         ; Always start row with '1'
    
NUM_GEN:
    MOV AH, 02H
    INT 21H
    INC DL                              ; Increment ASCII character: '1' -> '2' ...
    LOOP NUM_GEN
    
    ; 3. Print Newline
    MOV DL, 0DH
    MOV AH, 02H
    INT 21H
    MOV DL, 0AH
    INT 21H
    
    POP BX
    INC BL                              ; Increment for next row
    DEC BH                              ; Row counter
    JNZ ROW_LOOP
    
    ; Return to DOS
    MOV AH, 4CH
    INT 21H
MAIN ENDP
END MAIN

;=============================================================================
; NUMBER PYRAMID NOTES:
; - ASCII math: To print digits 1-9, we simply increment the starting char '1'.
; - Alignment is achieved by calculating padding spaces before numbers.
; - Expected Output (5 rows):
;       1
;      12
;     123
;    1234
;   12345
;=============================================================================
