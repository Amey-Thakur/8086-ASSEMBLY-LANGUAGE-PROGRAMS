; =============================================================================
; TITLE: Array Element Deletion via Left-Shift Compaction
; DESCRIPTION: This program demonstrates how to delete an element from a 
;              sequential array by shifting all subsequent elements one 
;              position to the left. It illustrates precise pointer manipulation 
;              and loop-based data displacement in the 8086 architecture.
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

    ; Labels for the register report at the end of the program.
    RPT_HEAD DB 0DH, 0AH, 'Registers when the program finished:', 0DH, 0AH, '$'
    RPT_N_AX DB '  AX = ', '$'
    RPT_N_BX DB '   BX = ', '$'
    RPT_N_CX DB '   CX = ', '$'
    RPT_N_DX DB '   DX = ', '$'
    RPT_NL   DB 0DH, 0AH, '$'
    ; Original Array Buffer
    DATA_ARRAY DB 10H, 20H, 30H, 40H, 50H     
    
    ; Setup Properties
    ARRAY_SIZE EQU 5                           
    DELETE_POS EQU 2                    ; 0-based index of element to delete (30H)

; -----------------------------------------------------------------------------
; CODE SEGMENT
; -----------------------------------------------------------------------------
.CODE
MAIN PROC
    ; --- Step 1: Initialize Data Segment ---
    MOV AX, @DATA
    MOV DS, AX
    
    ; --- Step 2: Pointer Setup for Data Movement ---
    ; To delete at index 2, we must move elements from [3] to [2], [4] to [3], etc.
    
    ; DI (Destination) points to the "hole" created by deletion.
    LEA DI, DATA_ARRAY                  
    ADD DI, DELETE_POS                  ; DI = Offset(DATA_ARRAY) + 2
    
    ; SI (Source) points to the element that will fill the hole.
    MOV SI, DI                          
    INC SI                              ; SI = Offset(DATA_ARRAY) + 3
    
    ; --- Step 3: Calculate Shift Count ---
    ; Number of shifts = Total Elements - 1 - Deletion Position
    MOV CX, ARRAY_SIZE - 1              
    SUB CX, DELETE_POS                  ; CX = 5 - 1 - 2 = 2 iterations
    
    ; --- Step 4: Iterative Shifting Loop ---
COMPACT_ARRAY:
    ; Copy element from SI to DI
    MOV AL, [SI]                        
    MOV [DI], AL                        
    
    ; Increment pointers for next pair
    INC SI                              
    INC DI                              
    
    LOOP COMPACT_ARRAY                  ; CX--, branch if CX > 0
    
    ; --- Step 5: Nullify Trailing Element ---
    ; After shifting, the last element remains duplicated at the end.
    ; We clear it to maintain array integrity.
    MOV BYTE PTR [DI], 00H              
    
    ; Verification: DATA_ARRAY is now {10H, 20H, 40H, 50H, 00H}.
    
    ; --- Step 6: Shutdown ---
; -------------------------------------------------------------------------
    ; WHAT THIS PROGRAM COMPUTED
    ;
    ; The work above leaves its answer in the registers. Printing them is what
    ; makes the program demonstrate itself rather than needing a debugger to be
    ; believed.
    ; -------------------------------------------------------------------------
    CALL RPT_REGISTERS

        MOV AH, 4CH                         
    INT 21H
MAIN ENDP

; -----------------------------------------------------------------------------
; RPT_DECIMAL
;
; Prints the unsigned value in AX as decimal. Named apart from anything the
; program already had, so this report cannot clash with it.
; -----------------------------------------------------------------------------
RPT_DECIMAL PROC
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX

    XOR CX, CX
    MOV BX, 10

RPT_SPLIT:
    XOR DX, DX
    DIV BX
    PUSH DX
    INC CX
    CMP AX, 0
    JNE RPT_SPLIT

RPT_EMIT:
    POP DX
    ADD DL, '0'
    MOV AH, 02H
    INT 21H
    LOOP RPT_EMIT

    POP DX
    POP CX
    POP BX
    POP AX
    RET
RPT_DECIMAL ENDP

; -----------------------------------------------------------------------------
; RPT_SAY
;
; Prints the dollar terminated string at DS:DX, leaving AX alone.
; -----------------------------------------------------------------------------
RPT_SAY PROC
    PUSH AX
    MOV AH, 09H
    INT 21H
    POP AX
    RET
RPT_SAY ENDP

; -----------------------------------------------------------------------------
; RPT_REGISTERS
;
; Prints the four general registers as they were on entry.
;
; They are pushed first and read back off, because printing needs AX for the
; value and DX for the message: reading them any later would report the state of
; the printer rather than the state of the program.
; -----------------------------------------------------------------------------
RPT_REGISTERS PROC
    PUSH DX
    PUSH CX
    PUSH BX
    PUSH AX

    PUSH BP
    MOV BP, SP

    LEA DX, RPT_HEAD
    CALL RPT_SAY

    LEA DX, RPT_N_AX
    CALL RPT_SAY
    MOV AX, [BP+2]
    CALL RPT_DECIMAL

    LEA DX, RPT_N_BX
    CALL RPT_SAY
    MOV AX, [BP+4]
    CALL RPT_DECIMAL

    LEA DX, RPT_N_CX
    CALL RPT_SAY
    MOV AX, [BP+6]
    CALL RPT_DECIMAL

    LEA DX, RPT_N_DX
    CALL RPT_SAY
    MOV AX, [BP+8]
    CALL RPT_DECIMAL

    LEA DX, RPT_NL
    CALL RPT_SAY

    POP BP

    POP AX
    POP BX
    POP CX
    POP DX
    RET
RPT_REGISTERS ENDP


END MAIN

; =============================================================================
; TECHNICAL NOTES & ARCHITECTURAL INSIGHTS
; =============================================================================
; 1. ARRAY COMPACTION LOGIC:
;    Static arrays in memory do not have a "delete" instruction. Deletion 
;    is logically achieved by overwriting the target value with its successor 
;    and shifting all following values. This ensures the array remains 
;    contiguous for subsequent operations like search or sum.
;
; 2. TIME COMPLEXITY (O(N)):
;    In the worst case (deleting the first element), the program must shift 
;    N-1 elements. In the best case (deleting the last element), 0 shifts 
;    are required. This is a classic example of linear time complexity in 
;    memory operations.
;
; 3. POINTER SYNCHRONIZATION:
;    The program uses SI and DI as "sliding windows." Synchronizing their 
;    increments is critical; if they drift, the data will be corrupted or 
;    shifted into incorrect memory segments.
;
; 4. BYTE PTR OVERRIDE:
;    The 'MOV BYTE PTR [DI], 00H' instruction uses a size override. This is 
;    necessary because a raw constant (00H) does not convey whether we are 
;    clearing a byte, word, or double-word at the address in DI.
;
; 5. BOUNDS SAFETY:
;    A production-grade implementation would first check if DELETE_POS is 
;    greater than or equal to ARRAY_SIZE to prevent "Buffer Overflow" 
;    vulnerabilities where data outside the array is shifted into it.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
