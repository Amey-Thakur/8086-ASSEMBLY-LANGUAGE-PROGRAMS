; =============================================================================
; TITLE: 16-bit Dividend by 8-bit Divisor (Unsigned)
; DESCRIPTION: This program demonstrates how to use the DIV instruction in the 
;              Intel 8086 to perform unsigned integer division. It specifically 
;              shows the implicit register usage and result placement for 
;              8-bit divisors.
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
    ; Dividend (16-bit Word): 6827H = 26,663 decimal
    VAL_DIVIDEND DW 6827H               
    
    ; Divisor (8-bit Byte): 0FEH = 254 decimal
    VAL_DIVISOR  DB 0FEH                
    
    ; Buffers to store results
    RES_QUO      DB ?                   ; Quotient (Expected: 69H = 105)
    RES_REM      DB ?                   ; Remainder (Expected: 0D5H = 213)

; -----------------------------------------------------------------------------
; CODE SEGMENT
; -----------------------------------------------------------------------------

    ; Labels for the report at the end of the program.
    RPT_HEAD DB 0DH, 0AH, 'Results:', 0DH, 0AH, '$'
    RPT_NL   DB 0DH, 0AH, '$'
    RPT_N_VAL_DIVIDEND DB '  VAL_DIVIDEND = ', '$'
    RPT_N_VAL_DIVISOR DB '  VAL_DIVISOR = ', '$'
    RPT_N_RES_QUO DB '  RES_QUO = ', '$'
    RPT_N_RES_REM DB '  RES_REM = ', '$'
.CODE
MAIN PROC
    ; --- Step 1: Initialization ---
    MOV AX, @DATA
    MOV DS, AX
    
    ; --- Step 2: Prepare Operands ---
    ; For an 8-bit divisor, the 8086 hardware REQUIRES the dividend in AX.
    MOV AX, VAL_DIVIDEND                
    MOV BL, VAL_DIVISOR                 
    
    ; --- Step 3: Perform Unsigned Division ---
    ; Calculation: 26663 / 254 = 105 (69H) with remainder 213 (D5H).
    DIV BL                              
    
    ; --- Step 4: Store Results ---
    MOV RES_QUO, AL                     ; Quotient is in AL
    MOV RES_REM, AH                     ; Remainder is in AH
    
    ; --- Step 5: Clean Exit ---
    
    ; -------------------------------------------------------------------------
    ; WHAT THIS PROGRAM COMPUTED
    ;
    ; The work above leaves its answers in the variables below. Printing them
    ; is what makes the program demonstrate itself rather than needing a
    ; debugger to be believed.
    ; -------------------------------------------------------------------------
    LEA DX, RPT_HEAD
    CALL RPT_SAY

    LEA DX, RPT_N_VAL_DIVIDEND
    CALL RPT_SAY
    MOV AX, VAL_DIVIDEND
    CALL RPT_DECIMAL
    LEA DX, RPT_NL
    CALL RPT_SAY

    LEA DX, RPT_N_VAL_DIVISOR
    CALL RPT_SAY
    XOR AX, AX
    MOV AL, VAL_DIVISOR
    CALL RPT_DECIMAL
    LEA DX, RPT_NL
    CALL RPT_SAY

    LEA DX, RPT_N_RES_QUO
    CALL RPT_SAY
    XOR AX, AX
    MOV AL, RES_QUO
    CALL RPT_DECIMAL
    LEA DX, RPT_NL
    CALL RPT_SAY

    LEA DX, RPT_N_RES_REM
    CALL RPT_SAY
    XOR AX, AX
    MOV AL, RES_REM
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
; 1. DIV OPERAND SIZES:
;    The 8086 handles division in two distinct modes:
;    - Mode A (8-bit divisor): AX / Reg8 -> AL (Quotient), AH (Remainder)
;    - Mode B (16-bit divisor): DX:AX / Reg16 -> AX (Quotient), DX (Remainder)
;
; 2. DIVIDE ERROR (INTERRUPT 0):
;    The processor triggers a "Divide-by-Zero" interrupt (Type 0) if:
;    - The divisor is 0.
;    - The quotient is too large to fit in the target register (Overflow).
;
; 3. SIGNED vs UNSIGNED:
;    - 'DIV' is strictly for unsigned (positive) numbers.
;    - 'IDIV' must be used for signed (Two's Complement) arithmetic.
;
; 4. REGISTER PRESERVATION:
;    The DIV instruction destroys original AX (and DX for 16-bit DIV) values.
;
; 5. EXAMPLE VERIFICATION:
;    Dividend (26,663) = (Quotient [105] * Divisor [254]) + Remainder [213]
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
