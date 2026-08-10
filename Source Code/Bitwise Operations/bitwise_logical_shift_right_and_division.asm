; =============================================================================
; TITLE: Bitwise Logical Shift Right (SHR) & Binary Division
; DESCRIPTION: This program demonstrates the 8086 'SHR' (Shift Logical Right) 
;              instruction. It illustrates how shifting bits to the right 
;              performs efficient unsigned division by powers of two while 
;              tracking remainders via the Carry Flag.
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
    ; Initial Value: 0010 0000 (20H / 32 decimal)
    SEED_VAL DB 20H                         
    
    ; Shift parameters (2 positions = Divide by 4)
    SHIFT_COUNT DB 2                    
    
    ; Buffer for division result
    SHR_RESULT DB ?                         

; -----------------------------------------------------------------------------
; CODE SEGMENT
; -----------------------------------------------------------------------------

    ; Labels for the report at the end of the program.
    RPT_HEAD DB 0DH, 0AH, 'Results:', 0DH, 0AH, '$'
    RPT_NL   DB 0DH, 0AH, '$'
    RPT_N_SEED_VAL DB '  SEED_VAL = ', '$'
    RPT_N_SHIFT_COUNT DB '  SHIFT_COUNT = ', '$'
    RPT_N_SHR_RESULT DB '  SHR_RESULT = ', '$'
.CODE
MAIN PROC
    ; --- Step 1: Initialize Data Segment ---
    MOV AX, @DATA
    MOV DS, AX
    
    ; --- Step 2: Load Working Register ---
    MOV AL, SEED_VAL                    ; AL = 0010 0000 (32)
    
    ; --- Step 3: Execute Logical Right Shift ---
    ; Multi-bit shifts on the 8086 require the count in CL.
    MOV CL, SHIFT_COUNT                 
    SHR AL, CL                          ; Shift AL right by 2 positions
    
    ; Execution Trace:
    ; Initial: 0010 0000 (32)
    ; Shift 1: 0001 0000 (16)  <- MSB filled with '0', LSB '0' to CF
    ; Shift 2: 0000 1000 (8)   <- MSB filled with '0', LSB '0' to CF
    
    ; --- Step 4: Persist Results ---
    ; Expected: 8 decimal (08H)
    MOV SHR_RESULT, AL                      
    
    ; --- Step 5: Termination ---
    
    ; -------------------------------------------------------------------------
    ; WHAT THIS PROGRAM COMPUTED
    ;
    ; The work above leaves its answers in the variables below. Printing them
    ; is what makes the program demonstrate itself rather than needing a
    ; debugger to be believed.
    ; -------------------------------------------------------------------------
    LEA DX, RPT_HEAD
    CALL RPT_SAY

    LEA DX, RPT_N_SEED_VAL
    CALL RPT_SAY
    XOR AX, AX
    MOV AL, SEED_VAL
    CALL RPT_DECIMAL
    LEA DX, RPT_NL
    CALL RPT_SAY

    LEA DX, RPT_N_SHIFT_COUNT
    CALL RPT_SAY
    XOR AX, AX
    MOV AL, SHIFT_COUNT
    CALL RPT_DECIMAL
    LEA DX, RPT_NL
    CALL RPT_SAY

    LEA DX, RPT_N_SHR_RESULT
    CALL RPT_SAY
    XOR AX, AX
    MOV AL, SHR_RESULT
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
; 1. MATHEMATICAL RELATIONSHIP:
;    An N-bit logical right shift is equivalent to floor division of an 
;    unsigned integer by 2^N (Result = Value / 2^N).
;
; 2. SHR vs SAR (UNSIGN vs SIGNED):
;    - SHR (Shift Logical Right): Fills the vacated Most Significant Bit 
;      (MSB) with a ZERO. This is used for unsigned numbers.
;    - SAR (Shift Arithmetic Right): Fills the vacated MSB with a COPY of 
;      the previous MSB (sign extension). This is used for signed numbers 
;      to preserve the negative sign.
;
; 3. CARRY FLAG (CF) AS REMAINDER:
;    During a shift right, the bits that are "pushed out" of the register 
;    from the Least Significant Bit (LSB) enter the Carry Flag. For a single 
;    bit shift, the CF effectively tells you if there was a remainder (i.e., 
;    if the original number was odd).
;
; 4. PRECISION LOSS:
;    Shifting right is a "lossy" operation for the discarded bits. Unlike 
;    rotation (ROR), the data shifted into the CF is lost once the next 
;    instruction alters the flags.
;
; 5. EFFICIENCY:
;    SHR is the most efficient way to perform unsigned division by powers 
;    of two, bypassing the complex microcode of the 'DIV' instruction.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
