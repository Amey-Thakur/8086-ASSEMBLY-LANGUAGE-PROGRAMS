; =============================================================================
; TITLE: Plotting Pixels In Mode 13h
; DESCRIPTION: Sets the 320 by 200 graphics mode and writes pixels through the BIOS, then restores the text mode it started in.
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
    M_TITLE DB 'Mode 13h: 320 by 200 pixels, 256 colours', 0DH, 0AH, '$'
    M_PLOT  DB 'Plotted $'
    M_PIX   DB ' pixels: a diagonal, a horizontal run and a box outline.', 0DH, 0AH, '$'
    M_READ  DB 'Reading the pixel at 60,50 back gave colour $'
    M_MATCH DB '  which is what was written there.', 0DH, 0AH, '$'
    M_DIFF  DB '  which is not what was written there.', 0DH, 0AH, '$'
    M_BACK  DB 'Text mode restored, so the screen is usable again.', 0DH, 0AH, '$'

; -----------------------------------------------------------------------------
; CODE SEGMENT
; -----------------------------------------------------------------------------
.CODE
START:
    MOV AX, @DATA
    MOV DS, AX

    ; -------------------------------------------------------------------------
    ; THE MODE IS SET BEFORE ANYTHING IS DRAWN AND PUT BACK AFTERWARDS. A
    ; PROGRAM THAT EXITS IN A GRAPHICS MODE LEAVES THE OPERATOR LOOKING AT A
    ; SCREEN THAT CANNOT SHOW TEXT.
    ; -------------------------------------------------------------------------
    MOV AX, 0013H                       ; Service 00h, mode 13h
    INT 10H

    XOR BP, BP                          ; Pixels plotted

    ; ---- a diagonal ---------------------------------------------------------
    MOV CX, 40                          ; Column
    MOV DX, 30                          ; Row
    MOV AL, 15                          ; White
    MOV DI, 60
DIAGONAL:
    CALL PLOT
    INC CX
    INC DX
    DEC DI
    JNZ DIAGONAL

    ; ---- a horizontal run in another colour ---------------------------------
    MOV CX, 40
    MOV DX, 50
    MOV AL, 4                           ; Red
    MOV DI, 80
HORIZONTAL:
    CALL PLOT
    INC CX
    DEC DI
    JNZ HORIZONTAL

    ; ---- a box outline ------------------------------------------------------
    MOV AL, 2                           ; Green
    MOV DX, 100
    MOV CX, 100
    MOV DI, 60
BOX_TOP:
    CALL PLOT
    INC CX
    DEC DI
    JNZ BOX_TOP

    MOV DX, 140
    MOV CX, 100
    MOV DI, 60
BOX_BOTTOM:
    CALL PLOT
    INC CX
    DEC DI
    JNZ BOX_BOTTOM

    MOV CX, 100
    MOV DX, 100
    MOV DI, 40
BOX_LEFT:
    CALL PLOT
    INC DX
    DEC DI
    JNZ BOX_LEFT

    MOV CX, 160
    MOV DX, 100
    MOV DI, 40
BOX_RIGHT:
    CALL PLOT
    INC DX
    DEC DI
    JNZ BOX_RIGHT

    ; -------------------------------------------------------------------------
    ; SERVICE 0DH READS A PIXEL BACK, WHICH IS HOW THE DRAWING IS CHECKED RATHER
    ; THAN TRUSTED. THE HORIZONTAL RUN COVERED 60,50 IN COLOUR 4.
    ; -------------------------------------------------------------------------
    MOV AH, 0DH
    MOV BH, 0
    MOV CX, 60
    MOV DX, 50
    INT 10H
    MOV SI, AX
    AND SI, 0FFH                        ; The colour comes back in AL

    ; ---- back to text before printing anything ------------------------------
    MOV AX, 0003H                       ; Mode 3, 80 by 25 colour text
    INT 10H

    LEA DX, M_TITLE
    CALL PRINT_MESSAGE

    LEA DX, M_PLOT
    CALL PRINT_MESSAGE
    MOV AX, BP
    CALL PRINT_DECIMAL
    LEA DX, M_PIX
    CALL PRINT_MESSAGE

    LEA DX, M_READ
    CALL PRINT_MESSAGE
    MOV AX, SI
    CALL PRINT_DECIMAL

    CMP SI, 4
    JNE COLOUR_WRONG
    LEA DX, M_MATCH
    CALL PRINT_MESSAGE
    JMP FINISHED

COLOUR_WRONG:
    LEA DX, M_DIFF
    CALL PRINT_MESSAGE

FINISHED:
    LEA DX, M_BACK
    CALL PRINT_MESSAGE

    MOV AH, 4CH
    INT 21H

; -----------------------------------------------------------------------------
; PLOT
;
; Writes one pixel: colour in AL, column in CX, row in DX. Service 0Ch takes
; them exactly there, so nothing has to be shuffled. BP counts the pixels.
; -----------------------------------------------------------------------------
PLOT PROC
    PUSH AX
    PUSH BX

    MOV AH, 0CH
    MOV BH, 0
    INT 10H
    INC BP

    POP BX
    POP AX
    RET
PLOT ENDP

; -----------------------------------------------------------------------------
; PRINT_DECIMAL
;
; Prints the unsigned value in AX as decimal, with no leading zeros.
; Every register it touches is restored, so a caller can rely on it.
; -----------------------------------------------------------------------------
PRINT_DECIMAL PROC
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX

    XOR CX, CX                          ; How many digits have been stacked
    MOV BX, 10

PD_DIVIDE:
    XOR DX, DX                          ; DX:AX is the dividend, so clear DX
    DIV BX                              ; AX = quotient, DX = this digit
    PUSH DX                             ; Digits arrive lowest first
    INC CX
    OR  AX, AX
    JNZ PD_DIVIDE                       ; Keep going until the quotient is zero

PD_EMIT:
    POP DX                              ; Unstacking reverses them into order
    ADD DL, '0'
    MOV AH, 02H
    INT 21H
    LOOP PD_EMIT

    POP DX
    POP CX
    POP BX
    POP AX
    RET
PRINT_DECIMAL ENDP

; -----------------------------------------------------------------------------
; NEWLINE
;
; Moves to the start of the next line. DOS needs both characters: the return
; moves the cursor to column zero and the feed moves it down a line.
; -----------------------------------------------------------------------------
NEWLINE PROC
    PUSH AX
    PUSH DX

    MOV DL, 0DH
    MOV AH, 02H
    INT 21H
    MOV DL, 0AH
    MOV AH, 02H
    INT 21H

    POP DX
    POP AX
    RET
NEWLINE ENDP

; -----------------------------------------------------------------------------
; PRINT_MESSAGE
;
; Prints the dollar terminated string at DS:DX, leaving AX exactly as it was.
;
; Service 09H needs the service number in AH, and AH is the top half of AX. A
; caller that has just computed a result into AX and then sets AH for itself
; destroys that result: 500 becomes 09F4H, which prints as 2548. Doing the call
; in here, around a push and a pop, removes the trap for good.
; -----------------------------------------------------------------------------
PRINT_MESSAGE PROC
    PUSH AX

    MOV AH, 09H
    INT 21H

    POP AX
    RET
PRINT_MESSAGE ENDP

END START

; =============================================================================
; TECHNICAL NOTES
; =============================================================================
; 1. Restore the mode you found:
;    - Mode 13h cannot display text, so printing in it produces nothing readable.
;    - Setting mode 3 again before printing is why the report appears at all.
;    - Exiting without restoring leaves the operator with an unusable screen.
; 2. The registers line up already:
;    - Service 0Ch wants the colour in AL, the column in CX and the row in DX.
;    - So a plotting loop can keep its coordinates in those registers and shuffle nothing.
;    - That is unusual for a BIOS call and worth taking advantage of.
; 3. Read a pixel back to check:
;    - Service 0Dh returns the colour at a position in AL.
;    - Reading back one known pixel turns a drawing into something testable.
;    - Only the low byte is meaningful, so the rest of AX is masked off.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
