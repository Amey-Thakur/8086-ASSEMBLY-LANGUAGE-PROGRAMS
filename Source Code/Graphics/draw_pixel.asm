; =============================================================================
; TITLE: Plot Single Pixel
; DESCRIPTION: Basic graphics primitive: plotting a single dot on the screen
;              at coordinates (X, Y) in Mode 13h.
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
    PIXEL_X     DW 160                  ; Center X
    PIXEL_Y     DW 100                  ; Center Y
    PIXEL_COL   DB 15                   ; White (15)

; -----------------------------------------------------------------------------
; CODE SEGMENT
; -----------------------------------------------------------------------------
.CODE
MAIN PROC
    ; --- Step 1: Initialize DS ---
    MOV AX, @DATA
    MOV DS, AX

    ; --- Step 2: Enter Mode 13h ---
    MOV AX, 0013H
    INT 10H

    ; --- Step 3: Setup ES ---
    MOV AX, 0A000H
    MOV ES, AX

    ; --- Step 4: Calculate Offset ---
    ; Offset = 320 * Y + X
    MOV AX, PIXEL_Y
    MOV BX, 320
    MUL BX
    ADD AX, PIXEL_X
    MOV DI, AX

    ; --- Step 5: Plot Pixel ---
    MOV AL, PIXEL_COL
    MOV ES:[DI], AL                     ; Write color byte to VRAM

    ; --- Step 6: Wait & Exit ---
    MOV AH, 00H
    INT 16H

    MOV AX, 0003H                       ; Restore Text Mode
    INT 10H

    MOV AH, 4CH
    INT 21H
MAIN ENDP
END MAIN

; =============================================================================
; TECHNICAL NOTES & ARCHITECTURAL INSIGHTS
; =============================================================================
; 1. COORDINATE SYSTEM:
;    - (0,0) is top-left.
;    - (319, 199) is bottom-right.
;    - Any write outside 0-63999 offset will wrap or corrupt other video pages 
;      (if available), but in Mode 13h it's usually safe within 64KB segment.
;
; 2. BIOS PLOT (INT 10h AH=0Ch):
;    We avoided INT 10h/AH=0Ch here because it is very slow compared to 
;    direct memory writing shown above.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
