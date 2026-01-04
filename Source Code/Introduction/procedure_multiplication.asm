; =============================================================================
; TITLE: Reusable Multiplication Procedure
; DESCRIPTION: Demonstrate multiple calls to a single multiplication procedure
;              that uses registers for parameter passing.
; AUTHOR: Amey Thakur (https://github.com/Amey-Thakur)
; REPOSITORY: https://github.com/Amey-Thakur/8086-ASSEMBLY-LANGUAGE-PROGRAMS
; LICENSE: MIT License
; =============================================================================

ORG 100H                            ; Start of COM program

; -----------------------------------------------------------------------------
; MAIN CODE SECTION
; -----------------------------------------------------------------------------
START:
    MOV AL, 1                       ; Initial value
    MOV BL, 2                       ; Multiplier

    ; Repeatedly double the value in AL by calling PROC_MUL
    CALL PROC_MUL                   ; AL = 1 * 2 = 2
    CALL PROC_MUL                   ; AL = 2 * 2 = 4
    CALL PROC_MUL                   ; AL = 4 * 2 = 8
    CALL PROC_MUL                   ; AL = 8 * 2 = 16

    RET                             ; Return to OS

; -----------------------------------------------------------------------------
; PROCEDURE: PROC_MUL
; Description: Multiplies AL by BL. Result stored in AX.
; -----------------------------------------------------------------------------
PROC_MUL PROC
    MUL BL                          ; AX = AL * BL
    RET                             ; Return to caller
PROC_MUL ENDP

END

; =============================================================================
; TECHNICAL NOTES
; =============================================================================
; 1. CODE REUSE:
;    - Defining logic once (e.g. math operations) and calling it repeatedly
;      reduces code size (drastically in larger programs).
;    - 'MUL source' performs unsigned multiplication.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
