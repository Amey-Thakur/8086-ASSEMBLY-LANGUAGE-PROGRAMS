; =============================================================================
; TITLE: Write to File
; DESCRIPTION: Creates (or overwrites) "OUTPUT.TXT" and writes a defined 
;              string of text into it.
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
    FILE_NAME   DB "OUTPUT.TXT", 0
    FILE_HANDLE DW ?
    
    TEXT_DATA   DB "Hello World from 8086 Assembly!", 0DH, 0AH
    DATA_LEN    EQU $ - TEXT_DATA       ; Auto-calculate length
    
    MSG_OK      DB 0DH, 0AH, "Data successfully written.$"
    MSG_ERR     DB 0DH, 0AH, "Error during file operation.$"

; -----------------------------------------------------------------------------
; CODE SEGMENT
; -----------------------------------------------------------------------------
.CODE
MAIN PROC
    ; --- Step 1: Initialize Data Segment ---
    MOV AX, @DATA
    MOV DS, AX
    
    ; --- Step 2: Create/Open File (INT 21h / AH=3Ch) ---
    ; Using Create Mode to Truncate if exists
    MOV CX, 0                           ; Attributes
    LEA DX, FILE_NAME
    MOV AH, 3CH
    INT 21H
    
    JC L_ERROR
    MOV FILE_HANDLE, AX
    
    ; --- Step 3: Write Data (INT 21h / AH=40h) ---
    ; BX = Handle
    ; CX = Byte Count
    ; DS:DX = Data Source
    MOV BX, FILE_HANDLE
    MOV CX, DATA_LEN
    LEA DX, TEXT_DATA
    MOV AH, 40H
    INT 21H
    
    JC L_ERROR
    
    ; Check if disk was full (AX < CX, but no Carry Set)
    CMP AX, CX
    JNE L_ERROR
    
    ; --- Step 4: Close File ---
    MOV BX, FILE_HANDLE
    MOV AH, 3EH
    INT 21H
    
    ; --- Step 5: Success Message ---
    LEA DX, MSG_OK
    MOV AH, 09H
    INT 21H
    JMP L_EXIT

L_ERROR:
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
; 1. WRITING OPERATIONS:
;    AH=40h writes from the current file pointer position.
;    After creation, the pointer is at 0 (start).
;
; 2. ERROR CHECKING:
;    Always check the Carry Flag (CF). Also, verify that the number of bytes 
;    written (returned in AX) equals the number requested (CX). Mismatches 
;    indicate a full disk.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
