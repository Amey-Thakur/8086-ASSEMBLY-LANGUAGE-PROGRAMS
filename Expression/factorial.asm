;=============================================================================
; Program:     Factorial using Recursion
; Description: Compute factorial of a positive integer using recursive
;              procedure. Demonstrates stack-based recursion.
; 
; Author:      Amey Thakur
; Repository:  https://github.com/Amey-Thakur/8086-ASSEMBLY-LANGUAGE-PROGRAMS
; License:     MIT License
;=============================================================================

;-----------------------------------------------------------------------------
; DATA SEGMENT
;-----------------------------------------------------------------------------
DATA SEGMENT
    NUM DW 0006H                        ; Calculate 6! = 720
    FACT DW ?                           ; Low word of result
DATA ENDS

ASSUME CS:CODE, DS:DATA

;-----------------------------------------------------------------------------
; CODE SEGMENT
;-----------------------------------------------------------------------------
CODE SEGMENT

START: 
       ; Initialize Data Segment
       MOV AX, DATA
       MOV DS, AX
       
       ; Initialize result to 1
       MOV AX, 01H
       MOV BX, NUM                      ; BX = 6
       
       ; Check for 0! = 1
       CMP BX, 0000H
       JZ X1
       
       ; Call recursive factorial procedure
       CALL FACT1

X1:    
       ; Store result
       MOV FACT, AX                     ; Store low word
       MOV FACT+2, DX                   ; Store high word (for large results)
       
       ; Exit to DOS
       MOV AH, 4CH
       INT 21H
       
;-----------------------------------------------------------------------------
; FACT1: Recursive Factorial Procedure
; Input: BX = current number, AX = accumulated result
; Output: DX:AX = factorial result
; Algorithm: n! = n * (n-1)!
;-----------------------------------------------------------------------------
FACT1 PROC
    ; Base case: 1! = 1
    CMP BX, 01H
    JZ BASE_CASE
    
    ; Recursive case: n! = n * (n-1)!
    PUSH BX                             ; Save current n
    DEC BX                              ; n = n - 1
    CALL FACT1                          ; Recursive call
    POP BX                              ; Restore n
    MUL BX                              ; DX:AX = AX * BX
    RET
    
BASE_CASE:
    MOV AX, 01H                         ; Return 1
    RET
FACT1 ENDP

CODE ENDS
END START

;=============================================================================
; FACTORIAL NOTES:
; - n! = n × (n-1) × (n-2) × ... × 2 × 1
; - 0! = 1 (by definition)
; - Recursion uses stack to save intermediate values
; - Example: 6! = 720 (2D0H)
; - Maximum for 16-bit: 7! = 5040, 8! = 40320 (needs 32-bit)
;=============================================================================
