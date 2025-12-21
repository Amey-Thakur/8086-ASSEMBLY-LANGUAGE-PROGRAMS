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
    STR_POS  DB 0DH, 0AH, 'Status: Result is POSITIVE (+)$'
    STR_NEG  DB 0DH, 0AH, 'Status: Result is NEGATIVE (-)$'
    STR_ZERO DB 0DH, 0AH, 'Status: Result is ZERO$'

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
    MOV AX, VAL1_SIGNED                 
    ADD AX, VAL2_SIGNED                 ; AX = -20 (FFECH)
    MOV FINAL_RESULT, AX
    
    ; --- Step 3: Evaluate Sign and Branch ---
    CMP AX, 0
    
    ; JG/JL are SIGNED jumps. They check (SF XOR OF) and ZF.
    JG  L_RESULT_IS_POSITIVE              
    JL  L_RESULT_IS_NEGATIVE              
    
    LEA DX, STR_ZERO
    JMP L_DISPLAY_STATUS
    
L_RESULT_IS_POSITIVE:
    LEA DX, STR_POS
    JMP L_DISPLAY_STATUS
    
L_RESULT_IS_NEGATIVE:
    LEA DX, STR_NEG
    
L_DISPLAY_STATUS:
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
;    To represent -X: Take binary for +X, invert bits, and add 1. 
;    This allows the same hardware to handle addition for all integers.
;
; 2. SIGNED vs UNSIGNED JUMPS:
;    - SIGNED (JG, JL): Evaluates SF and OF. Treats FFFFH as -1.
;    - UNSIGNED (JA, JB): Evaluates CF. Treats FFFFH as 65,535.
;
; 3. THE SIGN FLAG (SF):
;    Copy of the Most Significant Bit (MSB). If Bit 15 is 1, SF=1, 
;    signaling a negative value.
;
; 4. OVERFLOW FLAG (OF):
;    Set if a signed operation results in a value too large for the 
;    destination (e.g., adding two positives and getting a negative).
;
; 5. PERFORMANCE:
;    Conditional jumps in the 8086 are 'Short Jumps' (-128 to +127 bytes).
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
