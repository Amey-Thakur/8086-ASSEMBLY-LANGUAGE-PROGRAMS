; =============================================================================
; TITLE: Macro with Parameters
; DESCRIPTION: Demonstrates how to define and use macros that accept 
;              arguments to perform arithmetic and bitwise operations.
; AUTHOR: Amey Thakur (https://github.com/Amey-Thakur)
; REPOSITORY: https://github.com/Amey-Thakur/8086-ASSEMBLY-LANGUAGE-PROGRAMS
; LICENSE: MIT License
; =============================================================================

.MODEL SMALL
.STACK 100H

; -----------------------------------------------------------------------------
; MACRO DEFINITIONS
; -----------------------------------------------------------------------------

; Macro: ADD_VALUES
; Usage: ADD_VALUES <val1>, <val2>, <target_memory>
ADD_VALUES MACRO VAL1, VAL2, RESULT
    MOV AX, VAL1
    ADD AX, VAL2
    MOV RESULT, AX
ENDM

; Macro: MULTIPLY_POW2 (Multiply by 2^N)
; Usage: MULTIPLY_POW2 <value>, <n_bits>
MULTIPLY_POW2 MACRO VALUE, POWER
    MOV AX, VALUE
    MOV CL, POWER
    SHL AX, CL                      ; Arithmetic Shift Left: result in AX
ENDM

; -----------------------------------------------------------------------------
; DATA SEGMENT
; -----------------------------------------------------------------------------
.DATA
    NUM1    DW 100
    NUM2    DW 50
    SUM     DW ?
    PRODUCT DW ?

; -----------------------------------------------------------------------------
; CODE SEGMENT
; -----------------------------------------------------------------------------
.CODE
MAIN PROC
    MOV AX, @DATA
    MOV DS, AX
    
    ; Call Add Macro: Sum = 100 + 50 = 150
    ADD_VALUES NUM1, NUM2, SUM
    
    ; Call Multiply Macro: 100 * 2^3 = 100 * 8 = 800
    MULTIPLY_POW2 NUM1, 3
    MOV PRODUCT, AX                 ; Store the temporary result from AX
    
    ; Exit to DOS
    MOV AH, 4CH
    INT 21H
MAIN ENDP
END MAIN

; =============================================================================
; TECHNICAL NOTES
; =============================================================================
; 1. MACROS VS PROCEDURES:
;    - Parameters are replaced by actual text during expansion (Text Substitution).
;    - Macros act like inline functions in high-level languages.
;    - They increase code size (Code Bloat) but eliminate CALL/RET overhead.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
