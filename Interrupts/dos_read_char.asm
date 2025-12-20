;=============================================================================
; Program:     DOS Read Character
; Description: Read a single character from the keyboard with echo
;              using DOS Interrupt 21H, Function 01H.
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
    MSG1 DB 'Press any key: $'
    MSG2 DB 0DH, 0AH, 'You pressed: $'
    CHAR DB ?                           ; Storage for input

;-----------------------------------------------------------------------------
; CODE SEGMENT
;-----------------------------------------------------------------------------
.CODE
MAIN PROC
    ; Initialize Data Segment
    MOV AX, @DATA
    MOV DS, AX
    
    ; Display user prompt
    LEA DX, MSG1
    MOV AH, 09H
    INT 21H
    
    ;-------------------------------------------------------------------------
    ; READ CHARACTER WITH ECHO (INT 21H, AH=01H)
    ; Wait for key, display it on screen, and return ASCII in AL.
    ; Returns: AL = ASCII character
    ;-------------------------------------------------------------------------
    MOV AH, 01H                         ; DOS service: read with echo
    INT 21H
    MOV CHAR, AL                         ; Save char for later use
    
    ; Display confirmation message
    LEA DX, MSG2
    MOV AH, 09H
    INT 21H
    
    ; Display the character again using AH=02h
    MOV DL, CHAR
    MOV AH, 02H
    INT 21H
    
    ; Exit program
    MOV AH, 4CH
    INT 21H
MAIN ENDP
END MAIN

;=============================================================================
; DOS KEYBOARD INPUT NOTES:
; - AH=01h is a blocking call (program waits for user).
; - 'With Echo' means the typed character automatically appears on screen.
; - AL contains 0 if a special key (like an arrow key) was pressed;
;   another call to AH=01h or 07h or 08h is then needed to get the scan code.
;=============================================================================
