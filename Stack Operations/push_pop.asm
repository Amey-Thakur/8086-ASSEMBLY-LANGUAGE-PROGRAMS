;=============================================================================
; Program:     PUSH and POP Mechanics
; Description: Demonstrate the fundamental Last-In-First-Out (LIFO) behavior 
;              of the 8086 hardware stack through register manipulation.
; 
; Author:      Amey Thakur
; Repository:  https://github.com/Amey-Thakur/8086-ASSEMBLY-LANGUAGE-PROGRAMS
; License:     MIT License
;=============================================================================

.MODEL SMALL
.STACK 100H                         ; Allocate 256 bytes for system stack

;-----------------------------------------------------------------------------
; DATA SEGMENT
;-----------------------------------------------------------------------------
.DATA
    MSG DB 'Stack Operations Trace - Observe Registers in Debugger$'

;-----------------------------------------------------------------------------
; CODE SEGMENT
;-----------------------------------------------------------------------------
.CODE
MAIN PROC
    ; Initialize context
    MOV AX, @DATA
    MOV DS, AX
    
    ; 1. PUSH OPERATIONS
    ; Values are added to the stack; SP (Stack Pointer) decrements by 2.
    MOV AX, 1234H
    PUSH AX                         ; Stack Top: 1234H
    
    MOV BX, 5678H
    PUSH BX                         ; Stack Top: 5678H, 1234H
    
    MOV CX, 9ABCH
    PUSH CX                         ; Stack Top: 9ABCH, 5678H, 1234H
    
    ; 2. POP OPERATIONS
    ; Values are removed in reverse order; SP increments by 2.
    POP DX                          ; DX = 9ABCH (Last pushed)
    POP DX                          ; DX = 5678H
    POP DX                          ; DX = 1234H (First pushed)
    
    ; Graceful Exit
    MOV AH, 4CH
    INT 21H
MAIN ENDP
END MAIN

;=============================================================================
; STACK MECHANICS NOTES:
; - The stack grows "downwards" in memory (from higher towards lower addresses).
; - PUSH: Decrements SP by 2, then copies word to [SS:SP].
; - POP: Copies word from [SS:SP], then increments SP by 2.
; - PUSH/POP must operate on 16-bit (Word) operands in 8086.
;=============================================================================
