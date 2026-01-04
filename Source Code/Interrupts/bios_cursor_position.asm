; =============================================================================
; TITLE: BIOS Set Cursor Position
; DESCRIPTION: Demonstrates how to position the text cursor on the screen 
;              using BIOS Interrupt 10H, Function 02H.
; AUTHOR: Amey Thakur (https://github.com/Amey-Thakur)
; REPOSITORY: https://github.com/Amey-Thakur/8086-ASSEMBLY-LANGUAGE-PROGRAMS
; LICENSE: MIT License
; =============================================================================

.MODEL SMALL
.STACK 100H

; -----------------------------------------------------------------------------
; DATA SEGMENT
; -----------------------------------------------------------------------------
.DATA
    MSG_POS     DB "Cursor moved to Row 12, Col 30!$"

; -----------------------------------------------------------------------------
; CODE SEGMENT
; -----------------------------------------------------------------------------
.CODE
MAIN PROC
    ; --- Step 1: Initialize DS ---
    MOV AX, @DATA
    MOV DS, AX

    ; --- Step 2: Set Cursor Position (INT 10h / AH=02h) ---
    ; BH = Page Number (0 for standard text mode)
    ; DH = Row (0-24)
    ; DL = Column (0-79)
    MOV AH, 02H
    MOV BH, 00H
    MOV DH, 12                          ; Row 12 (Middle-ish)
    MOV DL, 30                          ; Column 30
    INT 10H

    ; --- Step 3: Print Message at New Position ---
    LEA DX, MSG_POS
    MOV AH, 09H
    INT 21H

    ; --- Step 4: Exit ---
    MOV AH, 4CH
    INT 21H
MAIN ENDP
END MAIN

; =============================================================================
; TECHNICAL NOTES & ARCHITECTURAL INSIGHTS
; =============================================================================
; 1. BIOS VIDEO SERVICES (INT 10h):
;    The BIOS controls the video hardware directly. Function 02h updates the 
;    cursor position in the video controller's registers.
;
; 2. COORDINATE SYSTEM:
;    - Text mode is typically 80x25.
;    - Top-Left is (0,0).
;    - Bottom-Right is (79,24).
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
