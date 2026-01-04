; =============================================================================
; TITLE: Conditional Branching & Status Flags Reference
; DESCRIPTION: This program serves as a comprehensive reference for 8086 
;              conditional jump instructions. It demonstrates how the CPU 
;              evaluates Status Flags (ZF, CF, SF, OF, PF) to decide program 
;              flow following arithmetic or comparison operations.
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
    ; Feedback messages for branching logic
    MSG_EQ    DB 'Result: Numbers are equal (ZF=1)$'
    MSG_NE    DB 'Result: Numbers are NOT equal (ZF=0)$'
    MSG_GT    DB 'Result: First operand is GREATER (Signed)$'
    MSG_LT    DB 'Result: First operand is LESS (Signed)$'
    
    ; Test Operands
    NUM_A     DW 50                          
    NUM_B     DW 30                          

; -----------------------------------------------------------------------------
; CODE SEGMENT
; -----------------------------------------------------------------------------
.CODE
MAIN PROC
    ; --- Step 1: Initialize Data Segment ---
    MOV AX, @DATA
    MOV DS, AX
    
    ; --- Step 2: Immediate Logic Execution ---
    ; The CMP instruction performs (NUM_A - NUM_B) internally.
    ; It discards the result but updates ALL status flags.
    MOV AX, NUM_A                        
    CMP AX, NUM_B                        ; Compare 50 (AX) with 30
    
    ; --- Step 3: Branching on Equality ---
    JE  L_EQUAL                          ; Jump if Equal (ZF = 1)
    
    ; If not equal, execution falls through here
    JNE L_NOT_EQUAL                      ; Jump if Not Equal (ZF = 0)
    
L_EQUAL:
    LEA DX, MSG_EQ
    JMP L_DISPLAY_AND_EXIT                 
    
L_NOT_EQUAL:
    ; --- Step 4: Branching on Magnitude (Signed) ---
    ; Reloading AX for clarity (though CMP already set flag state)
    MOV AX, NUM_A
    CMP AX, NUM_B
    
    JG  L_GREATER                        ; Jump if Greater (> signed)
    JL  L_LESS                           ; Jump if Less (< signed)
    
L_GREATER:
    LEA DX, MSG_GT
    JMP L_DISPLAY_AND_EXIT
    
L_LESS:
    LEA DX, MSG_LT
    
L_DISPLAY_AND_EXIT:
    ; --- Step 5: Service Routine to Display Message ---
    MOV AH, 09H
    INT 21H
    
    ; --- Step 6: Shutdown ---
    MOV AH, 4CH                         
    INT 21H
MAIN ENDP

END MAIN

; =============================================================================
; TECHNICAL NOTES & ARCHITECTURAL INSIGHTS
; =============================================================================
; 1. CONDITIONAL JUMP CLASSIFICATION:
;    -------------------------------------------------------------------------
;    EQUALITY/ZERO:
;    - JE / JZ   : Jump if Equal / Zero (ZF = 1)
;    - JNE / JNZ : Jump if Not Equal / Not Zero (ZF = 0)
;
;    SIGNED COMPARISONS (Signed Integers):
;    - JG      : Jump if Greater (ZF=0 AND SF=OF)
;    - JGE     : Jump if Greater or Equal (SF = OF)
;    - JL      : Jump if Less (SF != OF)
;    - JLE     : Jump if Less or Equal (ZF=1 OR SF != OF)
;
;    UNSIGNED COMPARISONS (Magnitude/Addresses):
;    - JA      : Jump if Above (CF=0 AND ZF=0)
;    - JAE     : Jump if Above or Equal (CF = 0)
;    - JB      : Jump if Below (CF = 1)
;    - JBE     : Jump if Below or Equal (CF=1 OR ZF=1)
;
; 2. JUMP DISTANCE CONSTRAINTS (8086):
;    On the 8086, conditional jumps are exclusively "SHORT" jumps. This means 
;    the displacement is a signed 8-bit value (-128 to +127 bytes from the 
;    current IP). If a target label is too far, the assembler will error. 
;    The workaround is a negated conditional jump coupled with a NEAR JMP.
;
; 3. THE FLAG EVALUATORS:
;    Instructions like JS (Jump on Sign), JO (Jump on Overflow), and JP 
;    (Jump on Parity) test specific hardware flags regardless of whether 
;    a comparison (CMP) was the last instruction executed.
;
; 4. PIPELINE IMPACT:
;    Branching disrupts the instruction prefetch queue on the 8086, incurring 
;    a cycles penalty compared to linear execution. Modern CPUs use branch 
;    prediction to mitigate this, but original 8086 hardware did not.
;
; 5. PARITY FLAG (PF):
;    Rarely used today, but PF checks the number of set bits in the lower 
;    byte of a result. It is set if the count is even. Primarily used in 
;    legacy communication protocols for error checking.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
