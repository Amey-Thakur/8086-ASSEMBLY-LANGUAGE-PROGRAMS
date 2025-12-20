;=============================================================================
; Program:     DOS Buffered String Input
; Description: Read a full string from the keyboard into a designated buffer
;              using DOS Interrupt 21H, Function 0AH.
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
    PROMPT DB 'Enter your name: $'
    
    ; Buffered Input Structure for AH=0Ah:
    ; Byte 0: Maximum number of characters to read (including Enter)
    ; Byte 1: Number of characters actually read (filled by DOS)
    ; Byte 2+: Actual character data
    BUFFER DB 50                         ; Max input size (49 chars + CR)
           DB ?                          ; Actual size (output from DOS)
           DB 50 DUP('$')                ; Initialized with $ for easy display
           
    NEWLINE DB 0DH, 0AH, '$'
    MSG DB 'Hello, $'

;-----------------------------------------------------------------------------
; CODE SEGMENT
;-----------------------------------------------------------------------------
.CODE
MAIN PROC
    ; Initialize Data Segment
    MOV AX, @DATA
    MOV DS, AX
    
    ; Display prompt
    LEA DX, PROMPT
    MOV AH, 09H
    INT 21H
    
    ;-------------------------------------------------------------------------
    ; READ BUFFERED STRING (INT 21H, AH=0AH)
    ; Input: DS:DX points to the buffer structure
    ;-------------------------------------------------------------------------
    LEA DX, BUFFER
    MOV AH, 0AH                         ; DOS service: buffered input
    INT 21H
    
    ; Move to next line for clean output
    LEA DX, NEWLINE
    MOV AH, 09H
    INT 21H
    
    ; Display Greeting
    LEA DX, MSG
    MOV AH, 09H
    INT 21H
    
    ;-------------------------------------------------------------------------
    ; DISPLAY INPUTTED STRING
    ; Data starts at offset +2 of the buffer used for AH=0Ah.
    ; Since we initialized with '$', we can print it directly.
    ;-------------------------------------------------------------------------
    LEA DX, BUFFER+2
    MOV AH, 09H
    INT 21H
    
    ; Exit safely
    MOV AH, 4CH
    INT 21H
MAIN ENDP
END MAIN

;=============================================================================
; BUFFERED INPUT NOTES:
; - AH=0Ah allows users to use Backspace to correct typing errors.
; - The input ends when the 'Enter' key (0Dh) is pressed.
; - Byte 1 of the buffer will contain the actual number of characters typed,
;   excluding the Carriage Return (0Dh).
; - The 0Dh char is always appended to the end of the input string in memory.
;=============================================================================
