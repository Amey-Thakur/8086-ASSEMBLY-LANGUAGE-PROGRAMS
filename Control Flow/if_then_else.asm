;=============================================================================
; Program:     If-Then-Else Structure
; Description: Implement high-level if-then-else logic in assembly.
;              Shows how to translate conditional statements.
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
    NUM DW 75                           ; Student score
    THRESHOLD DW 50                     ; Passing threshold
    MSG_PASS DB 'Result: PASS$'
    MSG_FAIL DB 'Result: FAIL$'

;-----------------------------------------------------------------------------
; CODE SEGMENT
; 
; High-level equivalent:
;   if (NUM >= THRESHOLD)
;       print "PASS"
;   else
;       print "FAIL"
;-----------------------------------------------------------------------------
.CODE
MAIN PROC
    ; Initialize Data Segment
    MOV AX, @DATA
    MOV DS, AX
    
    ;-------------------------------------------------------------------------
    ; IF Condition: Compare NUM with THRESHOLD
    ;-------------------------------------------------------------------------
    MOV AX, NUM                         ; AX = 75
    CMP AX, THRESHOLD                   ; Compare with 50
    
    ;-------------------------------------------------------------------------
    ; Branch based on condition
    ; JGE: Jump if Greater or Equal (signed)
    ;-------------------------------------------------------------------------
    JGE PASS_BLOCK                      ; If NUM >= 50, jump to PASS
    
    ;-------------------------------------------------------------------------
    ; ELSE Block (executed if condition is FALSE)
    ;-------------------------------------------------------------------------
    LEA DX, MSG_FAIL                    ; Load "FAIL" message
    JMP ENDIF                           ; Skip THEN block
    
PASS_BLOCK:
    ;-------------------------------------------------------------------------
    ; THEN Block (executed if condition is TRUE)
    ;-------------------------------------------------------------------------
    LEA DX, MSG_PASS                    ; Load "PASS" message
    
ENDIF:
    ;-------------------------------------------------------------------------
    ; Display Result (common exit point)
    ;-------------------------------------------------------------------------
    MOV AH, 09H
    INT 21H
    
    ;-------------------------------------------------------------------------
    ; Program Termination
    ;-------------------------------------------------------------------------
    MOV AH, 4CH                         ; DOS: Terminate program
    INT 21H
MAIN ENDP
END MAIN

;=============================================================================
; IF-THEN-ELSE PATTERN IN ASSEMBLY
;=============================================================================
; 
; High-level:          Assembly equivalent:
; -----------------    ---------------------
; if (condition)       CMP operand1, operand2
;     then_block       Jcc ELSE_BLOCK     ; Jump if condition FALSE
;                      ; then_block code
; else                 JMP ENDIF
;     else_block   ELSE_BLOCK:
; endif                ; else_block code
;                  ENDIF:
; 
; Note: The conditional jump is for the OPPOSITE condition!
; if (A >= B)  =>  JL ELSE_BLOCK (jump if less)
; if (A == B)  =>  JNE ELSE_BLOCK (jump if not equal)
;=============================================================================
