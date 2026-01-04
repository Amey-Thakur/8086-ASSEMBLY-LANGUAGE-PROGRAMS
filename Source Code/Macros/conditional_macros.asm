; =============================================================================
; TITLE: Conditional Assembly Macros
; DESCRIPTION: Demonstrates the use of IF/ELSE/ENDIF conditional directives 
;              within macros to handle different data types (Byte vs Word).
; AUTHOR: Amey Thakur (https://github.com/Amey-Thakur)
; REPOSITORY: https://github.com/Amey-Thakur/8086-ASSEMBLY-LANGUAGE-PROGRAMS
; LICENSE: MIT License
; =============================================================================

.MODEL SMALL
.STACK 100H

; -----------------------------------------------------------------------------
; MACRO DEFINITIONS
; -----------------------------------------------------------------------------

; Macro: MOVE_DATA
; Logic: Uses TYPE operator to decide whether to generate MOV AL (8-bit)
;        or MOV AX (16-bit) machine code during assembly.
MOVE_DATA MACRO DEST, SOURCE
    IF (TYPE SOURCE) EQ 1            ; If 'SOURCE' is a Byte
        MOV AL, SOURCE
        MOV DEST, AL
    ELSE                             ; If 'SOURCE' is a Word
        MOV AX, SOURCE
        MOV DEST, AX
    ENDIF
ENDM

; Macro: CHECK_ZERO
; Logic: Conditional jumps within a macro to print status messages.
; Note: 'LOCAL' directive prevents label redefinition errors.
CHECK_ZERO MACRO VALUE, ZERO_MSG, NONZERO_MSG
    LOCAL L_NOT_ZERO, L_DONE        ; Unique labels for each expansion
    
    MOV AX, VALUE
    CMP AX, 0
    JNE L_NOT_ZERO
    LEA DX, ZERO_MSG
    JMP L_DONE
L_NOT_ZERO:
    LEA DX, NONZERO_MSG
L_DONE:
    MOV AH, 09H
    INT 21H
ENDM

; -----------------------------------------------------------------------------
; DATA SEGMENT
; -----------------------------------------------------------------------------
.DATA
    TEST_VAL    DW 0                        ; Value to check
    MSG_ZERO    DB 'Status: Value is zero!$'
    MSG_NONZERO DB 'Status: Value is NOT zero!$'

; -----------------------------------------------------------------------------
; CODE SEGMENT
; -----------------------------------------------------------------------------
.CODE
MAIN PROC
    ; Initialize segment register
    MOV AX, @DATA
    MOV DS, AX
    
    ; Expand the CHECK_ZERO macro
    ; Note: Macro code is literally pasted here by the assembler.
    CHECK_ZERO TEST_VAL, MSG_ZERO, MSG_NONZERO
    
    ; Exit gracefully
    MOV AH, 4CH
    INT 21H
MAIN ENDP
END MAIN

; =============================================================================
; TECHNICAL NOTES
; =============================================================================
; 1. CONDITIONAL ASSEMBLY:
;    - MACROS are expanded at compile-time, not run-time.
;    - 'IF TYPE' allows for "generic" macros that adapt to operand sizes.
;    - The 'LOCAL' directive is critical for any macro containing jumps/labels.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
