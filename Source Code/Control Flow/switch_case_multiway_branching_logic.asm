; =============================================================================
; TITLE: Switch-Case Multipath Branching (Jump Table Implementation)
; DESCRIPTION: This program demonstrates an optimized way to implement 
;              multi-way selection logic (Switch-Case) using a Jump Table. 
;              By storing offsets in an array, the program achieves O(1) 
;              branching complexity, skipping multiple sequential comparisons.
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
    VAL_CHOICE    DB 2                  ; Simulate user input (1, 2, or 3)
    
    ; Feedback Messages
    MSG_1         DB 'Execution Path: Case 1 Selected$'
    MSG_2         DB 'Execution Path: Case 2 Selected$'
    MSG_3         DB 'Execution Path: Case 3 Selected$'
    MSG_DEFAULT   DB 'Execution Path: Default (Invalid Input)$'
    
    ; --- The Jump Table ---
    ; Array of word-sized pointers (offsets) to the handling labels.
    JUMP_TABLE    DW L_CASE_1, L_CASE_2, L_CASE_3

; -----------------------------------------------------------------------------
; CODE SEGMENT
; -----------------------------------------------------------------------------
.CODE
MAIN PROC
    ; --- Step 1: Initialize Data Segment ---
    MOV AX, @DATA
    MOV DS, AX
    
    ; --- Step 2: Validate Input Bounds ---
    ; Choice must be between 1 and 3.
    MOV AL, VAL_CHOICE                  
    CMP AL, 1
    JB L_DEFAULT                        ; Below 1
    CMP AL, 3
    JA L_DEFAULT                        ; Above 3
    
    ; --- Step 3: Calculate Table Offset ---
    ; Offset = (Choice - 1) * 2 bytes (since each label in the table is a Word)
    DEC AL                              ; Convert 1-3 to 0-2 index
    XOR AH, AH                          ; Clear high byte for 16-bit math
    SHL AX, 1                           ; Multiply by 2 via logical shift left
    MOV BX, AX                          ; Move to base register for memory access
    
    ; --- Step 4: Dispatch (Indirect Jump) ---
    JMP JUMP_TABLE[BX]                  ; Transfer control to the offset at [BX]
    
L_CASE_1:
    LEA DX, MSG_1
    JMP L_END_SWITCH
    
L_CASE_2:
    LEA DX, MSG_2
    JMP L_END_SWITCH
    
L_CASE_3:
    LEA DX, MSG_3
    JMP L_END_SWITCH
    
L_DEFAULT:
    LEA DX, MSG_DEFAULT
    
L_END_SWITCH:
    ; --- Step 5: Display Result ---
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
; 1. DISPATCH EFFICIENCY (O(1)):
;    Unlike a series of 'CMP' and 'JE' instructions (which take O(N) time), 
;    the Jump Table approach allows the CPU to calculate the destination 
;    address in a fixed number of cycles. This is how modern compilers 
;    optimize high-level 'switch' statements with contiguous cases.
;
; 2. INDIRECT JUMPING MECHANICS:
;    The instruction 'JMP JUMP_TABLE[BX]' is an indirect memory jump. The 
;    CPU fetches the 16-bit value stored at the memory location JUMP_TABLE + BX 
;    and loads it directly into the Instruction Pointer (IP).
;
; 3. DATA ALIGNMENT:
;    Storing the 'DW' pointers in the jump table ensures they are 16-bit 
;    aligned (if the data segment starts correctly). On the 8086, word-sized 
;    reads from even addresses are faster than from odd addresses.
;
; 4. SCALING THE OFFSET:
;    Since we are in real mode and using a 16-bit word table (+2 bytes per 
;    entry), we must shift left once (SHL AX, 1). If this were a 32-bit table 
;    in protected mode, we would shift left twice (SHL EAX, 2).
;
; 5. THE "FALL-THROUGH" RISK:
;    Each case block must conclude with an unconditional 'JMP L_END_SWITCH' 
;    to prevent the processor from executing the subsequent case handlers 
;    sequentially in memory.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
