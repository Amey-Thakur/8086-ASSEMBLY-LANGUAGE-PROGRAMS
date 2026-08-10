; =============================================================================
; TITLE: Procedure with Local Variables
; DESCRIPTION: Demonstrate the standard way to allocate and use local 
;              variables on the stack using the Base Pointer (BP) register.
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
    NUM1   DW 100
    NUM2   DW 50
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

; Procedure: CALCULATE
; Logic: Result = (Param1 + Param2) * 2
; Strategy: Stack-based parameters and local variable storage.
CALCULATE PROC
    ; Standard Activation Record Prologue
    PUSH BP                             ; Save caller's BP
    MOV BP, SP                          ; Establish new stack frame
    
    ; Allocate 2 bytes for a local variable [BP-2]
    SUB SP, 2        
    
    ; 1. Access Parameters from stack:
    ; [BP+0] = Old BP
    ; [BP+2] = Return Address (IP)
    ; [BP+4] = Param 2 (50) - Smallest offset since it was pushed last
    ; [BP+6] = Param 1 (100)
    
    MOV AX, [BP+6]                      ; Get first parameter
    ADD AX, [BP+4]                      ; Add second parameter
    
    ; 2. Store in Local Variable
    MOV [BP-2], AX                      ; temp_sum = AX
    
    ; 3. Perform operation using local variable
    MOV AX, [BP-2]
    SHL AX, 1                           ; AX = temp_sum * 2
    
    ; Standard Epilogue
    MOV SP, BP                          ; Deallocate local variable space
    POP BP                              ; Restore caller's BP
    
    RET 4                               ; Return and popup 4 bytes of params
CALCULATE ENDP

MAIN PROC
    ; State setup
    MOV AX, @DATA
    MOV DS, AX
    
    ; Passing parameters via Stack
    PUSH NUM1                           ; Push 1st param (100)
    PUSH NUM2                           ; Push 2nd param (50)
    
    CALL CALCULATE                      ; Execute our logic
    MOV RESULT, AX                      ; Result expected: 300
    
    ; Return to DOS
    
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
; 1. STACK FRAME:
;    - BP (Base Pointer) is the anchor for accessing both local variables 
;      (negative offset) and parameters (positive offset).
;    - 'SUB SP, N' creates space for local variables on the stack.
;    - 'RET N' is used for the "Pascal Calling Convention" to clean up the 
;      stack by the callee.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
