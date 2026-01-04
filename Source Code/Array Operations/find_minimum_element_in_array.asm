; =============================================================================
; TITLE: Minimum Element Discovery in Unsigned Arrays
; DESCRIPTION: This program identifies the smallest numerical value within a 
;              sequential array of 8-bit integers. It demonstrates the 
;              iterative comparison pattern, the use of conditional branching 
;              (JB), and efficient register-based state tracking.
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
    ; Source Data Set (Values in Hex: 45H=69, 23H=35, 89H=137, 12H=18, 67H=103)
    DATA_SET DB 45H, 23H, 89H, 12H, 67H     
    
    ; Setup analytical constants
    SET_LENGTH EQU 5                           
    
    ; Buffer for discovery result
    MINIMUM_VAL DB ?                            

; -----------------------------------------------------------------------------
; CODE SEGMENT
; -----------------------------------------------------------------------------
.CODE
MAIN PROC
    ; --- Step 1: Initialize Data Segment ---
    MOV AX, @DATA
    MOV DS, AX
    
    ; --- Step 2: Initialize Discovery State ---
    LEA SI, DATA_SET                    ; SI = Pointer to start of collection
    MOV CX, SET_LENGTH                  ; CX = Performance counter
    
    ; Algorithmic Assumption: The first element is the minimum until proven otherwise.
    MOV AL, [SI]                        ; AL = Initial champion (candidate for min)
    
    ; Adjust iterator for the first comparison
    INC SI                              
    DEC CX                              ; We have already processed element 1
    
    ; --- Step 3: Comparison and Update Loop ---
SEARCH_MIN:
    ; Check if the current candidate in memory is smaller than the current champion.
    CMP AL, [SI]                        
    
    ; JB (Jump if Below) performs an unsigned comparison.
    ; If Current Min (AL) is already smaller than memory value, we skip the update.
    JB SKIP_UPDATE                      
    
    ; Update Phase: New minimum discovered.
    MOV AL, [SI]                        
    
SKIP_UPDATE:
    INC SI                              ; Move to next element in memory
    LOOP SEARCH_MIN                     ; Decrement CX and branch if CX > 0
    
    ; --- Step 4: Persist Results ---
    ; Expected: AL = 12H (18 decimal)
    MOV MINIMUM_VAL, AL                         
    
    ; --- Step 5: Termination ---
    MOV AH, 4CH                         
    INT 21H
MAIN ENDP

END MAIN

; =============================================================================
; TECHNICAL NOTES & ARCHITECTURAL INSIGHTS
; =============================================================================
; 1. UNSIGNED vs SIGNED JUMPS:
;    This program uses JB (Jump if Below). On the 8086, 'Above' and 'Below' 
;    refer to unsigned comparisons (where 0 to 255 is the range). 'Greater' 
;    and 'Less' (JG/JL) refer to signed comparisons (where -128 to +127 is 
;    the range). Using the wrong jump would lead to incorrect results if 
;    the values exceeded 127.
;
; 2. O(N) SEARCH COMPLEXITY:
;    Finding the minimum in an unsorted array is a linear-time operation. 
;    The CPU must inspect every single element at least once. This loop 
;    is optimized to minimize instruction count per iteration.
;
; 3. IMPLICIT LOOP CONTROL:
;    The 'LOOP' instruction is used here. It specifically decrements CX. 
;    If the array length were 0, CX would wrap to FFFFH (65,535) and result 
;    in a massive memory-scan bug. Bounds checks are vital in production code.
;
; 4. REGISTER ASSIGNMENT:
;    - AL: Acts as the "Current Champion" (Minimum) register. Keeping the 
;      result in a high-speed register instead of memory prevents significant 
;      bus latency.
;    - SI: Standard Source Index pointer for array traversal.
;
; 5. COMPARISON FLAGS:
;    - The CMP instruction sets the Carry Flag (CF) if the first operand is 
;      less than the second (unsigned). 
;    - JB is functionally equivalent to JC (Jump if Carry set).
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
