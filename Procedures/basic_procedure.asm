;=============================================================================
; Program:     Basic Procedure Execution
; Description: Demonstrate the use of subroutines to avoid code duplication
;              for repetitive tasks like numeric scaling.
; 
; Author:      Amey Thakur
; Repository:  https://github.com/Amey-Thakur/8086-ASSEMBLY-LANGUAGE-PROGRAMS
; License:     MIT License
;=============================================================================

ORG 100H                            ; Standard COM entry point

;-----------------------------------------------------------------------------
; MAIN EXECUTION FLOW
;-----------------------------------------------------------------------------
START:
    MOV AL, 01H                         ; Initial value
    MOV BL, 02H                         ; Scaling factor

    ; Repeatedly double the value in AL by invoking the M2 procedure
    CALL M2                             ; AL = 2
    CALL M2                             ; AL = 4
    CALL M2                             ; AL = 8
    CALL M2                             ; AL = 16

    ; Return back to the shell
    RET

;-----------------------------------------------------------------------------
; SUBROUTINE: M2
; Description: Multiplies AL by BL. Result returns in AX.
;-----------------------------------------------------------------------------
M2 PROC
    MUL BL                              ; Multiply accumulator by BL
    RET                                 ; Jump back to the caller (POP IP)
M2 ENDP

END

;=============================================================================
; SUBROUTINE NOTES:
; - Procedures (Procs) encapsulate reusable logic.
; - The 'CALL' instruction pushes the IP (Instruction Pointer) onto the stack.
; - The 'RET' instruction pops that address back into the IP to resume flow.
; - This reduces the binary size compared to inline macro expansion.
;=============================================================================
