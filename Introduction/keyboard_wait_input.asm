; =============================================================================
; TITLE: Keyboard Wait (Input Interception)
; DESCRIPTION: Demonstrates how to pause program execution by waiting for a
;              BIOS keyboard event (INT 16H / AH=00H).
; AUTHOR: Amey Thakur (https://github.com/Amey-Thakur)
; REPOSITORY: https://github.com/Amey-Thakur/8086-ASSEMBLY-LANGUAGE-PROGRAMS
; LICENSE: MIT License
; =============================================================================

ORG 100H                            ; COM file entry point

; -----------------------------------------------------------------------------
; MAIN CODE SECTION
; -----------------------------------------------------------------------------
MAIN PROC NEAR
    ; -------------------------------------------------------------------------
    ; WAIT FOR KEYPRESS (BIOS INT 16H, AH=00H)
    ; This is a blocking call. The program will not proceed until a key is hit.
    ; Returns: AH = Scan code, AL = ASCII char
    ; -------------------------------------------------------------------------
    MOV AH, 00H                     ; BIOS: Get keystroke function
    INT 16H                         ; Call keyboard BIOS
    
    ; Graceful Exit to DOS
    MOV AX, 4C00H                   ; AH=4Ch, AL=00h
    INT 21H
MAIN ENDP

END MAIN

; =============================================================================
; TECHNICAL NOTES
; =============================================================================
; 1. SYSTEM PAUSE:
;    - Use this to prevent console windows from closing immediately.
;    - Unlike DOS input functions, this BIOS call does not echo the character.
;    - Useful for "Press any key to continue..." logic.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
