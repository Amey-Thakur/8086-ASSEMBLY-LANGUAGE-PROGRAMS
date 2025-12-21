; =============================================================================
; TITLE: Delete File
; DESCRIPTION: Deletes a specific file from the disk using DOS Interrupt 21h.
;              Attempts to remove "DELETE_ME.TXT".
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
    FILE_NAME   DB "DELETE_ME.TXT", 0   ; Null-terminated string
    
    MSG_OK      DB 0DH, 0AH, "Success: File deleted.$"
    MSG_ERR     DB 0DH, 0AH, "Error: File not found or Access Denied.$"

; -----------------------------------------------------------------------------
; CODE SEGMENT
; -----------------------------------------------------------------------------
.CODE
MAIN PROC
    ; --- Step 1: Initialize Data Segment ---
    MOV AX, @DATA
    MOV DS, AX
    
    ; --- Step 2: Delete File (INT 21h / AH=41h) ---
    LEA DX, FILE_NAME
    MOV AH, 41H
    INT 21H
    
    JC L_ERROR                          ; Jump if Carry Flag set
    
    ; --- Step 3: Success Message ---
    LEA DX, MSG_OK
    MOV AH, 09H
    INT 21H
    JMP L_EXIT

L_ERROR:
    ; --- Step 4: Error Handling ---
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
; 1. DELETION LOGIC (INT 21h / AH=41h):
;    - Takes a pointer to an ASCIIZ (null-terminated) path in DS:DX.
;    - Deletes the directory entry.
;    - Fails if the file is Read-Only or Currently Open by another process.
;
; 2. SECURITY:
;    Deleted files are not wiped from the disk surface, only the directory 
;    entry is marked as free (usually with a sigma/E5h character). Data 
;    recovery is possible until overwritten.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
