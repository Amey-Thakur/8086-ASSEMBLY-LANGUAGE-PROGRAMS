;=============================================================================
; Program:     BIOS Video Mode Setup
; Description: Demonstrate how to use BIOS Interrupt 10H to switch between
;              text and graphics video modes.
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
    ; SET VIDEO MODE (INT 10H, AH=00H)
    ; Input: AL = Desired video mode
    ;-------------------------------------------------------------------------
    MOV AH, 00H                         ; BIOS service: set mode
    MOV AL, 03H                         ; Standard 80x25 Color Text
    INT 10H                             ; Call BIOS
    
    ; Terminates the program immediately
    MOV AH, 4CH
    INT 21H
MAIN ENDP
END MAIN

;=============================================================================
; COMMON VIDEO MODES REFERENCE:
; Mode | Type     | Resolution | Colors | Notes
; -----|----------|------------|--------|-------------------------------------
; 00h  | Text     | 40x25      | B/W    | Large characters
; 01h  | Text     | 40x25      | 16     | 
; 02h  | Text     | 80x25      | B/W    | 
; 03h  | Text     | 80x25      | 16     | Standard DOS text mode
; 04h  | Graphics | 320x200    | 4      | CGA four color mode
; 12h  | Graphics | 640x480    | 16     | VGA standard graphics
; 13h  | Graphics | 320x200    | 256    | Popular for 8-bit games
;=============================================================================
