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

    ; Labels for the register report at the end of the program.
    RPT_HEAD DB 0DH, 0AH, 'Registers when the program finished:', 0DH, 0AH, '$'
    RPT_N_AX DB '  AX = ', '$'
    RPT_N_BX DB '   BX = ', '$'
    RPT_N_CX DB '   CX = ', '$'
    RPT_N_DX DB '   DX = ', '$'
    RPT_NL   DB 0DH, 0AH, '$'
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

; -------------------------------------------------------------------------
    ; WHAT THIS PROGRAM COMPUTED
    ;
    ; The work above leaves its answer in the registers. Printing them is what
    ; makes the program demonstrate itself rather than needing a debugger to be
    ; believed.
    ; -------------------------------------------------------------------------
    CALL RPT_REGISTERS

        MOV AH, 4CH
    INT 21H
MAIN ENDP

; -----------------------------------------------------------------------------
; RPT_DECIMAL
;
; Prints the unsigned value in AX as decimal. Named apart from anything the
; program already had, so this report cannot clash with it.
; -----------------------------------------------------------------------------
RPT_DECIMAL PROC
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX

    XOR CX, CX
    MOV BX, 10

RPT_SPLIT:
    XOR DX, DX
    DIV BX
    PUSH DX
    INC CX
    CMP AX, 0
    JNE RPT_SPLIT

RPT_EMIT:
    POP DX
    ADD DL, '0'
    MOV AH, 02H
    INT 21H
    LOOP RPT_EMIT

    POP DX
    POP CX
    POP BX
    POP AX
    RET
RPT_DECIMAL ENDP

; -----------------------------------------------------------------------------
; RPT_SAY
;
; Prints the dollar terminated string at DS:DX, leaving AX alone.
; -----------------------------------------------------------------------------
RPT_SAY PROC
    PUSH AX
    MOV AH, 09H
    INT 21H
    POP AX
    RET
RPT_SAY ENDP

; -----------------------------------------------------------------------------
; RPT_REGISTERS
;
; Prints the four general registers as they were on entry.
;
; They are pushed first and read back off, because printing needs AX for the
; value and DX for the message: reading them any later would report the state of
; the printer rather than the state of the program.
; -----------------------------------------------------------------------------
RPT_REGISTERS PROC
    PUSH DX
    PUSH CX
    PUSH BX
    PUSH AX

    PUSH BP
    MOV BP, SP

    ; The program may have pointed DS somewhere of its own, at a video segment
    ; or at segment zero, and the strings below live in the data image. SEG
    ; gives their segment whatever the program left in DS.
    PUSH DS
    MOV AX, SEG RPT_HEAD
    MOV DS, AX

    LEA DX, RPT_HEAD
    CALL RPT_SAY

    LEA DX, RPT_N_AX
    CALL RPT_SAY
    MOV AX, [BP+2]
    CALL RPT_DECIMAL

    LEA DX, RPT_N_BX
    CALL RPT_SAY
    MOV AX, [BP+4]
    CALL RPT_DECIMAL

    LEA DX, RPT_N_CX
    CALL RPT_SAY
    MOV AX, [BP+6]
    CALL RPT_DECIMAL

    LEA DX, RPT_N_DX
    CALL RPT_SAY
    MOV AX, [BP+8]
    CALL RPT_DECIMAL

    LEA DX, RPT_NL
    CALL RPT_SAY

    POP DS
    POP BP

    POP AX
    POP BX
    POP CX
    POP DX
    RET
RPT_REGISTERS ENDP

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
