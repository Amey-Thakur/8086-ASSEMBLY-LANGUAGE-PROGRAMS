;=============================================================================
; Program:     MOV Instruction Demo
; Description: Demonstrate the MOV instruction for transferring data between
;              memory variables and CPU registers.
; 
; Author:      Amey Thakur
; Repository:  https://github.com/Amey-Thakur/8086-ASSEMBLY-LANGUAGE-PROGRAMS
; License:     MIT License
;=============================================================================

ORG 100H                            ; COM file entry point

;-----------------------------------------------------------------------------
; MAIN CODE SECTION
;-----------------------------------------------------------------------------
START:
    ; Copy value from memory variable VAR1 (8-bit) into AL register
    MOV AL, VAR1                    ; AL = 7
    
    ; Copy value from memory variable VAR2 (16-bit) into BX register
    MOV BX, VAR2                    ; BX = 1234H

    ; Program termination
    RET                             ; Soft exit (return to DOS)

;-----------------------------------------------------------------------------
; DATA DEFINITIONS (Stored within the code segment for COM files)
;-----------------------------------------------------------------------------
VAR1 DB 7                           ; Define Byte (8-bit)
VAR2 DW 1234H                       ; Define Word (16-bit)

END

;=============================================================================
; MOV INSTRUCTION NOTES:
; - MOV destination, source
; - Rules:
;   1. Cannot move from memory to memory directly.
;   2. Cannot move immediate value into a segment register directly.
;   3. Source and destination must be the same size.
;=============================================================================
