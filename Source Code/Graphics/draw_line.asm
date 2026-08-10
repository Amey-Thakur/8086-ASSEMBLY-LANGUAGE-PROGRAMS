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

    ; Labels for the report at the end of the program.
    RPT_HEAD DB 0DH, 0AH, 'Results:', 0DH, 0AH, '$'
    RPT_NL   DB 0DH, 0AH, '$'
    RPT_N_LINE_ROW DB '  LINE_ROW = ', '$'
    RPT_N_LINE_START DB '  LINE_START = ', '$'
    RPT_N_LINE_LEN DB '  LINE_LEN = ', '$'
    RPT_N_LINE_COLOR DB '  LINE_COLOR = ', '$'
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

    
    ; -------------------------------------------------------------------------
    ; WHAT THIS PROGRAM COMPUTED
    ;
    ; The work above leaves its answers in the variables below. Printing them
    ; is what makes the program demonstrate itself rather than needing a
    ; debugger to be believed.
    ; -------------------------------------------------------------------------
    LEA DX, RPT_HEAD
    CALL RPT_SAY

    LEA DX, RPT_N_LINE_ROW
    CALL RPT_SAY
    MOV AX, LINE_ROW
    CALL RPT_DECIMAL
    LEA DX, RPT_NL
    CALL RPT_SAY

    LEA DX, RPT_N_LINE_START
    CALL RPT_SAY
    MOV AX, LINE_START
    CALL RPT_DECIMAL
    LEA DX, RPT_NL
    CALL RPT_SAY

    LEA DX, RPT_N_LINE_LEN
    CALL RPT_SAY
    MOV AX, LINE_LEN
    CALL RPT_DECIMAL
    LEA DX, RPT_NL
    CALL RPT_SAY

    LEA DX, RPT_N_LINE_COLOR
    CALL RPT_SAY
    XOR AX, AX
    MOV AL, LINE_COLOR
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
