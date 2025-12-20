;=============================================================================
; Program:     VGA Rectangle Drawing (Mode 13h)
; Description: Draw a filled rectangle in VGA mode by iterating through
;              rows and using REP STOSB for efficient filling.
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
    X1 DW 50                            ; Left column
    Y1 DW 50                            ; Top row
    X2 DW 150                           ; Right column
    Y2 DW 100                           ; Bottom row
    COLOR DB 12                         ; Light Red color code

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
    ;-------------------------------------------------------------------------
    MOV AH, 00H
    MOV AL, 13H
    INT 10H
    
    ; Set ES to video segment (0A000h)
    MOV AX, 0A000H
    MOV ES, AX
    
    ;-------------------------------------------------------------------------
    ; Calculate Dimensions
    ;-------------------------------------------------------------------------
    MOV DX, Y2
    SUB DX, Y1                          ; DX = Height (number of rows)
    
    MOV BX, X2
    SUB BX, X1                          ; BX = Width (pixels per row)
    
    ; Start at first row
    MOV AX, Y1
    
;-------------------------------------------------------------------------
; MAIN DRAWING LOOP: Iterate through rows
;-------------------------------------------------------------------------
DRAW_ROW:
    PUSH AX
    PUSH DX                             ; Save row counter
    
    ; Calculate offset for current row: (Y * 320) + X1
    MOV DX, 320
    MUL DX                              ; DX:AX = Y * 320
    ADD AX, X1                          ; AX = start of current row
    MOV DI, AX                          ; DI points to row start in ES
    
    ; Draw the row scanline
    MOV CX, BX                          ; Width of rectangle
    MOV AL, COLOR                       ; Fill color
    CLD                                 ; Increment DI
    REP STOSB                           ; Write row pixels
    
    POP DX                              ; Restore row counter
    POP AX                              ; Restore current Y
    
    INC AX                              ; Move to next row
    DEC DX                              ; Decrement height counter
    JNZ DRAW_ROW                        ; Continue until height=0
    
    ;-------------------------------------------------------------------------
    ; Cleanup and Exit
    ;-------------------------------------------------------------------------
    ; Wait for keypress
    MOV AH, 00H
    INT 16H
    
    ; Return to text mode
    MOV AH, 00H
    MOV AL, 03H
    INT 10H
    
    ; Exit to DOS
    MOV AH, 4CH
    INT 21H
MAIN ENDP
END MAIN

;=============================================================================
; RECTANGLE DRAWING NOTES:
; - Instead of plotting pixel-by-pixel, we use 'REP STOSB' for each row.
; - This is significantly faster as it utilizes dedicated string instructions.
; - To draw an outlined rectangle, one would draw four individual lines.
;=============================================================================
