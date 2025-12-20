;=============================================================================
; Program:     Hello World (Direct VGA Memory)
; Description: Display "Hello, World!" by writing directly to the video 
;              memory segment 0B800h in text mode.
; 
; Author:      Amey Thakur
; Repository:  https://github.com/Amey-Thakur/8086-ASSEMBLY-LANGUAGE-PROGRAMS
; License:     MIT License
;=============================================================================

ORG 100H                            ; COM file entry point

;-----------------------------------------------------------------------------
; INITIALIZATION
;-----------------------------------------------------------------------------
START:
    ; Set Video Mode: 80x25 16-color text (Mode 03h)
    MOV AX, 0003H                   ; AH=0, AL=3
    INT 10H
    
    ; Optional: Disable blinking to enable all 16 background colors
    MOV AX, 1003H
    MOV BX, 0
    INT 10H
    
    ; Point DS to the video memory segment (Text Mode: 0B800h)
    MOV AX, 0B800H
    MOV DS, AX

;-----------------------------------------------------------------------------
; WRITE CHARACTERS TO VIDEO RAM
; Memory layout: [Char1][Attr1][Char2][Attr2]...
; Offset [00h] is top-left corner.
;-----------------------------------------------------------------------------
    MOV [02H], 'H'                  ; Write 'H' at 2nd column
    MOV [04H], 'e'
    MOV [06H], 'l'
    MOV [08H], 'l'
    MOV [0AH], 'o'
    MOV [0CH], ','
    MOV [0EH], 'W'
    MOV [10H], 'o'
    MOV [12H], 'r'
    MOV [14H], 'l'
    MOV [16H], 'd'
    MOV [18H], '!'

;-----------------------------------------------------------------------------
; COLOR THE CHARACTERS
; Attributes are stored at odd offsets (1, 3, 5...).
;-----------------------------------------------------------------------------
    MOV CX, 12                      ; Number of characters to color
    MOV DI, 03H                     ; Start at the attribute byte of 'H'

COLOR_LOOP:
    ; Attribute bitmask: [B-G-R-I (BG)] [B-G-R-I (FG)]
    ; 11101100b: Light Red on Yellow
    MOV BYTE PTR [DI], 11101100B
    ADD DI, 2                       ; Move to next attribute byte
    LOOP COLOR_LOOP
    
    ; Wait for keypress
    MOV AH, 0
    INT 16H

    RET                             ; Back to DOS

END

;=============================================================================
; VGA MEMORY NOTES:
; - Text mode memory starts at 0B8000h (Segment 0B800h).
; - Each screen position takes 2 bytes:
;   Byte 1: ASCII Character
;   Byte 2: Attribute (Colors and effects)
; - This is the fastest way to update the screen.
;=============================================================================
