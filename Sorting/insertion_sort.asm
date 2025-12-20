;=============================================================================
; Program:     Insertion Sort
; Description: Sort a byte array using the Insertion Sort algorithm, which
;              is efficient for small data sets and partially sorted arrays.
; 
; Author:      Amey Thakur
; Repository:  https://github.com/Amey-Thakur/8086-ASSEMBLY-LANGUAGE-PROGRAMS
; License:     MIT License
;=============================================================================

.MODEL SMALL
.STACK 100H

;-----------------------------------------------------------------------------
; DATA SEGMENT
;-----------------------------------------------------------------------------
.DATA
    ARR DB 64, 25, 12, 22, 11            ; Example data
    LEN EQU 5
    MSG DB 'Insertion Sort sequence finalized successfully.$'

;-----------------------------------------------------------------------------
; CODE SEGMENT
;-----------------------------------------------------------------------------
.CODE
MAIN PROC
    ; State init
    MOV AX, @DATA
    MOV DS, AX
    
    MOV CX, LEN - 1                     ; Total passes required
    MOV SI, 1                           ; i = 1 (start with second element)
    
;-------------------------------------------------------------------------
; OUTER LOOP: Pick 'Key' and Compare with Sorted Sub-array
;-------------------------------------------------------------------------
OUTER_PASS:
    PUSH CX
    
    MOV AL, ARR[SI]                     ; Key = Current element
    MOV BX, SI
    DEC BX                              ; j = i - 1
    
;-------------------------------------------------------------------------
; INNER LOOP: Shift elements greater than Key to the right
;-------------------------------------------------------------------------
SHIFT_SEARCH:
    CMP BX, 0                           ; Check if we reached array start
    JL INSERT_NOW
    
    CMP ARR[BX], AL                     ; Compare ARR[j] with Key
    JBE INSERT_NOW                      ; If ARR[j] <= Key, stop shifting
    
    ; SHIFT: ARR[j+1] = ARR[j]
    MOV DL, ARR[BX]
    MOV ARR[BX+1], DL
    
    DEC BX                              ; j = j - 1
    JMP SHIFT_SEARCH

INSERT_NOW:
    ; Place Key in correct position
    MOV ARR[BX+1], AL
    
    INC SI                              ; Move to next element (i++)
    POP CX
    LOOP OUTER_PASS
    
    ; Notification
    LEA DX, MSG
    MOV AH, 09H
    INT 21H
    
    ; Termination
    MOV AH, 4CH
    INT 21H
MAIN ENDP
END MAIN

;=============================================================================
; INSERTION SORT NOTES:
; - Algorithm: Simulates sorting a hand of playing cards.
; - Performance: Excellent for small N.
; - Stability: It is a stable sort (preserves relative order of equal items).
; - O(N) in best case (already sorted), O(N^2) in worst case.
;=============================================================================
