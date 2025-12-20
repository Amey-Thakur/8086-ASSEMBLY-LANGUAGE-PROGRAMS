;=============================================================================
; Program:     Procedure Demo (Basic)
; Description: Demonstrate defining and calling a basic procedure using 
;              CALL and RET instructions in a COM-style program.
; 
; Author:      Amey Thakur
; Repository:  https://github.com/Amey-Thakur/8086-ASSEMBLY-LANGUAGE-PROGRAMS
; License:     MIT License
;=============================================================================

ORG 100H                            ; Start of COM program

;-----------------------------------------------------------------------------
; MAIN CODE SECTION
;-----------------------------------------------------------------------------
START:
    CALL M1                         ; Call the procedure M1

    MOV AX, 2                       ; Resume execution here after M1 returns

    RET                             ; Return control to the operating system

;-----------------------------------------------------------------------------
; PROCEDURE: M1
; Description: A simple procedure that sets the BX register.
;-----------------------------------------------------------------------------
M1 PROC
    MOV BX, 5                       ; Perform some work
    RET                             ; Return to the instruction after CALL
M1 ENDP

END

;=============================================================================
; PROCEDURE NOTES:
; - 'CALL' pushes the address of the next instruction (IP) onto the stack.
; - 'RET' pops the saved address back into the IP to return control.
; - Procedures help in breaking down complex tasks into manageable blocks.
;=============================================================================
