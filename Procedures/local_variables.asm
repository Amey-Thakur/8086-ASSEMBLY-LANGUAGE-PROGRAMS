; Program: Procedure with Local Variables
; Description: Procedure using stack for local variables
; Author: Amey Thakur

.MODEL SMALL
.STACK 100H

.DATA
    NUM1 DW 100
    NUM2 DW 50
    RESULT DW ?

.CODE
; Procedure to calculate (a + b) * 2
; Uses BP for stack frame
CALCULATE PROC
    PUSH BP
    MOV BP, SP
    SUB SP, 2        ; Allocate local variable
    
    ; [BP-2] = local variable (temp sum)
    MOV AX, [BP+4]   ; First parameter
    ADD AX, [BP+6]   ; Add second parameter
    MOV [BP-2], AX   ; Store in local variable
    
    ; Multiply by 2
    MOV AX, [BP-2]
    SHL AX, 1
    
    MOV SP, BP       ; Deallocate local variables
    POP BP
    RET 4            ; Clean up parameters
CALCULATE ENDP

MAIN PROC
    MOV AX, @DATA
    MOV DS, AX
    
    PUSH NUM1        ; Push first parameter
    PUSH NUM2        ; Push second parameter
    CALL CALCULATE   ; Call procedure
    MOV RESULT, AX   ; Store result (300)
    
    MOV AH, 4CH      ; Exit to DOS
    INT 21H
MAIN ENDP
END MAIN
