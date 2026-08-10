; =============================================================================
; TITLE: Seven Segment Display Driver
; DESCRIPTION: Turns each digit into the pattern of lit segments, driven from a lookup table rather than worked out.
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
    DISPLAY_PORT EQU 199

    ; Bit order g f e d c b a, so bit 0 is the top bar and bit 6 the middle.
    ;              a
    ;            f   b
    ;              g
    ;            e   c
    ;              d
    SEGMENTS DB 0111111B    ; 0  a b c d e f
             DB 0000110B    ; 1  b c
             DB 1011011B    ; 2  a b d e g
             DB 1001111B    ; 3  a b c d g
             DB 1100110B    ; 4  b c f g
             DB 1101101B    ; 5  a c d f g
             DB 1111101B    ; 6  a c d e f g
             DB 0000111B    ; 7  a b c
             DB 1111111B    ; 8  all seven
             DB 1101111B    ; 9  a b c d f g

    NUMBER  DW 40961                    ; The number to show, digit by digit
    DIGITS  DB 5 DUP (0)

    M_TITLE DB 'Driving a seven segment display from a table', 0DH, 0AH, '$'
    M_SHOW  DB 'Showing $'
    M_HEAD  DB 0DH, 0AH, 'digit  pattern  segments lit', 0DH, 0AH, '$'
    M_GAP   DB '      $'
    M_TWO   DB '       $'
    M_NAMES DB 'abcdefg'
    M_COUNT DB 0DH, 0AH, 'Segments lit altogether: $'
    M_WHY   DB 'A table is one memory read per digit. Working the pattern out '
            DB 'would take a dozen instructions and be no more correct.', 0DH, 0AH, '$'
    M_DASH  DB '-$'

; -----------------------------------------------------------------------------
; CODE SEGMENT
; -----------------------------------------------------------------------------
.CODE
START:
    MOV AX, @DATA
    MOV DS, AX

    LEA DX, M_TITLE
    CALL PRINT_MESSAGE
    LEA DX, M_SHOW
    CALL PRINT_MESSAGE
    MOV AX, NUMBER
    CALL PRINT_DECIMAL
    CALL NEWLINE
    LEA DX, M_HEAD
    CALL PRINT_MESSAGE

    ; -------------------------------------------------------------------------
    ; THE DIGITS COME OUT OF A DIVISION LOWEST FIRST, SO THEY ARE STORED AND
    ; THEN READ BACK IN REVERSE TO DISPLAY THEM IN THE ORDER WRITTEN.
    ; -------------------------------------------------------------------------
    MOV AX, NUMBER
    LEA DI, DIGITS
    MOV BX, 10
    MOV CX, 5

SPLIT_DIGITS:
    XOR DX, DX
    DIV BX
    MOV [DI], DL                        ; The remainder is the digit
    INC DI
    LOOP SPLIT_DIGITS

    ; -------------------------------------------------------------------------
    ; NOW FROM THE TOP DOWN. BP TOTALS THE LIT SEGMENTS, WHICH IS WHAT DECIDES
    ; THE CURRENT A REAL DISPLAY WILL DRAW.
    ; -------------------------------------------------------------------------
    XOR BP, BP
    MOV SI, 4                           ; Highest digit first
    MOV CX, 5

EACH_DIGIT:
    ; ---- the digit ----------------------------------------------------------
    MOV BL, DIGITS[SI]
    XOR BH, BH
    MOV AX, BX
    CALL PRINT_DECIMAL
    LEA DX, M_GAP
    CALL PRINT_MESSAGE

    ; ---- its pattern, from the table ----------------------------------------
    MOV AL, SEGMENTS[BX]
    MOV DI, BX                          ; Keep the digit, BX is needed below
    XOR BH, BH
    MOV BL, AL
    MOV AX, BX
    CALL PRINT_DECIMAL
    LEA DX, M_TWO
    CALL PRINT_MESSAGE

    ; ---- and the same pattern as letters ------------------------------------
    MOV AL, BL
    CALL SHOW_SEGMENTS

    CALL NEWLINE
    DEC SI
    LOOP EACH_DIGIT

    LEA DX, M_COUNT
    CALL PRINT_MESSAGE
    MOV AX, BP
    CALL PRINT_DECIMAL
    CALL NEWLINE

    LEA DX, M_WHY
    CALL PRINT_MESSAGE

    MOV AH, 4CH
    INT 21H

; -----------------------------------------------------------------------------
; SHOW_SEGMENTS
;
; Prints the letter of each lit segment in AL, lowest bit first, and adds the
; number lit to BP. The port is driven with the same pattern.
; -----------------------------------------------------------------------------
SHOW_SEGMENTS PROC
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX
    PUSH SI

    OUT DISPLAY_PORT, AL                ; What the hardware receives

    MOV BL, AL
    XOR SI, SI
    MOV CX, 7

EACH_SEGMENT:
    TEST BL, 1
    JZ SEGMENT_OFF

    INC BP
    MOV DL, M_NAMES[SI]
    MOV AH, 02H
    INT 21H
    JMP SEGMENT_NEXT

SEGMENT_OFF:
    LEA DX, M_DASH
    CALL PRINT_MESSAGE

SEGMENT_NEXT:
    SHR BL, 1
    INC SI
    LOOP EACH_SEGMENT

    POP SI
    POP DX
    POP CX
    POP BX
    POP AX
    RET
SHOW_SEGMENTS ENDP

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
; 1. A table beats arithmetic:
;    - Ten patterns is ten bytes, read with one indexed access.
;    - There is no formula relating a digit to its segments, so any code would be a table in disguise.
;    - This is the standard shape for any decoder: characters, keypads, instruction sets.
; 2. Digits come out backwards:
;    - Dividing by ten yields the lowest digit first, which is the wrong end to display.
;    - Storing them and walking back down is the simplest fix.
;    - The alternative, pushing them and popping them, uses the stack to reverse instead.
; 3. Counting the lit segments:
;    - Each lit segment draws current, so the total decides the supply needed.
;    - Eight lights all seven; one lights only two.
;    - The same bit walking loop that prints the letters does the counting.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
