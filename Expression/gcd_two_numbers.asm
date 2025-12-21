; =============================================================================
; TITLE: Greatest Common Divisor (GCD)
; DESCRIPTION: Calculates the GCD of two numbers using the Euclidean Algorithm.
;              GCD(a, b) = GCD(b, a % b).
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
    NUM_A   DW 24                       ; Input A
    NUM_B   DW 18                       ; Input B
    VAL_GCD DW ?                        ; Result
    MSG_RES DB "GCD: $"

; -----------------------------------------------------------------------------
; CODE SEGMENT
; -----------------------------------------------------------------------------
.CODE
MAIN PROC
    ; --- Step 1: Initialize Data Segment ---
    MOV AX, @DATA
    MOV DS, AX
    
    ; --- Step 2: Load Values ---
    MOV AX, NUM_A
    MOV BX, NUM_B
    
    ; --- Step 3: Euclidean Loop ---
    ; Loop: While (B != 0) { Temp = B; B = A % B; A = Temp; }
    
CALC_LOOP:
    CMP BX, 0                           ; Is B (Divisor) zero?
    JE L_DONE
    
    ; A % B
    XOR DX, DX                          ; Clear High Word for DIV
    DIV BX                              ; DX:AX / BX -> AX(Quot), DX(Rem)
    
    ; Move B to A, Remainder to B
    MOV AX, BX                          ; A = old B
    MOV BX, DX                          ; B = Remainder
    
    JMP CALC_LOOP
    
L_DONE:
    MOV VAL_GCD, AX                     ; GCD is in A (AX)
    
    ; --- Step 4: Display Result ---
    LEA DX, MSG_RES
    MOV AH, 09H
    INT 21H
    
    MOV AX, VAL_GCD
    ADD AX, 30H                         ; Simple ASCII for single digit
    MOV DL, AL
    MOV AH, 02H
    INT 21H
    
    ; --- Step 5: Exit ---
    MOV AH, 4CH
    INT 21H
MAIN ENDP

END MAIN

; =============================================================================
; TECHNICAL NOTES & ARCHITECTURAL INSIGHTS
; =============================================================================
; 1. EUCLIDEAN ALGORITHM:
;    This is the most efficient method for GCD. It is based on the principle 
;    that the GCD of two numbers also divides their difference (or remainder).
;    Efficiency is O(Log min(a,b)).
;
; 2. DIVISION INSTRUCTION:
;    DIV BX divides DX:AX by BX. We must ensure DX is zero before division 
;    to treat AX as the sole dividend. The remainder (Modulo) ends up in DX.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
