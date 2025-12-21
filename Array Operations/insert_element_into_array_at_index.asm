; =============================================================================
; TITLE: Array Element Insertion via Right-Shift Displacement
; DESCRIPTION: This program demonstrates how to insert a new element into a 
;              sequential array at a specific index. It features the critical 
;              "Backwards Shift" logic required to prevent data corruption 
;              when moving data within the same memory block.
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
    ; Array with pre-allocated buffer space (0 at the end)
    ; Original Logic: {10, 20, 30, 40, 50}
    DATA_ARRAY DB 10H, 20H, 30H, 40H, 50H, 0  
    
    ; Setup Properties
    CURRENT_LEN EQU 5                          
    INSERT_POS  EQU 2                    ; 0-based index to insert at
    NEW_ELEMENT DB 25H                   ; Value to be inserted

; -----------------------------------------------------------------------------
; CODE SEGMENT
; -----------------------------------------------------------------------------
.CODE
MAIN PROC
    ; --- Step 1: Initialize Data Segment ---
    MOV AX, @DATA
    MOV DS, AX
    
    ; --- Step 2: Pointer Setup for Backwards Shift ---
    ; To insert at index 2, we must move element [4] to [5], [3] to [4], and [2] to [3].
    ; We MUST start from the end to avoid overwriting data we haven't moved yet.
    
    LEA SI, DATA_ARRAY                  
    ADD SI, CURRENT_LEN - 1             ; SI = Source (Point to '50H' at index 4)
    
    LEA DI, DATA_ARRAY                  
    ADD DI, CURRENT_LEN                 ; DI = Destination (Point to empty index 5)
    
    ; --- Step 3: Calculate Shift Iterations ---
    ; Shifts required = Current Length - Insertion Position
    MOV CX, CURRENT_LEN                 
    SUB CX, INSERT_POS                  ; CX = 5 - 2 = 3 iterations
    
    ; --- Step 4: Iterative Backwards Shifting Loop ---
SHIFT_RIGHT_LOOP:
    ; Move current element one position to the right
    MOV AL, [SI]                        
    MOV [DI], AL                        
    
    ; Decrement pointers to move "backwards" through the array
    DEC SI                              
    DEC DI                              
    
    LOOP SHIFT_RIGHT_LOOP               ; CX--, branch if CX > 0
    
    ; --- Step 5: The Actual Insertion ---
    ; DI now points to the target index (index 2) freed by the shift.
    MOV AL, NEW_ELEMENT                 
    MOV [DI], AL                        
    
    ; Verification: DATA_ARRAY is now {10H, 20H, 25H, 30H, 40H, 50H}.
    
    ; --- Step 6: Shutdown ---
    MOV AH, 4CH                         
    INT 21H
MAIN ENDP

END MAIN

; =============================================================================
; TECHNICAL NOTES & ARCHITECTURAL INSIGHTS
; =============================================================================
; 1. THE BACKWARDS SHIFT REQUIREMENT:
;    When shifting data "right" (to a higher memory address) within a single 
;    array, you must begin at the tail end. If you started at the insertion 
;    point, you would overwrite index 3 with index 2, then try to move the 
;    (now overwritten) index 3 to index 4, leading to data corruption.
;
; 2. TIME COMPLEXITY (O(N)):
;    Insertion in a contiguous array is expensive. In the worst case 
;    (inserting at index 0), every single element must be moved. This 
;    linearity makes large arrays inefficient for frequent insertions.
;
; 3. BUFFER OVERFLOW RISK:
;    Static array insertion assumes that 'memory[length]' is valid and 
;    allocated. In this program, we explicitly defined 'ARR DB ..., 0' to 
;    reserve that crucial extra byte. Without pre-allocation, this logic 
;    would corrupt adjacent variables in the DATA segment.
;
; 4. POINTER WRAP-AROUND:
;    Decrementing pointers (DEC SI) near the start of a segment requires 
;    caution. However, since our array is safely positioned within the 
;    DATA segment, the offsets remain valid.
;
; 5. REGISTER REUSE:
;    AL is used as a high-speed intermediate for the movement. Using 16-bit 
;    registers (AX) with a Word Pointer would move 2 bytes at a time, but 
;    would require careful alignment handling for odd-sized arrays.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
