; =============================================================================
; TITLE: Prime Number Detector
; DESCRIPTION: Determines if a given 8-bit number is Prime. A prime number 
;              is only divisible by 1 and itself. This program uses a brute-force 
;              division loop from 2 to N-1.
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
    TEST_VAL    DB 113                  ; Input (113 is Prime)
    
    MSG_PRIME   DB 0DH, 0AH, "Result: PRIME Number$"
    MSG_NOT     DB 0DH, 0AH, "Result: NOT a Prime Number$"

; -----------------------------------------------------------------------------
; CODE SEGMENT
; -----------------------------------------------------------------------------
.CODE
MAIN PROC
    ; --- Step 1: Initialize Data Segment ---
    MOV AX, @DATA
    MOV DS, AX
    
    ; --- Step 2: Edge Case Checks ---
    MOV AL, TEST_VAL
    CMP AL, 2
    JB L_NOT_PRIME                      ; 0 and 1 are not Prime
    JE L_IS_PRIME                       ; 2 is Prime
    
    ; --- Step 3: Division Loop (2 to N/2 or N-1) ---
    MOV CL, 2                           ; Divisor
    
CHECK_LOOP:
    MOV AL, TEST_VAL
    MOV AH, 0
    DIV CL                              ; AX / CL -> Remainder in AH
    
    CMP AH, 0
    JE L_NOT_PRIME                      ; If Remainder 0, it's divisible -> Not Prime
    
    INC CL
    CMP CL, TEST_VAL                    ; Check until CL == N
    JNE CHECK_LOOP
    
    ; If we reach here, no divisor found
    JMP L_IS_PRIME
    
L_IS_PRIME:
    LEA DX, MSG_PRIME
    MOV AH, 09H
    INT 21H
    JMP L_EXIT
    
L_NOT_PRIME:
    LEA DX, MSG_NOT
    MOV AH, 09H
    INT 21H
    
    ; --- Step 4: Exit ---
L_EXIT:
    MOV AH, 4CH
    INT 21H
MAIN ENDP

END MAIN

; =============================================================================
; TECHNICAL NOTES & ARCHITECTURAL INSIGHTS
; =============================================================================
; 1. OPTIMIZATION:
;    The loop currently runs from 2 to N-1.
;    A better optimization is to run only up to N/2 or SQRT(N). 
;    If no factor is found by SQRT(N), the number is prime.
;
; 2. REGISTER USAGE:
;    - AL: Dividend (The number being tested)
;    - CL: Divisor (Current potential factor)
;    - AH: Remainder (The result of Modulo)
;
; 3. EDGE CASES:
;    - 1 is not prime.
;    - 2 is the only even prime.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
