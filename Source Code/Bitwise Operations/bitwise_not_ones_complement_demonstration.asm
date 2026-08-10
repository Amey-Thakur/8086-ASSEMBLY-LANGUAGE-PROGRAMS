; =============================================================================
; TITLE: Bitwise Logical NOT Operation (One's Complement)
; DESCRIPTION: This program demonstrates the 8086 'NOT' instruction, which 
;              performs a bitwise logical negation. This operation inverts 
;              every bit in the operand (0 becomes 1, and 1 becomes 0), effectively 
;              calculating the One's Complement of a value.
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
    ; Original value: 0000 1111 (0FH / 15 decimal)
    ORIG_VAL DB 0FH                     
    
    ; Buffer for negation result
    NOT_RES  DB ?                         

; -----------------------------------------------------------------------------
; CODE SEGMENT
; -----------------------------------------------------------------------------

    ; Labels for the report at the end of the program.
    RPT_HEAD DB 0DH, 0AH, 'Results:', 0DH, 0AH, '$'
    RPT_NL   DB 0DH, 0AH, '$'
    RPT_N_ORIG_VAL DB '  ORIG_VAL = ', '$'
    RPT_N_NOT_RES DB '  NOT_RES = ', '$'
.CODE
MAIN PROC
    ; --- Step 1: Initialize Data Segment ---
    MOV AX, @DATA
    MOV DS, AX
    
    ; --- Step 2: Load Target Value ---
    MOV AL, ORIG_VAL                    ; AL = 0000 1111
    
    ; --- Step 3: Execute Bitwise NOT ---
    ; Truth Table for NOT:
    ; Input 0 -> Output 1
    ; Input 1 -> Output 0
    
    NOT AL                              ; Invert all bits in AL
    
    ; Calculation Trace:
    ; Input:  0 0 0 0 1 1 1 1  (0FH)
    ; Output: 1 1 1 1 0 0 0 0  (F0H)
    
    ; --- Step 4: Persist Results ---
    MOV NOT_RES, AL                     
    
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

    LEA DX, RPT_N_ORIG_VAL
    CALL RPT_SAY
    XOR AX, AX
    MOV AL, ORIG_VAL
    CALL RPT_DECIMAL
    LEA DX, RPT_NL
    CALL RPT_SAY

    LEA DX, RPT_N_NOT_RES
    CALL RPT_SAY
    XOR AX, AX
    MOV AL, NOT_RES
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
; 1. ONE'S COMPLEMENT LOGIC:
;    The NOT instruction is a unary operation (takes one operand). It is the 
;    fundamental building block for calculating One's Complement. To derive 
;    the Two's Complement (used for signed arithmetic), one would follow 
;    NOT with an 'INC' (Increment) instruction.
;
; 2. FLAG BEHAVIOR (CRITICAL):
;    Unlike most arithmetic and logic instructions (AND, OR, XOR, ADD), the 
;    NOT instruction does NOT affect any status flags in the 8086. 
;    - The Zero Flag (ZF), Sign Flag (SF), and Carry Flag (CF) remain exactly 
;      as they were before the NOT execution.
;    - If a program needs to check the result for zero or sign, an explicit 
;      comparison (CMP) or a TEST instruction must follow.
;
; 3. NEG vs NOT:
;    - NOT: Bitwise inversion (Logical negation).
;    - NEG: Arithmetic negation (calculates Two's Complement: 0 - Value). 
;      NEG DOES affect flags, including setting the Carry Flag if the 
;      input is not zero.
;
; 4. BIT REVERSAL vs BIT INVERSION:
;    Beginners often confuse inversion (NOT) with reversal (swapping bit 
;    positions). NOT merely flips the state of each independent bit without 
;    moving them.
;
; 5. ELECTRICAL PERSPECTIVE:
;    At the hardware level, the NOT instruction corresponds to a series of 
;    parallel CMOS Inverters. It is one of the most electrically simple and 
;    fastest instructions the CPU can execute.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
