; =============================================================================
; TITLE: Signed Arithmetic and Conditional Branching Demo
; DESCRIPTION: This program demonstrates how the 8086 handles signed integers 
;              using Two's Complement representation. It showcases signed 
;              addition, the use of the Sign Flag (SF), and the critical 
;              distinction between signed (JG/JL) and unsigned (JA/JB) jumps.
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
    ; Signed Words (DW = 16-bit)
    ; -50 in binary (Two's Complement) is FFCEH
    VAL1_SIGNED DW -50                  
    VAL2_SIGNED DW 30                   
    FINAL_RESULT DW ?
    
    ; Messages for status report
    STR_POS  DB 10,13, 'Status: The result is POSITIVE (+)$'
    STR_NEG  DB 10,13, 'Status: The result is NEGATIVE (-)$'
    STR_ZERO DB 10,13, 'Status: The result is exactly ZERO$'

; -----------------------------------------------------------------------------
; CODE SEGMENT
; -----------------------------------------------------------------------------
.CODE
MAIN PROC
    ; --- Step 1: Initialize Data Segment ---
    MOV AX, @DATA
    MOV DS, AX
    
    ; --- Step 2: Signed Addition ---
    ; The hardware ADD instruction works the same for signed and unsigned.
    ; The difference lies in how WE interpret the flags (SF, OF).
    MOV AX, VAL1_SIGNED                 ; AX = -50 (FFCEH)
    ADD AX, VAL2_SIGNED                 ; AX = -50 + 30 = -20 (FFECH)
    MOV FINAL_RESULT, AX
    
    ; --- Step 3: Evaluate Sign and Branch ---
    ; CMP performs a dummy subtraction to update the flags.
    CMP AX, 0
    
    ; JG/JL are SIGNED jumps. They check (SF XOR OF) and ZF.
    ; JA/JB are UNSIGNED jumps. They check CF and ZF.
    JG  RESULT_IS_POSITIVE              ; Jump if Greater (> 0)
    JL  RESULT_IS_NEGATIVE              ; Jump if Less    (< 0)
    
    ; If neither jump is taken, the result must be zero.
    LEA DX, STR_ZERO
    JMP DISPLAY_STATUS
    
RESULT_IS_POSITIVE:
    LEA DX, STR_POS
    JMP DISPLAY_STATUS
    
RESULT_IS_NEGATIVE:
    LEA DX, STR_NEG
    
DISPLAY_STATUS:
    MOV AH, 09H
    INT 21H
    
    ; --- Step 4: Finalize Program ---
    MOV AH, 4CH
    INT 21H
MAIN ENDP

END MAIN

; =============================================================================
; TECHNICAL NOTES & ARCHITECTURAL INSIGHTS
; =============================================================================
; 1. TWO'S COMPLEMENT REPRESENTATION:
;    To represent -X:
;    - Take the binary for +X.
;    - Invert all bits (One's Complement).
;    - Add 1 (Two's Complement).
;    This allows the CPU to use the same addition hardware for all math.
;
; 2. SIGNED vs UNSIGNED JUMPS:
;    - SIGNED (e.g., JG, JL, JGE, JLE): These use the Sign Flag (SF) and 
;      the Overflow Flag (OF). They treat FFFFH as -1.
;    - UNSIGNED (e.g., JA, JB, JAE, JBE): These use the Carry Flag (CF). 
;      They treat FFFFH as 65,535.
;
; 3. THE SIGN FLAG (SF):
;    SF is simply a copy of the Most Significant Bit (MSB) of the result. 
;    If Bit 15 is 1, SF is set, signaling a negative value in signed context.
;
; 4. OVERFLOW FLAG (OF):
;    OF is set if a signed operation results in a value too large for the 
;    destination (e.g., adding two positive numbers and getting a negative 
;    result).
;
; 5. EXAMPLE VALUES (16-bit):
;    - Positive Max: +32,767 (7FFFH)
;    - Negative Max: -32,768 (8000H)
;    - Negative One: -1      (FFFFH)
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
