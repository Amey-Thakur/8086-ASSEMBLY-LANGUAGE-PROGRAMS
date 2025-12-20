;=============================================================================
; Program:     Colored Text Demo (Text Mode)
; Description: Demonstrate how to display colored text by directly writing
;              to the video memory segment 0B800h.
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
    MSG DB 'Colored Text Demo!'         ; String to display
    LEN EQU 18                           ; String length

;-----------------------------------------------------------------------------
; CODE SEGMENT
;-----------------------------------------------------------------------------
.CODE
MAIN PROC
    ; Initialize Data Segment
    MOV AX, @DATA
    MOV DS, AX
    
    ;-------------------------------------------------------------------------
    ; Set Video Mode: Standard 80x25 Text Mode (Mode 03h)
    ;-------------------------------------------------------------------------
    MOV AH, 00H
    MOV AL, 03H
    INT 10H
    
    ;-------------------------------------------------------------------------
    ; Access Video Memory
    ; Segment 0B800h is the start of video memory in color text modes.
    ; Each character on screen takes 2 bytes: [Char][Attribute]
    ;-------------------------------------------------------------------------
    MOV AX, 0B800H
    MOV ES, AX
    
    ; Calculate starting address: Row 12, Column 30
    ; Memory Offset = (row * 80 + column) * 2
    MOV DI, (12 * 80 + 30) * 2
    
    ; Setup for loop
    LEA SI, MSG
    MOV CX, LEN                         ; Number of characters
    MOV BL, 0                           ; Starting color counter
    
;-------------------------------------------------------------------------
; DISPLAY LOOP: Write Char and Attribute pair to ES:DI
;-------------------------------------------------------------------------
PRINT_LOOP:
    LODSB                               ; Load character from DS:SI into AL
    MOV ES:[DI], AL                     ; Store ASCII character in video memory
    INC DI
    
    ; Attribute Byte Structure:
    ; Bit 0-3: Foreground color
    ; Bit 4-6: Background color
    ; Bit 7  : Blink (if enabled)
    MOV AL, BL
    AND AL, 0FH                         ; Use foreground colors (0-15)
    OR AL, 10H                          ; Add Blue background (bit 4=1)
    
    MOV ES:[DI], AL                     ; Store attribute in video memory
    INC DI
    
    INC BL                              ; Cycle to next color
    LOOP PRINT_LOOP
    
    ; Wait for user keypress before exit
    MOV AH, 00H
    INT 16H
    
    ; Exit to DOS
    MOV AH, 4CH
    INT 21H
MAIN ENDP
END MAIN

;=============================================================================
; TEXT MODE COLOR REFERENCE (Standard 16 Colors):
; 0: Black      4: Red          8: Dark Grey    12: Light Red
; 1: Blue       5: Magenta      9: Light Blue   13: Light Magenta
; 2: Green      6: Brown        10: Light Green  14: Yellow
; 3: Cyan       7: Light Grey   11: Light Cyan   15: White
;=============================================================================
