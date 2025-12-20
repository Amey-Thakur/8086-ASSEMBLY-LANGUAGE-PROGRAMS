;=============================================================================
; Program:     Diamond Star Pattern
; Description: Generate and display a symmetric diamond pattern using 
;              asterisks (*) and spaces through nested loop logic.
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
    HALF_HEIGHT DB 5                    ; Number of rows for the upper half
    MSG DB 'Symmetric Diamond Pattern:', 0DH, 0AH, '$'

;-----------------------------------------------------------------------------
; CODE SEGMENT
;-----------------------------------------------------------------------------
.CODE
MAIN PROC
    MOV AX, @DATA
    MOV DS, AX
    
    ; Display header
    LEA DX, MSG
    MOV AH, 09H
    INT 21H
    
    ;-------------------------------------------------------------------------
    ; PART 1: UPPER HALF (Including Middle Row)
    ;-------------------------------------------------------------------------
    MOV BL, 1                           ; Current row star count
    MOV BH, HALF_HEIGHT                 ; Remaining rows to print
    
UPPER_HALF_LOOP:
    PUSH BX
    
    ; 1. Print Leading Spaces: (HALF_HEIGHT - current_row)
    MOV AL, HALF_HEIGHT
    SUB AL, BL
    MOV CL, AL
    JZ SKIP_SPACES_UPPER
    
SPACE_UPPER:
    MOV DL, ' '
    MOV AH, 02H
    INT 21H
    LOOP SPACE_UPPER

SKIP_SPACES_UPPER:
    ; 2. Print Stars with space padding
    MOV CL, BL
STAR_UPPER:
    MOV DL, '*'
    MOV AH, 02H
    INT 21H
    MOV DL, ' '                         ; Space between stars for aesthetics
    INT 21H
    LOOP STAR_UPPER
    
    ; 3. Move to next line
    CALL PRINT_NEWLINE
    
    POP BX
    INC BL                              ; Increase stars for next row
    DEC BH                              ; Decrease row counter
    JNZ UPPER_HALF_LOOP
    
    ;-------------------------------------------------------------------------
    ; PART 2: LOWER HALF (Remaining HALF_HEIGHT - 1 rows)
    ;-------------------------------------------------------------------------
    MOV BL, HALF_HEIGHT
    DEC BL                              ; Start with one less than max stars
    MOV BH, BL                          ; Row counter
    
LOWER_HALF_LOOP:
    PUSH BX
    
    ; 1. Print Leading Spaces
    MOV AL, HALF_HEIGHT
    SUB AL, BL
    MOV CL, AL
SPACE_LOWER:
    MOV DL, ' '
    MOV AH, 02H
    INT 21H
    LOOP SPACE_LOWER
    
    ; 2. Print Stars
    MOV CL, BL
STAR_LOWER:
    MOV DL, '*'
    MOV AH, 02H
    INT 21H
    MOV DL, ' '
    INT 21H
    LOOP STAR_LOWER
    
    ; 3. Newline
    CALL PRINT_NEWLINE
    
    POP BX
    DEC BL                              ; Decrease stars for next row
    DEC BH                              ; Decrease row counter
    JNZ LOWER_HALF_LOOP
    
    ; Exit
    MOV AH, 4CH
    INT 21H
MAIN ENDP

; Simple Helper for CR/LF
PRINT_NEWLINE PROC
    MOV DL, 0DH
    MOV AH, 02H
    INT 21H
    MOV DL, 0AH
    INT 21H
    RET
PRINT_NEWLINE ENDP

END MAIN

;=============================================================================
; PATTERN LOGIC NOTES:
; - The diamond consists of an increasing triangle followed by a decreasing one.
; - Space indentation is calculated as: MaxRows - CurrentRow.
; - Pushing CX/BX to the stack is essential when using nested LOOP instructions
;   to prevent register corruption.
;=============================================================================
