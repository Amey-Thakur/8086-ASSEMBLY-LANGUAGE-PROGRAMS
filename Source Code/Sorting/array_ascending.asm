; =============================================================================
; TITLE: Array Ascending Sort
; DESCRIPTION: Implementation of an exchange-based sorting algorithm to 
;              arrange a given byte array in ascending order.
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
    ARR   DB 8, 2, 7, 4, 3               ; Target array
    LIMIT EQU 5                          ; Array size
    MSG   DB 'Array successfully sorted in Ascending order.$'

; -----------------------------------------------------------------------------
; CODE SEGMENT
; -----------------------------------------------------------------------------
.CODE
START:
    ; Register initialization
    MOV AX, @DATA
    MOV DS, AX
    
    MOV CX, LIMIT                       ; Setup outer loop counter (N)
    DEC CX                              ; Need N-1 passes

    ; -------------------------------------------------------------------------
    ; OUTER BUBBLE PASS
    ; -------------------------------------------------------------------------
OUTER_PASS:
    PUSH CX                             ; Save outer counter
    LEA SI, ARR                         ; Reset pointer to start of array
    
    ; -------------------------------------------------------------------------
    ; INNER COMPARISON LOOP
    ; -------------------------------------------------------------------------
INNER_COMPARE:
    MOV AL, [SI]                        ; Get current element
    CMP AL, [SI+1]                      ; Compare with next neighbor
    JLE SKIP_SWAP                       ; If AL <= Next, no swap needed
    
    ; Perform the Swap
    XCHG AL, [SI+1]
    MOV [SI], AL

SKIP_SWAP:
    INC SI                              ; Move to next pair
    LOOP INNER_COMPARE                  ; Repeat CX times for this pass
    
    POP CX                              ; Restore outer counter
    LOOP OUTER_PASS                     ; Start next pass
    
    ; Output Result Message
    LEA DX, MSG
    MOV AH, 09H
    INT 21H
    
    ; Terminal exit
    MOV AH, 4CH
    INT 21H

END START

; =============================================================================
; TECHNICAL NOTES
; =============================================================================
; 1. ALGORITHM:
;    - Standard Bubble Sort.
;    - Complexity: O(N^2). Suitable for very small datasets only.
;    - In-place: No additional memory used outside the original array.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
