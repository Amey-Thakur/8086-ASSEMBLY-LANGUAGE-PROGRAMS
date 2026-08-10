; =============================================================================
; TITLE: Bitwise Right Circular Rotation (ROR)
; DESCRIPTION: This program demonstrates the 8086 'ROR' (Rotate Right) 
;              instruction. It demonstrates how bits shifted out of the 
;              Least Significant Bit (LSB) re-enter the register at the 
;              Most Significant Bit (MSB), maintaining data integrity.
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
    ; Initial Value: 1000 0001 (81H / 129 decimal)
    ; In binary: [1]000 000[1]
    SEED_VAL DB 81H                         
    
    ; Setup rotation parameters
    ROT_COUNT DB 2                   
    
    ; Result storage
    ROT_RESULT DB ?                         

; -----------------------------------------------------------------------------
; CODE SEGMENT
; -----------------------------------------------------------------------------

    ; Labels for the report at the end of the program.
    RPT_HEAD DB 0DH, 0AH, 'Results:', 0DH, 0AH, '$'
    RPT_NL   DB 0DH, 0AH, '$'
    RPT_N_SEED_VAL DB '  SEED_VAL = ', '$'
    RPT_N_ROT_COUNT DB '  ROT_COUNT = ', '$'
    RPT_N_ROT_RESULT DB '  ROT_RESULT = ', '$'
.CODE
MAIN PROC
    ; --- Step 1: Initialize Data Segment ---
    MOV AX, @DATA
    MOV DS, AX
    
    ; --- Step 2: Load Working Register ---
    MOV AL, SEED_VAL                    ; AL = 1000 0001
    
    ; --- Step 3: Execute Right Rotation ---
    ; Note: For rotations > 1 bit, the count must be provided in the CL register.
    MOV CL, ROT_COUNT                
    ROR AL, CL                          ; Rotate AL right by 2 positions
    
    ; Visual Execution Trace:
    ; Start: 1000 000[1]  (81H)
    ; 1st:   [1]100 0000  (C0H) -> LSB '1' moved to MSB and Carry Flag
    ; 2nd:   [0]110 0000  (60H) -> LSB '0' moved to MSB and Carry Flag
    
    ; --- Step 4: Persist Results ---
    ; Final Result in AL = 0110 0000 (60H)
    MOV ROT_RESULT, AL                      
    
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

    LEA DX, RPT_N_ROT_COUNT
    CALL RPT_SAY
    XOR AX, AX
    MOV AL, ROT_COUNT
    CALL RPT_DECIMAL
    LEA DX, RPT_NL
    CALL RPT_SAY

    LEA DX, RPT_N_ROT_RESULT
    CALL RPT_SAY
    XOR AX, AX
    MOV AL, ROT_RESULT
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
; 1. BIT PRESERVATION (ROTATION):
;    The ROR instruction ensures that no data bits are lost during the 
;    operation. The LSB (Bit 0) "wraps around" to fill the newly empty 
;    MSB (Bit 7). This distinguishes rotation from logical shifts (SHR), 
;    which simply fill the MSB with zero.
;
; 2. CARRY FLAG (CF) INTERACTION:
;    During each single-bit rotation, the bit that is moved from LSB to MSB 
;    is ALSO copied into the Carry Flag. This allows the CPU to branch based 
;    on the state of the "discarded" bit using JC or JNC instructions.
;
; 3. ROR vs RCR:
;    - ROR (Rotate Right): The LSB re-enters the MSB directly. CF is a mirror 
;      of the LSB.
;    - RCR (Rotate Carry Right): The Carry Flag itself is part of the rotation 
;      chain. Data moves: CF -> MSB -> ... -> LSB -> CF. This is a 9-bit 
;      rotation (for an 8-bit register).
;
; 4. MATHEMATICAL UTILITY:
;    Rotation is not directly equivalent to division (unlike SHR), but it is 
;    essential for algorithms that treat a byte or word as a circular buffer, 
;    such as encryption subroutines (S-boxes) or CRC calculations.
;
; 5. 8086 INSTRUCTION CONSTRAINTS:
;    On the original 8086/8088, the shift/rotate count could only be 1 (as an 
;    immediate) or CL (as a register). Later processors (80286+) allowed any 
;    immediate byte for count, but for backward compatibility, using CL is 
;    the "gold standard" approach.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
