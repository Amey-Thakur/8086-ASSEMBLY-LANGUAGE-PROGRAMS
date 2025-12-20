;=============================================================================
; Program:     Print Alphabets (A-Z and a-z)
; Description: Display the entire English alphabet in both Uppercase and 
;              Lowercase using simple loops and ASCII incrementing.
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
    MSG1 DB 'Uppercase A-Z: $'
    MSG2 DB 0DH, 0AH, 'Lowercase a-z: $'
    NEWLINE DB 0DH, 0AH, '$'

;-----------------------------------------------------------------------------
; CODE SEGMENT
;-----------------------------------------------------------------------------
.CODE
MAIN PROC
    ; Initialize data segment
    MOV AX, @DATA
    MOV DS, AX
    
    ;-------------------------------------------------------------------------
    ; 1. PRINT UPPERCASE A-Z
    ;-------------------------------------------------------------------------
    LEA DX, MSG1
    MOV AH, 09H
    INT 21H
    
    MOV CX, 26                      ; Counter for 26 letters
    MOV DL, 'A'                     ; ASCII 65 (Uppercase A)
    
UPPER_LOOP:
    MOV AH, 02H                     ; Print character in DL
    INT 21H
    
    INC DL                          ; Next character in ASCII table
    
    ; Print a space separator for readability
    PUSH DX                         ; Save current letter
    MOV DL, ' '
    MOV AH, 02H
    INT 21H
    POP DX                          ; Restore letter
    
    LOOP UPPER_LOOP
    
    ;-------------------------------------------------------------------------
    ; 2. PRINT LOWERCASE a-z
    ;-------------------------------------------------------------------------
    LEA DX, MSG2
    MOV AH, 09H
    INT 21H
    
    MOV CX, 26
    MOV DL, 'a'                     ; ASCII 97 (Lowercase a)
    
LOWER_LOOP:
    MOV AH, 02H
    INT 21H
    
    INC DL                          ; Next letter
    
    ; Print space
    PUSH DX
    MOV DL, ' '
    MOV AH, 02H
    INT 21H
    POP DX
    
    LOOP LOWER_LOOP
    
    ;-------------------------------------------------------------------------
    ; EXIT
    ;-------------------------------------------------------------------------
    MOV AH, 4CH
    INT 21H
MAIN ENDP
END MAIN

;=============================================================================
; ALPHABET NOTES:
; - Uppercase 'A' starts at 65 (41h).
; - Lowercase 'a' starts at 97 (61h).
; - The offset between Upper and Lower is exactly 32 (20h), which is why
;   toggling the 5th bit (bit 5) switches case.
;=============================================================================
