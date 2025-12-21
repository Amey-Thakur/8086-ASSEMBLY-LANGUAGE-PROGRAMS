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
    MOV AH, 4CH
    INT 21H
MAIN ENDP

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
