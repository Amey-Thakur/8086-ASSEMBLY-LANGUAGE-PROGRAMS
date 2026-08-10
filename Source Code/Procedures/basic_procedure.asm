; =============================================================================
; TITLE: Basic Procedure Execution
; DESCRIPTION: Demonstrate the use of subroutines to avoid code duplication
;              for repetitive tasks like numeric scaling.
; AUTHOR: Amey Thakur (https://github.com/Amey-Thakur)
; REPOSITORY: https://github.com/Amey-Thakur/8086-ASSEMBLY-LANGUAGE-PROGRAMS
; LICENSE: MIT License
; =============================================================================

ORG 100H                            ; Standard COM entry point

; -----------------------------------------------------------------------------
; MAIN EXECUTION FLOW
; -----------------------------------------------------------------------------
START:
    MOV AL, 01H                         ; Initial value
    MOV BL, 02H                         ; Scaling factor

    ; Repeatedly double the value in AL by invoking the M2 procedure
    CALL M2                             ; AL = 2
    CALL M2                             ; AL = 4
    CALL M2                             ; AL = 8
    CALL M2                             ; AL = 16

    ; Return back to the shell
    RET

; -----------------------------------------------------------------------------
; SUBROUTINE: M2
; Description: Multiplies AL by BL. Result returns in AX.
; -----------------------------------------------------------------------------
M2 PROC
    MUL BL                              ; Multiply accumulator by BL
    ; -------------------------------------------------------------------------
    ; WHAT THIS PROGRAM COMPUTED
    ;
    ; The work above leaves its answer in the registers. Printing them is what
    ; makes the program demonstrate itself instead of needing a debugger.
    ; -------------------------------------------------------------------------
    CALL RPT_REGISTERS

    RET                                 ; Jump back to the caller (POP IP)
M2 ENDP


; -----------------------------------------------------------------------------
; THE REPORT
;
; Everything below belongs to the report added so this program shows its result
; rather than leaving it in the registers for a debugger to find. The strings
; sit here beside the code that uses them, which is legal: the assembler places
; every declaration in the data image wherever it is written.
; -----------------------------------------------------------------------------
    RPT_HEAD DB 0DH, 0AH, 'Registers when the program finished:', 0DH, 0AH, '$'
    RPT_N_AX DB '  AX = ', '$'
    RPT_N_BX DB '   BX = ', '$'
    RPT_N_CX DB '   CX = ', '$'
    RPT_N_DX DB '   DX = ', '$'
    RPT_NL   DB 0DH, 0AH, '$'

; -----------------------------------------------------------------------------
; RPT_REGISTERS
;
; Prints the four general registers as they were on entry.
;
; They are pushed first and read back through BP, because printing needs AX for
; the value and DX for the message. Reading them any later would report the
; state of the printer rather than the state of the program.
; -----------------------------------------------------------------------------
RPT_REGISTERS PROC
    PUSH DX
    PUSH CX
    PUSH BX
    PUSH AX

    PUSH BP
    MOV BP, SP

    ; The program may have pointed DS somewhere of its own, at a video segment
    ; or at segment zero, and the strings below live in the data image. SEG
    ; gives their segment whatever the program left in DS.
    PUSH DS
    MOV AX, SEG RPT_HEAD
    MOV DS, AX

    LEA DX, RPT_HEAD
    CALL RPT_SAY

    LEA DX, RPT_N_AX
    CALL RPT_SAY
    MOV AX, [BP+2]
    CALL RPT_DECIMAL

    LEA DX, RPT_N_BX
    CALL RPT_SAY
    MOV AX, [BP+4]
    CALL RPT_DECIMAL

    LEA DX, RPT_N_CX
    CALL RPT_SAY
    MOV AX, [BP+6]
    CALL RPT_DECIMAL

    LEA DX, RPT_N_DX
    CALL RPT_SAY
    MOV AX, [BP+8]
    CALL RPT_DECIMAL

    LEA DX, RPT_NL
    CALL RPT_SAY

    POP DS
    POP BP

    POP AX
    POP BX
    POP CX
    POP DX
    RET
RPT_REGISTERS ENDP

; -----------------------------------------------------------------------------
; RPT_DECIMAL
;
; Prints the unsigned value in AX as decimal, lowest digit last.
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
; Prints the dollar terminated string at DS:DX, leaving AX alone.
; -----------------------------------------------------------------------------
RPT_SAY PROC
    PUSH AX
    MOV AH, 09H
    INT 21H
    POP AX
    RET
RPT_SAY ENDP

END

; =============================================================================
; TECHNICAL NOTES
; =============================================================================
; 1. PROCEDURES:
;    - Procedures (Procs) encapsulate reusable logic.
;    - The 'CALL' instruction pushes the IP (Instruction Pointer) onto the stack.
;    - The 'RET' instruction pops that address back into the IP to resume flow.
;    - This reduces the binary size compared to inline macro expansion.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
