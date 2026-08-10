; =============================================================================
; TITLE: Procedure Parameter Passing
; DESCRIPTION: Demonstrate the standard register-based method for 
;              passing arguments to a subroutine.
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
    NUM1   DW 10
    NUM2   DW 20
    RESULT DW ?

; -----------------------------------------------------------------------------
; CODE SEGMENT
; -----------------------------------------------------------------------------

    ; Labels for the report at the end of the program.
    RPT_HEAD DB 0DH, 0AH, 'Results:', 0DH, 0AH, '$'
    RPT_NL   DB 0DH, 0AH, '$'
    RPT_N_NUM1 DB '  NUM1 = ', '$'
    RPT_N_NUM2 DB '  NUM2 = ', '$'
    RPT_N_RESULT DB '  RESULT = ', '$'
.CODE

; Procedure: ADD_NUMBERS
; Interface: 
;   Input: AX = Operand 1, BX = Operand 2
;   Output: AX = Summation Result
ADD_NUMBERS PROC
    ADD AX, BX                          ; Perform the summation
    RET                                 ; Return to caller
ADD_NUMBERS ENDP

MAIN PROC
    ; Segment setup
    MOV AX, @DATA
    MOV DS, AX
    
    ; Preparing registers for the procedure call
    MOV AX, NUM1                        ; Load first parameter
    MOV BX, NUM2                        ; Load second parameter
    
    CALL ADD_NUMBERS                    ; Invoke the procedure
    MOV RESULT, AX                      ; Store the returned value
    
    ; Return control to DOS
    
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

    LEA DX, RPT_N_RESULT
    CALL RPT_SAY
    MOV AX, RESULT
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
; 1. PARAMETERS:
;    - Passing via registers is the fastest method but limited by register count.
;    - Other methods include passing via Stack (unlimited count) or Global 
;      Variables (low reentrancy/security).
;    - AX is conventionally used to return values to the caller.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
