; =============================================================================
; TITLE: DOS Read Character
; DESCRIPTION: Reads a single character from Standard Input with ECHO using 
;              DOS Interrupt 21H, Function 01H.
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
    MSG_PROMPT  DB "Press a key: $"
    MSG_OUT     DB 0DH, 0AH, "You pressed: $"

; -----------------------------------------------------------------------------
; CODE SEGMENT
; -----------------------------------------------------------------------------
.CODE
MAIN PROC
    ; --- Step 1: Initialize DS ---
    MOV AX, @DATA
    MOV DS, AX

    ; --- Step 2: Prompt ---
    LEA DX, MSG_PROMPT
    MOV AH, 09H
    INT 21H

    ; --- Step 3: Read Char (INT 21h / AH=01h) ---
    ; Waits for keypress. Echoes char to screen. Returns in AL.
    MOV AH, 01H
    INT 21H
    
    PUSH AX                             ; Save the char

    ; --- Step 4: Display Output Label ---
    LEA DX, MSG_OUT
    MOV AH, 09H
    INT 21H

    ; --- Step 5: Print Saved Char ---
    POP AX
    MOV DL, AL
    MOV AH, 02H
    INT 21H

    ; --- Step 6: Exit ---
    MOV AH, 4CH
    INT 21H
MAIN ENDP
END MAIN

; =============================================================================
; TECHNICAL NOTES & ARCHITECTURAL INSIGHTS
; =============================================================================
; 1. DOS FUNCTION 01h:
;    - Reads from Stdin.
;    - Echoes to Stdout automatically.
;    - If CTRL-C is pressed, executes INT 23h (Terminate).
;    - For "Special Keys" (like F1), it returns 00h. You must call it again 
;      to get the scan code.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
