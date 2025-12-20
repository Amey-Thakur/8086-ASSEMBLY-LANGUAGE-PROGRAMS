;=============================================================================
; Program:     Decimal Number Input
; Description: Read a multi-digit decimal number from the user keyboard,
;              convert the ASCII input stream into a 16-bit integer.
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
    PROMPT DB 'Enter a decimal number: $'
    RESULT_MSG DB 0DH, 0AH, 'Stored value (verified): $'
    NUMBER DW 0

;-----------------------------------------------------------------------------
; CODE SEGMENT
;-----------------------------------------------------------------------------
.CODE
MAIN PROC
    ; Initialize Data Segment
    MOV AX, @DATA
    MOV DS, AX
    
    ; Prompt user
    LEA DX, PROMPT
    MOV AH, 09H
    INT 21H
    
    ; Call input routine
    CALL READ_NUMBER
    MOV NUMBER, AX                      ; Store result in memory
    
    ; Echo back the number to verify conversion
    LEA DX, RESULT_MSG
    MOV AH, 09H
    INT 21H
    
    MOV AX, NUMBER
    CALL PRINT_DECIMAL
    
    ; Exit to DOS
    MOV AH, 4CH
    INT 21H
MAIN ENDP

;-----------------------------------------------------------------------------
; PROCEDURE: READ_NUMBER
; Output: AX (The resulting integer)
; Logic: Accumulates digits using Weighting Method: Total = (Total * 10) + New
;-----------------------------------------------------------------------------
READ_NUMBER PROC
    PUSH BX
    PUSH CX
    PUSH DX
    
    XOR BX, BX                          ; Clear accumulator (Running Total)
    
READ_LOOP:
    MOV AH, 01H                         ; DOS: Read with echo
    INT 21H
    
    CMP AL, 0DH                         ; Is it 'Enter' key?
    JE READ_DONE
    
    ; Input Validation: Only allow '0'-'9'
    CMP AL, '0'
    JB READ_LOOP
    CMP AL, '9'
    JA READ_LOOP
    
    ; Convert ASCII '0'-'9' to value 0-9
    SUB AL, '0'
    XOR AH, AH
    
    ; Accumulate: BX = (BX * 10) + AX
    PUSH AX                             ; Save current digit
    MOV AX, BX
    MOV CX, 10
    MUL CX                              ; AX = Current Total * 10
    MOV BX, AX                          ; Back to BX
    POP AX                              ; Restore digit
    ADD BX, AX                          ; Add digit to total
    
    JMP READ_LOOP
    
READ_DONE:
    MOV AX, BX                          ; Return final result in AX
    
    POP DX
    POP CX
    POP BX
    RET
READ_NUMBER ENDP

;-----------------------------------------------------------------------------
; PROCEDURE: PRINT_DECIMAL (Standard conversion for verification)
;-----------------------------------------------------------------------------
PRINT_DECIMAL PROC
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX
    
    XOR CX, CX
    MOV BX, 10
    
DIV_LOOP:
    XOR DX, DX
    DIV BX
    PUSH DX
    INC CX
    CMP AX, 0
    JNE DIV_LOOP
    
PRINT_L:
    POP DX
    ADD DL, '0'
    MOV AH, 02H
    INT 21H
    LOOP PRINT_L
    
    POP DX
    POP CX
    POP BX
    POP AX
    RET
PRINT_DECIMAL ENDP

END MAIN

;=============================================================================
; INPUT CONVERSION NOTES:
; - Reading digits one-by-one requires an accumulator.
; - The calculation 'Result = Result * 10 + NewDigit' correctly weights 
;   place values (hundreds, tens, units).
; - Max input: 65535 (16-bit limit). Overflow handling is not implemented.
;=============================================================================
