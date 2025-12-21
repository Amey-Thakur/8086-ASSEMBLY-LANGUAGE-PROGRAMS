; =============================================================================
; TITLE: Nested Macros Implementation
; DESCRIPTION: Demonstrates macro nesting (macros calling other macros) 
;              and the 'LOCAL' directive to prevent label collision.
; AUTHOR: Amey Thakur (https://github.com/Amey-Thakur)
; REPOSITORY: https://github.com/Amey-Thakur/8086-ASSEMBLY-LANGUAGE-PROGRAMS
; LICENSE: MIT License
; =============================================================================

.MODEL SMALL
.STACK 100H

; -----------------------------------------------------------------------------
; MACRO DEFINITIONS
; -----------------------------------------------------------------------------

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
    LOCAL L_LOOP                    ; Mandatory for multiple expansions
    MOV CX, COUNT
L_LOOP:
    PRINT_CHAR CHAR                 ; Call basic macro
    LOOP L_LOOP
ENDM

; Top-level Macro: PRINT_BORDER
; Calls PRINT_LINE and PRINT_CHAR to draw a full separator with newline.
PRINT_BORDER MACRO
    PRINT_LINE '*', 40              ; Draw 40 asterisks
    PRINT_CHAR 0DH                  ; Carriage Return
    PRINT_CHAR 0AH                  ; Line Feed
ENDM

; -----------------------------------------------------------------------------
; DATA SEGMENT
; -----------------------------------------------------------------------------
.DATA
    MSG DB 'Nested Macros Demonstration Layout$'

; -----------------------------------------------------------------------------
; CODE SEGMENT
; -----------------------------------------------------------------------------
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

; =============================================================================
; TECHNICAL NOTES
; =============================================================================
; 1. NESTING & LOCAL:
;    - LOCAL Directive: Every time the macro expands, the assembler generates
;      a unique name (like ??0001) for the label.
;    - Nesting allows for building complex code templates from primitives.
;    - Too much nesting makes debugging harder due to massive code expansion.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
