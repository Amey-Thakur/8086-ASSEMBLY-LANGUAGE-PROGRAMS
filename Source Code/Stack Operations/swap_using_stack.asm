; =============================================================================
; TITLE: Register Swap via Stack
; DESCRIPTION: Demonstrate how to exchange the values of two registers 
;              without using a third temporary register.
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
    VAL1    DW 1111H                     ; Operand A
    VAL2    DW 2222H                     ; Operand B
    MSG     DB 'Registers Swapped using Stack Mechanics.$'

; -----------------------------------------------------------------------------
; CODE SEGMENT
; -----------------------------------------------------------------------------
.CODE
MAIN PROC
    ; Segment Access
    MOV AX, @DATA
    MOV DS, AX
    
    ; Load initial states
    MOV AX, VAL1                        ; AX = 1111H
    MOV BX, VAL2                        ; BX = 2222H
    
    ; -------------------------------------------------------------------------
    ; THE STACK SWAP PATTERN
    ; Logic: PUSH A, PUSH B -> POP A (gets B), POP B (gets A)
    ; -------------------------------------------------------------------------
    PUSH AX                             ; Stack: [1111H]
    PUSH BX                             ; Stack: [2222H, 1111H]
    
    POP AX                              ; AX = 2222H (TOS retrieved)
    POP BX                              ; BX = 1111H
    
    ; Update memory to reflect change
    MOV VAL1, AX
    MOV VAL2, BX
    
    ; Final message
    LEA DX, MSG
    MOV AH, 09H
    INT 21H
    
    ; End Application
    MOV AH, 4CH
    INT 21H
MAIN ENDP
END MAIN

; =============================================================================
; TECHNICAL NOTES
; =============================================================================
; 1. SWAPPING:
;    - This method is safer than the XOR swap for some architectures and 
;      doesn't require an extra GPR (General Purpose Register).
;    - Important: The order of popping MUST be the same as the order of pushing
;      into the DESIRED registers.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
