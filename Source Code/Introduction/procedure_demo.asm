; =============================================================================
; TITLE: Procedure Call Demo
; DESCRIPTION: Demonstrate defining and calling a basic procedure using 
;              CALL and RET instructions in a COM-style program.
; AUTHOR: Amey Thakur (https://github.com/Amey-Thakur)
; REPOSITORY: https://github.com/Amey-Thakur/8086-ASSEMBLY-LANGUAGE-PROGRAMS
; LICENSE: MIT License
; =============================================================================

ORG 100H                            ; Start of COM program

; -----------------------------------------------------------------------------
; MAIN CODE SECTION
; -----------------------------------------------------------------------------
START:
    CALL PROC_M1                    ; Call the procedure M1

    MOV AX, 2                       ; Resume execution here after M1 returns

    RET                             ; Return control to the operating system

; -----------------------------------------------------------------------------
; PROCEDURE: PROC_M1
; Description: A simple procedure that sets the BX register.
; -----------------------------------------------------------------------------
PROC_M1 PROC
    MOV BX, 5                       ; Perform some work
    ; -------------------------------------------------------------------------
    ; WHAT THIS PROGRAM COMPUTED
    ;
    ; The work above leaves its answer in the registers. Printing them is what
    ; makes the program demonstrate itself instead of needing a debugger.
    ; -------------------------------------------------------------------------
    CALL RPT_REGISTERS

    RET                             ; Return to the instruction after CALL
PROC_M1 ENDP


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
; 1. PROCEDURE MECHANICS:
;    - 'CALL' pushes the address of the next instruction (IP) onto the stack.
;    - 'RET' pops the saved address back into the IP to return control.
;    - Procedures help in breaking down complex tasks into manageable blocks.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
