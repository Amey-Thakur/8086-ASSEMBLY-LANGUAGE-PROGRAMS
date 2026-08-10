; =============================================================================
; TITLE: The Text Mode Colour Attributes
; DESCRIPTION: Writes every foreground and background combination directly into video memory, where the attribute byte lives.
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
    VIDEO_SEG EQU 0B800H                ; Colour text mode video memory
    COLUMNS   EQU 80

    M_TITLE DB 'The sixteen colours, written straight into video memory', 0DH, 0AH, '$'
    M_HOW   DB 'Each cell is two bytes: the character, then its attribute.', 0DH, 0AH, '$'
    M_ATTR  DB 'The attribute is background in the high nibble and foreground '
            DB 'in the low one.', 0DH, 0AH, '$'
    M_CELLS DB 0DH, 0AH, 'Cells written: $'
    M_WHERE DB 0DH, 0AH, 'They were placed on rows 3 to 6, starting at column 4.'
            DB 0DH, 0AH, '$'
    M_FASTER DB 'Writing memory needs no interrupt at all, which is why every '
            DB 'game did it this way.', 0DH, 0AH, '$'

; -----------------------------------------------------------------------------
; CODE SEGMENT
; -----------------------------------------------------------------------------
.CODE
START:
    MOV AX, @DATA
    MOV DS, AX

    LEA DX, M_TITLE
    CALL PRINT_MESSAGE
    LEA DX, M_HOW
    CALL PRINT_MESSAGE
    LEA DX, M_ATTR
    CALL PRINT_MESSAGE

    ; -------------------------------------------------------------------------
    ; ES POINTS AT THE VIDEO SEGMENT. A CELL AT ROW R COLUMN C IS AT OFFSET
    ; (R * 80 + C) * 2, BECAUSE EVERY CELL IS TWO BYTES.
    ; -------------------------------------------------------------------------
    MOV AX, VIDEO_SEG
    MOV ES, AX

    XOR BP, BP                          ; Cells written
    MOV BX, 0                           ; Foreground colour

EACH_FOREGROUND:
    ; ---- work out where this row starts -------------------------------------
    MOV AX, BX
    SHR AX, 2                           ; Four colours to a row
    ADD AX, 3                           ; First row used
    MOV DX, COLUMNS
    MUL DX
    MOV DI, AX

    MOV AX, BX
    AND AX, 3                           ; Which of the four on this row
    MOV CX, 18
    MUL CX                              ; Eighteen columns apart
    ADD AX, 4                           ; First column used
    ADD DI, AX

    SHL DI, 1                           ; Two bytes to a cell

    ; ---- the attribute: this foreground on a blue background ----------------
    MOV AH, BL
    AND AH, 0FH
    OR  AH, 10H                         ; Background one, blue

    ; ---- four characters showing the colour number --------------------------
    MOV AL, 'C'
    MOV ES:[DI], AX
    ADD DI, 2
    INC BP

    MOV AL, BL
    CMP AL, 10
    JB SINGLE_DIGIT

    MOV AL, '1'
    MOV ES:[DI], AX
    ADD DI, 2
    INC BP
    MOV AL, BL
    SUB AL, 10
    ADD AL, '0'
    MOV ES:[DI], AX
    ADD DI, 2
    INC BP
    JMP AFTER_NUMBER

SINGLE_DIGIT:
    ADD AL, '0'
    MOV ES:[DI], AX
    ADD DI, 2
    INC BP

AFTER_NUMBER:
    MOV AL, ' '
    MOV ES:[DI], AX
    INC BP

    INC BX
    CMP BX, 16
    JB EACH_FOREGROUND

    ; -------------------------------------------------------------------------
    ; THE CURSOR IS MOVED BELOW THE TABLE. WRITING VIDEO MEMORY DIRECTLY DOES
    ; NOT MOVE IT, WHICH IS BOTH THE ADVANTAGE AND THE THING TO REMEMBER.
    ; -------------------------------------------------------------------------
    MOV AH, 02H
    MOV BH, 0
    MOV DH, 9
    MOV DL, 0
    INT 10H

    LEA DX, M_CELLS
    CALL PRINT_MESSAGE
    MOV AX, BP
    CALL PRINT_DECIMAL
    LEA DX, M_WHERE
    CALL PRINT_MESSAGE
    LEA DX, M_FASTER
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
; 1. Two bytes to a cell:
;    - The low byte is the character and the high byte its attribute.
;    - So a word write at the right offset sets both at once, as here.
;    - The offset is (row times 80 plus column) doubled.
; 2. The attribute byte:
;    - Bits 0 to 3 are the foreground colour and bits 4 to 6 the background.
;    - Bit 7 is either blinking or bright backgrounds, depending on the adapter.
;    - Sixteen foregrounds and eight backgrounds gives the familiar palette.
; 3. Direct writes bypass the cursor:
;    - Nothing about writing memory moves the cursor or scrolls the screen.
;    - That is why it is fast, and why the cursor must be moved by hand afterwards.
;    - B800h is the colour text segment; a monochrome adapter used B000h.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
