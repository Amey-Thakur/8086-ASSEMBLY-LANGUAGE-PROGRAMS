;=============================================================================
; Program:     File Reading
; Description: Demonstrate how to open, read content from, and close a 
;              file using DOS interrupts.
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
    FILENAME DB 'INPUT.TXT', 0          ; Primary input source
    BUFFER DB 256 DUP('$')               ; Read buffer (initialized with $)
    HANDLE DW ?                          ; File handle
    MSG_CONTENT DB 'File content:', 0DH, 0AH, '$'
    MSG_ERROR DB 'Error: Could not read file!$'

;-----------------------------------------------------------------------------
; CODE SEGMENT
;-----------------------------------------------------------------------------
.CODE
MAIN PROC
    ; Initialize Data Segment
    MOV AX, @DATA
    MOV DS, AX
    
    ;-------------------------------------------------------------------------
    ; OPEN EXISTING FILE (INT 21H, AH=3DH)
    ; Input: AH = 3DH
    ;        AL = Access mode (0=read, 1=write, 2=read/write)
    ;        DS:DX = ASCIIZ filename
    ; Output: AX = Handle (if CF=0)
    ;-------------------------------------------------------------------------
    MOV AH, 3DH
    MOV AL, 0                           ; Read-only mode
    LEA DX, FILENAME
    INT 21H
    JC ERROR
    MOV HANDLE, AX                      ; Store handle
    
    ;-------------------------------------------------------------------------
    ; READ FROM FILE (INT 21H, AH=3FH)
    ; Input: AH = 3FH
    ;        BX = File handle
    ;        CX = Number of bytes to read
    ;        DS:DX = Buffer offset
    ; Output: AX = Number of bytes actually read
    ;-------------------------------------------------------------------------
    MOV AH, 3FH
    MOV BX, HANDLE
    MOV CX, 255                         ; Leave space for terminating '$'
    LEA DX, BUFFER
    INT 21H
    JC ERROR
    
    ;-------------------------------------------------------------------------
    ; CLOSE FILE
    ;-------------------------------------------------------------------------
    MOV AH, 3EH
    MOV BX, HANDLE
    INT 21H
    
    ;-------------------------------------------------------------------------
    ; DISPLAY CONTENT
    ;-------------------------------------------------------------------------
    LEA DX, MSG_CONTENT
    MOV AH, 09H
    INT 21H
    
    LEA DX, BUFFER                      ; Display read data
    MOV AH, 09H
    INT 21H
    JMP EXIT
    
ERROR:
    LEA DX, MSG_ERROR
    MOV AH, 09H
    INT 21H
    
EXIT:
    ; Exit to DOS
    MOV AH, 4CH
    INT 21H
MAIN ENDP
END MAIN

;=============================================================================
; FILE READING NOTES:
; - Handlers: Use the handle returned by AH=3Dh for subsequent operations.
; - Buffering: CX specifies max read; AX returns actual read count.
; - End of File (EOF): If AX returns 0, the end of file has been reached.
;=============================================================================
