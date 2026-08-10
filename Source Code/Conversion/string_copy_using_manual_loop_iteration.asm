; =============================================================================
; TITLE: String Copy Implementation (Manual Loop Iteration)
; DESCRIPTION: This program demonstrates how to copy data from a source to a 
;              destination using standard MOV and LOOP instructions. This 
;              approach is less efficient than the hardware primitives but 
;              more flexible for adding per-byte logic (e.g., case conversion).
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
    ; Source and Destination in the same segment for this demonstration
    VAL_SOURCE    DB "BIOMEDICAL"
    VAL_DEST      DB 10 DUP('?')
    LEN_STRING    EQU 10

    ; The buffers carry no terminator, so they cannot be printed with service
    ; 09H. These labels are for the running commentary only.
    M_BEFORE      DB "Source: $"
    M_AFTER       DB 0DH, 0AH, "Copied: $"
    M_END         DB 0DH, 0AH, "$"

; -----------------------------------------------------------------------------
; CODE SEGMENT
; -----------------------------------------------------------------------------
.CODE
MAIN PROC
    ; --- Step 1: Initialize Data Segment ---
    MOV AX, @DATA
    MOV DS, AX
    
    ; --- Step 2: Setup Pointers & Counter ---
    LEA SI, VAL_SOURCE                   ; Source Index (SI)
    LEA DI, VAL_DEST                     ; Destination Index (DI)
    MOV CX, LEN_STRING                   ; Iteration count
    
    ; --- Step 3: Manual Transfer Loop ---
L_MANUAL_COPY:
    ; (A) Load byte into an intermediate register
    MOV AL, [SI]                         
    
    ; (B) Store byte from intermediate register to destination
    MOV [DI], AL                         
    
    ; (C) Update Pointers
    INC SI                               
    INC DI                               
    
    ; (D) Repeat until counter hits 0
    LOOP L_MANUAL_COPY                   
    
    ; --- Step 4: Show both buffers ---
    ; The copy is finished and VAL_DEST now mirrors VAL_SOURCE. Leaving the
    ; result in memory alone would make this indistinguishable from a program
    ; that had not run, so both are printed and can be compared by eye.
    LEA DX, M_BEFORE
    MOV AH, 09H
    INT 21H
    LEA SI, VAL_SOURCE
    MOV CX, LEN_STRING
    CALL SHOW_BUFFER

    LEA DX, M_AFTER
    MOV AH, 09H
    INT 21H
    LEA SI, VAL_DEST
    MOV CX, LEN_STRING
    CALL SHOW_BUFFER

    LEA DX, M_END
    MOV AH, 09H
    INT 21H

    ; --- Step 5: Shutdown ---
    MOV AH, 4CH
    INT 21H
MAIN ENDP

; -----------------------------------------------------------------------------
; SHOW_BUFFER
;
; Prints the CX characters at DS:SI, one at a time.
;
; Service 09H cannot be used, because neither buffer ends in a dollar sign: they
; hold exactly ten characters and nothing else. Printing by count rather than by
; terminator is what any fixed length field needs.
; -----------------------------------------------------------------------------
SHOW_BUFFER PROC
    PUSH AX
    PUSH CX
    PUSH DX
    PUSH SI

    JCXZ SHOW_DONE

SHOW_ONE:
    MOV DL, [SI]
    MOV AH, 02H
    INT 21H
    INC SI
    LOOP SHOW_ONE

SHOW_DONE:
    POP SI
    POP DX
    POP CX
    POP AX
    RET
SHOW_BUFFER ENDP

END MAIN

; =============================================================================
; TECHNICAL NOTES & ARCHITECTURAL INSIGHTS
; =============================================================================
; 1. FLEXIBILITY VS SPEED:
;    While 'REP MOVSB' is significantly faster, it cannot be interrupted by 
;    per-byte logic. If one needed to copy a string AND capitalize it simultaneously, 
;    this manual loop pattern is required to insert the 'AND AL, 0DFH' logic 
;    between instructions (A) and (B).
;
; 2. THE BOTTLENECK (INTERMEDIATE STORAGE):
;    This manual method requires moving data into 'AL' before moving it to 
;    destination. This doubles the memory bus load compared to string 
;    instructions, which theoretically move data more directly.
;
; 3. POINTER SYNCHRONIZATION:
;    Failing to increment either SI or DI in every pass results in data 
;    corruption. Manual copy loops are significantly more prone to "Off-By-One" 
;    errors and pointer desynchronization compared to MOVSB.
;
; 4. REGISTER PRESERVATION:
;    This pattern consumes 'AL', whereas specialized hardware instructions 
;    leave AX/BX/DX untouched, preserving them for other calculations.
;
; 5. LOOP OVERHEAD:
;    The 'LOOP' instruction at Step 3(D) incurs a branch penalty every single 
;    iteration. On older processors, this constant branching prevents optimal 
;    instruction pre-fetching.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =

;=============================================================================
; COMPARISON WITH STRING INSTRUCTIONS:
; 
; Manual Method:                String Instruction Method:
; -----------------             -------------------------
; COPY_LOOP:                    CLD
;   MOV AL, [SI]                MOV CX, 10
;   MOV [DI], AL                REP MOVSB
;   INC SI
;   INC DI
;   LOOP COPY_LOOP
; 
; String instructions are faster and more compact!
;=============================================================================