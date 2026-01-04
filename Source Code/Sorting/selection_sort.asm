; =============================================================================
; TITLE: Selection Sort
; DESCRIPTION: Implementation of Selection Sort algorithm for an 8-bit
;              byte array.
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
    ARR DB 64, 25, 12, 22, 11            ; Input Data
    LEN EQU 5
    MSG DB 'Selection Sort execution finished.$'

; -----------------------------------------------------------------------------
; CODE SEGMENT
; -----------------------------------------------------------------------------
.CODE
MAIN PROC
    ; Segment registers
    MOV AX, @DATA
    MOV DS, AX
    
    ; Selection Sort Procedure:
    ; Repeatedly find the minimum element in the unsorted part
    ; and swap it with the first unsorted element.
    
    MOV CX, LEN - 1                     ; Outer loop counter (passes)
    XOR SI, SI                          ; SI = current boundary (i)
    
    ; -------------------------------------------------------------------------
    ; OUTER BATCH LOOP
    ; -------------------------------------------------------------------------
OUTER_PASS:
    PUSH CX
    
    MOV DI, SI                          ; min_idx = i
    MOV BX, SI
    INC BX                              ; j = i + 1
    
    ; Calculate inner loop limit: (Length - 1 - i)
    MOV AX, LEN
    SUB AX, SI
    DEC AX
    MOV CX, AX
    JZ CHECK_SWAP                       ; If no neighbors left, skip search
    
    ; -------------------------------------------------------------------------
    ; INNER MINIMUM FINDER
    ; -------------------------------------------------------------------------
SEARCH_MIN:
    MOV AL, ARR[BX]
    CMP AL, ARR[DI]                     ; If current < current_min
    JAE NOT_NEW_MIN
    MOV DI, BX                          ; Update min_idx
    
NOT_NEW_MIN:
    INC BX                              ; Next element
    LOOP SEARCH_MIN

CHECK_SWAP:
    ; Swap ARR[i] with ARR[min_idx]
    CMP DI, SI
    JE NO_SWAP                          ; Skip if current is already the min
    
    MOV AL, ARR[SI]
    MOV DL, ARR[DI]
    MOV ARR[SI], DL
    MOV ARR[DI], AL
    
NO_SWAP:
    INC SI                              ; Move boundary to right
    POP CX
    LOOP OUTER_PASS                     ; Repeat for remaining elements
    
    ; Final display
    LEA DX, MSG
    MOV AH, 09H
    INT 21H
    
    ; Exit code
    MOV AH, 4CH
    INT 21H
MAIN ENDP
END MAIN

; =============================================================================
; TECHNICAL NOTES
; =============================================================================
; 1. SELECTION SORT:
;    - Selection sort never makes more than O(N) swaps, which is beneficial 
;      if the write operation is expensive.
;    - Total comparisons: O(N^2).
;    - Simple to implement but not adaptive (same work regardless of initial order).
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
