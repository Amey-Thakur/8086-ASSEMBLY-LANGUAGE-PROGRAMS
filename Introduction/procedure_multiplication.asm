;=============================================================================
; Program:     Procedure Multiplication
; Description: Demonstrate multiple calls to a multiplication procedure
;              that uses registers for parameter passing.
; 
; Author:      Amey Thakur
; Repository:  https://github.com/Amey-Thakur/8086-ASSEMBLY-LANGUAGE-PROGRAMS
; License:     MIT License
;=============================================================================

ORG 100H                            ; Start of COM program

;-----------------------------------------------------------------------------
; MAIN CODE SECTION
;-----------------------------------------------------------------------------
START:
    MOV AL, 1                       ; Initial value
    MOV BL, 2                       ; Multiplier

    ; Repeatedly double the value in AL by calling M2
    CALL M2                         ; AL = 1 * 2 = 2
    CALL M2                         ; AL = 2 * 2 = 4
    CALL M2                         ; AL = 4 * 2 = 8
    CALL M2                         ; AL = 8 * 2 = 16

    RET                             ; Return to OS

;-----------------------------------------------------------------------------
; PROCEDURE: M2
; Description: Multiplies AL by BL. Result stored in AX.
;-----------------------------------------------------------------------------
M2 PROC
    MUL BL                          ; AX = AL * BL
    RET                             ; Return to caller
M2 ENDP

END

;=============================================================================
; MULTIPLICATION NOTES:
; - 'MUL source' performs unsigned multiplication.
; - For 8-bit MUL, result is stored in AX.
; - Reusing the same procedure reduces code size and improves readability.
;=============================================================================
