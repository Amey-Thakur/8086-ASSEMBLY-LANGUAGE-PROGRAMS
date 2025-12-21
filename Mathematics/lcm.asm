; =============================================================================
; TITLE: Least Common Multiple (LCM)
; DESCRIPTION: Calculate the LCM of two 16-bit numbers using the relationship:
;              LCM(a, b) = (a * b) / GCD(a, b).
; AUTHOR: Amey Thakur (https://github.com/Amey-Thakur)
; REPOSITORY: https://github.com/Amey-Thakur/8086-ASSEMBLY-LANGUAGE-PROGRAMS
; LICENSE: MIT License
; =============================================================================

.MODEL SMALL
.STACK 100H

; -----------------------------------------------------------------------------
; DATA SEGMENT
; -----------------------------------------------------------------------------
.DATA
    NUM1    DW 12                        ; First number
    NUM2    DW 18                        ; Second number
    GCD_VAL DW ?                         ; Buffer for GCD
    LCM_VAL DW ?                         ; Buffer for final LCM result
    MSG     DB 'LCM calculation completed successfully.$'

; -----------------------------------------------------------------------------
; CODE SEGMENT
; -----------------------------------------------------------------------------
.CODE
MAIN PROC
    ; Initialize environment
    MOV AX, @DATA
    MOV DS, AX
    
    ; -------------------------------------------------------------------------
    ; STEP 1: Find GCD (Greatest Common Divisor) using Euclidean Algorithm
    ; -------------------------------------------------------------------------
    MOV AX, NUM1
    MOV BX, NUM2
    
GCD_LOOP:
    CMP BX, 0                           ; Base case: remainder is 0
    JE GCD_DONE
    XOR DX, DX                          ; Clear for division
    DIV BX                              ; Divide AX by BX, remainder in DX
    MOV AX, BX                          ; Older divisor becomes dividend
    MOV BX, DX                          ; Remainder becomes new divisor
    JMP GCD_LOOP
    
GCD_DONE:
    MOV GCD_VAL, AX                     ; GCD of 12 and 18 is 6
    
    ; -------------------------------------------------------------------------
    ; STEP 2: Find LCM = (NUM1 * NUM2) / GCD_VAL
    ; -------------------------------------------------------------------------
    MOV AX, NUM1
    MUL NUM2                            ; DX:AX = NUM1 * NUM2 (Product can be 32-bit)
    
    DIV GCD_VAL                         ; Quotient AX = (DX:AX) / GCD_VAL
    MOV LCM_VAL, AX                     ; LCM of 12 and 18 is 36
    
    ; Print status message
    LEA DX, MSG
    MOV AH, 09H
    INT 21H
    
    ; Termination
    MOV AH, 4CH
    INT 21H
MAIN ENDP
END MAIN

; =============================================================================
; TECHNICAL NOTES
; =============================================================================
; 1. LCM ALGORITHM:
;    - Euclid's Algorithm for GCD is highly efficient for large numbers.
;    - Division of a 32-bit product (DX:AX) by a 16-bit GCD is handled correctly 
;      by the 'DIV' instruction.
;    - Example: 12 (2*2*3) and 18 (2*3*3). LCM is 2*2*3*3 = 36.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
