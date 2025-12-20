;=============================================================================
; Program:     Search Element in Array (Debugger Trace)
; Description: Basic linear search on an immediate array using indexed 
;              addressing and debug traps (INT 3).
; 
; Author:      Amey Thakur
; Repository:  https://github.com/Amey-Thakur/8086-ASSEMBLY-LANGUAGE-PROGRAMS
; License:     MIT License
;=============================================================================

DATA SEGMENT
    STRING1 DB 11H, 22H, 33H, 44H, 55H    ; Data bytes
    TARGET  DB 33H                        ; Target element
    
    MSG1    DB "STATUS: ELEMENT FOUND!$"
    MSG2    DB "STATUS: ELEMENT NOT FOUND!$"
DATA ENDS

;-----------------------------------------------------------------------------
; MACROS
;-----------------------------------------------------------------------------
PRINT_RESULT MACRO MSG
    LEA DX, MSG
    MOV AH, 09H
    INT 21H
ENDM

;-----------------------------------------------------------------------------
; CODE SEGMENT
;-----------------------------------------------------------------------------
CODE SEGMENT
    ASSUME CS:CODE, DS:DATA

START:
    ; Setup segments
    MOV AX, DATA
    MOV DS, AX
    
    MOV AL, TARGET                      ; Target byte to search for
    LEA SI, STRING1                     ; Start of array
    MOV CX, 5                           ; Process 5 elements
    
;-------------------------------------------------------------------------
; SEARCH LOGIC
;-------------------------------------------------------------------------
SEARCH_UP:
    MOV BL, [SI]                        ; Get byte from memory at SI
    CMP AL, BL                          ; Compare with TARGET
    JZ FOUND_EXIT                       ; If Zero (Equal), jump to success
    
    INC SI                              ; Move to next memory location
    DEC CX                              ; Decrement counter
    JNZ SEARCH_UP                       ; Loop if CX > 0
    
    ; Case: Element not found
    PRINT_RESULT MSG2
    JMP TERMINATE

;-------------------------------------------------------------------------
; FOUND HANDLER
;-------------------------------------------------------------------------
FOUND_EXIT:
    PRINT_RESULT MSG1

TERMINATE:
    ; INT 3 is a breakpoint. It invokes the CPU's debug trap handler.
    ; This allows inspection of registers at this exact state.
    INT 3                               
    
    ; Graceful Exit
    MOV AH, 4CH
    INT 21H

CODE ENDS
END START

;=============================================================================
; DEBUGGER NOTES:
; - 'INT 3' launches the debugger in most tools (like DEBUG.EXE or CodeView).
; - Indexed addressing [SI] is used here to traverse the raw memory block.
; - This is the most fundamental 'Find' logic in low-level programming.
;=============================================================================
