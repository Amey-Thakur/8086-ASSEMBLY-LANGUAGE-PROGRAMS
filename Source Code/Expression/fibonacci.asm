; =============================================================================
; TITLE: Fibonacci Series Generator
; DESCRIPTION: Generates and displays the Fibonacci sequence (1, 1, 2, 3...) 
;              up to a specified count. Demonstrates iterative sequence 
;              generation and register swapping logic.
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
    COUNT       DB 10                   ; Generate 10 terms
    TERM_A      DB 1                    ; T(n-2)
    TERM_B      DB 1                    ; T(n-1)
    
    MSG_SEP     DB ', $'
    
; -----------------------------------------------------------------------------
; CODE SEGMENT
; -----------------------------------------------------------------------------
.CODE
MAIN PROC
    ; --- Step 1: Initialize Data Segment ---
    MOV AX, @DATA
    MOV DS, AX
    
    ; --- Step 2: Handle First Two Terms ---
    ; Print Term 1 (1)
    MOV AL, TERM_A
    CALL PRINT_NUM
    LEA DX, MSG_SEP
    MOV AH, 09H
    INT 21H
    
    ; Print Term 2 (1)
    MOV AL, TERM_B
    CALL PRINT_NUM
    
    ; Adjust Loop Counter (Total - 2)
    MOV CH, 0
    MOV CL, COUNT
    SUB CL, 2
    
    ; --- Step 3: Generation Loop ---
GEN_LOOP:
    LEA DX, MSG_SEP
    MOV AH, 09H
    INT 21H
    
    ; Calculate Next: C = A + B
    MOV AL, TERM_A
    ADD AL, TERM_B
    MOV BL, AL                  ; Save C in BL
    
    ; Output C
    CALL PRINT_NUM
    
    ; Shift: A = B, B = C
    MOV AL, TERM_B
    MOV TERM_A, AL
    MOV TERM_B, BL
    
    LOOP GEN_LOOP
    
    ; --- Step 4: Exit ---
    MOV AH, 4CH
    INT 21H
MAIN ENDP

; -----------------------------------------------------------------------------
; PROCEDURE: PRINT_NUM
; INPUT:  AL = Number to print (0-99 supported for simplicity)
; -----------------------------------------------------------------------------
PRINT_NUM PROC
    PUSH AX
    PUSH DX
    
    AAM                         ; Split Byte to Digits (AH=Tens, AL=Units)
    ADD AX, 3030H               ; Convert to ASCII
    
    PUSH AX
    MOV DL, AH                  ; Print Tens
    MOV AH, 02H
    INT 21H
    POP AX
    
    MOV DL, AL                  ; Print Units
    MOV AH, 02H
    INT 21H
    
    POP DX
    POP AX
    RET
PRINT_NUM ENDP

END MAIN

; =============================================================================
; TECHNICAL NOTES & ARCHITECTURAL INSIGHTS
; =============================================================================
; 1. SERIES LOGIC:
;    Fibonacci(n) = Fibonacci(n-1) + Fibonacci(n-2).
;    We maintain the "trailing two" numbers in TERM_A and TERM_B.
;
; 2. REGISTER SWAPPING:
;    To advance the window [A, B] -> [B, A+B], we perform a 3-step value swap.
;    Since efficient swapping is key, keeping values in registers (AL, BL) 
;    inside the loop is preferred over memory access.
;
; 3. OVERFLOW:
;    Using 8-bit registers limits the series to 255 (Term 13 is 233, Term 14 
;    is 377). For larger series, 16-bit (DW) or 32-bit arithmetic is required.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
