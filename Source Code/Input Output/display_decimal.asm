; =============================================================================
; TITLE: Display Decimal Representation
; DESCRIPTION: Converts a 16-bit integer into its Decimal (Base 10) ASCII 
;              string using repeated division logic.
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
    TEST_VAL    DW 12345                ; Example Value
    MSG_OUT     DB "Decimal Output: $"

; -----------------------------------------------------------------------------
; CODE SEGMENT
; -----------------------------------------------------------------------------
.CODE
MAIN PROC
    ; --- Step 1: Initialize DS ---
    MOV AX, @DATA
    MOV DS, AX

    ; --- Step 2: Display Header ---
    LEA DX, MSG_OUT
    MOV AH, 09H
    INT 21H

    ; --- Step 3: Print Decimal ---
    MOV AX, TEST_VAL
    CALL PRINT_DEC_PROC

    ; --- Step 4: Exit ---
    MOV AH, 4CH
    INT 21H
MAIN ENDP

; -----------------------------------------------------------------------------
; PROCEDURE: PRINT_DEC_PROC
; Input: AX (Value to print)
; -----------------------------------------------------------------------------
PRINT_DEC_PROC PROC
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX

    MOV CX, 0                           ; Digit Counter
    MOV BX, 10                          ; Divisor

L_DIV_LOOP:
    XOR DX, DX                          ; Clear High Word for Division
    DIV BX                              ; AX = Quotient, DX = Remainder (0-9)
    PUSH DX                             ; Push Remainder to Stack
    INC CX                              ; Count Digits
    
    CMP AX, 0                           ; Quotient 0?
    JNE L_DIV_LOOP                      ; No, continue dividing

L_PRINT_LOOP:
    POP DX                              ; Pop Last Remainder (Most Significant Digit)
    ADD DL, '0'                         ; ASCII Conversion
    MOV AH, 02H
    INT 21H
    LOOP L_PRINT_LOOP

    POP DX
    POP CX
    POP BX
    POP AX
    RET
PRINT_DEC_PROC ENDP

END MAIN

; =============================================================================
; TECHNICAL NOTES & ARCHITECTURAL INSIGHTS
; =============================================================================
; 1. DECIMAL CONVERSION ALGORITHM:
;    - Number modulo 10 gives the last digit.
;    - Number divided by 10 removes the last digit.
;    - Repeat until number is 0.
;
; 2. STACK USAGE:
;    Division extracts digits in reverse order (ones, then tens...). Pushing 
;    them onto the stack and popping them allows printing in the correct 
;    order (LIFO).
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
