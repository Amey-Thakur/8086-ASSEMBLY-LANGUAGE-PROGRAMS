; =============================================================================
; TITLE: Procedure Parameter Passing
; DESCRIPTION: Demonstrate the standard register-based method for 
;              passing arguments to a subroutine.
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
    NUM1   DW 10
    NUM2   DW 20
    RESULT DW ?

; -----------------------------------------------------------------------------
; CODE SEGMENT
; -----------------------------------------------------------------------------
.CODE

; Procedure: ADD_NUMBERS
; Interface: 
;   Input: AX = Operand 1, BX = Operand 2
;   Output: AX = Summation Result
ADD_NUMBERS PROC
    ADD AX, BX                          ; Perform the summation
    RET                                 ; Return to caller
ADD_NUMBERS ENDP

MAIN PROC
    ; Segment setup
    MOV AX, @DATA
    MOV DS, AX
    
    ; Preparing registers for the procedure call
    MOV AX, NUM1                        ; Load first parameter
    MOV BX, NUM2                        ; Load second parameter
    
    CALL ADD_NUMBERS                    ; Invoke the procedure
    MOV RESULT, AX                      ; Store the returned value
    
    ; Return control to DOS
    MOV AH, 4CH
    INT 21H
MAIN ENDP

END MAIN

; =============================================================================
; TECHNICAL NOTES
; =============================================================================
; 1. PARAMETERS:
;    - Passing via registers is the fastest method but limited by register count.
;    - Other methods include passing via Stack (unlimited count) or Global 
;      Variables (low reentrancy/security).
;    - AX is conventionally used to return values to the caller.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
