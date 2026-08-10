; =============================================================================
; TITLE: Drawing A Sprite From A Bitmap
; DESCRIPTION: A shape held as rows of bits, plotted pixel by pixel, which is how every sprite on hardware of this era was stored.
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
    ; Eight rows of eight bits. A set bit is a pixel; the shape is an arrow.
    SPRITE  DB 00011000B
            DB 00111100B
            DB 01111110B
            DB 11011011B
            DB 00011000B
            DB 00011000B
            DB 00011000B
            DB 00011000B
    ROWS    EQU 8
    WIDTH   EQU 8

    AT_X    DW 100
    AT_Y    DW 60
    PLOTTED DW 0

    M_TITLE DB 'A sprite held as eight bytes of bits', 0DH, 0AH, '$'
    M_SHAPE DB 'The shape, as the bits read:', 0DH, 0AH, '$'
    M_ON    DB '#$'
    M_OFF   DB '.$'
    M_COUNT DB 0DH, 0AH, 'Pixels set in the bitmap: $'
    M_DREW  DB 'Pixels plotted on screen:  $'
    M_AGREE DB 0DH, 0AH, 'The two agree, so every set bit reached the screen.', 0DH, 0AH, '$'
    M_DISAG DB 0DH, 0AH, 'The two disagree.', 0DH, 0AH, '$'
    M_WHY   DB 'Eight bytes describe a sixty-four pixel shape, which is why '
            DB 'bitmaps were stored this way.', 0DH, 0AH, '$'

; -----------------------------------------------------------------------------
; CODE SEGMENT
; -----------------------------------------------------------------------------
.CODE
START:
    MOV AX, @DATA
    MOV DS, AX

    LEA DX, M_TITLE
    CALL PRINT_MESSAGE
    LEA DX, M_SHAPE
    CALL PRINT_MESSAGE

    ; -------------------------------------------------------------------------
    ; THE SHAPE IS SHOWN AS TEXT FIRST, WHICH IS BOTH A PICTURE AND A COUNT OF
    ; HOW MANY PIXELS OUGHT TO BE DRAWN. BP ACCUMULATES THAT COUNT.
    ; -------------------------------------------------------------------------
    XOR BP, BP
    XOR SI, SI
    MOV CX, ROWS

EACH_ROW_TEXT:
    PUSH CX
    MOV BL, SPRITE[SI]
    MOV CX, WIDTH

EACH_BIT_TEXT:
    ; The leftmost pixel is the highest bit, so the test walks down from bit 7.
    TEST BL, 10000000B
    JZ BIT_IS_CLEAR

    INC BP
    LEA DX, M_ON
    CALL PRINT_MESSAGE
    JMP BIT_TEXT_NEXT

BIT_IS_CLEAR:
    LEA DX, M_OFF
    CALL PRINT_MESSAGE

BIT_TEXT_NEXT:
    SHL BL, 1
    LOOP EACH_BIT_TEXT

    CALL NEWLINE
    INC SI
    POP CX
    LOOP EACH_ROW_TEXT

    ; -------------------------------------------------------------------------
    ; AND NOW THE SAME WALK, PLOTTING INSTEAD OF PRINTING. THE POSITION OF A
    ; PIXEL IS THE SPRITE ORIGIN PLUS ITS ROW AND COLUMN WITHIN THE SHAPE.
    ; -------------------------------------------------------------------------
    MOV AX, 0013H
    INT 10H

    XOR SI, SI
    MOV CX, ROWS

EACH_ROW_PLOT:
    PUSH CX
    MOV BL, SPRITE[SI]
    XOR DI, DI                          ; Column within the sprite
    MOV CX, WIDTH

EACH_BIT_PLOT:
    TEST BL, 10000000B
    JZ PLOT_NEXT

    PUSH CX
    MOV CX, AT_X
    ADD CX, DI
    MOV DX, AT_Y
    ADD DX, SI
    MOV AH, 0CH
    MOV AL, 14                          ; Yellow
    MOV BH, 0
    INT 10H
    POP CX
    INC PLOTTED

PLOT_NEXT:
    SHL BL, 1
    INC DI
    LOOP EACH_BIT_PLOT

    INC SI
    POP CX
    LOOP EACH_ROW_PLOT

    MOV AX, 0003H
    INT 10H

    LEA DX, M_COUNT
    CALL PRINT_MESSAGE
    MOV AX, BP
    CALL PRINT_DECIMAL
    CALL NEWLINE

    LEA DX, M_DREW
    CALL PRINT_MESSAGE
    MOV AX, PLOTTED
    CALL PRINT_DECIMAL

    MOV AX, PLOTTED
    CMP AX, BP
    JNE COUNTS_DIFFER

    LEA DX, M_AGREE
    CALL PRINT_MESSAGE
    JMP EXPLAIN

COUNTS_DIFFER:
    LEA DX, M_DISAG
    CALL PRINT_MESSAGE

EXPLAIN:
    LEA DX, M_WHY
    CALL PRINT_MESSAGE

    MOV AH, 4CH
    INT 21H

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
; 1. The highest bit is the leftmost pixel:
;    - Testing bit 7 and shifting left walks the row from left to right.
;    - Testing bit 0 and shifting right would draw every row mirrored.
;    - The binary literals in the data are written so the shape is readable in the source.
; 2. Counted two ways:
;    - The text pass counts the set bits; the plotting pass counts the pixels drawn.
;    - Comparing them catches a bit walked over or plotted twice.
;    - This is the cheapest possible self check for a drawing routine.
; 3. Why bitmaps and not pixel lists:
;    - Eight bytes describe sixty-four pixels, a saving of eight to one.
;    - On a machine with 640K of memory that mattered a great deal.
;    - The cost is a bit test per pixel, which is two instructions.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
