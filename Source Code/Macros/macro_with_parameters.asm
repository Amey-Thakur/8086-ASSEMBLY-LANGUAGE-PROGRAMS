; =============================================================================
; TITLE: Macro with Parameters
; DESCRIPTION: Demonstrates how to define and use macros that accept 
;              arguments to perform arithmetic and bitwise operations.
; AUTHOR: Amey Thakur (https://github.com/Amey-Thakur)
; REPOSITORY: https://github.com/Amey-Thakur/8086-ASSEMBLY-LANGUAGE-PROGRAMS
; LICENSE: MIT License
; =============================================================================

.MODEL SMALL
.STACK 100H

; -----------------------------------------------------------------------------
; MACRO DEFINITIONS
; -----------------------------------------------------------------------------

; Macro: ADD_VALUES
; Usage: ADD_VALUES <val1>, <val2>, <target_memory>
ADD_VALUES MACRO VAL1, VAL2, RESULT
    MOV AX, VAL1
    ADD AX, VAL2
    MOV RESULT, AX
ENDM

; Macro: MULTIPLY_POW2 (Multiply by 2^N)
; Usage: MULTIPLY_POW2 <value>, <n_bits>
MULTIPLY_POW2 MACRO VALUE, POWER
    MOV AX, VALUE
    MOV CL, POWER
    SHL AX, CL                      ; Arithmetic Shift Left: result in AX
ENDM

; -----------------------------------------------------------------------------
; DATA SEGMENT
; -----------------------------------------------------------------------------
.DATA
    NUM1    DW 100
    NUM2    DW 50
    SUM     DW ?
    PRODUCT DW ?

; -----------------------------------------------------------------------------
; CODE SEGMENT
; -----------------------------------------------------------------------------

    ; Labels for the report at the end of the program.
    RPT_HEAD DB 0DH, 0AH, 'Results:', 0DH, 0AH, '$'
    RPT_NL   DB 0DH, 0AH, '$'
    RPT_N_NUM1 DB '  NUM1 = ', '$'
    RPT_N_NUM2 DB '  NUM2 = ', '$'
    RPT_N_SUM DB '  SUM = ', '$'
    RPT_N_PRODUCT DB '  PRODUCT = ', '$'
.CODE
MAIN PROC
    MOV AX, @DATA
    MOV DS, AX
    
    ; Call Add Macro: Sum = 100 + 50 = 150
    ADD_VALUES NUM1, NUM2, SUM
    
    ; Call Multiply Macro: 100 * 2^3 = 100 * 8 = 800
    MULTIPLY_POW2 NUM1, 3
    MOV PRODUCT, AX                 ; Store the temporary result from AX
    
    ; Exit to DOS
    
    ; -------------------------------------------------------------------------
    ; WHAT THIS PROGRAM COMPUTED
    ;
    ; The work above leaves its answers in the variables below. Printing them
    ; is what makes the program demonstrate itself rather than needing a
    ; debugger to be believed.
    ; -------------------------------------------------------------------------
    LEA DX, RPT_HEAD
    CALL RPT_SAY

    LEA DX, RPT_N_NUM1
    CALL RPT_SAY
    MOV AX, NUM1
    CALL RPT_DECIMAL
    LEA DX, RPT_NL
    CALL RPT_SAY

    LEA DX, RPT_N_NUM2
    CALL RPT_SAY
    MOV AX, NUM2
    CALL RPT_DECIMAL
    LEA DX, RPT_NL
    CALL RPT_SAY

    LEA DX, RPT_N_SUM
    CALL RPT_SAY
    MOV AX, SUM
    CALL RPT_DECIMAL
    LEA DX, RPT_NL
    CALL RPT_SAY

    LEA DX, RPT_N_PRODUCT
    CALL RPT_SAY
    MOV AX, PRODUCT
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
; TECHNICAL NOTES
; =============================================================================
; 1. MACROS VS PROCEDURES:
;    - Parameters are replaced by actual text during expansion (Text Substitution).
;    - Macros act like inline functions in high-level languages.
;    - They increase code size (Code Bloat) but eliminate CALL/RET overhead.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
