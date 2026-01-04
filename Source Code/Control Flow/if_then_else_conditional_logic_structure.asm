; =============================================================================
; TITLE: If-Then-Else Conditional Logic Structure
; DESCRIPTION: This program demonstrates the implementation of high-level 
;              if-then-else selection logic in 8086 Assembly. It highlights 
;              comparison mechanics (CMP) and the use of conditional vs 
;              unconditional jumps to redirect program execution flow.
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
    VAL_SCORE     DW 75                 ; Student score (0-100)
    VAL_THRESHOLD DW 50                 ; Passing threshold
    
    ; Result strings
    MSG_PASS      DB 'Status: PASS (Score meets threshold)$'
    MSG_FAIL      DB 'Status: FAIL (Score below threshold)$'

; -----------------------------------------------------------------------------
; CODE SEGMENT
; -----------------------------------------------------------------------------
.CODE
MAIN PROC
    ; --- Step 1: Initialize Data Segment ---
    MOV AX, @DATA
    MOV DS, AX
    
    ; --- Step 2: Comparison (The 'IF' Condition) ---
    ; CMP AX, BX evaluates (AX - BX) and sets the processor flags.
    MOV AX, VAL_SCORE                   
    CMP AX, VAL_THRESHOLD               
    
    ; --- Step 3: Branch Decision ---
    ; JGE: Jump if Greater or Equal. If condition matches, skip the FAIL block.
    JGE L_PASS_THEN                     
    
    ; --- Step 4: 'ELSE' Block (Negative Case) ---
    LEA DX, MSG_FAIL                    
    JMP L_ENDIF                         ; Must jump over the THEN block
    
L_PASS_THEN:
    ; --- Step 5: 'THEN' Block (Positive Case) ---
    LEA DX, MSG_PASS                    
    
L_ENDIF:
    ; --- Step 6: Common Execution Path ---
    MOV AH, 09H                         ; DOS Display String
    INT 21H
    
    ; --- Step 7: Termination ---
    MOV AH, 4CH
    INT 21H
MAIN ENDP

END MAIN 

; =============================================================================
; TECHNICAL NOTES & ARCHITECTURAL INSIGHTS
; =============================================================================
; 1. FLAG EVALUATION MECHANICS:
;    The 'JGE' (Jump if Greater or Equal) instruction in signed arithmetic 
;    expects that the Sign Flag (SF) is equal to the Overflow Flag (OF). 
;    This hardware check ensures correct logic even if an arithmetic wrap-around 
;    occurred during the 'CMP' subtraction.
;
; 2. THE PIPELINE PENALTY (BRANCH PREDICTION):
;    On modern processors, branches are predicted. On the 8086, any jump 
;    causes the instruction prefetch queue to be flushed. This makes sequential 
;    code slightly faster than code with many jumps.
;
; 3. THE "JUMP OVER" PATTERN:
;    In assembly, high-level 'if-then-else' requires an explicit unconditional 
;    'JMP' at the end of the first block to avoid "falling through" into 
;    the else-code. Negating the condition (e.g., using JL instead of JGE 
;    to jump to ELSE) can sometimes simplify the instruction count.
;
; 4. SIGNED VS UNSIGNED LOGIC:
;    - JGE/JL/JG/JLE: Used for signed integers (where MSB is sign).
;    - JAE/JB/JA/JBE: Used for unsigned integers (where MSB represents magnitude).
;    Using the wrong jump type for your data can lead to critical logic errors 
;    when comparing negative numbers.
;
; 5. LABELLING CONVENTION:
;    Professional assembly often uses 'L_' prefixes for local labels to distinguish 
;    conditional branch targets from procedures (PROCs) or data variables.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
