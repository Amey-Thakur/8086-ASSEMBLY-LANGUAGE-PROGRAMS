;=============================================================================
; Program:     DOS Display String
; Description: Demonstrate how to display a $-terminated string using 
;              DOS Interrupt 21H, Function 09H.
; 
; Author:      Amey Thakur
; Repository:  https://github.com/Amey-Thakur/8086-ASSEMBLY-LANGUAGE-PROGRAMS
; License:     MIT License
;=============================================================================

.MODEL SMALL
.STACK 100H

;-----------------------------------------------------------------------------
; DATA SEGMENT
;-----------------------------------------------------------------------------
.DATA
    ; Note: Strings for AH=09h MUST end with the '$' character.
    MSG DB 'Hello, 8086 Assembly World!', 0DH, 0AH, '$'

;-----------------------------------------------------------------------------
; CODE SEGMENT
;-----------------------------------------------------------------------------
.CODE
MAIN PROC
    ; Initialize Data Segment
    MOV AX, @DATA
    MOV DS, AX
    
    ;-------------------------------------------------------------------------
    ; DISPLAY STRING (INT 21H, AH=09H)
    ; Input: AH = 09H
    ;        DS:DX = Pointer to $-terminated string
    ;-------------------------------------------------------------------------
    LEA DX, MSG                         ; Get offset of the string
    MOV AH, 09H                         ; DOS service: display string
    INT 21H                             ; Call DOS
    
    ; Exit safely
    MOV AH, 4CH
    INT 21H
MAIN ENDP
END MAIN

;=============================================================================
; DOS STRING OUTPUT NOTES:
; - This function is convenient but limited: it cannot print the '$' character.
; - 0Dh is Carriage Return (moves cursor to start of line).
; - 0Ah is Line Feed (moves cursor to next line).
; - Always ensure DS correctly points to the segment containing the string.
;=============================================================================
