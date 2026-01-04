; =============================================================================
; TITLE: Nested Procedure Calls
; DESCRIPTION: Demonstrate procedural hierarchy where one subroutine calls 
;              another, showcasing the stack's LIFO nature for return addresses.
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
    NUM     DW 10
    RESULT  DW ?
    MSG     DB 'Success: Nested procedure hierarchy executed.$'

; -----------------------------------------------------------------------------
; CODE SEGMENT
; -----------------------------------------------------------------------------
.CODE

; Level 2: Inner Procedure
; Just doubles the number in AX.
DOUBLE_AX PROC
    SHL AX, 1                           ; Fast multiply by 2
    RET
DOUBLE_AX ENDP

; Level 1: Outer Procedure
; Performs a quadruple operation by calling the double routine twice.
QUADRUPLE_AX PROC
    CALL DOUBLE_AX                      ; 1st level nest
    CALL DOUBLE_AX                      ; 1st level nest
    RET
QUADRUPLE_AX ENDP

; Entry Point
MAIN PROC
    ; Initialize environment
    MOV AX, @DATA
    MOV DS, AX
    
    ; Use the procedural logic: 10 * 4 = 40
    MOV AX, NUM
    CALL QUADRUPLE_AX
    MOV RESULT, AX
    
    ; Confirmation message
    LEA DX, MSG
    MOV AH, 09H
    INT 21H
    
    ; Exit
    MOV AH, 4CH
    INT 21H
MAIN ENDP

END MAIN

; =============================================================================
; TECHNICAL NOTES
; =============================================================================
; 1. NESTING:
;    - Each 'CALL' adds an entry to the hardware stack.
;    - Inner procedures must always return (RET) before the outer procedures
;      can resume their work.
;    - There is no limit to nesting depth other than the available stack memory.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
