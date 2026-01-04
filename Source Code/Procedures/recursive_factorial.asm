; =============================================================================
; TITLE: Recursive Factorial
; DESCRIPTION: Calculate the factorial of a 16-bit number (n!) using 
;              a recursive procedure call.
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
    NUM    DW 5                         ; Target number
    RESULT DW ?                         ; Buffer for 120 (5!)

; -----------------------------------------------------------------------------
; CODE SEGMENT
; -----------------------------------------------------------------------------
.CODE

; Procedure: FACTORIAL (Recursive)
; Logic: 
;   IF n <= 1 RETURN 1
;   ELSE RETURN n * FACTORIAL(n-1)
FACTORIAL PROC
    ; Base Condition check
    CMP AX, 1
    JLE BASE_CASE                       ; If AX <= 1, return 1
    
    ; Recursive step
    PUSH AX                             ; Save current 'n' on stack
    DEC AX                              ; AX = n - 1
    
    CALL FACTORIAL                      ; Recursion: find (n-1)!
                                        ; Result of (n-1)! returns in AX
    
    POP BX                              ; Recover current 'n' into BX
    MUL BX                              ; AX = (n-1)! * n
    
    RET                                 ; Go up one level in recursion
    
BASE_CASE:
    MOV AX, 1                           ; 1! = 1
    RET
FACTORIAL ENDP

MAIN PROC
    ; Environment setup
    MOV AX, @DATA
    MOV DS, AX
    
    MOV AX, NUM                         ; Start with input '5'
    CALL FACTORIAL                      ; Compute 5!
    MOV RESULT, AX                      ; Final result: 120
    
    ; Application Exit
    MOV AH, 4CH
    INT 21H
MAIN ENDP

END MAIN

; =============================================================================
; TECHNICAL NOTES
; =============================================================================
; 1. RECURSION:
;    - Recursion in 8086 depends heavily on the Stack for saving return
;      addresses and local state (registers).
;    - Risk: "Stack Overflow" if the recursion is too deep.
;    - This implementation uses the register AX to pass and return values.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
