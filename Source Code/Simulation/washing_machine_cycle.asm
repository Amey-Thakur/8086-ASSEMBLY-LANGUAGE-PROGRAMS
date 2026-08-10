; =============================================================================
; TITLE: Washing Machine Cycle
; DESCRIPTION: Runs the phases of a wash in order, each with its own duration and its own set of driven outputs.
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
    MOTOR_PORT EQU 7

    ; Five phases. Each has a duration in minutes and an output pattern:
    ; bit 0 valve, bit 1 drum, bit 2 heater, bit 3 pump.
    MINUTES DB 4,     30,    3,     12,    5
    OUTPUTS DB 0001B, 0110B, 1000B, 0010B, 1010B
    PHASES  EQU 5

    N_FILL  DB 'Fill  $'
    N_WASH  DB 'Wash  $'
    N_DRAIN DB 'Drain $'
    N_RINSE DB 'Rinse $'
    N_SPIN  DB 'Spin  $'

    ; A table of the five name addresses, so the loop can pick one by number.
    NAMES   DW N_FILL, N_WASH, N_DRAIN, N_RINSE, N_SPIN

    M_TITLE DB 'A wash cycle, phase by phase', 0DH, 0AH, '$'
    M_HEAD  DB 'phase   minutes  outputs  valve drum heater pump', 0DH, 0AH, '$'
    M_GAP   DB '        $'
    M_TWO   DB '       $'
    M_ON    DB 'on    $'
    M_OFF   DB '--    $'
    M_TOTAL DB 0DH, 0AH, 'Total cycle time: $'
    M_MINS  DB ' minutes', 0DH, 0AH, '$'

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
    ; SI IS THE PHASE NUMBER. THE NAME TABLE HOLDS ADDRESSES, SO IT IS INDEXED
    ; BY SI DOUBLED WHILE THE BYTE TABLES ARE INDEXED BY SI ITSELF.
    ; -------------------------------------------------------------------------
    XOR SI, SI
    XOR BP, BP                          ; Total minutes
    MOV CX, PHASES

EACH_PHASE:
    ; ---- the name, out of the address table ---------------------------------
    MOV BX, SI
    SHL BX, 1
    MOV DX, NAMES[BX]
    CALL PRINT_MESSAGE

    ; ---- how long it runs ---------------------------------------------------
    MOV BL, MINUTES[SI]
    XOR BH, BH
    ADD BP, BX
    MOV AX, BX
    CALL PRINT_DECIMAL
    LEA DX, M_GAP
    CALL PRINT_MESSAGE

    ; ---- what it drives -----------------------------------------------------
    MOV BL, OUTPUTS[SI]
    XOR BH, BH
    MOV AL, BL
    OUT MOTOR_PORT, AL                  ; The machine acts on this

    MOV AX, BX
    CALL PRINT_DECIMAL
    LEA DX, M_TWO
    CALL PRINT_MESSAGE

    ; ---- and the same pattern read out one bit at a time --------------------
    MOV AL, OUTPUTS[SI]
    CALL SHOW_BITS
    CALL NEWLINE

    INC SI
    LOOP EACH_PHASE

    LEA DX, M_TOTAL
    CALL PRINT_MESSAGE
    MOV AX, BP
    CALL PRINT_DECIMAL
    LEA DX, M_MINS
    CALL PRINT_MESSAGE

    MOV AH, 4CH
    INT 21H

; -----------------------------------------------------------------------------
; SHOW_BITS
;
; Prints the low four bits of AL as on or off, lowest bit first, so the columns
; read valve, drum, heater, pump.
; -----------------------------------------------------------------------------
SHOW_BITS PROC
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX

    MOV BL, AL
    MOV CX, 4

EACH_BIT:
    TEST BL, 1
    JZ BIT_CLEAR

    LEA DX, M_ON
    CALL PRINT_MESSAGE
    JMP BIT_DONE

BIT_CLEAR:
    LEA DX, M_OFF
    CALL PRINT_MESSAGE

BIT_DONE:
    SHR BL, 1
    LOOP EACH_BIT

    POP DX
    POP CX
    POP BX
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
; 1. Two tables indexed differently:
;    - MINUTES and OUTPUTS are bytes, so SI indexes them directly.
;    - NAMES holds addresses, which are words, so it needs SI doubled.
;    - Mixing the two strides up is the commonest bug in a table driven loop.
; 2. Outputs as a bit mask:
;    - One bit per actuator lets a phase drive several at once.
;    - Spin is 1010B, which is the pump and the drum together.
;    - TEST followed by a shift walks the mask without destroying it.
; 3. Simulated time:
;    - Nothing here waits; the durations are added up rather than lived through.
;    - That is the right choice for a model, and the total is the useful output.
;    - A real controller would count timer ticks in the same loop.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
