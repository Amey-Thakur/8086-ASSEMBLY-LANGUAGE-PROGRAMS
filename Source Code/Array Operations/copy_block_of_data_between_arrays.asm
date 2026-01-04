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
    MOV AH, 4CH                         
    INT 21H
MAIN ENDP

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
