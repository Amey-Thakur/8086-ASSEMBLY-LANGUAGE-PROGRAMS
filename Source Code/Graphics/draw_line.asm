; =============================================================================
; TITLE: Draw Line (VGA Mode 13h)
; DESCRIPTION: Demonstrates drawing a horizontal line in 320x200 256-color mode
;              using direct memory access (Segment A000h).
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
    LINE_ROW    DW 100                  ; Y Position (0-199)
    LINE_START  DW 50                   ; X Start (0-319)
    LINE_LEN    DW 220                  ; X Length
    LINE_COLOR  DB 14                   ; Yellow (14)

; -----------------------------------------------------------------------------
; CODE SEGMENT
; -----------------------------------------------------------------------------
.CODE
MAIN PROC
    ; --- Step 1: Initialize DS ---
    MOV AX, @DATA
    MOV DS, AX

    ; --- Step 2: Enter Mode 13h (Graphics) ---
    MOV AX, 0013H
    INT 10H

    ; --- Step 3: Setup ES to Video Segment ---
    MOV AX, 0A000H
    MOV ES, AX

    ; --- Step 4: Calculate Start Offset ---
    ; Offset = (Y * 320) + X
    MOV AX, LINE_ROW
    MOV BX, 320
    MUL BX                              ; AX = Y * 320
    ADD AX, LINE_START
    MOV DI, AX                          ; DI = Start Pixel Address

    ; --- Step 5: Draw Line ---
    MOV CX, LINE_LEN                    ; Count
    MOV AL, LINE_COLOR                  ; Color
    
    CLD                                 ; Increment DI
    REP STOSB                           ; Store AL to ES:DI x CX times

    ; --- Step 6: Wait & Restore ---
    MOV AH, 00H
    INT 16H                             ; Wait for Key

    MOV AX, 0003H                       ; Return to Text Mode
    INT 10H

    MOV AH, 4CH
    INT 21H
MAIN ENDP
END MAIN

; =============================================================================
; TECHNICAL NOTES & ARCHITECTURAL INSIGHTS
; =============================================================================
; 1. VGA MODE 13h:
;    - Resolution: 320 x 200 pixels.
;    - Colors: 256 (1 Byte per pixel).
;    - Memory: Linear mapping at A000:0000.
;
; 2. STOSB INSTRUCTION:
;    - Stores AL into [ES:DI] and updates DI.
;    - REP prefix repeats it CX times.
;    - This is the fastest way to fill a horizontal span on 8086.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
