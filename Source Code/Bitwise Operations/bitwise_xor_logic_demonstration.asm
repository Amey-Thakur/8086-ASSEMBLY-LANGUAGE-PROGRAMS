; =============================================================================
; TITLE: Bitwise Logical XOR Operation (Exclusive-OR & Toggling)
; DESCRIPTION: This program demonstrates the 8086 'XOR' instruction, which 
;              performs a bitwise logical Exclusive-OR. XOR returns 1 ONLY 
;              when the corresponding bits of the operands are different. It is 
;              a versatile tool for toggling bit states and clearing registers.
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
    ; Alternating bit patterns
    VAL_X DB 0AAH                       ; 1010 1010
    VAL_Y DB 055H                       ; 0101 0101
    
    ; Result storage
    XOR_RES DB ?                         

; -----------------------------------------------------------------------------
; CODE SEGMENT
; -----------------------------------------------------------------------------

    ; Labels for the report at the end of the program.
    RPT_HEAD DB 0DH, 0AH, 'Results:', 0DH, 0AH, '$'
    RPT_NL   DB 0DH, 0AH, '$'
    RPT_N_VAL_X DB '  VAL_X = ', '$'
    RPT_N_VAL_Y DB '  VAL_Y = ', '$'
    RPT_N_XOR_RES DB '  XOR_RES = ', '$'
.CODE
MAIN PROC
    ; --- Step 1: Initialize Data Segment ---
    MOV AX, @DATA
    MOV DS, AX
    
    ; --- Step 2: Load First Operands ---
    MOV AL, VAL_X                       ; AL = 1010 1010
    
    ; --- Step 3: Execute Bitwise XOR ---
    ; Truth Table for XOR:
    ; A=0, B=0 -> 0 | A=1, B=1 -> 0 (Same bits result in 0)
    ; A=0, B=1 -> 1 | A=1, B=0 -> 1 (Different bits result in 1)
    
    XOR AL, VAL_Y                       ; AL = (1010 1010) XOR (0101 0101)
    
    ; Result: 1111 1111 (FFH) as every bit was different.
    
    ; --- Step 4: Persist Result ---
    MOV XOR_RES, AL                     
    
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

    LEA DX, RPT_N_VAL_X
    CALL RPT_SAY
    XOR AX, AX
    MOV AL, VAL_X
    CALL RPT_DECIMAL
    LEA DX, RPT_NL
    CALL RPT_SAY

    LEA DX, RPT_N_VAL_Y
    CALL RPT_SAY
    XOR AX, AX
    MOV AL, VAL_Y
    CALL RPT_DECIMAL
    LEA DX, RPT_NL
    CALL RPT_SAY

    LEA DX, RPT_N_XOR_RES
    CALL RPT_SAY
    XOR AX, AX
    MOV AL, XOR_RES
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
; 1. BIT TOGGLING:
;    XOR is uniquely suited for "inverting" or "toggling" specific bits. Loading 
;    a mask with 1s in the target positions will flip the state of those bits in 
;    the destination, while leaving other bits (XORed with 0) unchanged.
;
; 2. REGISTER ZEROING (XOR AX, AX):
;    A highly optimized idiom in X86 assembly is clearing a register by XORing 
;    it with itself. 'XOR AX, AX' is shorter (2 bytes) and usually faster than 
;    'MOV AX, 0' (3 bytes), as it utilizes the ALU instead of the immediate data 
;    pipeline.
;
; 3. EQUALITY CHECKING:
;    If (A XOR B) results in 0 (sets the Zero Flag), it is mathematically 
;    guaranteed that A and B are identical.
;
; 4. THE XOR CIPHER (CRYPTOGRAPHY):
;    XOR is the basic building block of stream ciphers and One-Time Pads. Since 
;    (A XOR B) XOR B = A, XORing data with a key once encrypts it, and XORing 
;    it again with the same key decrypts it perfectly.
;
; 5. PARITY GENERATION:
;    The XOR operation is fundamentally a parity calculator. The final Parity 
;    Flag (PF) set after an XOR operation tells you if the result has an even 
;    sum of set bits.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
