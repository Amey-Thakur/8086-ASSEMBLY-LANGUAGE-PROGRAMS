; =============================================================================
; TITLE: Driving a Seven Segment Display
; DESCRIPTION: Sends each digit from nought to nine to a display port, using a
;              lookup table rather than working the pattern out.
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
    DISPLAY EQU 199                     ; The numeric display port

    ; Which segments to light for each digit. The bits are, from the lowest,
    ; a b c d e f g and the decimal point, where a is the top bar and g the
    ; middle one.
    ;
    ;      aaa
    ;     f   b
    ;      ggg
    ;     e   c
    ;      ddd
    PATTERN DB 3FH, 06H, 5BH, 4FH, 66H
            DB 6DH, 7DH, 07H, 7FH, 6FH

    M_HEAD  DB 'digit  segments  sent to port 199', 0DH, 0AH, '$'
    GAP     DB '      $'
    SMALLGAP DB '  $'

; -----------------------------------------------------------------------------
; CODE SEGMENT
; -----------------------------------------------------------------------------
.CODE
START:
    MOV AX, @DATA
    MOV DS, AX

    LEA DX, M_HEAD
    MOV AH, 09H
    INT 21H

    XOR BX, BX                          ; The digit

EACH_DIGIT:
    CMP BX, 10
    JAE FINISHED

    ; Show the digit
    MOV AX, BX
    PUSH BX
    CALL PRINT_DECIMAL
    LEA DX, GAP
    MOV AH, 09H
    INT 21H
    POP BX

    ; -------------------------------------------------------------------------
    ; THE PATTERN IS LOOKED UP RATHER THAN CALCULATED. THERE IS NO ARITHMETIC
    ; RELATION BETWEEN A DIGIT AND THE SEGMENTS THAT DRAW IT, SO A TABLE IS
    ; NOT A SHORTCUT HERE BUT THE ONLY SENSIBLE METHOD.
    ; -------------------------------------------------------------------------
    MOV AL, PATTERN[BX]
    MOV BP, AX                          ; Keep it for the port write

    PUSH BX
    CALL SHOW_BITS
    LEA DX, SMALLGAP
    MOV AH, 09H
    INT 21H
    POP BX

    ; Out it goes to the display
    MOV AX, BP
    OUT DISPLAY, AL

    PUSH BX
    MOV AX, BP
    AND AX, 0FFH
    CALL PRINT_DECIMAL
    CALL NEWLINE
    POP BX

    INC BX
    JMP EACH_DIGIT

FINISHED:
    MOV AX, 4C00H
    INT 21H

; -----------------------------------------------------------------------------
; SHOW_BITS
;
; Prints AL as eight ones and zeros, most significant first. A port value is
; a set of independent lines rather than a number, so binary is the form that
; says what it means.
; -----------------------------------------------------------------------------
SHOW_BITS PROC
    PUSH AX
    PUSH CX
    PUSH DX

    MOV CX, 8

SB_LOOP:
    SHL AL, 1
    MOV DL, '0'
    JNC SB_EMIT
    MOV DL, '1'

SB_EMIT:
    PUSH AX
    MOV AH, 02H
    INT 21H
    POP AX
    LOOP SB_LOOP

    POP DX
    POP CX
    POP AX
    RET
SHOW_BITS ENDP

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

END START

; =============================================================================
; TECHNICAL NOTES
; =============================================================================
; 1. A TABLE, NOT A FORMULA:
;    - The seven segments that draw a three have nothing arithmetic in
;    - common with those that draw a two. Ten bytes of table replace code
;    - that could not be written.
; 2. COMMON ANODE INVERTS IT:
;    - On a common anode display a low line lights the segment, so every
;    - pattern is complemented. NOT AL before the OUT is the whole
;    - difference, and getting it wrong lights everything except the digit.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
