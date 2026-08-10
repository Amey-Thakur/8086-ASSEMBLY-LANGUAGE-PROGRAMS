; =============================================================================
; TITLE: Traffic Light Controller
; DESCRIPTION: A four state machine driving the lamp port, held in each state for a fixed number of ticks.
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
    LAMP_PORT EQU 4

    ; One entry per state: the lamp pattern and how long it lasts.
    ; Bit 0 is red, bit 1 amber, bit 2 green.
    PATTERN DB 001B, 011B, 100B, 010B
    HOLDFOR DB 6,    2,    6,    2
    STATES  EQU 4

    M_TITLE DB 'A traffic light as a four state machine', 0DH, 0AH, '$'
    M_HEAD  DB 'tick  state  lamps  port', 0DH, 0AH, '$'
    M_RED   DB 'red        $'
    M_RAMB  DB 'red+amber  $'
    M_GREEN DB 'green      $'
    M_AMBER DB 'amber      $'
    M_GAP   DB '     $'
    M_TWO   DB '  $'
    M_CYCLE DB 0DH, 0AH, 'Two full cycles ran, thirty-two ticks in all.', 0DH, 0AH, '$'
    M_WHY   DB 'The pattern and the duration are data, so the sequence changes '
            DB 'without touching the code.', 0DH, 0AH, '$'

; -----------------------------------------------------------------------------
; CODE SEGMENT
; -----------------------------------------------------------------------------
.CODE
START:
    MOV AX, @DATA
    MOV DS, AX

    LEA DX, M_TITLE
    CALL PRINT_MESSAGE
    LEA DX, M_HEAD
    CALL PRINT_MESSAGE

    ; -------------------------------------------------------------------------
    ; BP COUNTS TICKS ACROSS THE WHOLE RUN SO THE REPORT READS AS A TIMELINE.
    ; TWO CYCLES ARE RUN, WHICH IS ENOUGH TO SHOW THE SEQUENCE REPEATING AND
    ; STILL TERMINATES.
    ; -------------------------------------------------------------------------
    XOR BP, BP                          ; Tick number
    MOV CX, 2                           ; Two full cycles

EACH_CYCLE:
    PUSH CX
    XOR SI, SI                          ; State number
    MOV CX, STATES

EACH_STATE:
    PUSH CX

    ; ---- hold this state for its own number of ticks ------------------------
    MOV BL, HOLDFOR[SI]
    XOR BH, BH
    MOV CX, BX

HOLD_TICK:
    ; The lamp is written on every tick, which is what a real controller does:
    ; the port is not remembered by the hardware, only by the program.
    MOV BL, PATTERN[SI]
    XOR BH, BH
    MOV AL, BL
    OUT LAMP_PORT, AL

    CALL REPORT_TICK
    INC BP
    LOOP HOLD_TICK

    INC SI
    POP CX
    LOOP EACH_STATE

    POP CX
    LOOP EACH_CYCLE

    LEA DX, M_CYCLE
    CALL PRINT_MESSAGE
    LEA DX, M_WHY
    CALL PRINT_MESSAGE

    MOV AH, 4CH
    INT 21H

; -----------------------------------------------------------------------------
; REPORT_TICK
;
; Prints one line: the tick number, the state number, its name and the value
; sent to the port. SI holds the state and BP the tick.
; -----------------------------------------------------------------------------
REPORT_TICK PROC
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX

    MOV AX, BP
    CALL PRINT_DECIMAL
    LEA DX, M_GAP
    CALL PRINT_MESSAGE

    MOV AX, SI
    CALL PRINT_DECIMAL
    LEA DX, M_GAP
    CALL PRINT_MESSAGE

    ; ---- the name of the state ----------------------------------------------
    CMP SI, 0
    JNE TRY_RAMB
    LEA DX, M_RED
    JMP SAY_NAME
TRY_RAMB:
    CMP SI, 1
    JNE TRY_GREEN
    LEA DX, M_RAMB
    JMP SAY_NAME
TRY_GREEN:
    CMP SI, 2
    JNE USE_AMBER
    LEA DX, M_GREEN
    JMP SAY_NAME
USE_AMBER:
    LEA DX, M_AMBER

SAY_NAME:
    CALL PRINT_MESSAGE

    MOV BL, PATTERN[SI]
    XOR BH, BH
    MOV AX, BX
    CALL PRINT_DECIMAL
    CALL NEWLINE

    POP DX
    POP CX
    POP BX
    POP AX
    RET
REPORT_TICK ENDP

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
; 1. The sequence lives in data:
;    - PATTERN holds the lamps for each state and HOLDFOR how long it lasts.
;    - Adding a state means adding a byte to each table and changing STATES.
;    - A machine built out of jumps instead would need the code rewritten.
; 2. Why the port is written every tick:
;    - An output port holds whatever was last written to it, with no memory of state.
;    - Writing it once per tick is what a real controller does, and is idempotent.
;    - The port journal in the simulator therefore shows the whole timeline.
; 3. Red and amber together:
;    - The pattern is a bit mask, so two lamps can be lit at once.
;    - State one is 011B, which is red and amber, as used in the United Kingdom.
;    - A country without that phase would simply have three states in the table.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
