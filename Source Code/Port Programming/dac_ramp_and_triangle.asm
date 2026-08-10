; =============================================================================
; TITLE: Generating a Waveform Through a DAC
; DESCRIPTION: Sends a rising ramp and then a triangle to a converter port,
;              which is how a waveform is produced without any analogue parts.
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
    DAC     EQU 9
    STEP    EQU 32                      ; Eight samples across the full range

    M_RAMP  DB 'A rising ramp:', 0DH, 0AH, '$'
    M_TRI   DB 'A triangle:', 0DH, 0AH, '$'
    GAP     DB ' $'

; -----------------------------------------------------------------------------
; CODE SEGMENT
; -----------------------------------------------------------------------------
.CODE
START:
    MOV AX, @DATA
    MOV DS, AX

    ; -------------------------------------------------------------------------
    ; A DAC TURNS THE BYTE ON ITS PORT INTO A VOLTAGE. SENDING A RISING SERIES
    ; PRODUCES A RAMP, AND THE SHAPE OF THE OUTPUT IS ENTIRELY THE SHAPE OF
    ; THE NUMBERS SENT TO IT.
    ; -------------------------------------------------------------------------
    LEA DX, M_RAMP
    MOV AH, 09H
    INT 21H

    XOR AL, AL
    MOV CX, 8

RAMP:
    OUT DAC, AL
    PUSH AX
    PUSH CX
    XOR AH, AH
    CALL PRINT_DECIMAL
    LEA DX, GAP
    MOV AH, 09H
    INT 21H
    POP CX
    POP AX

    ADD AL, STEP
    LOOP RAMP

    CALL NEWLINE

    ; -------------------------------------------------------------------------
    ; A TRIANGLE IS A RAMP UP FOLLOWED BY A RAMP DOWN. NOTHING CHANGES EXCEPT
    ; THE SIGN OF THE STEP, WHICH IS WHY BOTH ARE WRITTEN AS ONE ROUTINE IN
    ; ANY REAL SIGNAL GENERATOR.
    ; -------------------------------------------------------------------------
    LEA DX, M_TRI
    MOV AH, 09H
    INT 21H

    XOR AL, AL
    MOV CX, 8

TRI_UP:
    OUT DAC, AL
    PUSH AX
    PUSH CX
    XOR AH, AH
    CALL PRINT_DECIMAL
    LEA DX, GAP
    MOV AH, 09H
    INT 21H
    POP CX
    POP AX

    ADD AL, STEP
    LOOP TRI_UP

    MOV AL, 224                         ; Just below the top, going down
    MOV CX, 8

TRI_DOWN:
    OUT DAC, AL
    PUSH AX
    PUSH CX
    XOR AH, AH
    CALL PRINT_DECIMAL
    LEA DX, GAP
    MOV AH, 09H
    INT 21H
    POP CX
    POP AX

    SUB AL, STEP
    LOOP TRI_DOWN

    CALL NEWLINE

    MOV AL, 0                           ; Back to zero volts
    OUT DAC, AL

    MOV AX, 4C00H
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

END START

; =============================================================================
; TECHNICAL NOTES
; =============================================================================
; 1. THE STEP DECIDES THE SMOOTHNESS:
;    - Eight samples across the range gives a visible staircase. Two
;    - hundred and fifty six would give a smooth ramp and take thirty two
;    - times as long, which for a fixed sample rate means a lower
;    - frequency.
; 2. WRAPPING IS AUDIBLE:
;    - Adding thirty two to 224 gives nought rather than 256, so a ramp
;    - that overruns drops straight to zero volts. In a signal generator
;    - that is a click on every cycle.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
