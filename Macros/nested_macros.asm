;=============================================================================
; Program:     Nested Macros Implementation
; Description: Demonstrate macro nesting (macros calling other macros) 
;              and the 'LOCAL' directive to prevent label collision.
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

; Base Macro: PRINT_CHAR
; Simply displays the character provided in parameter.
PRINT_CHAR MACRO CHAR
    MOV DL, CHAR
    MOV AH, 02H
    INT 21H
ENDM

; Intermediate Macro: PRINT_LINE (Nested)
; Uses PRINT_CHAR inside a loop.
PRINT_LINE MACRO CHAR, COUNT
    LOCAL LINE_LOOP                 ; Mandatory for multiple expansions
    MOV CX, COUNT
LINE_LOOP:
    PRINT_CHAR CHAR                 ; Call basic macro
    LOOP LINE_LOOP
ENDM

; Top-level Macro: PRINT_BORDER
; Calls PRINT_LINE and PRINT_CHAR to draw a full separator with newline.
PRINT_BORDER MACRO
    PRINT_LINE '*', 40              ; Draw 40 asterisks
    PRINT_CHAR 0DH                  ; Carriage Return
    PRINT_CHAR 0AH                  ; Line Feed
ENDM

;-----------------------------------------------------------------------------
; DATA SEGMENT
;-----------------------------------------------------------------------------
.DATA
    MSG DB 'Nested Macros Demonstration Layout$'

;-----------------------------------------------------------------------------
; CODE SEGMENT
;-----------------------------------------------------------------------------
.CODE
MAIN PROC
    MOV AX, @DATA
    MOV DS, AX
    
    ; Usage of top-level macro
    PRINT_BORDER
    
    LEA DX, MSG
    MOV AH, 09H
    INT 21H
    
    ; Manual Newline
    PRINT_CHAR 0DH
    PRINT_CHAR 0AH
    
    ; Re-use top-level macro
    PRINT_BORDER
    
    ; Return control
    MOV AH, 4CH
    INT 21H
MAIN ENDP
END MAIN

;=============================================================================
; NESTING AND LOCAL NOTES:
; - LOCAL Directive: Every time the macro expands, the assembler generates
;   a unique name (like ??0001) for the label to avoid "Duplicate Label" errors.
; - Nesting allows for building complex code templates from simple primitives.
; - Deep nesting can make debugging difficult as the code expands massively.
;=============================================================================
