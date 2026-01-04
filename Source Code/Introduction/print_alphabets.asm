; =============================================================================
; TITLE: Print Alphabets (Full Set)
; DESCRIPTION: Display the entire English alphabet in both Uppercase (A-Z) and 
;              Lowercase (a-z) using loops and ASCII arithmetic.
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
    MSG_UPPER   DB 'Uppercase A-Z: $'
    MSG_LOWER   DB 0DH, 0AH, 'Lowercase a-z: $'

; -----------------------------------------------------------------------------
; CODE SEGMENT
; -----------------------------------------------------------------------------
.CODE
MAIN PROC
    ; Initialize data segment
    MOV AX, @DATA
    MOV DS, AX
    
    ; -------------------------------------------------------------------------
    ; 1. PRINT UPPERCASE A-Z
    ; -------------------------------------------------------------------------
    LEA DX, MSG_UPPER
    MOV AH, 09H
    INT 21H
    
    MOV CX, 26                      ; Counter for 26 letters
    MOV DL, 'A'                     ; ASCII 65 (Uppercase A)
    
L_UPPER:
    MOV AH, 02H                     ; Print character in DL
    INT 21H
    
    INC DL                          ; Next character in ASCII table
    
    ; Print a space separator for readability
    PUSH DX                         ; Save current letter
    MOV DL, ' '
    MOV AH, 02H
    INT 21H
    POP DX                          ; Restore letter
    
    LOOP L_UPPER
    
    ; -------------------------------------------------------------------------
    ; 2. PRINT LOWERCASE a-z
    ; -------------------------------------------------------------------------
    LEA DX, MSG_LOWER
    MOV AH, 09H
    INT 21H
    
    MOV CX, 26
    MOV DL, 'a'                     ; ASCII 97 (Lowercase a)
    
L_LOWER:
    MOV AH, 02H
    INT 21H
    
    INC DL                          ; Next letter
    
    ; Print space
    PUSH DX
    MOV DL, ' '
    MOV AH, 02H
    INT 21H
    POP DX
    
    LOOP L_LOWER
    
    ; -------------------------------------------------------------------------
    ; EXIT
    ; -------------------------------------------------------------------------
    MOV AH, 4CH
    INT 21H
MAIN ENDP
END MAIN

; =============================================================================
; TECHNICAL NOTES
; =============================================================================
; 1. ASCII TABLE:
;    - Uppercase 'A' = 65.
;    - Lowercase 'a' = 97.
;    - 'INC DL' simply moves to the next ASCII value.
;    - Note that there are characters between 'Z' (90) and 'a' (97).
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
