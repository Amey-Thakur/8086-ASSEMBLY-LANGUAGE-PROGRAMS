; =============================================================================
; TITLE: String Copy Implementation (Hardware MOVSB Instruction)
; DESCRIPTION: This program demonstrates the most efficient way to copy a 
;              block of memory on the 8086: the 'REP MOVSB' primitive. It 
;              highlights the use of the Extra Segment (ES) and the Count 
;              Register (CX) for hardware-accelerated data movement.
; AUTHOR: Amey Thakur (https://github.com/Amey-Thakur)
; REPOSITORY: https://github.com/Amey-Thakur/8086-ASSEMBLY-LANGUAGE-PROGRAMS
; LICENSE: MIT License
; =============================================================================

.MODEL SMALL
.STACK 100H

; -----------------------------------------------------------------------------
; DATA SEGMENT (Source Data)
; -----------------------------------------------------------------------------
.DATA

    ; Labels for the register report at the end of the program.
    RPT_HEAD DB 0DH, 0AH, 'Registers when the program finished:', 0DH, 0AH, '$'
    RPT_N_AX DB '  AX = ', '$'
    RPT_N_BX DB '   BX = ', '$'
    RPT_N_CX DB '   CX = ', '$'
    RPT_N_DX DB '   DX = ', '$'
    RPT_NL   DB 0DH, 0AH, '$'
    VAL_SOURCE    DB "BIOMEDICAL"       ; Original string (10 bytes)
    LEN_STRING    EQU 10                

; -----------------------------------------------------------------------------
; EXTRA SEGMENT (Destination Buffer)
; -----------------------------------------------------------------------------
; On the 8086, the 'ES' (Extra Segment) is specifically designed to handle 
; destination targets for string primitives like MOVS and STOS.
.FARDATA
    VAL_DEST      DB 10 DUP('?')        ; Destination workspace

; -----------------------------------------------------------------------------
; CODE SEGMENT
; -----------------------------------------------------------------------------
.CODE
MAIN PROC
    ; --- Step 1: Initialize Segments ---
    MOV AX, @DATA
    MOV DS, AX                           ; DS points to source segment
    
    ; Initialize ES to point to the segment containing VAL_DEST
    MOV AX, SEG VAL_DEST
    MOV ES, AX                           
    
    ; --- Step 2: Setup String Pointers (Offset Level) ---
    LEA SI, VAL_SOURCE                   ; Source offset in DS
    LEA DI, VAL_DEST                     ; Destination offset in ES
    
    ; --- Step 3: Direction & Count Management ---
    ; CLD (Clear Direction Flag) ensures SI and DI increment after each byte.
    CLD                                  
    MOV CX, LEN_STRING                   ; Set transfer count
    
    ; --- Step 4: The Hardware Primitive (REP MOVSB) ---
    ; Operation Trace:
    ; (1) ES:[DI] = DS:[SI]
    ; (2) SI = SI + 1, DI = DI + 1 (Because DF=0)
    ; (3) CX = CX - 1
    ; (4) Continue until CX = 0
    REP MOVSB                            
    
    ; --- Step 5: Termination ---
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
; 1. HARDWARE DATA MOVEMENT:
;    'REP MOVSB' is a micro-coded recursive operation. Once triggered, the 
;    CPU's Execution Unit (EU) enters a specialized state that moves data 
;    without re-fetching the instruction opcode, maximizing bus throughput.
;
; 2. SEGMENT RIGIDITY:
;    The 8086 hardware architecture couples SI with DS and DI with ES for all 
;    string primitives. While SI can be overridden with a segment prefix, 
;    DI is fixed to ES. This makes ES management critical in multi-model 
;    programming.
;
; 3. WORD-LEVEL THROUGHPUT (MOVSW):
;    For large blocks, 'REP MOVSW' (Move String Word) can move two bytes in a 
;    single memory cycle, essentially doubling the copy speed compared to 
;    MOVSB.
;
; 4. OVERLAPPING MEMORY (THE DIRECTION FLAG):
;    If the source and destination buffers overlap (e.g., shifting data 
;    within the same array), 'STD' (Set Direction) should be used to copy 
;    backward from the end, preventing data corruption before it is read.
;
; 5. INTERRUPTIBILITY:
;    REP-prefixed instructions are interruptible. The CPU saves the current 
;    CX, SI, and DI state. After the ISR finishes, it resumes the copy 
;    exactly where it left off, maintaining system responsiveness during 
;    massive block transfers.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
