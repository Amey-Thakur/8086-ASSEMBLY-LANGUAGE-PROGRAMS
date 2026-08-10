; =============================================================================
; TITLE: Iterative Array Summation (8-bit to 16-bit Accumulation)
; DESCRIPTION: This program calculates the arithmetic sum of all 8-bit elements 
;              in an array. It demonstrates a robust accumulator pattern that 
;              promotes 8-bit operands to a 16-bit register to prevent 
;              arithmetic overflow during the summation process.
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
    ; Array of 5 bytes (Sum = 16+32+48+64+80 = 240 decimal / F0H)
    INT_ARRAY DB 10H, 20H, 30H, 40H, 50H     
    
    ; Constant for array length
    ARRAY_LEN EQU 5                           
    
    ; Buffer for 16-bit result (to avoid overflow)
    FINAL_SUM DW ?                            

; -----------------------------------------------------------------------------
; CODE SEGMENT
; -----------------------------------------------------------------------------

    ; Labels for the report at the end of the program.
    RPT_HEAD DB 0DH, 0AH, 'Results:', 0DH, 0AH, '$'
    RPT_NL   DB 0DH, 0AH, '$'
    RPT_N_FINAL_SUM DB '  FINAL_SUM = ', '$'
.CODE
MAIN PROC
    ; --- Step 1: Initialize Data Segment ---
    MOV AX, @DATA
    MOV DS, AX
    
    ; --- Step 2: Initialize Pointers and Counters ---
    LEA SI, INT_ARRAY                   ; SI = Pointer to current array element
    MOV CL, ARRAY_LEN                   ; CL = Loop counter
    XOR AX, AX                          ; AX = 0 (Initialize Accumulator)
    
    ; --- Step 3: The Summation Loop ---
SUM_LOOP:
    ; We must add an 8-bit value to a 16-bit accumulator.
    ; To do this safely, we clear the high byte of a temporary register (BX).
    MOV BL, [SI]                        ; Load current 8-bit element into BL
    XOR BH, BH                          ; Clear BH to ensure BX = BL (numeric)
    
    ADD AX, BX                          ; AX (16-bit) = AX + BX (16-bit)
    
    INC SI                              ; Move to next byte in memory
    DEC CL                              ; Decrement number of elements remaining
    JNZ SUM_LOOP                        ; Repeat if CL is not zero
    
    ; Result Trace: AX will hold F0H (240 decimal).
    
    ; --- Step 4: Persistent Storage ---
    MOV FINAL_SUM, AX                   ; Store result in memory
    
    ; --- Step 5: Shutdown ---
    
    ; -------------------------------------------------------------------------
    ; WHAT THIS PROGRAM COMPUTED
    ;
    ; The work above leaves its answers in the variables below. Printing them
    ; is what makes the program demonstrate itself rather than needing a
    ; debugger to be believed.
    ; -------------------------------------------------------------------------
    LEA DX, RPT_HEAD
    CALL RPT_SAY

    LEA DX, RPT_N_FINAL_SUM
    CALL RPT_SAY
    MOV AX, FINAL_SUM
    CALL RPT_DECIMAL
    LEA DX, RPT_NL
    CALL RPT_SAY

    MOV AH, 4CH                         
    INT 21H
MAIN ENDP

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
; 1. MIXED-SIZE ARITHMETIC:
;    The 8086 does not have an instruction to directly add an 8-bit memory 
;    value to a 16-bit register (e.g., ADD AX, [SI] is illegal if SI points to 
;    a byte). We solve this by "zero-extending" the byte into a word register 
;    (BX) using 'XOR BH, BH'.
;
; 2. THE ACCUMULATOR PATTERN:
;    Using a 16-bit register (AX) to sum 8-bit values is a defensive coding 
;    practice. Since the maximum value of a byte is 255, summing just 26 
;    bytes could exceed the capacity of an 8-bit register (255 * 2 = 510). 
;    AX can safely sum up to 257 maximum-value bytes before overflowing.
;
; 3. REGISTER-INDIRECT ADDRESSING:
;    '[SI]' uses the Source Index register as a pointer. This is an efficient 
;    way to traverse memory-resident data structures like arrays.
;
; 4. FLAG INTERPRETATION:
;    - The Zero Flag (ZF) is utilized by JNZ (Jump if Not Zero) to control 
;      the loop termination.
;    - The Carry Flag (CF) would be set if the total sum exceeded 65,535.
;
; 5. PERFORMANCE:
;    Manual loops are standard for complex logic, but for simple summation, 
;    string instructions in more advanced architectures (or specialized DSPs) 
;    often provide hardware acceleration.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
