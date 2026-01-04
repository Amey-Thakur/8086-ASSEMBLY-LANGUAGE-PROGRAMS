; =============================================================================
; TITLE: BIOS Timer Delay
; DESCRIPTION: Demonstrates the usage of BIOS Interrupt 15h (System Services) 
;              to create precise delays. Displays characters with 1-second 
;              intervals. Formatted as a Boot Sector simulation.
; AUTHOR: Amey Thakur (https://github.com/Amey-Thakur)
; REPOSITORY: https://github.com/Amey-Thakur/8086-ASSEMBLY-LANGUAGE-PROGRAMS
; LICENSE: MIT License
; =============================================================================

NAME "boot_timer"
#make_boot#
ORG 7C00H                           ; Bootloader Entry Point

; -----------------------------------------------------------------------------
; CODE SEGMENT
; -----------------------------------------------------------------------------
START:
    ; --- Step 1: Initialize Stack & Segments ---
    MOV AX, CS
    MOV DS, AX
    MOV ES, AX
    
    ; --- Step 2: Clear Screen ---
    MOV AX, 03H                     ; Text Mode 80x25
    INT 10H
    
    MOV CX, 10                      ; Loop 10 times
    MOV AL, 'A'                     ; Start char

L_PRINT_LOOP:
    PUSH AX                         ; Save Char
    
    ; Print Char (TTY)
    MOV AH, 0EH
    INT 10H
    
    ; --- Step 3: Wait 1 Second ---
    ; INT 15h / AH=86h
    ; CX:DX = Microseconds
    ; 1,000,000 us = 000F 4240h
    PUSH CX                         ; Save Loop Counter
    
    MOV CX, 000FH                   ; High Word
    MOV DX, 4240H                   ; Low Word
    MOV AH, 86H
    INT 15H
    
    POP CX                          ; Restore Loop Counter
    POP AX                          ; Restore Char
    
    INC AL                          ; Next Letter
    LOOP L_PRINT_LOOP
    
    ; --- Step 4: Reboot Prompt ---
    LEA SI, MSG_REBOOT
    CALL PRINT_STR
    
    ; Wait for Keypress
    MOV AH, 00H
    INT 16H
    
    ; Reboot (INT 19h)
    INT 19H

; -----------------------------------------------------------------------------
; UTILITIES & DATA
; -----------------------------------------------------------------------------
PRINT_STR PROC
    L_NEXT_CHAR:
        LODSB
        CMP AL, 0
        JE L_DONE
        MOV AH, 0EH
        INT 10H
        JMP L_NEXT_CHAR
    L_DONE:
        RET
PRINT_STR ENDP

MSG_REBOOT DB 0DH, 0AH, "Sequence Complete. Press any key to reboot...", 0

END

; =============================================================================
; TECHNICAL NOTES & ARCHITECTURAL INSIGHTS
; =============================================================================
; 1. INT 15H / AH=86H (WAIT):
;    This is the BIOS "Wait" function. It pauses the CPU for a specified number 
;    of microseconds. It works by monitoring the CMOS Real Time Clock (RTC) 
;    or PIT (Programmable Interval Timer).
;
; 2. BOOT SECTOR ENVIRONMENT:
;    This program uses #make_boot# to generate a 512-byte binary with the 
;    AA55h signature. It runs without an operating system, demonstrating 
;    bare-metal hardware access.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =