;=============================================================================
; Program:     BIOS Set Cursor Position
; Description: Demonstrate how to position the text cursor on the screen 
;              using BIOS Interrupt 10H, Function 02H.
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
    MSG DB 'Cursor positioned at row 10, column 20!$'

;-----------------------------------------------------------------------------
; CODE SEGMENT
;-----------------------------------------------------------------------------
.CODE
MAIN PROC
    ; Initialize Data Segment
    MOV AX, @DATA
    MOV DS, AX
    
    ;-------------------------------------------------------------------------
    ; SET CURSOR POSITION (INT 10H, AH=02H)
    ; Input: AH = 02H
    ;        BH = Page number (usually 0)
    ;        DH = Row (0 to 24)
    ;        DL = Column (0 to 79)
    ;-------------------------------------------------------------------------
    MOV AH, 02H                         ; BIOS service: set cursor
    MOV BH, 00H                         ; Page number 0
    MOV DH, 10                          ; Target Row
    MOV DL, 20                          ; Target Column
    INT 10H                             ; Call Video BIOS
    
    ; Display message starting at the new cursor position
    LEA DX, MSG
    MOV AH, 09H                         ; DOS service: display string
    INT 21H
    
    ; Exit to DOS
    MOV AH, 4CH
    INT 21H
MAIN ENDP
END MAIN

;=============================================================================
; BIOS VIDEO NOTES:
; - INT 10H is the primary interface for screen operations.
; - AH=02H moves the hardware cursor, which also updates the location 
;   where the next DOS 'display string' (INT 21H/09H) will appear.
; - Coordinates are zero-indexed: (0,0) is the top-left corner.
;=============================================================================
