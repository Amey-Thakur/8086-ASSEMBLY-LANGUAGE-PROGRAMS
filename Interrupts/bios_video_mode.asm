; Program: BIOS Interrupt 10H - Set Video Mode
; Description: Set video mode using INT 10H, AH=00H
; Author: Amey Thakur

.MODEL SMALL
.STACK 100H

.CODE
MAIN PROC
    ; Set video mode to 80x25 text mode
    MOV AH, 00H      ; BIOS function: set video mode
    MOV AL, 03H      ; Mode 3: 80x25 16-color text
    INT 10H          ; Call BIOS interrupt
    
    MOV AH, 4CH      ; Exit to DOS
    INT 21H
MAIN ENDP
END MAIN

; Common Video Modes:
; AL = 00H : 40x25 B/W text
; AL = 01H : 40x25 color text
; AL = 02H : 80x25 B/W text
; AL = 03H : 80x25 color text
; AL = 04H : 320x200 4-color graphics
; AL = 05H : 320x200 B/W graphics
; AL = 06H : 640x200 2-color graphics
; AL = 07H : 80x25 monochrome text
; AL = 13H : 320x200 256-color graphics (VGA)
