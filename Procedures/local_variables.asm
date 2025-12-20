;=============================================================================
; Program:     Procedure with Local Variables
; Description: Demonstrate the standard way to allocate and use local 
;              variables on the stack using the Base Pointer (BP) register.
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
    NUM1   DW 100
    NUM2   DW 50
    RESULT DW ?

;-----------------------------------------------------------------------------
; CODE SEGMENT
;-----------------------------------------------------------------------------
.CODE

; Procedure: CALCULATE
; Logic: Result = (Param1 + Param2) * 2
; Strategy: Stack-based parameters and local variable storage.
CALCULATE PROC
    ; Standard Activation Record Prologue
    PUSH BP                             ; Save caller's BP
    MOV BP, SP                          ; Establish new stack frame
    
    ; Allocate 2 bytes for a local variable [BP-2]
    SUB SP, 2        
    
    ; 1. Access Parameters from stack:
    ; [BP+0] = Old BP
    ; [BP+2] = Return Address (IP)
    ; [BP+4] = Param 2 (50) - Smallest offset since it was pushed last
    ; [BP+6] = Param 1 (100)
    
    MOV AX, [BP+6]                      ; Get first parameter
    ADD AX, [BP+4]                      ; Add second parameter
    
    ; 2. Store in Local Variable
    MOV [BP-2], AX                      ; temp_sum = AX
    
    ; 3. Perform operation using local variable
    MOV AX, [BP-2]
    SHL AX, 1                           ; AX = temp_sum * 2
    
    ; Standard Epilogue
    MOV SP, BP                          ; Deallocate local variable space
    POP BP                              ; Restore caller's BP
    
    RET 4                               ; Return and popup 4 bytes of params
CALCULATE ENDP

MAIN PROC
    ; State setup
    MOV AX, @DATA
    MOV DS, AX
    
    ; Passing parameters via Stack
    PUSH NUM1                           ; Push 1st param (100)
    PUSH NUM2                           ; Push 2nd param (50)
    
    CALL CALCULATE                      ; Execute our logic
    MOV RESULT, AX                      ; Result expected: 300
    
    ; Return to DOS
    MOV AH, 4CH
    INT 21H
MAIN ENDP

END MAIN

;=============================================================================
; STACK FRAME NOTES:
; - BP (Base Pointer) is the anchor for accessing both local variables 
;   (negative offset) and parameters (positive offset).
; - 'SUB SP, N' creates space for local variables on the stack.
; - 'RET N' is used for the "Pascal Calling Convention" to clean up the 
;   stack by the callee.
;=============================================================================
