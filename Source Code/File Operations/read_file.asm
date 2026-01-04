; =============================================================================
; TITLE: Read File Content
; DESCRIPTION: Opens an existing text file ("INPUT.TXT") and reads its content 
;              into a buffer, then displays it to standard output.
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
    FILE_NAME   DB "INPUT.TXT", 0       ; Target file
    FILE_HANDLE DW ?
    
    BUFFER      DB 512 DUP('$')         ; Read buffer (initialized with Terminator)
    
    MSG_HEADER  DB 0DH, 0AH, "--- File Contents ---", 0DH, 0AH, "$"
    MSG_ERR     DB 0DH, 0AH, "Error: Could not read file.$"

; -----------------------------------------------------------------------------
; CODE SEGMENT
; -----------------------------------------------------------------------------
.CODE
MAIN PROC
    ; --- Step 1: Initialize Data Segment ---
    MOV AX, @DATA
    MOV DS, AX
    
    ; --- Step 2: Open File (INT 21h / AH=3Dh) ---
    ; AL = Access Mode (0=Read, 1=Write, 2=Read/Write)
    MOV AL, 0
    LEA DX, FILE_NAME
    MOV AH, 3DH
    INT 21H
    
    JC L_ERROR
    MOV FILE_HANDLE, AX                 ; Save Handle
    
    ; --- Step 3: Read File (INT 21h / AH=3Fh) ---
    ; BX = Handle
    ; CX = Byte Count to Read
    ; DS:DX = Buffer
    MOV BX, FILE_HANDLE
    MOV CX, 510                         ; Read up to 510 bytes (safe limit)
    LEA DX, BUFFER
    MOV AH, 3FH
    INT 21H
    
    JC L_ERROR
    
    ; Note: AX now holds the actual number of bytes read.
    ; Since we initialized BUFFER with '$', we can print directly if it's text.
    
    ; --- Step 4: Display Content ---
    LEA DX, MSG_HEADER
    MOV AH, 09H
    INT 21H
    
    LEA DX, BUFFER
    MOV AH, 09H
    INT 21H
    
    ; --- Step 5: Close File (INT 21h / AH=3Eh) ---
    MOV BX, FILE_HANDLE
    MOV AH, 3EH
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
; 1. BUFFER MANAGEMENT:
;    We read a chunk of data into memory. If the file is larger than the buffer, 
;    we would need a loop to read -> print -> read until AX (bytes read) is 0.
;
; 2. FILE POINTER:
;    DOS maintains a read/write pointer for each handle. It advances automatically 
;    after each read operation.
;
; 3. DISPLAY LIMITATION:
;    Using AH=09h (Print String) requires the data to be '$' terminated. 
;    Binary files would need a different display method (e.g., Hex Dump).
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
