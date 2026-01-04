; =============================================================================
; TITLE: Direct Video Memory Access (Colored Text)
; DESCRIPTION: Demonstrates how to write directly to the Video Graphics Array 
;              (VGA) memory at segment 0B800h to display colored text.
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
    MSG_TEXT    DB "Direct Video Memory Write!"
    MSG_LEN     EQU $ - MSG_TEXT

; -----------------------------------------------------------------------------
; CODE SEGMENT
; -----------------------------------------------------------------------------
.CODE
MAIN PROC
    ; --- Step 1: Initialize DS ---
    MOV AX, @DATA
    MOV DS, AX

    ; --- Step 2: Set Video Mode (03h - 80x25 Text) ---
    MOV AH, 00H
    MOV AL, 03H
    INT 10H

    ; --- Step 3: Setup ES to Video Segment ---
    ; In Text Mode (CGA/EGA/VGA), memory starts at B800:0000
    MOV AX, 0B800H
    MOV ES, AX

    ; --- Step 4: Calculate Screen Position ---
    ; Position: Row 10, Col 20
    ; Formula: Offset = (Row * 80 + Col) * 2
    ; Note: *2 because each cell is 2 bytes (Char + Attribute)
    MOV AX, 10
    MOV BX, 80
    MUL BX                              ; AX = 800
    ADD AX, 20                          ; AX = 820
    SHL AX, 1                           ; AX = 1640 (Multiply by 2)
    MOV DI, AX                          ; DI points to target memory

    ; --- Step 5: Write Character Loop ---
    LEA SI, MSG_TEXT
    MOV CX, MSG_LEN
    MOV AH, 01H                         ; Initial Color: Blue (1)

L_PRINT_LOOP:
    LODSB                               ; AL = [SI], SI++
    MOV ES:[DI], AL                     ; Write Char to Video RAM
    INC DI
    
    MOV ES:[DI], AH                     ; Write Attribute to Video RAM
    INC DI
    
    INC AH                              ; Cycle Colors
    AND AH, 0FH                         ; Keep color 0-15
    LOOP L_PRINT_LOOP

    ; --- Step 6: Wait & Exit ---
    MOV AH, 00H
    INT 16H                             ; Wait for Key

    MOV AH, 4CH
    INT 21H
MAIN ENDP
END MAIN

; =============================================================================
; TECHNICAL NOTES & ARCHITECTURAL INSIGHTS
; =============================================================================
; 1. VIDEO MEMORY LAYOUT (TEXT MODE):
;    The screen is a grid of 80x25 characters.
;    Memory is linear: B800:0000 is top-left char, B800:0001 is its color.
;
; 2. ATTRIBUTE BYTE FORMAT (8 bits):
;    [Blink E | BG R G B | I | FG R G B]
;    - Bit 7: Blink
;    - Bits 4-6: Background Color
;    - Bit 3: Intensity (Bright)
;    - Bits 0-2: Foreground Color
;
; 3. PERFORMANCE:
;    Writing directly to B800h is significantly faster than using INT 10h calls.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
