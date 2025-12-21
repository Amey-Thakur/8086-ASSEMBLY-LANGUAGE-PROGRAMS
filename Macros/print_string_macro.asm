; =============================================================================
; TITLE: Standard String Macro
; DESCRIPTION: Encapsulates DOS string display and newline logic into simplistic
;              reusable macros to clean up the main code structure.
; AUTHOR: Amey Thakur (https://github.com/Amey-Thakur)
; REPOSITORY: https://github.com/Amey-Thakur/8086-ASSEMBLY-LANGUAGE-PROGRAMS
; LICENSE: MIT License
; =============================================================================

.MODEL SMALL
.STACK 100H

; -----------------------------------------------------------------------------
; MACRO DEFINITIONS
; -----------------------------------------------------------------------------

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

; -----------------------------------------------------------------------------
; DATA SEGMENT
; -----------------------------------------------------------------------------
.DATA
    MSG1 DB 'Message One: Hello from Macro Logic!$'
    MSG2 DB 'Message Two: Macros reduce repetitive code.$'
    MSG3 DB 'Message Three: Assembly programming made easier.$'

; -----------------------------------------------------------------------------
; CODE SEGMENT
; -----------------------------------------------------------------------------
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

; =============================================================================
; TECHNICAL NOTES
; =============================================================================
; 1. ABSTRACTION:
;    - Macros provide a way to create a "Language within a Language".
;    - PRINT_STR makes the ASM code look almost like invalid C or BASIC, 
;      improving readability for high-level logic.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
