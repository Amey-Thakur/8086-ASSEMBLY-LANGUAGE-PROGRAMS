; =============================================================================
; TITLE: BIOS Set Video Mode
; DESCRIPTION: Demonstrates how to switch video modes via BIOS (INT 10h).
;              Switches to 80x25 Color Text Mode (Mode 03h).
; AUTHOR: Amey Thakur (https://github.com/Amey-Thakur)
; REPOSITORY: https://github.com/Amey-Thakur/8086-ASSEMBLY-LANGUAGE-PROGRAMS
; LICENSE: MIT License
; =============================================================================

.MODEL SMALL
.STACK 100H

; -----------------------------------------------------------------------------
; CODE SEGMENT
; -----------------------------------------------------------------------------
.CODE
MAIN PROC
    ; --- Step 1: Set Video Mode (INT 10h / AH=00h) ---
    ; AL = Video Mode
    ; 03h = 80x25 Text (Color) - Default DOS Mode
    ; 13h = 320x200 Graphics (256 Colors)
    MOV AH, 00H
    MOV AL, 03H
    INT 10H

    ; --- Step 2: Exit ---
    ; Note: Switching modes typically clears the screen.
    MOV AH, 4CH
    INT 21H
MAIN ENDP
END MAIN

; =============================================================================
; TECHNICAL NOTES & ARCHITECTURAL INSIGHTS
; =============================================================================
; 1. VIDEO MODES:
;    - Mode 03h: Standard Text Mode (80 columns, 25 rows).
;    - Mode 13h: VGA Graphics (320x200).
;
; 2. SIDE EFFECTS:
;    Setting the video mode resets the video controller, clears video memory, 
;    resets the cursor to (0,0), and loads the default font. It is the standard 
;    way to "Clear Screen".
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
