; =============================================================================
; TITLE: Factorial Calculation (Recursion)
; DESCRIPTION: Computes the factorial of a number (N!) using value-passing 
;              recursion. Demonstrates stack frame management relative to 
;              procedures in 8086 assembly.
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
    INPUT_N    DW 5                     ; Calculate 5! = 120
    RESULT_LO  DW ?                     ; Lower 16-bits
    RESULT_HI  DW ?                     ; Upper 16-bits (for > 65535)

; -----------------------------------------------------------------------------
; CODE SEGMENT
; -----------------------------------------------------------------------------

    ; Labels for the report at the end of the program.
    RPT_HEAD DB 0DH, 0AH, 'Results:', 0DH, 0AH, '$'
    RPT_NL   DB 0DH, 0AH, '$'
    RPT_N_INPUT_N DB '  INPUT_N = ', '$'
    RPT_N_RESULT_LO DB '  RESULT_LO = ', '$'
    RPT_N_RESULT_HI DB '  RESULT_HI = ', '$'
.CODE
MAIN PROC
    ; --- Step 1: Initialize Data Segment ---
    MOV AX, @DATA
    MOV DS, AX
    
    ; --- Step 2: Prepare Recursion ---
    MOV AX, 1                           ; Initialize Accumulator
    MOV BX, INPUT_N                     ; Load N
    
    ; Check Base Case 0! = 1
    CMP BX, 0
    JE L_STORE_RESULT
    
    CALL CALC_FACTORIAL
    
L_STORE_RESULT:
    MOV RESULT_LO, AX
    MOV RESULT_HI, DX
    
    ; --- Step 3: Termination ---
    
    ; -------------------------------------------------------------------------
    ; WHAT THIS PROGRAM COMPUTED
    ;
    ; The work above leaves its answers in the variables below. Printing them
    ; is what makes the program demonstrate itself rather than needing a
    ; debugger to be believed.
    ; -------------------------------------------------------------------------
    LEA DX, RPT_HEAD
    CALL RPT_SAY

    LEA DX, RPT_N_INPUT_N
    CALL RPT_SAY
    MOV AX, INPUT_N
    CALL RPT_DECIMAL
    LEA DX, RPT_NL
    CALL RPT_SAY

    LEA DX, RPT_N_RESULT_LO
    CALL RPT_SAY
    MOV AX, RESULT_LO
    CALL RPT_DECIMAL
    LEA DX, RPT_NL
    CALL RPT_SAY

    LEA DX, RPT_N_RESULT_HI
    CALL RPT_SAY
    MOV AX, RESULT_HI
    CALL RPT_DECIMAL
    LEA DX, RPT_NL
    CALL RPT_SAY

    MOV AH, 4CH
    INT 21H
MAIN ENDP

; -----------------------------------------------------------------------------
; PROCEDURE: CALC_FACTORIAL
; INPUT:  BX = N
; OUTPUT: DX:AX = Result
; LOGIC:  Recursive Call until BX=1. Then Unwind multiplying AX * BX.
; -----------------------------------------------------------------------------
CALC_FACTORIAL PROC
    ; Base Case: If BX == 1, Return
    CMP BX, 1
    JE L_BASE_RET
    
    PUSH BX                             ; Save current N
    DEC BX                              ; N = N - 1
    CALL CALC_FACTORIAL                 ; Recursive Call
    
    POP BX                              ; Restore N (Unwinding)
    MUL BX                              ; AX = AX * BX (Result * N)
    RET
    
L_BASE_RET:
    MOV AX, 1                           ; 1! = 1
    MOV DX, 0
    RET
CALC_FACTORIAL ENDP

; -----------------------------------------------------------------------------
; RPT_DECIMAL
;
; Prints the unsigned value in AX as decimal. Named apart from any helper the
; program already had, so adding this report cannot clash with it.
;
; The digits come out of the division lowest first, which is the wrong order to
; print them in, so they are pushed and then popped back off.
; -----------------------------------------------------------------------------
RPT_DECIMAL PROC
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX

    XOR CX, CX
    MOV BX, 10

RPT_SPLIT:
    XOR DX, DX
    DIV BX
    PUSH DX
    INC CX
    CMP AX, 0
    JNE RPT_SPLIT

RPT_EMIT:
    POP DX
    ADD DL, '0'
    MOV AH, 02H
    INT 21H
    LOOP RPT_EMIT

    POP DX
    POP CX
    POP BX
    POP AX
    RET
RPT_DECIMAL ENDP

; -----------------------------------------------------------------------------
; RPT_SAY
;
; Prints the dollar terminated string at DS:DX without disturbing AX, which
; matters because the caller usually has the value it is about to print there.
; -----------------------------------------------------------------------------
RPT_SAY PROC
    PUSH AX
    MOV AH, 09H
    INT 21H
    POP AX
    RET
RPT_SAY ENDP


END MAIN

; =============================================================================
; TECHNICAL NOTES & ARCHITECTURAL INSIGHTS
; =============================================================================
; 1. RECURSION ON THE STACK:
;    Each CALL pushes the Return Address (IP).
;    Each PUSH BX saves the state of 'N' for that depth.
;    Stack Depth = N * 2 bytes (BX) + N * 2 bytes (IP) = 4N bytes overhead.
;
; 2. MULTIPLICATION LIMITS:
;    - MUL BX multiplies AX by BX. Result is in DX:AX (32-bit).
;    - 8! = 40,320 (Fits in AX).
;    - 9! = 362,880 (Requires DX:AX).
;    This implementation supports results up to DX:AX limits, though we assume 
;    input <= 8 for simple 16-bit logic in MAIN display if we added one.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
