;=============================================================================
; Program:     DOS Display Character
; Description: Demonstrate how to display a single ASCII character on the 
;              screen using DOS Interrupt 21H, Function 02H.
; 
; Author:      Amey Thakur
; Repository:  https://github.com/Amey-Thakur/8086-ASSEMBLY-LANGUAGE-PROGRAMS
; License:     MIT License
;=============================================================================

.MODEL SMALL
.STACK 100H

;-----------------------------------------------------------------------------
; CODE SEGMENT
;-----------------------------------------------------------------------------
.CODE
MAIN PROC
    ;-------------------------------------------------------------------------
    ; DISPLAY CHARACTER (INT 21H, AH=02H)
    ; Input: AH = 02H
    ;        DL = ASCII character to display
    ; Output: AL is set to DL value
    ;-------------------------------------------------------------------------
    MOV DL, 'A'                         ; Character to display
    MOV AH, 02H                         ; DOS service: display char
    INT 21H                             ; Call DOS
    
    ; Terminate program
    MOV AH, 4CH
    INT 21H
MAIN ENDP
END MAIN

;=============================================================================
; DOS CHARACTER OUTPUT NOTES:
; - Function 02H is the simplest way to print one byte.
; - It supports control characters like 0Dh (Carriage Return) and 0Ah (Line Feed).
; - The hardware cursor moves forward by one position after display.
;=============================================================================
