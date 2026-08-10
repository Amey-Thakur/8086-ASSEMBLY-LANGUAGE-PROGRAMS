; =============================================================================
; TITLE: 16-bit and 8-bit Addition Demonstration
; DESCRIPTION: This program demonstrates basic arithmetic operations using 
;              both 8-bit and 16-bit operands in the Intel 8086. It covers 
;              register usage, memory-to-register transfers, and foundational 
;              binary addition mechanics.
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
    ; 8-bit variables (DB = Define Byte, 8 bits)
    VAL8_1 DB 05H                       ; Example 8-bit value 1
    VAL8_2 DB 06H                       ; Example 8-bit value 2
    SUM8   DB ?                         ; 8-bit result buffer
    
    ; 16-bit variables (DW = Define Word, 16 bits)
    VAL16_1 DW 1234H                    ; Example 16-bit value 1
    VAL16_2 DW 0055H                    ; Example 16-bit value 2
    SUM16   DW ?                        ; 16-bit result buffer

; -----------------------------------------------------------------------------
; CODE SEGMENT
; -----------------------------------------------------------------------------

    ; Labels for the report at the end of the program.
    RPT_HEAD DB 0DH, 0AH, 'Results:', 0DH, 0AH, '$'
    RPT_NL   DB 0DH, 0AH, '$'
    RPT_N_VAL8_1 DB '  VAL8_1 = ', '$'
    RPT_N_VAL8_2 DB '  VAL8_2 = ', '$'
    RPT_N_SUM8 DB '  SUM8 = ', '$'
    RPT_N_VAL16_1 DB '  VAL16_1 = ', '$'
    RPT_N_VAL16_2 DB '  VAL16_2 = ', '$'
    RPT_N_SUM16 DB '  SUM16 = ', '$'
.CODE
MAIN PROC
    ; --- Step 1: Initialize the Data Segment ---
    ; In the 8086 architecture, the DS register cannot be loaded directly with 
    ; an immediate value. We use AX as an intermediary.
    MOV AX, @DATA
    MOV DS, AX                   
    
    ; --- Step 2: 8-bit Addition (Byte-level) ---
    ; We use the AL (Accumulator Low) register for 8-bit operations.
    MOV AL, VAL8_1                 
    ADD AL, VAL8_2                 ; AL = 05H + 06H = 0BH
    MOV SUM8, AL                   ; Store the 8-bit result back to memory
    
    ; --- Step 3: 16-bit Addition (Word-level) ---
    ; We use the CX register as a 16-bit general-purpose accumulator here.
    MOV CX, VAL16_1                
    ADD CX, VAL16_2                ; CX = 1234H + 0055H = 1289H
    MOV SUM16, CX                  ; Store the 16-bit result back to memory
    
    ; --- Step 4: DOS Termination ---
    
    ; -------------------------------------------------------------------------
    ; WHAT THIS PROGRAM COMPUTED
    ;
    ; The work above leaves its answers in the variables below. Printing them
    ; is what makes the program demonstrate itself rather than needing a
    ; debugger to be believed.
    ; -------------------------------------------------------------------------
    LEA DX, RPT_HEAD
    CALL RPT_SAY

    LEA DX, RPT_N_VAL8_1
    CALL RPT_SAY
    XOR AX, AX
    MOV AL, VAL8_1
    CALL RPT_DECIMAL
    LEA DX, RPT_NL
    CALL RPT_SAY

    LEA DX, RPT_N_VAL8_2
    CALL RPT_SAY
    XOR AX, AX
    MOV AL, VAL8_2
    CALL RPT_DECIMAL
    LEA DX, RPT_NL
    CALL RPT_SAY

    LEA DX, RPT_N_SUM8
    CALL RPT_SAY
    XOR AX, AX
    MOV AL, SUM8
    CALL RPT_DECIMAL
    LEA DX, RPT_NL
    CALL RPT_SAY

    LEA DX, RPT_N_VAL16_1
    CALL RPT_SAY
    MOV AX, VAL16_1
    CALL RPT_DECIMAL
    LEA DX, RPT_NL
    CALL RPT_SAY

    LEA DX, RPT_N_VAL16_2
    CALL RPT_SAY
    MOV AX, VAL16_2
    CALL RPT_DECIMAL
    LEA DX, RPT_NL
    CALL RPT_SAY

    LEA DX, RPT_N_SUM16
    CALL RPT_SAY
    MOV AX, SUM16
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
; 1. REGISTER HIERARCHY: 
;    - The general-purpose registers AX, BX, CX, DX are 16-bit.
;    - Each can be split into two 8-bit registers (e.g., AH and AL).
;    - This allows for memory-efficient processing of byte-sized data.
;
; 2. OPERAND SIZE MATCHING:
;    - The Intel 8086 is a CISC processor that requires operands in an 
;      instruction (like ADD) to be of the exact same size.
;    - Illegal: 'ADD AX, BL' (16-bit + 8-bit) will result in an assembler error.
;
; 3. FLAG REGISTER (PSW) UPDATES:
;    - CARRY FLAG (CF): Set if the result exceeds the register size (Unsigned).
;    - ZERO FLAG (ZF): Set if the mathematical result is exactly zero.
;    - SIGN FLAG (SF): Set if the most significant bit (MSB) of the result is 1.
;    - OVERFLOW FLAG (OF): Set if the result is out of range for Signed arithmetic.
;
; 4. DATA ALIGNMENT:
;    - While the 8086 can access bytes at any address, 16-bit 'Word' accesses 
;      are faster when aligned to even memory addresses.
;
; 5. SEGMENT INITIALIZATION:
;    - The 'MOV DS, AX' step is critical. Without it, the program will look 
;      for variables in an undefined segment, leading to memory corruption or 
;      crashes.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =

