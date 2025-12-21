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
    
    ; Result: Memory at VAL_DEST now mirrors VAL_SOURCE.
            
    ; --- Step 4: Shutdown ---
    MOV AH, 4CH
    INT 21H
MAIN ENDP

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


;-----------------------------------------------------------------------------
; DATA SEGMENT
;-----------------------------------------------------------------------------
DATA SEGMENT
    SOURCE DB "BIOMEDICAL"               ; Source string (10 chars)
    DEST DB 10 DUP(?)                    ; Destination buffer
DATA ENDS

;-----------------------------------------------------------------------------
; CODE SEGMENT
;-----------------------------------------------------------------------------
CODE SEGMENT
    ASSUME CS:CODE, DS:DATA
    
START:
    ; Initialize Data Segment
    MOV AX, DATA
    MOV DS, AX
    
    ;-------------------------------------------------------------------------
    ; Setup for Manual Copy
    ;-------------------------------------------------------------------------
    MOV SI, OFFSET SOURCE                ; SI points to source
    MOV DI, OFFSET DEST                  ; DI points to destination
    MOV CX, 000AH                        ; Count = 10 characters
    
    ;-------------------------------------------------------------------------
    ; Manual Copy Loop (without string instructions)
    ; Uses MOV to copy byte by byte
    ;-------------------------------------------------------------------------
COPY_LOOP:
    MOV AL, [SI]                         ; Load byte from source
    MOV [DI], AL                         ; Store byte to destination
    INC SI                               ; Next source byte
    INC DI                               ; Next destination byte
    LOOP COPY_LOOP                       ; Decrement CX, loop if not zero
    
    ; Result: "BIOMEDICAL" copied to DEST
            
    ;-------------------------------------------------------------------------
    ; Program Termination
    ;-------------------------------------------------------------------------
    MOV AH, 4CH
    INT 21H
CODE ENDS
END START

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