; =============================================================================
; TITLE: Create New File
; DESCRIPTION: Demonstrates how to create a new file using DOS Interrupt 21h.
;              The program attempts to create "TEST.TXT" in the current directory.
; AUTHOR: Amey Thakur (https://github.com/Amey-Thakur)
; REPOSITORY: https://github.com/Amey-Thakur/8086-ASSEMBLY-LANGUAGE-PROGRAMS
; LICENSE: MIT License
; =============================================================================

.MODEL SMALL
.STACK 100H

; -----------------------------------------------------------------------------
; DATA SEGMENT
; -----------------------------------------------------------------------------
.DATA
    ; File Parameters
    FILE_NAME   DB "TEST.TXT", 0        ; Null-terminated string
    FILE_HANDLE DW ?                    ; Storage for the file handle
    
    ; Messages
    MSG_OK      DB 0DH, 0AH, "Success: File 'TEST.TXT' Created.$"
    MSG_ERR     DB 0DH, 0AH, "Error: Could not create file.$"

; -----------------------------------------------------------------------------
; CODE SEGMENT
; -----------------------------------------------------------------------------
.CODE
MAIN PROC
    ; --- Step 1: Initialize Data Segment ---
    MOV AX, @DATA
    MOV DS, AX
    
    ; --- Step 2: Create File (INT 21h / AH=3Ch) ---
    ; CX = Attributes (0 = Normal, 1 = ReadOnly, 2 = Hidden, etc.)
    MOV CX, 0
    LEA DX, FILE_NAME
    MOV AH, 3CH
    INT 21H
    
    JC L_ERROR                          ; Jump if Carry Flag is set (Error)
    
    ; On success, AX contains the File Handle
    MOV FILE_HANDLE, AX
    
    ; --- Step 3: Close File (INT 21h / AH=3Eh) ---
    ; Good practice to close the handle after creation if not writing immediately
    MOV BX, FILE_HANDLE
    MOV AH, 3EH
    INT 21H
    
    ; --- Step 4: Success Message ---
    LEA DX, MSG_OK
    MOV AH, 09H
    INT 21H
    JMP L_EXIT

L_ERROR:
    ; --- Step 5: Error Handling ---
    LEA DX, MSG_ERR
    MOV AH, 09H
    INT 21H

L_EXIT:
    MOV AH, 4CH
    INT 21H
MAIN ENDP

END MAIN

; =============================================================================
; TECHNICAL NOTES & ARCHITECTURAL INSIGHTS
; =============================================================================
; 1. DOS FILE SERVICES (INT 21h):
;    - AH=3Ch: Create File.
;      Returns Handle in AX if successful.
;      Returns Error Code in AX if failed (CF=1).
;    - AH=3Eh: Close File.
;      Releases the file handle back to the OS.
;
; 2. FILE HANDLES:
;    DOS uses a 16-bit integer (Handle) to track open files. Standard handles:
;    0=Stdin, 1=Stdout, 2=Stderr. New files get handles starting from 5.
;
; 3. ATTRIBUTES:
;    00h = Normal
;    01h = Read-Only
;    02h = Hidden
;    04h = System
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
