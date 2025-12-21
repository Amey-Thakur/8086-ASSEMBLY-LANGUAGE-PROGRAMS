; =============================================================================
; TITLE: Binary Search Algorithm
; DESCRIPTION: Implementation of Binary Search on a sorted array of 16-bit 
;              unsigned integers.
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
    ; Sorted array of elements
    ARR         DW 0005H, 0111H, 2161H, 4541H, 7161H, 8231H
    LIMIT       DW 6                     ; Number of elements
    TARGET      EQU 4541H                ; Search key
    
    MSG_FOUND   DB 'Element found at 1-based index: $'
    POS         DB ' _rd Position','$'
    MSG_FAIL    DB 'Element not found in the array.$'

; -----------------------------------------------------------------------------
; CODE SEGMENT
; -----------------------------------------------------------------------------
.CODE
START:
    MOV AX, @DATA
    MOV DS, AX
    
    MOV BX, 0                           ; Left pointer (Low)
    MOV DX, LIMIT                       ; Right pointer (High)
    DEC DX                              ; Index is 0 to (N-1)
    
    MOV CX, TARGET                      ; Value to search for

    ; -------------------------------------------------------------------------
    ; BINARY SEARCH LOOP
    ; Logic: While (Low <= High)
    ; -------------------------------------------------------------------------
SEARCH_LOOP:
    CMP BX, DX                          ; Check range
    JA NOT_FOUND                        ; If Low > High, target is absent
    
    ; Mid = (Low + High) / 2
    MOV AX, BX
    ADD AX, DX
    SHR AX, 1                           ; Result in AX (Mid index)
    
    ; Calculate offset: Address = BASE + (Mid * 2)
    MOV SI, AX
    SHL SI, 1                           ; Multiply by 2 for Word array
    
    ; Comparison
    CMP CX, ARR[SI]                     ; Compare target with ARR[Mid]
    JE  ELEMENT_FOUND                   ; Exact match
    JA  GO_RIGHT                        ; If Target > ARR[Mid], search right half
    
    ; GO_LEFT: High = Mid - 1
    DEC AX
    MOV DX, AX
    JMP SEARCH_LOOP

GO_RIGHT:
    ; Low = Mid + 1
    INC AX
    MOV BX, AX
    JMP SEARCH_LOOP

    ; -------------------------------------------------------------------------
    ; RESULT HANDLING
    ; -------------------------------------------------------------------------
ELEMENT_FOUND:
    ; Convert 0-based index in AX to 1-based display digit
    ADD AL, 1
    ADD AL, '0'                         ; Numerical to ASCII
    MOV POS, AL
    
    LEA DX, MSG_FOUND
    MOV AH, 09H
    INT 21H
    
    LEA DX, POS
    MOV AH, 09H
    INT 21H
    JMP FINISH

NOT_FOUND:
    LEA DX, MSG_FAIL
    MOV AH, 09H
    INT 21H

FINISH:
    MOV AH, 4CH
    INT 21H

END START

; =============================================================================
; TECHNICAL NOTES
; =============================================================================
; 1. ALGORITHM:
;    - Array must be pre-sorted for binary search to work.
;    - Complexity: O(log N). Much faster than linear search for large datasets.
;    - This implementation uses the SHL technique for fast index scaling.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =