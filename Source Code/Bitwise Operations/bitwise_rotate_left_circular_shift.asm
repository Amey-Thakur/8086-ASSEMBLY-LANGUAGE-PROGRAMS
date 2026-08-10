; =============================================================================
; TITLE: Bitwise Left Circular Rotation (ROL)
; DESCRIPTION: This program demonstrates the 8086 'ROL' (Rotate Left) 
;              instruction. Unlike logical shifts which discard data, 
;              rotation preserves all bits by wrapping the Most Significant 
;              Bit (MSB) around to the Least Significant Bit (LSB).
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
    ; Bit 7 (MSB) and Bit 0 (LSB) are set.
    SEED_VAL DB 81H                         
    
    ; Setup rotation parameters
    ROT_COUNT DB 2                   
    
    ; Storage for the final rotated state
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
    
    ; --- Step 3: Execute Left Rotation ---
    ; On the 8086, multi-bit rotations require the count in the CL register.
    MOV CL, ROT_COUNT                
    ROL AL, CL                          ; Rotate AL left by 2 positions
    
    ; Visual Execution Trace:
    ; Start: [1]000 0001  (81H)
    ; 1st:   0000 001[1]  (03H) -> MSB '1' moved to LSB and Carry Flag
    ; 2nd:   0000 011[0]  (06H) -> MSB '0' moved to LSB and Carry Flag
    
    ; --- Step 4: Persist Results ---
    MOV ROT_RESULT, AL                  ; Result = 06H
    
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
; 1. CIRCULAR BIT PRESERVATION:
;    The ROL instruction is a "non-lossy" operation. While SHL fills vacated 
;    bits with zeros, ROL takes the bit shifted out of position 7 and 
;    re-inserts it into position 0. This makes it ideal for iterative 
;    processing of every bit in a word.
;
; 2. CARRY FLAG (CF) INTERACTION:
;    In a ROL operation, the bit that is rotated from the MSB to the LSB is 
;    ALSO copied into the Carry Flag. This allows a programmer to test the 
;    MSB state using conditional jumps (JC/JNC) without losing the original 
;    bit data.
;
; 3. ROL vs RCL:
;    - ROL (Rotate Left): Rotates the 8 bits of the register. CF is just a 
;      copy of the MSB.
;    - RCL (Rotate Carry Left): Rotates a 9-bit quantity consisting of the 
;      8 register bits PLUS the Carry Flag. Data moves: CF -> LSB -> ... -> MSB -> CF.
;
; 4. OVERFLOW FLAG (OF) BEHAVIOR:
;    For a 1-bit rotation (count = 1), the OF is set if the rotation changes 
;    the MSB (sign bit). For multi-bit rotations (count > 1), the OF state 
;    is technically undefined on some X86 variants, though often it remains 
;    based on the last bit moved.
;
; 5. PERFORMANCE & UTILIZATION:
;    Rotation is commonly used in hashing algorithms, cryptography (e.g., 
;    shifting keys), and for converting between big-endian and little-endian 
;    formats in 16 or 32-bit registers.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
