; =============================================================================
; TITLE: Block Memory Copy using String Instructions (MOVSB)
; DESCRIPTION: This program demonstrates the most efficient way to copy a block 
;              of data from one memory location to another using the 8086's 
;              dedicated string processing hardware. It features the REP 
;              prefix and the MOVSB instruction.
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
    ; Source data to be copied
    SRC_ARRAY DB 11H, 22H, 33H, 44H, 55H     
    
    ; Destination buffer initialized to zeros
    DST_ARRAY DB 5 DUP(0)                     
    
    ; Array length (constant)
    ARRAY_LEN EQU 5                           

; -----------------------------------------------------------------------------
; CODE SEGMENT
; -----------------------------------------------------------------------------
.CODE
MAIN PROC
    ; --- Step 1: Segment Initialization ---
    MOV AX, @DATA
    MOV DS, AX                          ; DS:SI points to Source
    MOV ES, AX                          ; ES:DI points to Destination
    
    ; --- Step 2: Pointer and Counter Setup ---
    ; String instructions implicitly use SI, DI, and CX.
    LEA SI, SRC_ARRAY                   ; Source Index
    LEA DI, DST_ARRAY                   ; Destination Index
    MOV CX, ARRAY_LEN                   ; Number of bytes to copy
    
    ; --- Step 3: Direction Flag Configuration ---
    ; CLD (Clear Direction Flag) ensures the pointers increment forward (SI++, DI++).
    ; STD (Set Direction Flag) would make them decrement (SI--, DI--).
    CLD                                 
    
    ; --- Step 4: The Repeat-Move Execution ---
    ; REP MOVSB effectively runs as a high-speed microcode loop:
    ; WHILE CX != 0:
    ;   [ES:DI] = [DS:SI]
    ;   SI++, DI++
    ;   CX--
    REP MOVSB                           
    
    ; Verification: DST_ARRAY now reflects {11H, 22H, 33H, 44H, 55H}.
    
    ; --- Step 5: Graceful Termination ---
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
; 1. STRING INSTRUCTION HARDWARE:
;    The 8086 includes a specialized String Processing Unit in its micro-code. 
;    Instructions like MOVSB are significantly faster than a manual loop 
;    (MOV AL, [SI] / MOV [DI], AL / INC SI / INC DI / LOOP) because the 
;    pointer adjustment happens within the same instruction cycle.
;
; 2. SEGMENT RIGIDITY:
;    - MOVSB always sources from the segment defined by DS (Data Segment).
;    - MOVSB always targets the segment defined by ES (Extra Segment).
;    This is why we must ensure both DS and ES are correctly initialized.
;
; 3. WORD-LEVEL OPTIMIZATION:
;    For even faster copies, especially with large data, MOVSW (Move String 
;    Word) can be used. It moves 2 bytes at a time, effectively doubling the 
;    throughput per clock cycle.
;
; 4. OVERLAPPING MEMORY:
;    If the source and destination arrays overlap, the Direction Flag (DF) must 
;    be carefully managed (CLD for forward or STD for backward) to prevent 
;    overwriting data before it is copied.
;
; 5. THE REP PREFIX:
;    REP is a prefix that tells the CPU to repeat the subsequent string 
;    instruction as long as CX is not zero. It is one of the few ways to achieve 
;    zero-overhead looping in the 8086.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
