;=============================================================================
; Program:     File Deletion
; Description: Demonstrate how to delete a file from the disk using 
;              DOS INT 21H (AH=41H).
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
    FILENAME DB 'DELETE_ME.TXT', 0      ; Null-terminated filename
    MSG_SUCCESS DB 'File deleted successfully!$'
    MSG_ERROR DB 'Error deleting file (File not found)!$'

;-----------------------------------------------------------------------------
; CODE SEGMENT
;-----------------------------------------------------------------------------
.CODE
MAIN PROC
    ; Initialize Data Segment
    MOV AX, @DATA
    MOV DS, AX
    
    ;-------------------------------------------------------------------------
    ; DELETE FILE (INT 21H, AH=41H)
    ; Input: AH = 41H
    ;        DS:DX = Pointer to ASCIIZ filename
    ; Output: AX = Error code (if CF=1)
    ;-------------------------------------------------------------------------
    MOV AH, 41H
    LEA DX, FILENAME
    INT 21H
    
    JC ERROR                            ; Carry flag set means error
    
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
; FILE DELETION NOTES:
; - File MUST not be open when attempting to delete it.
; - Wildcards (*, ?) are NOT allowed in filenames.
; - Error codes in AX:
;   02h: File not found
;   05h: Access denied (e.g. read-only or directory)
;=============================================================================
