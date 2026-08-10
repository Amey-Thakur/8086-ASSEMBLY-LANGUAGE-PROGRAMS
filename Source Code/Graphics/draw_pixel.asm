; =============================================================================
; TITLE: Plot Single Pixel
; DESCRIPTION: Basic graphics primitive: plotting a single dot on the screen
;              at coordinates (X, Y) in Mode 13h.
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
    PIXEL_X     DW 160                  ; Center X
    PIXEL_Y     DW 100                  ; Center Y
    PIXEL_COL   DB 15                   ; White (15)

; -----------------------------------------------------------------------------
; CODE SEGMENT
; -----------------------------------------------------------------------------

    ; Labels for the report at the end of the program.
    RPT_HEAD DB 0DH, 0AH, 'Results:', 0DH, 0AH, '$'
    RPT_NL   DB 0DH, 0AH, '$'
    RPT_N_PIXEL_X DB '  PIXEL_X = ', '$'
    RPT_N_PIXEL_Y DB '  PIXEL_Y = ', '$'
    RPT_N_PIXEL_COL DB '  PIXEL_COL = ', '$'
.CODE
MAIN PROC
    ; --- Step 1: Initialize DS ---
    MOV AX, @DATA
    MOV DS, AX

    ; --- Step 2: Enter Mode 13h ---
    MOV AX, 0013H
    INT 10H

    ; --- Step 3: Setup ES ---
    MOV AX, 0A000H
    MOV ES, AX

    ; --- Step 4: Calculate Offset ---
    ; Offset = 320 * Y + X
    MOV AX, PIXEL_Y
    MOV BX, 320
    MUL BX
    ADD AX, PIXEL_X
    MOV DI, AX

    ; --- Step 5: Plot Pixel ---
    MOV AL, PIXEL_COL
    MOV ES:[DI], AL                     ; Write color byte to VRAM

    ; --- Step 6: Wait & Exit ---
    MOV AH, 00H
    INT 16H

    MOV AX, 0003H                       ; Restore Text Mode
    INT 10H

    
    ; -------------------------------------------------------------------------
    ; WHAT THIS PROGRAM COMPUTED
    ;
    ; The work above leaves its answers in the variables below. Printing them
    ; is what makes the program demonstrate itself rather than needing a
    ; debugger to be believed.
    ; -------------------------------------------------------------------------
    LEA DX, RPT_HEAD
    CALL RPT_SAY

    LEA DX, RPT_N_PIXEL_X
    CALL RPT_SAY
    MOV AX, PIXEL_X
    CALL RPT_DECIMAL
    LEA DX, RPT_NL
    CALL RPT_SAY

    LEA DX, RPT_N_PIXEL_Y
    CALL RPT_SAY
    MOV AX, PIXEL_Y
    CALL RPT_DECIMAL
    LEA DX, RPT_NL
    CALL RPT_SAY

    LEA DX, RPT_N_PIXEL_COL
    CALL RPT_SAY
    XOR AX, AX
    MOV AL, PIXEL_COL
    CALL RPT_DECIMAL
    LEA DX, RPT_NL
    CALL RPT_SAY

    MOV AH, 4CH
    INT 21H
MAIN ENDP

; -----------------------------------------------------------------------------
; RPT_DECIMAL
;
; Prints the unsigned value in AX as decimal. Named apart from any helper the
; program already had, so adding this report cannot clash with it.
;
; The digits come out of the division lowest first, which is the wrong order to
; print them in, so they are pushed and then popped back off.
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
; Prints the dollar terminated string at DS:DX without disturbing AX, which
; matters because the caller usually has the value it is about to print there.
; -----------------------------------------------------------------------------
RPT_SAY PROC
    PUSH AX
    MOV AH, 09H
    INT 21H
    POP AX
    RET
RPT_SAY ENDP

END MAIN

; =============================================================================
; TECHNICAL NOTES & ARCHITECTURAL INSIGHTS
; =============================================================================
; 1. COORDINATE SYSTEM:
;    - (0,0) is top-left.
;    - (319, 199) is bottom-right.
;    - Any write outside 0-63999 offset will wrap or corrupt other video pages 
;      (if available), but in Mode 13h it's usually safe within 64KB segment.
;
; 2. BIOS PLOT (INT 10h AH=0Ch):
;    We avoided INT 10h/AH=0Ch here because it is very slow compared to 
;    direct memory writing shown above.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
