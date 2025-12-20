;=============================================================================
; Program:     File Writing
; Description: Demonstrate creating a file and writing a text string to it
;              using DOS INT 21H interrupts.
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
    FILENAME DB 'OUTPUT.TXT', 0         ; Target filename
    CONTENT DB 'Hello from 8086 Assembly!', 0DH, 0AH
    CONTENT_LEN EQU $ - CONTENT          ; Calculate precise data length
    HANDLE DW ?
    MSG_SUCCESS DB 'Data written successfully to OUTPUT.TXT!$'
    MSG_ERROR DB 'Error performing file operation!$'

;-----------------------------------------------------------------------------
; CODE SEGMENT
;-----------------------------------------------------------------------------
.CODE
MAIN PROC
    ; Initialize Data Segment
    MOV AX, @DATA
    MOV DS, AX
    
    ;-------------------------------------------------------------------------
    ; CREATE/TRUNCATE FILE (AH=3CH)
    ; Note: If file exists, its length is truncated to zero.
    ;-------------------------------------------------------------------------
    MOV AH, 3CH
    MOV CX, 0                           ; Attributes
    LEA DX, FILENAME
    INT 21H
    JC ERROR
    MOV HANDLE, AX
    
    ;-------------------------------------------------------------------------
    ; WRITE TO FILE (INT 21H, AH=40H)
    ; Input: AH = 40H
    ;        BX = File handle
    ;        CX = Number of bytes to write
    ;        DS:DX = Buffer offset
    ;-------------------------------------------------------------------------
    MOV AH, 40H
    MOV BX, HANDLE
    MOV CX, CONTENT_LEN
    LEA DX, CONTENT
    INT 21H
    JC ERROR
    
    ;-------------------------------------------------------------------------
    ; CLOSE FILE (AH=3EH)
    ;-------------------------------------------------------------------------
    MOV AH, 3EH
    MOV BX, HANDLE
    INT 21H
    
    LEA DX, MSG_SUCCESS
    JMP DISPLAY
    
ERROR:
    LEA DX, MSG_ERROR
    
DISPLAY:
    MOV AH, 09H
    INT 21H
    
    ; Exit to DOS
    MOV AH, 4CH
    INT 21H
MAIN ENDP
END MAIN

;=============================================================================
; FILE WRITING NOTES:
; - AH=3Ch creates a NEW file or erases an existing one.
; - AH=40h writes 'CX' bytes to the file at current position.
; - If AH=40h returns AX < CX, the disk is likely full.
;=============================================================================
