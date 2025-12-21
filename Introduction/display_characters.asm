; =============================================================================
; TITLE: Display Characters
; DESCRIPTION: Demonstrate character-by-character output using DOS services.
;              Useful for building dynamic text in loops.
; AUTHOR: Amey Thakur (https://github.com/Amey-Thakur)
; REPOSITORY: https://github.com/Amey-Thakur/8086-ASSEMBLY-LANGUAGE-PROGRAMS
; LICENSE: MIT License
; =============================================================================

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

; =============================================================================
; TECHNICAL NOTES
; =============================================================================
; 1. OUTPUT:
;    - INT 21H Function 02H is the standard way to print single characters.
;    - It supports ASCII control characters (e.g., Tab, Backspace).
;    - Character in DL is echoed to standard output.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
