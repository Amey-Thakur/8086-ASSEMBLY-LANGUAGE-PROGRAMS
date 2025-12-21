; =============================================================================
; TITLE: DOS Buffered String Input
; DESCRIPTION: Reads a string from the keyboard into a buffer using DOS 
;              Interrupt 21H, Function 0Ah. Allows backspace editing.
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
    MSG_PROMPT  DB "Enter text (max 20): $"
    MSG_UNSAFE  DB " (Note: This is technically vulnerable to overflow if manual check fails in raw mode, but safe here via DOS limit)$"
    MSG_OUT     DB 0DH, 0AH, "You typed: $"

    ; BUFFER STRUCTURE for INT 21h / AH=0Ah
    ; Byte 0: Max characters buffer can hold
    ; Byte 1: Actual characters read (Returned by DOS)
    ; Byte 2+: Actual string data
    INPUT_BUF   DB 21                   ; Max 20 chars + Enter
                DB ?                    ; Count
                DB 21 DUP('$')          ; Buffer area (init with $)

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

    ; --- Step 3: Buffered Input (INT 21h / AH=0Ah) ---
    LEA DX, INPUT_BUF                   ; DX points to Buffer Structure
    MOV AH, 0AH
    INT 21H

    ; --- Step 4: Display Output Label ---
    LEA DX, MSG_OUT
    MOV AH, 09H
    INT 21H

    ; --- Step 5: Display Buffer Content ---
    ; INPUT_BUF+2 starts the actual string.
    ; Since we pre-filled with '$', and DOS adds CR (0Dh), we can just print.
    ; *Clean Output Hack*: We can technically just print from +2.
    LEA DX, INPUT_BUF + 2
    MOV AH, 09H
    INT 21H

    ; --- Step 6: Exit ---
    MOV AH, 4CH
    INT 21H
MAIN ENDP
END MAIN

; =============================================================================
; TECHNICAL NOTES & ARCHITECTURAL INSIGHTS
; =============================================================================
; 1. BUFFERED INPUT (Function 0Ah):
;    - The most powerful DOS input method.
;    - Handles Backspace, Enter, and buffers typing until Enter is pressed.
;    - The first byte determines the limit, preventing buffer overflows at the 
;      OS level (unlike raw gets() in C).
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
