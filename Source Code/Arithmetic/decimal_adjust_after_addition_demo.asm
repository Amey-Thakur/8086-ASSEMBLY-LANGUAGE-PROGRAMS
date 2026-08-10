; =============================================================================
; TITLE: DAA (Decimal Adjust after Addition) Practical Demo
; DESCRIPTION: This program provides a clear demonstration of how the 8086 
;              CPU handles Packed BCD (Binary Coded Decimal) arithmetic. 
;              It shows the automated correction process that happens inside 
;              the ALU when the DAA instruction is invoked.
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
    ; Packed BCD Example: 27H (27) + 35H (35)
    ; In standard binary addition: 27H + 35H = 5CH.
    ; Since 'C' (12) is not a valid decimal digit, DAA must correct it.
    VAL1 DB 27H                         
    VAL2 DB 35H                         

; -----------------------------------------------------------------------------
; CODE SEGMENT
; -----------------------------------------------------------------------------

    ; Labels for the report at the end of the program.
    RPT_HEAD DB 0DH, 0AH, 'Results:', 0DH, 0AH, '$'
    RPT_NL   DB 0DH, 0AH, '$'
    RPT_N_VAL1 DB '  VAL1 = ', '$'
    RPT_N_VAL2 DB '  VAL2 = ', '$'
.CODE
MAIN PROC
    ; --- Step 1: Initialize Data Segment ---
    MOV AX, @DATA
    MOV DS, AX

    ; --- Step 2: Perform Native Binary Addition ---
    ; Result = 5CH (Illegal BCD)
    MOV AL, VAL1                        
    ADD AL, VAL2                        
    
    ; --- Step 3: Invoke the Decimal Adjust (DAA) ---
    ; Process:
    ; 1. Low Nibble (C) > 9? Yes.
    ; 2. ALU adds 06H to AL: 5CH + 06H = 62H.
    ; 3. ALU sets Auxiliary Carry (AF) to 1.
    ; Final AL = 62H (Human-readable 62).
    DAA                                 
    
    ; --- Step 4: Clean Exit ---
    
    ; -------------------------------------------------------------------------
    ; WHAT THIS PROGRAM COMPUTED
    ;
    ; The work above leaves its answers in the variables below. Printing them
    ; is what makes the program demonstrate itself rather than needing a
    ; debugger to be believed.
    ; -------------------------------------------------------------------------
    LEA DX, RPT_HEAD
    CALL RPT_SAY

    LEA DX, RPT_N_VAL1
    CALL RPT_SAY
    XOR AX, AX
    MOV AL, VAL1
    CALL RPT_DECIMAL
    LEA DX, RPT_NL
    CALL RPT_SAY

    LEA DX, RPT_N_VAL2
    CALL RPT_SAY
    XOR AX, AX
    MOV AL, VAL2
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
; 1. WHY DAA IS NECESSARY:
;    Binary addition of BCD numbers often results in "holes" (values 
;    between 1010 and 1111) that don't map to decimal digits. DAA refills 
;    these holes by adding 6.
;
; 2. HARDWARE FLAGS INVOLVED:
;    - AF (Auxiliary Carry): Tracks carry from Bit 3 to Bit 4. It is 
;      specifically designed to support BCD instructions like DAA.
;    - CF (Carry Flag): Tracks carries from Bit 7 (byte overflow).
;
; 3. THE MAGIC NUMBER 6:
;    Adding 6 (0110b) "jumps" over the 6 illegal hexadecimal values (A, B, C, 
;    D, E, F), effectively forcing a binary overflow that ripples into the 
;    next decimal nibble.
;
; 4. COMPARISON:
;    - 27H + 35H in HEX = 5CH.
;    - 27 + 35 in DECIMAL = 62.
;    - 62H is the hexadecimal encoding of the sequence 0110 0010.
;
; 5. RESTRICTIONS:
;    - DAA only operates on the AL register.
;    - It should only be used immediately after an ADD or ADC instruction.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
