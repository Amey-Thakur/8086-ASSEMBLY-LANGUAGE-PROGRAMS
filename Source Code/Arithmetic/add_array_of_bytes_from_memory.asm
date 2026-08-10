; =============================================================================
; TITLE: Addition of Byte Array from Memory
; DESCRIPTION: This program calculates the 16-bit sum of a series of ten 8-bit 
;              unsigned integers stored in consecutive memory locations. It 
;              demonstrates memory segmentation, indirect addressing, and 
;              manual carry propagation.
; AUTHOR: Amey Thakur (https://github.com/Amey-Thakur)
; REPOSITORY: https://github.com/Amey-Thakur/8086-ASSEMBLY-LANGUAGE-PROGRAMS
; LICENSE: MIT License
; =============================================================================

.MODEL SMALL
.STACK 100H

; -----------------------------------------------------------------------------
; CODE SEGMENT
; -----------------------------------------------------------------------------
.CODE
MAIN PROC
    ; --- Step 1: Initialize Data Segment ---
    ; We manually set the DS register to point to the base address 2000H.
    MOV AX, 2000H
    MOV DS, AX
    
    ; --- Step 2: Set up Pointers and Counters ---
    MOV SI, 0000H                       ; SI = 0000H (Base offset)
    MOV CX, 000AH                       ; CX = 10 (Loop counter)
    MOV AX, 0000H                       ; AL = Sum Low, AH = Sum High (Carry)
    
    ; --- Step 3: Core Addition Loop ---
L_ADD_LOOP:   
    ADD AL, [SI]                        
    
    ; Manual Carry Propagation: If CF is 1, increment the high byte of sum.
    JNC L_SKIP_CARRY                      
    INC AH                              
    
L_SKIP_CARRY:   
    INC SI                              
    LOOP L_ADD_LOOP                     
    
    ; --- Step 4: Store results ---
    MOV [SI], AX                        
    
    ; --- Step 5: Termination ---
    ; -------------------------------------------------------------------------
    ; WHAT THIS PROGRAM COMPUTED
    ;
    ; The work above leaves its answer in the registers. Printing them is what
    ; makes the program demonstrate itself instead of needing a debugger.
    ; -------------------------------------------------------------------------
    CALL RPT_REGISTERS

    MOV AH, 4CH
    INT 21H
MAIN ENDP


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

END MAIN

; =============================================================================
; TECHNICAL NOTES & ARCHITECTURAL INSIGHTS
; =============================================================================
; 1. PHYSICAL ADDRESSING: 
;    Formula: Physical Address = (Segment Register * 0x10) + Offset
;    Example: 2000:0000 => 20000H + 0000H = 20000H.
;
; 2. CARRY PROPAGATION:
;    Standard 8-bit addition (ADD AL, mem) only updates the 8-bit register. 
;    The manual "JNC/INC AH" logic mimics how a 16-bit ADC (Add with Carry) 
;    instruction works.
;
; 3. ACCUMULATOR USAGE:
;    AX is treated here as a 16-bit accumulator split into AH (High) and AL (Low).
;    AL stores the partial sum, while AH counts the carries.
;
; 4. LITTLE-ENDIAN STORAGE:
;    The 8086 architecture stores the Low Byte (AL) first in memory, followed 
;    by the High Byte (AH).
;
; 5. LOOP INSTRUCTION:
;    The LOOP instruction is a shorthand for 'DEC CX' followed by 'JNZ label'. 
;    It is a fundamental tool for iterating through arrays.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =

