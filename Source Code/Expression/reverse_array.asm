; =============================================================================
; TITLE: Array Reversal
; DESCRIPTION: Reverses the contents of a byte array. It uses a second buffer 
;              to store the reversed copy. In-place reversal (using XCHG) 
;              is an alternative not demonstrated here.
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
    SRC_ARR     DB 1, 2, 3, 4, 5        ; Original
    DST_ARR     DB 5 DUP(?)             ; Destination
    ARR_LEN     EQU 5

; -----------------------------------------------------------------------------
; CODE SEGMENT
; -----------------------------------------------------------------------------
.CODE
MAIN PROC
    ; --- Step 1: Initialize Data Segment ---
    MOV AX, @DATA
    MOV DS, AX
    MOV ES, AX                          ; ES needed for potential string ops (optional here)
    
    ; --- Step 2: Setup Pointers ---
    LEA SI, SRC_ARR                     ; SI -> Start of Source
    LEA DI, DST_ARR                     ; DI -> Start of Dest
    ADD DI, ARR_LEN - 1                 ; DI -> End of Dest (Reverse fill)
    
    MOV CX, ARR_LEN
    
    ; --- Step 3: Copy Loop ---
REV_LOOP:
    MOV AL, [SI]                        ; Load from Start
    MOV [DI], AL                        ; Store at End
    
    INC SI                              ; Move Forward
    DEC DI                              ; Move Backward
    LOOP REV_LOOP
    
    ; Verification: DST_ARR is now {5, 4, 3, 2, 1}
    
    ; --- Step 4: Exit ---
    MOV AH, 4CH
    INT 21H
MAIN ENDP

END MAIN

; =============================================================================
; TECHNICAL NOTES & ARCHITECTURAL INSIGHTS
; =============================================================================
; 1. POINTER ARITHMETIC:
;    We use two pointers moving in opposite logical directions relative to their 
;    arrays:
;    - SI increments (0 -> N)
;    - DI decrements (N -> 0)
;    This effectively maps Source[i] to Dest[N-1-i].
;
; 2. SEGMENT INITIALIZATION:
;    While this program uses DS for both reads and writes, initializing ES is 
;    good practice if we were using STOSB or MOVSB instructions.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
