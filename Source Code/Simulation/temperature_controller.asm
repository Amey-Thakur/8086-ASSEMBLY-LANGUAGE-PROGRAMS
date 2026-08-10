; =============================================================================
; TITLE: Temperature Controller With Hysteresis
; DESCRIPTION: Switches a heater on and off around a target, with a dead band so it does not chatter at the boundary.
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
    HEATER_PORT EQU 127

    TARGET  EQU 22
    BAND    EQU 2                       ; Switch at target minus and plus this

    ; A sequence of readings, as a sensor would deliver them over time.
    READINGS DB 18, 19, 21, 23, 24, 25, 24, 22, 20, 19, 21, 24
    SAMPLES  EQU 12

    STATE_B DB 0                        ; 1 while the heater is on

    M_TITLE DB 'A heater controlled with a dead band', 0DH, 0AH, '$'
    M_SET   DB 'Target 22 degrees, switching at 20 and 24.', 0DH, 0AH, '$'
    M_HEAD  DB 0DH, 0AH, 'reading  heater  note', 0DH, 0AH, '$'
    M_GAP   DB '        $'
    M_ON    DB 'on      $'
    M_OFF   DB 'off     $'
    M_SWON  DB 'switched on, below 20', 0DH, 0AH, '$'
    M_SWOFF DB 'switched off, above 24', 0DH, 0AH, '$'
    M_HOLD  DB 'no change needed', 0DH, 0AH, '$'
    M_CYCLE DB 0DH, 0AH, 'Times the heater switched: $'
    M_WHY   DB 'Without the band a reading wobbling around 22 would switch the '
            DB 'relay on every sample.', 0DH, 0AH, '$'

; -----------------------------------------------------------------------------
; CODE SEGMENT
; -----------------------------------------------------------------------------
.CODE
START:
    MOV AX, @DATA
    MOV DS, AX

    LEA DX, M_TITLE
    CALL PRINT_MESSAGE
    LEA DX, M_SET
    CALL PRINT_MESSAGE
    LEA DX, M_HEAD
    CALL PRINT_MESSAGE

    XOR SI, SI
    XOR BP, BP                          ; How many times it switched
    MOV CX, SAMPLES

EACH_SAMPLE:
    ; ---- the reading --------------------------------------------------------
    MOV BL, READINGS[SI]
    XOR BH, BH
    MOV AX, BX
    CALL PRINT_DECIMAL
    LEA DX, M_GAP
    CALL PRINT_MESSAGE

    ; -------------------------------------------------------------------------
    ; THE DECISION. THE TWO THRESHOLDS ARE DIFFERENT, WHICH IS WHAT HYSTERESIS
    ; MEANS: THE POINT AT WHICH IT TURNS ON IS NOT THE POINT AT WHICH IT TURNS
    ; OFF, SO A READING BETWEEN THEM CHANGES NOTHING.
    ; -------------------------------------------------------------------------
    MOV DI, 0                           ; 0 unchanged, 1 turned on, 2 turned off

    CMP BX, TARGET - BAND
    JAE NOT_TOO_COLD

    CMP STATE_B, 1
    JE DECIDED
    MOV STATE_B, 1
    MOV DI, 1
    INC BP
    JMP DECIDED

NOT_TOO_COLD:
    CMP BX, TARGET + BAND
    JBE DECIDED                         ; Inside the band

    CMP STATE_B, 0
    JE DECIDED
    MOV STATE_B, 0
    MOV DI, 2
    INC BP

DECIDED:
    ; ---- drive the relay and report -----------------------------------------
    MOV AL, STATE_B
    OUT HEATER_PORT, AL

    CMP STATE_B, 1
    JNE SAY_OFF
    LEA DX, M_ON
    JMP SAY_STATE
SAY_OFF:
    LEA DX, M_OFF
SAY_STATE:
    CALL PRINT_MESSAGE

    CMP DI, 1
    JNE TRY_OFF_NOTE
    LEA DX, M_SWON
    JMP SAY_NOTE
TRY_OFF_NOTE:
    CMP DI, 2
    JNE USE_HOLD
    LEA DX, M_SWOFF
    JMP SAY_NOTE
USE_HOLD:
    LEA DX, M_HOLD
SAY_NOTE:
    CALL PRINT_MESSAGE

    INC SI
    LOOP EACH_SAMPLE

    LEA DX, M_CYCLE
    CALL PRINT_MESSAGE
    MOV AX, BP
    CALL PRINT_DECIMAL
    CALL NEWLINE

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
; 1. Two thresholds, not one:
;    - It turns on below target minus the band and off above target plus it.
;    - Between the two nothing happens, whichever way the reading is moving.
;    - A single threshold would switch on every crossing, however small.
; 2. Why chattering matters:
;    - A mechanical relay has a limited number of operations in it.
;    - Switching a heater on and off every second wears it out and wastes energy.
;    - The band trades a little accuracy for a great deal of relay life.
; 3. The state has to be remembered:
;    - The decision depends on whether the heater is already on.
;    - STATE_B holds that between samples, since the reading alone is not enough.
;    - This is what makes it a state machine rather than a pure function.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
