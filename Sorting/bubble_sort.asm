; =============================================================================
; TITLE: Bubble Sort (16-bit)
; DESCRIPTION: Implementation of Bubble Sort algorithm for a set of 
;              unsigned 16-bit word integers.
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
    ; Word array (DW)
    A   DW 0005H, 0ABCDH, 5678H, 1234H, 0EFCDH, 45EFH
    NUM EQU 6                           ; Total count of words
    MSG DB 'Word-sized Bubble Sort completed.$'

; -----------------------------------------------------------------------------
; CODE SEGMENT
; -----------------------------------------------------------------------------
.CODE
START:
    ; Context setup
    MOV AX, @DATA
    MOV DS, AX
    
    MOV BX, NUM                         ; Load count
    DEC BX                              ; N-1 comparisons per pass

    ; -------------------------------------------------------------------------
    ; BUBBLE SORT OPERATION
    ; -------------------------------------------------------------------------
PASS_LOOP:
    MOV CX, BX                          ; Inner loop counter
    LEA SI, A                           ; Reset SI for each new pass
    
SWAP_INNER:
    MOV AX, [SI]                        ; Load current Word
    CMP AX, [SI+2]                      ; Compare with next Word (+2 byte offset)
    JBE NO_EXCH                         ; If AX <= Next, continue
    
    ; Exchange contents
    XCHG AX, [SI+2]
    MOV [SI], AX

NO_EXCH:
    ADD SI, 2                           ; Move to next Word address
    LOOP SWAP_INNER                     ; Repeat for this pass
    
    DEC BX                              ; Optimization: one less comparison next time
    JNZ PASS_LOOP                       ; Repeat until done
    
    ; Result output
    LEA DX, MSG
    MOV AH, 09H
    INT 21H
    
    ; End process
    MOV AH, 4CH
    INT 21H

END START

; =============================================================================
; TECHNICAL NOTES
; =============================================================================
; 1. DATA SIZE:
;    - This version handles 16-bit data (Words). SI increments by 2 accordingly.
;    - Bubble sort derives its name from smaller values "bubbling" to the surface.
;    - Average and worst-case complexity: O(N^2).
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
