;=============================================================================
; Program:     Keyboard Input Handler
; Description: Demonstrate the use of BIOS keyboard interrupts to capture
;              and print keystrokes in real-time.
; 
; Author:      Amey Thakur
; Repository:  https://github.com/Amey-Thakur/8086-ASSEMBLY-LANGUAGE-PROGRAMS
; License:     MIT License
;=============================================================================

NAME "keybrd"

ORG 100H                            ; COM file format

;-----------------------------------------------------------------------------
; MAIN PROCEDURE
;-----------------------------------------------------------------------------
; This code loops until the 'Esc' key is pressed.
; It uses BIOS interrupts:
; - INT 16h / AH=01h: Check for keystroke in buffer
; - INT 16h / AH=00h: Read keystroke from buffer
; - INT 10h / AH=0Eh: Telegraph print character
;-----------------------------------------------------------------------------

; Print a welcome message:
MOV DX, OFFSET MSG
MOV AH, 9
INT 21H

;-----------------------------------------------------------------------------
; Eternal loop to capture and print keys
;-----------------------------------------------------------------------------
WAIT_FOR_KEY:
    ; Check for keystroke in keyboard buffer (non-blocking)
    ; Return: ZF = 0 if key is in buffer, ZF = 1 if no key
    MOV AH, 1                       ; BIOS: Check for keystroke
    INT 16H
    JZ  WAIT_FOR_KEY                ; No key? Loop back and wait

    ; Get keystroke from keyboard (blocking - removes from buffer)
    ; Return: AL = ASCII char, AH = Scan code
    MOV AH, 0                       ; BIOS: Read keystroke
    INT 16H

    ; Print the key using BIOS TTY output
    ; Input: AL = ASCII char
    MOV AH, 0EH                     ; BIOS: Telegraph output
    INT 10H

    ; Check if 'Esc' was pressed to exit
    ; Esc key code is 1Bh (27 decimal)
    CMP AL, 1BH
    JZ  EXIT                        ; Exit if Esc pressed

    JMP WAIT_FOR_KEY                ; Continue loop

;-----------------------------------------------------------------------------
; Exit sequence
;-----------------------------------------------------------------------------
EXIT:
    RET                             ; Return to DOS

;-----------------------------------------------------------------------------
; DATA SECTION
;-----------------------------------------------------------------------------
MSG  DB "Type anything...", 0DH, 0AH
     DB "[Enter] - carriage return.", 0DH, 0AH
     DB "[Ctrl]+[Enter] - line feed.", 0DH, 0AH
     DB "You may hear a beep when buffer is overflown.", 0DH, 0AH
     DB "Press Esc to exit.", 0DH, 0AH, "$"

END

;=============================================================================
; KEYBOARD INTERRUPTS NOTES:
; - INT 16h is the BIOS keyboard service.
; - AH=01h: Scans the buffer. If ZF=0, a key is waiting in AX.
; - AH=00h: Actually pulls the next key out of the BIOS buffer.
; - Keyboard buffer is a hardware-filled queue that can hold ~15 keys.
;=============================================================================
