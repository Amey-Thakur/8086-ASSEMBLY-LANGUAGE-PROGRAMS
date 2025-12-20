;=============================================================================
; Program:     Display Characters
; Description: Demonstrate character-by-character output using DOS services.
;              Useful for building dynamic text in loops.
; 
; Author:      Amey Thakur
; Repository:  https://github.com/Amey-Thakur/8086-ASSEMBLY-LANGUAGE-PROGRAMS
; License:     MIT License
;=============================================================================

; Simple segmented structure
CODE SEGMENT
    ASSUME CS:CODE

START:
    ; Load ASCII code for 'a' into DL
    MOV DL, 'a'
    
    ; Select DOS Character Output sub-function
    MOV AH, 02H                     ; AH=02h (Print char in DL)
    
    ; Request DOS interrupt
    INT 21H
    
    ; Terminate program and return to command prompt
    MOV AX, 4C00H                   ; AH=4Ch (Exit), AL=00h (Success)
    INT 21H

CODE ENDS

END START

;=============================================================================
; OUTPUT NOTES:
; - INT 21H Function 02H is the standard way to print single characters.
; - It supports ASCII control characters (e.g., Tab, Backspace).
; - Character in DL is echoed to standard output.
;=============================================================================
