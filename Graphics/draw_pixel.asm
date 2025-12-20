;=============================================================================
; Program:     VGA Pixel Drawing (Mode 13h)
; Description: Draw a single pixel in the center of the screen in 
;              320x200 256-color graphics mode.
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
    X_POS DW 160                        ; Center column (0-319)
    Y_POS DW 100                        ; Center row (0-199)
    COLOR DB 15                         ; White color code

;-----------------------------------------------------------------------------
; CODE SEGMENT
;-----------------------------------------------------------------------------
.CODE
MAIN PROC
    ; Initialize Data Segment
    MOV AX, @DATA
    MOV DS, AX
    
    ;-------------------------------------------------------------------------
    ; Set VGA Graphics Mode 13h
    ; Resolution: 320x200 pixels
    ; Colors: 256 simultaneous colors
    ;-------------------------------------------------------------------------
    MOV AH, 00H
    MOV AL, 13H
    INT 10H
    
    ;-------------------------------------------------------------------------
    ; Calculate Video Memory Address
    ; Address = (Row * 320) + Column
    ; Segment: 0A000h
    ;-------------------------------------------------------------------------
    MOV AX, Y_POS
    MOV BX, 320
    MUL BX                              ; AX = Y * 320
    ADD AX, X_POS                       ; AX = (Y * 320) + X
    
    ; Set ES to video segment
    MOV BX, 0A000H
    MOV ES, BX
    
    ;-------------------------------------------------------------------------
    ; Plot the Pixel
    ; Direct memory write to ES:[DI]
    ;-------------------------------------------------------------------------
    MOV DI, AX                          ; Offset in video memory
    MOV AL, COLOR                       ; Get color index
    MOV ES:[DI], AL                      ; Write to video memory
    
    ; Wait for user input to see the result
    MOV AH, 00H
    INT 16H
    
    ; Reset back to standard text mode
    MOV AH, 00H
    MOV AL, 03H
    INT 10H
    
    ; Exit to DOS
    MOV AH, 4CH
    INT 21H
MAIN ENDP
END MAIN

;=============================================================================
; VGA PIXEL ADDRESSING:
; - Screen starts at (0,0) (Top-Left) and ends at (319,199) (Bottom-Right).
; - Each byte in segment 0A000h represents one pixel.
; - Color index 15 usually defaults to Bright White in the standard palette.
;=============================================================================
