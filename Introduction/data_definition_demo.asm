; =============================================================================
; TITLE: data_definition_demo.asm
; DESCRIPTION: Demonstrates how the assembler interprets data as instructions.
;              These raw hex bytes correspond exactly to the MOV and RET logic
;              found in mov_instruction_demo.asm.
; AUTHOR: Amey Thakur (https://github.com/Amey-Thakur)
; REPOSITORY: https://github.com/Amey-Thakur/8086-ASSEMBLY-LANGUAGE-PROGRAMS
; LICENSE: MIT License
; =============================================================================

ORG 100H

; -----------------------------------------------------------------------------
; EXECUTABLE BYTES
; -----------------------------------------------------------------------------

; Opcode A0: MOV AL, [addr]
DB 0A0H
DB 08H                              ; Low byte of offset 0108h
DB 01H                              ; High byte of offset (Segment is same)

; Opcode 8B 1E: MOV BX, [addr]
DB 8BH
DB 1EH
DB 09H                              ; Low byte of offset 0109h
DB 01H                              ; High byte of offset

; Opcode C3: RET
DB 0C3H

; -----------------------------------------------------------------------------
; DATA BYTES (Starts at offset 0108h)
; -----------------------------------------------------------------------------

DB 7                                ; Equivalent to VAR1 DB 7

; Equivalent to VAR2 DW 1234H (Stored in Little-Endian: 34h, 12h)
DB 34H
DB 12H

END

; =============================================================================
; TECHNICAL NOTES
; =============================================================================
; 1. MACHINE CODE:
;    - This file shows that there is no fundamental difference between code
;      and data in memory except for where the Instruction Pointer (IP) points.
;    - 'DB' allows programmers to write raw opcodes if the assembler doesn't 
;      support a specific instruction.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
