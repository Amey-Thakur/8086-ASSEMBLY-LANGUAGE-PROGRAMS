; =============================================================================
; TITLE: DOS Display Character
; DESCRIPTION: Displays a single character using DOS Interrupt 21H, Function 02H.
; AUTHOR: Amey Thakur (https://github.com/Amey-Thakur)
; REPOSITORY: https://github.com/Amey-Thakur/8086-ASSEMBLY-LANGUAGE-PROGRAMS
; LICENSE: MIT License
; =============================================================================

.MODEL SMALL
.STACK 100H

; -----------------------------------------------------------------------------
; CODE SEGMENT
; -----------------------------------------------------------------------------
.CODE
MAIN PROC
    ; --- Step 1: Display 'A' (INT 21h / AH=02h) ---
    MOV DL, 'A'                         ; Character to print
    MOV AH, 02H
    INT 21H

    ; --- Step 2: Display Newline ---
    MOV DL, 0DH                         ; CR
    INT 21H
    MOV DL, 0AH                         ; LF
    INT 21H

    ; --- Step 3: Exit ---
    MOV AH, 4CH
    INT 21H
MAIN ENDP
END MAIN

; =============================================================================
; TECHNICAL NOTES & ARCHITECTURAL INSIGHTS
; =============================================================================
; 1. DOS FUNCTION 02h:
;    - Writes the character in DL to Standard Output (Stdout).
;    - Advances the cursor.
;    - Detects Ctrl-Break.
;
; 2. REDIRECTION:
;    Since it uses Stdout, output can be redirected to a file or pipe 
;    (e.g., PROG.EXE > OUTPUT.TXT).
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
