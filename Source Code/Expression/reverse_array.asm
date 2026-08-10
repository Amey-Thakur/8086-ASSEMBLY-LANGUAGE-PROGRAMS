; =============================================================================
; TITLE: Array Reversal
; DESCRIPTION: Reverses the contents of a byte array. It uses a second buffer 
;              to store the reversed copy. In-place reversal (using XCHG) 
;              is an alternative not demonstrated here.
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
    SRC_ARR     DB 1, 2, 3, 4, 5        ; Original
    DST_ARR     DB 5 DUP(?)             ; Destination
    ARR_LEN     EQU 5

; -----------------------------------------------------------------------------
; CODE SEGMENT
; -----------------------------------------------------------------------------
.CODE
MAIN PROC
    ; --- Step 1: Initialize Data Segment ---
    MOV AX, @DATA
    MOV DS, AX
    MOV ES, AX                          ; ES needed for potential string ops (optional here)
    
    ; --- Step 2: Setup Pointers ---
    LEA SI, SRC_ARR                     ; SI -> Start of Source
    LEA DI, DST_ARR                     ; DI -> Start of Dest
    ADD DI, ARR_LEN - 1                 ; DI -> End of Dest (Reverse fill)
    
    MOV CX, ARR_LEN
    
    ; --- Step 3: Copy Loop ---
REV_LOOP:
    MOV AL, [SI]                        ; Load from Start
    MOV [DI], AL                        ; Store at End
    
    INC SI                              ; Move Forward
    DEC DI                              ; Move Backward
    LOOP REV_LOOP
    
    ; Verification: DST_ARR is now {5, 4, 3, 2, 1}
    
    ; --- Step 4: Exit ---
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
; TECHNICAL NOTES & ARCHITECTURAL INSIGHTS
; =============================================================================
; 1. POINTER ARITHMETIC:
;    We use two pointers moving in opposite logical directions relative to their 
;    arrays:
;    - SI increments (0 -> N)
;    - DI decrements (N -> 0)
;    This effectively maps Source[i] to Dest[N-1-i].
;
; 2. SEGMENT INITIALIZATION:
;    While this program uses DS for both reads and writes, initializing ES is 
;    good practice if we were using STOSB or MOVSB instructions.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
