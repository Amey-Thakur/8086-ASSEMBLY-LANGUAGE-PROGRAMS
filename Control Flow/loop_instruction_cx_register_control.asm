; =============================================================================
; TITLE: Loop Instruction (CX Register Hardware Control)
; DESCRIPTION: This program demonstrates the specific hardware-accelerated 
;              looping mechanism of the 8086. It utilizes the CX (Count) 
;              register and the LOOP primitive to perform iterative logic 
;              with minimal instruction overhead.
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
    MSG_HEADER    DB 'Counting Sequence: $'
    MSG_NEWLINE   DB 0DH, 0AH, '$'
    VAL_START_DIG DB '1'                 ; Starting ASCII digit

; -----------------------------------------------------------------------------
; CODE SEGMENT
; -----------------------------------------------------------------------------
.CODE
MAIN PROC
    ; --- Step 1: Initialize Data Segment ---
    MOV AX, @DATA
    MOV DS, AX
    
    ; --- Step 2: Display Header ---
    LEA DX, MSG_HEADER
    MOV AH, 09H
    INT 21H
    
    ; --- Step 3: Setup Loop Counter ---
    ; On the 8086, the 'LOOP' instruction specifically targets the CX register.
    MOV CX, 9                           ; Perform 9 iterations
    MOV DL, VAL_START_DIG               ; Load initial digit for display
    
    ; --- Step 4: Iterative Execution ---
L_ITERATE:
    ; Display current character (stored in DL)
    MOV AH, 02H                         ; DOS: Display character
    INT 21H                             
    
    ; Space separator for readability
    PUSH DX                             ; Save current digit/pointer
    MOV DL, ' '
    MOV AH, 02H
    INT 21H
    POP DX                              ; Restore current digit
    
    INC DL                              ; Move to next ASCII character
    
    ; The 'LOOP' primitive effectively performs:
    ; (1) CX = CX - 1
    ; (2) IF CX != 0 THEN JUMP TO label
    LOOP L_ITERATE                      
    
    ; --- Step 5: Termination Cleanup ---
    LEA DX, MSG_NEWLINE
    MOV AH, 09H
    INT 21H
    
    MOV AH, 4CH
    INT 21H
MAIN ENDP

END MAIN

; =============================================================================
; TECHNICAL NOTES & ARCHITECTURAL INSIGHTS
; =============================================================================
; 1. THE ZERO-COUNT TRAP:
;    A critical behavior to note: if CX is 0 when the 'LOOP' instruction is 
;    reached, the CPU will decrement it to 0FFFFH and attempt to loop 
;    65,536 times. Defensive programmers often use 'JCXZ' (Jump if CX is Zero) 
;    before entering a loop to prevent this overflow.
;
; 2. HARDWARE OPTIMIZATION:
;    The 'LOOP' instruction is a micro-coded primitive. It is more compact 
;    (2 bytes) than the equivalent manual sequence 'DEC CX' (1 byte) + 
;    'JNZ label' (2 bytes), saving instruction cache space.
;
; 3. DISTANCE LIMITS:
;    Like conditional jumps, 'LOOP' is a SHORT jump. The target label must 
;    be within -128 to +127 bytes relative to the instruction pointer.
;
; 4. SPECIALIZED LOOP VARIANTS:
;    - LOOPE/LOOPZ (Loop while Equal): Continues while CX > 0 AND ZF=1. 
;      Ideal for searching an array for the first non-matching byte.
;    - LOOPNE/LOOPNZ (Loop while Not Equal): Continues while CX > 0 AND ZF=0. 
;      Ideal for searching an array for a specific target value.
;
; 5. FLAG TRANSPARENCY:
;    Crucially, 'LOOP' DOES NOT affect the processor flags. This allows high-level 
;    logic within the loop to preserve the results of comparisons across 
;    multiple iterations without 'LOOP' interfering with the Zero or Carry flags.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
