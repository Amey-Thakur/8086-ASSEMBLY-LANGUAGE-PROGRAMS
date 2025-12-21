; =============================================================================
; TITLE: Last-In-First-Out (LIFO) Stack Implementation
; DESCRIPTION: This program implements a custom Stack data structure using an 
;              array. Unlike the system stack (SS:SP), this "Software Stack" 
;              gives the developer full control over PUSH and POP operations, 
;              overflow checks, and Top-of-Stack (TOS) tracking.
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
    STACK_BUF  DB 5 DUP(0)              ; Stack storage (Size: 5 bytes)
    MSG_EMPTY  DB 0DH, 0AH, "Status: Stack Underflow!$"
    MSG_FULL   DB 0DH, 0AH, "Status: Stack Overflow!$"
    MSG_PUSH   DB 0DH, 0AH, "Pushed To Stack: $"
    MSG_POP    DB 0DH, 0AH, "Popped From Stack: $"
    
    ; Pointer (0-based Index)
    ; TOS (Top Of Stack): Points to the current top element
    ; Initialized to -1 to indicate empty state
    VAR_TOS    DB -1                    
    
    MAX_SIZE   EQU 5                    

; -----------------------------------------------------------------------------
; CODE SEGMENT
; -----------------------------------------------------------------------------
.CODE
MAIN PROC
    ; --- Step 1: Initialize Segment ---
    MOV AX, @DATA
    MOV DS, AX
    
    ; --- Step 2: Stack Operations Demonstration ---
    
    ; Push '1' (31H)
    MOV AL, '1'
    CALL CUSTOM_PUSH
    
    ; Push '2' (32H)
    MOV AL, '2'
    CALL CUSTOM_PUSH
    
    ; Pop (Should be '2')
    CALL CUSTOM_POP
    
    ; Pop (Should be '1')
    CALL CUSTOM_POP
    
    ; Pop (Should trigger Underflow)
    CALL CUSTOM_POP
    
    ; --- Step 3: Shutdown ---
    MOV AH, 4CH
    INT 21H
MAIN ENDP

; -----------------------------------------------------------------------------
; PROCEDURE: CUSTOM_PUSH
; INPUT:  AL = Value to push
; OUTPUT: Updates STACK_BUF and TOS. Prints error if FULL.
; -----------------------------------------------------------------------------
CUSTOM_PUSH PROC
    PUSH AX
    PUSH BX
    
    ; Check Overflow: Is TOS == MAX_SIZE - 1?
    MOV BL, VAR_TOS
    CMP BL, MAX_SIZE - 1
    JE L_STACK_FULL
    
    ; Increment TOS
    INC VAR_TOS
    MOV BL, VAR_TOS
    XOR BH, BH                          ; BX = TOS Index
    
    ; Access original AL value from Stack frame if PUSH AX was first...
    ; Simplification: We pushed AX at start, so [SP+something] is valid,
    ; OR we assume AL is the argument. Let's retrieve argument properly.
    ; Real AL is at [SP+4] (after PUSH AX, PUSH BX).
    ; For this demo, we'll just use the AL that was passed, but we must
    ; POP BX and AX first to get the correct AL if we want to be clean.
    ; But wait, 'AL' is the input register. Pushing AX saves it, but we
    ; want to USE it.
    
    ; Better logic:
    POP BX
    POP AX                              ; Restore Argument AL
    PUSH AX
    PUSH BX
    
    MOV STACK_BUF[BX], AL
    
    ; Feedback
    PUSH AX
    LEA DX, MSG_PUSH
    MOV AH, 09H
    INT 21H
    POP AX
    
    MOV DL, AL
    MOV AH, 02H
    INT 21H
    
    JMP L_PUSH_EXIT

L_STACK_FULL:
    LEA DX, MSG_FULL
    MOV AH, 09H
    INT 21H

L_PUSH_EXIT:
    POP BX
    POP AX
    RET
CUSTOM_PUSH ENDP

; -----------------------------------------------------------------------------
; PROCEDURE: CUSTOM_POP
; OUTPUT: Prints value. Decrements TOS. Prints error if EMPTY.
; -----------------------------------------------------------------------------
CUSTOM_POP PROC
    PUSH AX
    PUSH BX
    
    ; Check Underflow: Is TOS == -1?
    MOV BL, VAR_TOS
    CMP BL, -1
    JE L_STACK_EMPTY
    
    ; Retrieve Value
    XOR BH, BH
    MOV AL, STACK_BUF[BX]
    
    ; Decrement TOS
    DEC VAR_TOS
    
    ; Feedback
    PUSH AX
    LEA DX, MSG_POP
    MOV AH, 09H
    INT 21H
    POP AX
    
    MOV DL, AL
    MOV AH, 02H
    INT 21H
    
    JMP L_POP_EXIT

L_STACK_EMPTY:
    LEA DX, MSG_EMPTY
    MOV AH, 09H
    INT 21H

L_POP_EXIT:
    POP BX
    POP AX
    RET
CUSTOM_POP ENDP

END MAIN

; =============================================================================
; TECHNICAL NOTES & ARCHITECTURAL INSIGHTS
; =============================================================================
; 1. STACK PRINCIPLE (LIFO):
;    The Stack operates on "Last-In, First-Out". The element inserted most 
;    recently is the first one to be removed. This is crucial for:
;    - Function calls (saving return addresses).
;    - Local variables.
;    - Interrupt handling.
;
; 2. HARDWARE VS SOFTWARE STACK:
;    - Hardware Stack (SS:SP): Manipulated by PUSH/POP instructions directly. 
;      Grows downwards in memory (High -> Low address).
;    - Software Stack (This Program): Custom array implementation. We chose 
;      to let it grow upwards (Indices 0 -> 4) for intuitive array indexing.
;
; 3. BOUNDARY CONDITIONS:
;    - Overflow: Pushing when TOS = MAX - 1.
;    - Underflow: Popping when TOS = -1.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
