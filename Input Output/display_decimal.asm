;=============================================================================
; Program:     Display Decimal
; Description: Convert a 16-bit unsigned integer into its ASCII decimal
;              representation using repeated division by 10.
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
    NUM DW 12345                        ; Example 16-bit number
    MSG DB 'Decimal Value: $'

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
    
    ; Load number and convert to decimal display
    MOV AX, NUM
    CALL PRINT_DECIMAL
    
    ; Exit to DOS
    MOV AH, 4CH
    INT 21H
MAIN ENDP

;-----------------------------------------------------------------------------
; PROCEDURE: PRINT_DECIMAL
; Input: AX (Value to print)
; Logic: Repeated division by 10. Remainders are pushed to stack to reverse
;        their order (Least Significant Digit comes out first in division).
;-----------------------------------------------------------------------------
PRINT_DECIMAL PROC
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX
    
    XOR CX, CX                          ; Initialize digit counter
    MOV BX, 10                          ; Divisor for base 10
    
DIVIDE_LOOP:
    XOR DX, DX                          ; Clear DX for 32-bit / 16-bit division
    DIV BX                              ; AX = Quotient, DX = Remainder (Digit)
    PUSH DX                             ; Save digit on stack
    INC CX                              ; Increment digit count
    CMP AX, 0                           ; Is quotient zero?
    JNE DIVIDE_LOOP                     ; If not, keep dividing
    
; Stack now contains digits in reverse order (e.g., 5, 4, 3, 2, 1)
PRINT_LOOP:
    POP DX                              ; Get digit (1, 2, 3, 4, 5)
    ADD DL, '0'                         ; Convert numeric value to ASCII ('0'-'9')
    MOV AH, 02H                         ; DOS: Display character function
    INT 21H
    LOOP PRINT_LOOP                     ; Display all CX digits
    
    POP DX
    POP CX
    POP BX
    POP AX
    RET
PRINT_DECIMAL ENDP

END MAIN

;=============================================================================
; DECIMAL CONVERSION NOTES:
; - Division by 10 extracts the rightmost digit as the remainder.
; - The stack is used here as a LIFO (Last-In, First-Out) buffer to 
;   correctly order the digits for display from left to right.
; - Range: 0 to 65535 (16-bit unsigned).
;=============================================================================
