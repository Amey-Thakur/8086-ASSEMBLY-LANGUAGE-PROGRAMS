; =============================================================================
; TITLE: A Water Level Controller
; DESCRIPTION: Reads two float switches and drives a pump and an alarm, with
;              hysteresis so the pump does not chatter at the threshold.
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
    SENSORS EQU 62                      ; Bit 0 low float, bit 1 high float
    OUTPUTS EQU 63                      ; Bit 0 pump, bit 1 alarm

    ; A sequence of sensor readings to work through, standing in for a tank
    ; filling and emptying.
    READINGS DB 00000000B               ; below both floats
             DB 00000001B               ; above the low float
             DB 00000011B               ; above both
             DB 00000001B               ; falling back below the high float
             DB 00000000B               ; below both again
    HOWMANY EQU 5

    PUMP    EQU 00000001B
    ALARM   EQU 00000010B
    STATE   DB 0

    M_READ  DB 'sensors $'
    M_OUT   DB '   outputs $'
    M_FILL  DB '   filling', 0DH, 0AH, '$'
    M_HOLD  DB '   holding', 0DH, 0AH, '$'
    M_FULL  DB '   full, pump off', 0DH, 0AH, '$'

; -----------------------------------------------------------------------------
; CODE SEGMENT
; -----------------------------------------------------------------------------
.CODE
START:
    MOV AX, @DATA
    MOV DS, AX

    LEA SI, READINGS
    MOV CX, HOWMANY

EACH_READING:
    ; Stand in for the floats
    MOV AL, [SI]
    OUT SENSORS, AL

    IN  AL, SENSORS
    MOV BL, AL                          ; The two float bits

    PUSH CX
    PUSH SI

    LEA DX, M_READ
    MOV AH, 09H
    INT 21H
    MOV AL, BL
    CALL SHOW_BITS

    ; -------------------------------------------------------------------------
    ; THE HYSTERESIS IS THE WHOLE DESIGN. THE PUMP STARTS WHEN THE WATER IS
    ; BELOW THE LOW FLOAT AND STOPS ONLY WHEN IT REACHES THE HIGH ONE. WITH A
    ; SINGLE THRESHOLD THE PUMP WOULD SWITCH ON AND OFF CONTINUOUSLY AS THE
    ; SURFACE MOVED, WHICH DESTROYS THE PUMP AND THE RELAY BOTH.
    ; -------------------------------------------------------------------------
    TEST BL, 00000010B                  ; Above the high float?
    JNZ  TANK_FULL

    TEST BL, 00000001B                  ; Above the low float?
    JZ   TANK_LOW

    ; Between the two: leave the pump as it is
    LEA DX, M_HOLD
    JMP APPLY

TANK_LOW:
    OR  BYTE PTR STATE, PUMP            ; Start filling
    LEA DX, M_FILL
    JMP APPLY

TANK_FULL:
    MOV AL, PUMP
    NOT AL
    AND BYTE PTR STATE, AL              ; Stop the pump
    LEA DX, M_FULL

APPLY:
    PUSH DX
    MOV AL, STATE
    OUT OUTPUTS, AL

    LEA DX, M_OUT
    MOV AH, 09H
    INT 21H
    MOV AL, STATE
    CALL SHOW_BITS
    POP DX

    MOV AH, 09H
    INT 21H

    POP SI
    POP CX
    INC SI
    LOOP EACH_READING

    ; Everything off
    MOV BYTE PTR STATE, 0
    MOV AL, 0
    OUT OUTPUTS, AL

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
; 1. TWO FLOATS, NOT ONE:
;    - A single switch at one height makes the pump start and stop many
;    - times a minute as the surface ripples. Two, with the pump running
;    - between them, gives one long cycle instead.
; 2. THE MIDDLE CASE CHANGES NOTHING:
;    - Between the floats the controller deliberately leaves the pump as
;    - it found it. That memory of the previous state is what hysteresis
;    - is, and it is why STATE has to persist between readings.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
