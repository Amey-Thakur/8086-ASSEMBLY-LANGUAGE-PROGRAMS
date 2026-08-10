; =============================================================================
; TITLE: A Running Light
; DESCRIPTION: Moves a single lit lamp along a row of eight and back, by
;              rotating one bit through a port.
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
    LAMPS   EQU 4                       ; The lamp port
    SWEEPS  EQU 2

    M_HEAD  DB 'A single lamp travelling along eight and back:', 0DH, 0AH, '$'

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

    MOV BP, SWEEPS

SWEEP:
    ; -------------------------------------------------------------------------
    ; ONE BIT, SHIFTED LEFT SEVEN TIMES AND THEN RIGHT SEVEN TIMES. A ROTATE
    ; WOULD WRAP AT THE END AND JUMP STRAIGHT BACK TO THE FIRST LAMP; A SHIFT
    ; STOPS, WHICH IS WHAT MAKES THE MOVEMENT LOOK LIKE A SWEEP RATHER THAN A
    ; CIRCLE.
    ; -------------------------------------------------------------------------
    MOV AL, 00000001B
    MOV CX, 8

RIGHT_TO_LEFT:
    OUT LAMPS, AL
    PUSH AX
    PUSH CX
    CALL SHOW_BITS
    CALL NEWLINE
    POP CX
    POP AX

    SHL AL, 1
    LOOP RIGHT_TO_LEFT

    MOV AL, 10000000B
    MOV CX, 8

LEFT_TO_RIGHT:
    OUT LAMPS, AL
    PUSH AX
    PUSH CX
    CALL SHOW_BITS
    CALL NEWLINE
    POP CX
    POP AX

    SHR AL, 1
    LOOP LEFT_TO_RIGHT

    DEC BP
    JNZ SWEEP

    ; Leave them all off
    MOV AL, 0
    OUT LAMPS, AL

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
; 1. SHIFT, NOT ROTATE:
;    - A rotate makes the lamp reappear at the far end immediately. A
;    - shift lets it fall off, and the second loop brings it back, which
;    - is what a sweep looks like.
; 2. TURNING THEM OFF AT THE END:
;    - A port latch holds its value after the program ends, so a lamp left
;    - lit stays lit. Leaving hardware in a known state is part of
;    - finishing.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
