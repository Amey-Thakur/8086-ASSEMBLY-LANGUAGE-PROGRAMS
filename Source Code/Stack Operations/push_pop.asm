; =============================================================================
; TITLE: PUSH and POP Mechanics
; DESCRIPTION: Demonstrate the fundamental Last-In-First-Out (LIFO) behavior 
;              of the 8086 hardware stack through register manipulation.
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

    ; Labels for the register report at the end of the program.
    RPT_HEAD DB 0DH, 0AH, 'Registers when the program finished:', 0DH, 0AH, '$'
    RPT_N_AX DB '  AX = ', '$'
    RPT_N_BX DB '   BX = ', '$'
    RPT_N_CX DB '   CX = ', '$'
    RPT_N_DX DB '   DX = ', '$'
    RPT_NL   DB 0DH, 0AH, '$'
    MSG DB 'Stack Operations Trace - Observe Registers in Debugger$'

; -----------------------------------------------------------------------------
; CODE SEGMENT
; -----------------------------------------------------------------------------
.CODE
MAIN PROC
    ; Initialize context
    MOV AX, @DATA
    MOV DS, AX
    
    ; 1. PUSH OPERATIONS
    ; Values are added to the stack; SP (Stack Pointer) decrements by 2.
    MOV AX, 1234H
    PUSH AX                         ; Stack Top: 1234H
    
    MOV BX, 5678H
    PUSH BX                         ; Stack Top: 5678H, 1234H
    
    MOV CX, 9ABCH
    PUSH CX                         ; Stack Top: 9ABCH, 5678H, 1234H
    
    ; 2. POP OPERATIONS
    ; Values are removed in reverse order; SP increments by 2.
    POP DX                          ; DX = 9ABCH (Last pushed)
    POP DX                          ; DX = 5678H
    POP DX                          ; DX = 1234H (First pushed)
    
    ; Graceful Exit
; -------------------------------------------------------------------------
    ; WHAT THIS PROGRAM COMPUTED
    ;
    ; The work above leaves its answer in the registers. Printing them is what
    ; makes the program demonstrate itself rather than needing a debugger to be
    ; believed.
    ; -------------------------------------------------------------------------
    CALL RPT_REGISTERS

        MOV AH, 4CH
    INT 21H
MAIN ENDP

; -----------------------------------------------------------------------------
; RPT_DECIMAL
;
; Prints the unsigned value in AX as decimal. Named apart from anything the
; program already had, so this report cannot clash with it.
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

; -----------------------------------------------------------------------------
; RPT_REGISTERS
;
; Prints the four general registers as they were on entry.
;
; They are pushed first and read back off, because printing needs AX for the
; value and DX for the message: reading them any later would report the state of
; the printer rather than the state of the program.
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

END MAIN

; =============================================================================
; TECHNICAL NOTES
; =============================================================================
; 1. STACK MECHANICS:
;    - The stack grows "downwards" in memory (from higher towards lower addresses).
;    - PUSH: Decrements SP by 2, then copies word to [SS:SP].
;    - POP: Copies word from [SS:SP], then increments SP by 2.
;    - PUSH/POP must operate on 16-bit (Word) operands in 8086.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
