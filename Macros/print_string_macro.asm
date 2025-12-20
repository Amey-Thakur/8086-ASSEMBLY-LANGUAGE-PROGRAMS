;=============================================================================
; Program:     Standard String Macro
; Description: Simplify console output using macros for string display
;              and newline management.
; 
; Author:      Amey Thakur
; Repository:  https://github.com/Amey-Thakur/8086-ASSEMBLY-LANGUAGE-PROGRAMS
; License:     MIT License
;=============================================================================

.MODEL SMALL
.STACK 100H

;-----------------------------------------------------------------------------
; MACRO DEFINITIONS
;-----------------------------------------------------------------------------

; Macro: PRINT_STR
; Encapsulates LEA and DOS INT 21H for $-terminated strings.
PRINT_STR MACRO STRING_LABEL
    LEA DX, STRING_LABEL
    MOV AH, 09H
    INT 21H
ENDM

; Macro: NEWLINE
; Encapsulates ASCII 13 (CR) and 10 (LF) output.
NEWLINE MACRO
    MOV DL, 0DH                     ; Carriage Return
    MOV AH, 02H
    INT 21H
    MOV DL, 0AH                     ; Line Feed
    MOV AH, 02H
    INT 21H
ENDM

;-----------------------------------------------------------------------------
; DATA SEGMENT
;-----------------------------------------------------------------------------
.DATA
    MSG1 DB 'Message One: Hello from Macro Logic!$'
    MSG2 DB 'Message Two: Macros reduce repetitive code.$'
    MSG3 DB 'Message Three: Assembly programming made easier.$'

;-----------------------------------------------------------------------------
; CODE SEGMENT
;-----------------------------------------------------------------------------
.CODE
MAIN PROC
    ; Initialize DS
    MOV AX, @DATA
    MOV DS, AX
    
    ; Clean execution flow using macros
    PRINT_STR MSG1
    NEWLINE
    
    PRINT_STR MSG2
    NEWLINE
    
    PRINT_STR MSG3
    
    ; Exit back to DOS
    MOV AH, 4CH
    INT 21H
MAIN ENDP
END MAIN

;=============================================================================
; MACRO VS PROCEDURE COMPARISON:
; Feature    | Macros                   | Procedures
; -----------|--------------------------|---------------------------
; Expansion  | At compilation time      | At execution time
; Code Size  | Increases with each use  | Constant
; Speed      | Faster (no CALL/RET)     | Slower overhead
; Arguments  | Generic/Flexible         | Via registers or stack
;=============================================================================
