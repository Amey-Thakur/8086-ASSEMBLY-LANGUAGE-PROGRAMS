; =============================================================================
; TITLE: Draw Filled Rectangle
; DESCRIPTION: Draws a solid colored rectangle by iteratively drawing 
;              horizontal lines.
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
    RECT_X      DW 100
    RECT_Y      DW 50
    RECT_W      DW 120
    RECT_H      DW 100
    RECT_COL    DB 4                    ; Red (4)

; -----------------------------------------------------------------------------
; CODE SEGMENT
; -----------------------------------------------------------------------------

    ; Labels for the report at the end of the program.
    RPT_HEAD DB 0DH, 0AH, 'Results:', 0DH, 0AH, '$'
    RPT_NL   DB 0DH, 0AH, '$'
    RPT_N_RECT_X DB '  RECT_X = ', '$'
    RPT_N_RECT_Y DB '  RECT_Y = ', '$'
    RPT_N_RECT_W DB '  RECT_W = ', '$'
    RPT_N_RECT_H DB '  RECT_H = ', '$'
    RPT_N_RECT_COL DB '  RECT_COL = ', '$'
.CODE
MAIN PROC
    ; --- Step 1: Initialize DS ---
    MOV AX, @DATA
    MOV DS, AX

    ; --- Step 2: Mode 13h ---
    MOV AX, 0013H
    INT 10H

    ; --- Step 3: ES -> Video RAM ---
    MOV AX, 0A000H
    MOV ES, AX

    ; --- Step 4: Drawing Loop ---
    ; Logic: For Row = Y to Y+H, Draw Line(X, Width)
    
    MOV DX, RECT_H                      ; ROW COUNTER (Height)
    MOV BX, RECT_Y                      ; CURRENT ROW (Y)

L_DRAW_ROW:
    ; Calculate Row Start: DI = (BX * 320) + RECT_X
    MOV AX, BX
    PUSH DX                             ; Save Loop Counter (Height)
    
    MOV DX, 320
    MUL DX                              ; DX:AX = 320 * Y
    ADD AX, RECT_X
    MOV DI, AX                          ; DI = Pixel Address
    
    ; Draw One Horizontal Line
    MOV CX, RECT_W                      ; Width (Pixels in row)
    MOV AL, RECT_COL
    REP STOSB                           ; Fill Row
    
    POP DX                              ; Restore Loop Counter
    INC BX                              ; Next Row (Y++)
    DEC DX                              ; Height--
    JNZ L_DRAW_ROW

    ; --- Step 5: Wait & Exit ---
    MOV AH, 00H
    INT 16H

    MOV AX, 0003H
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

    LEA DX, RPT_N_RECT_X
    CALL RPT_SAY
    MOV AX, RECT_X
    CALL RPT_DECIMAL
    LEA DX, RPT_NL
    CALL RPT_SAY

    LEA DX, RPT_N_RECT_Y
    CALL RPT_SAY
    MOV AX, RECT_Y
    CALL RPT_DECIMAL
    LEA DX, RPT_NL
    CALL RPT_SAY

    LEA DX, RPT_N_RECT_W
    CALL RPT_SAY
    MOV AX, RECT_W
    CALL RPT_DECIMAL
    LEA DX, RPT_NL
    CALL RPT_SAY

    LEA DX, RPT_N_RECT_H
    CALL RPT_SAY
    MOV AX, RECT_H
    CALL RPT_DECIMAL
    LEA DX, RPT_NL
    CALL RPT_SAY

    LEA DX, RPT_N_RECT_COL
    CALL RPT_SAY
    XOR AX, AX
    MOV AL, RECT_COL
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
; 1. RASTERIZATION:
;    Filling a shape is done by "rasterizing" it—breaking it down into 
;    horizontal scanlines. This effectively treats a 2D area fill as a set 
;    of 1D line fills.
;
; 2. OPTIMIZATION:
;    Calculating the address from scratch (MUL 320) each row is slow.
;    Faster method: Calculate first row address, then just ADD DI, 320 
;    at the end of each loop iteration.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
