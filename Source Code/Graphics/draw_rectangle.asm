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

    MOV AH, 4CH
    INT 21H
MAIN ENDP
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
