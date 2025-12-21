; =============================================================================
; TITLE: While Loop Structure (Pre-Test Conditional Iteration)
; DESCRIPTION: This program demonstrates the implementation of a 'while' 
;              loop structure in assembly. It highlights the "Pre-Test" 
;              pattern where the loop condition is evaluated at the start, 
;              ensuring the body executes zero or more times.
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
    VAL_ITER_COUNT DW 0                 ; Counter (i)
    VAL_LIMIT      DW 5                 ; Loop limit
    
    MSG_BODY       DB 'Loop Iteration Index: $'
    MSG_NEWLINE    DB 0DH, 0AH, '$'

; -----------------------------------------------------------------------------
; CODE SEGMENT
; -----------------------------------------------------------------------------
.CODE
MAIN PROC
    ; --- Step 1: Initialize Data Segment ---
    MOV AX, @DATA
    MOV DS, AX
    
L_WHILE_START:
    ; --- Step 2: The Pre-Test Condition ---
    ; Equivalent to: while (VAL_ITER_COUNT < VAL_LIMIT)
    MOV AX, VAL_ITER_COUNT
    CMP AX, VAL_LIMIT
    
    ; If i >= limit, the condition is false. Exit immediately.
    JGE L_WHILE_END                     
    
    ; --- Step 3: Loop Body ---
    ; (A) Display Description
    LEA DX, MSG_BODY
    MOV AH, 09H
    INT 21H
    
    ; (B) Display current count (Convert 0-5 to ASCII)
    MOV AX, VAL_ITER_COUNT
    ADD AL, '0'                         
    MOV DL, AL
    MOV AH, 02H
    INT 21H
    
    ; (C) Visual Cleanup
    LEA DX, MSG_NEWLINE
    MOV AH, 09H
    INT 21H
    
    ; --- Step 4: Increment Iteration Counter ---
    INC VAL_ITER_COUNT                  ; i++
    
    ; --- Step 5: Circular Jump ---
    ; Return to the top to re-evaluate the condition.
    JMP L_WHILE_START                   
    
L_WHILE_END:
    ; --- Step 6: Shutdown ---
    MOV AH, 4CH
    INT 21H
MAIN ENDP

END MAIN

; =============================================================================
; TECHNICAL NOTES & ARCHITECTURAL INSIGHTS
; =============================================================================
; 1. PRE-TEST VS POST-TEST:
;    The 'While' loop is a pre-test loop. If 'limit' were 0 initially, the 
;    loop body would never execute. In contrast, 'Do-While' loops execute 
;    the body at least once because the condition is checked at the bottom.
;
; 2. THE COMPILATION PATTERN:
;    While loops are usually compiled into:
;      1. Top-Level Comparison
;      2. Conditional Jump to Exit
;      3. Body Code
;      4. Unconditional Jump to Start
;    More advanced compilers sometimes "rotate" the loop into a Do-While 
;    guarded by an IF to reduce the number of jumps per iteration.
;
; 3. REGISTER OPTIMIZATION:
;    For performance-critical loops, it is best to keep the counter in a 
;    register (like SI or CX) rather than memory (VAL_ITER_COUNT). This 
;    eliminates repeated memory bus cycles in every iteration.
;
; 4. INFINITE LOOP PREVENTION:
;    In assembly, forgetting the 'INC' instruction or jumping to the wrong 
;    label (e.g., jumping back above the initialization) results in an 
;    infinite loop that freezes the DOS environment.
;
; 5. EXIT COORDINATION:
;    The 'L_WHILE_END' label serves as a common exit point. Using clean 
;    labeling like START/END allows for easy code maintenance and debugger 
;    navigation.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
