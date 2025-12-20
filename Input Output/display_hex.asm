;=============================================================================
; Program:     Display Hexadecimal
; Description: Convert a 16-bit value into its 4-digit hexadecimal ASCII
;              representation (0-9, A-F).
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
    NUM DW 0ABCDH                       ; Example hexadecimal value
    MSG DB 'Hexadecimal Value: $'

;-----------------------------------------------------------------------------
; CODE SEGMENT
;-----------------------------------------------------------------------------
.CODE
MAIN PROC
    ; Initialize Data Segment
    MOV AX, @DATA
    MOV DS, AX
    
    ; Display header message
    LEA DX, MSG
    MOV AH, 09H
    INT 21H
    
    ; Load number and print in hex
    MOV AX, NUM
    CALL PRINT_HEX
    
    ; Print 'H' suffix for clarity
    MOV DL, 'H'
    MOV AH, 02H
    INT 21H
    
    ; Exit to DOS
    MOV AH, 4CH
    INT 21H
MAIN ENDP

;-----------------------------------------------------------------------------
; PROCEDURE: PRINT_HEX
; Input: AX (16-bit value)
; Logic: Process 4 nibbles (4 bits each). Uses ROL and Masking.
;-----------------------------------------------------------------------------
PRINT_HEX PROC
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX
    
    MOV BX, AX                          ; Use BX as working register
    MOV CX, 4                           ; 4 hex digits in a 16-bit word
    
ROTATE_LOOP:
    ROL BX, 4                           ; Bring next nibble to low 4 bits of BL
    MOV AL, BL
    AND AL, 0FH                         ; Mask out everything except the nibble
    
    ; Convert 0-F to '0'-'9' or 'A'-'F'
    CMP AL, 9
    JA HEX_LETTER
    ADD AL, '0'                         ; Digit 0-9
    JMP PRINT_DIGIT
    
HEX_LETTER:
    ADD AL, 'A' - 10                    ; Letter A-F (Offset 10)
    
PRINT_DIGIT:
    MOV DL, AL
    MOV AH, 02H                         ; DOS: Print character
    INT 21H
    
    LOOP ROTATE_LOOP                    ; Repeat for all nibbles
    
    POP DX
    POP CX
    POP BX
    POP AX
    RET
PRINT_HEX ENDP

END MAIN

;=============================================================================
; HEXADECIMAL NOTES:
; - One hex digit represents exactly 4 bits (a nibble).
; - ROL BX, 4 is an efficient way to iterate nibbles from High to Low.
; - ASCII math: 'A' follows '9' with a gap in the ASCII table, 
;   handled here by CMP and conditional branches.
;=============================================================================
