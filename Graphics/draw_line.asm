;=============================================================================
; Program:     VGA Line Drawing (Mode 13h)
; Description: Demonstrate drawing a horizontal line in 256-color VGA mode
;              by writing directly to video segment 0A000h.
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
    X_START DW 50                       ; Column start
    X_END DW 270                        ; Column end
    Y_POS DW 100                        ; Row position
    COLOR DB 14                         ; Yellow color code

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
    ; Resolution: 320x200 | Colors: 256
    ; Video Segment: 0A000h
    ;-------------------------------------------------------------------------
    MOV AH, 00H
    MOV AL, 13H
    INT 10H
    
    MOV AX, 0A000H
    MOV ES, AX                          ; ES points to graphics memory
    
    ;-------------------------------------------------------------------------
    ; Calculate Linear Memory Address
    ; Address = (Y * 320) + X
    ;-------------------------------------------------------------------------
    MOV AX, Y_POS
    MOV BX, 320
    MUL BX                              ; AX = Y * 320
    ADD AX, X_START                     ; AX = (Y * 320) + X_START
    MOV DI, AX                          ; DI = Start pointer in video segment
    
    ;-------------------------------------------------------------------------
    ; Calculate Line length (Pixels to Draw)
    ;-------------------------------------------------------------------------
    MOV CX, X_END
    SUB CX, X_START                     ; CX = Number of pixels
    
    ;-------------------------------------------------------------------------
    ; Draw Horizontal Line
    ; REP STOSB copies AL to ES:DI, incrementing DI, CX times.
    ;-------------------------------------------------------------------------
    MOV AL, COLOR
    CLD                                 ; Incrementing DI
    REP STOSB
    
    ; Wait for keypress
    MOV AH, 00H
    INT 16H
    
    ; Return to standard 80x25 text mode (Mode 03h)
    MOV AH, 00H
    MOV AL, 03H
    INT 10H
    
    ; Exit to DOS
    MOV AH, 4CH
    INT 21H
MAIN ENDP
END MAIN

;=============================================================================
; VGA MODE 13H NOTES:
; - Memory mapped at 0A000:0000 to 0A000:FA00 approx.
; - Linear address space: 1 pixel = 1 byte.
; - Total Pixels: 320 columns * 200 rows = 64,000 pixels.
; - Color Palette: 256 colors defined by DAC registers.
;=============================================================================
