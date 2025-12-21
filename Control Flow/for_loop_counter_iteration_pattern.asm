; =============================================================================
; TITLE: For-Loop Counter Iteration Pattern
; DESCRIPTION: This program implements a standard 'for' loop structure using 
;              manual initialization, conditional branching, and increment 
;              logic. It provides a visual bridge between high-level control 
;              structures and low-level disassembly.
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
    MSG_ITER      DB 'Loop Iteration Count: $'
    CHAR_SPACE    DB ' ', '$'                
    VAL_NEWLINE   DB 0DH, 0AH, '$'

; -----------------------------------------------------------------------------
; CODE SEGMENT
;
; High-Level Pseudocode:
;   for (i = 1; i <= 5; i++) {
;       print "Iteration: ", i
;   }
; -----------------------------------------------------------------------------
.CODE
MAIN PROC
    ; --- Step 1: Initialize Data Segment ---
    MOV AX, @DATA
    MOV DS, AX
    
    ; --- Step 2: Loop Initialization ---
    ; Using BL as the 'i' counter variable.
    MOV BL, 1                           ; i = 1
    
L_FOR_START:
    ; --- Step 3: Condition Check (i <= 5) ---
    CMP BL, 5                           ; Is i > 5?
    JG L_FOR_END                        ; If TRUE, terminal the loop
    
    ; --- Step 4: Loop Body ---
    
    ; Display Iteration Label
    LEA DX, MSG_ITER
    MOV AH, 09H
    INT 21H
    
    ; Display Counter (Convert numeric 1-5 to ASCII '1'-'5')
    MOV DL, BL
    ADD DL, '0'                         ; Scalar to ASCII
    MOV AH, 02H
    INT 21H
    
    ; Display Newline
    LEA DX, VAL_NEWLINE
    MOV AH, 09H
    INT 21H
    
    ; --- Step 5: Iteration Increment (i++) ---
    INC BL                              
    
    ; --- Step 6: Loop Back Unconditionally ---
    JMP L_FOR_START
    
L_FOR_END:
    ; --- Step 7: Termination ---
    MOV AH, 4CH                         
    INT 21H
MAIN ENDP

END MAIN

; =============================================================================
; TECHNICAL NOTES & ARCHITECTURAL INSIGHTS
; =============================================================================
; 1. FOR-LOOP MAPPING:
;    A "for" loop in assembly is typically composed of four segments:
;    - Initialization: Set counter state before entering.
;    - Test (Pre-condition): CMP followed by a conditional jump to the end.
;    - Body: The actual workload.
;    - Increment & JMP: Update state and return to the test.
;
; 2. REGISTER SELECTION:
;    While any General Purpose Register (GPR) can be used as a counter, using 
;    the CX register allows for the use of the specialized 'LOOP' instruction, 
;    which combines the decrement, zero-check, and jump into one cycle.
;
; 3. PERFORMANCE OPTIMIZATION (LOOP INSTRUCTION):
;    ```assembly
;    MOV CX, 5
;    L1:
;        ; Body here
;        LOOP L1  ; Dec CX and jump if CX != 0
;    ```
;    This is generally more cycle-efficient than a manual DEC/CMP/JNZ pattern.
;
; 4. COMPARISON TYPE (JG vs JA):
;    This program uses 'JG' (Jump if Greater), which assumes 'i' is a signed 
;    integer. If our counter was intended to be unsigned, 'JA' (Jump if Above) 
;    would be the correct semantic choice.
;
; 5. BRANCH PREDICTION:
;    The 'JMP L_FOR_START' at the bottom of the loop is an unconditional jump, 
;    meaning the CPU pipeline always follows it back to the test condition 
;    unless the terminal condition (JG) is met.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
