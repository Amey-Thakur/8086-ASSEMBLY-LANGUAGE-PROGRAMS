;=============================================================================
; Program:     File Creation
; Description: Demonstrate how to create a new file using DOS INT 21H.
;              Initializes a new file with normal attributes.
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
    FILENAME DB 'TEST.TXT', 0           ; Null-terminated filename
    HANDLE DW ?                          ; To store file handle
    MSG_SUCCESS DB 'File created successfully!$'
    MSG_ERROR DB 'Error creating file!$'

;-----------------------------------------------------------------------------
; CODE SEGMENT
;-----------------------------------------------------------------------------
.CODE
MAIN PROC
    ; Initialize Data Segment
    MOV AX, @DATA
    MOV DS, AX
    
    ;-------------------------------------------------------------------------
    ; CREATE FILE (INT 21H, AH=3CH)
    ; Input: AH = 3CH
    ;        CX = File attributes (0=normal, 1=read-only, 2=hidden, 4=system)
    ;        DS:DX = Offset of null-terminated filename
    ; Output: AX = File handle (if CF=0)
    ;         AX = Error code (if CF=1)
    ;-------------------------------------------------------------------------
    MOV AH, 3CH
    MOV CX, 0                           ; Normal file
    LEA DX, FILENAME
    INT 21H
    
    JC ERROR                            ; Jump if carry flag set (error)
    
    ; Save the file handle for future use (writing/closing)
    MOV HANDLE, AX
    
    ;-------------------------------------------------------------------------
    ; CLOSE FILE (INT 21H, AH=3EH)
    ; Input: BX = File handle
    ;-------------------------------------------------------------------------
    MOV AH, 3EH
    MOV BX, HANDLE
    INT 21H
    
    ; Display success message
    LEA DX, MSG_SUCCESS
    JMP DISPLAY
    
ERROR:
    ; Display error message
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
; FILE CREATION NOTES:
; - Filenames must be ASCIIZ (null-terminated).
; - Handle is a unique 16-bit identifier for the open file session.
; - Error codes (returned in AX if CF=1):
;   03h: Path not found
;   04h: Too many open files
;   05h: Access denied
;=============================================================================
