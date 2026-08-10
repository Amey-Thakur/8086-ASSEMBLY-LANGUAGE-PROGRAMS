; =============================================================================
; TITLE: Parking Lot Occupancy
; DESCRIPTION: Tracks how many spaces are taken as cars arrive and leave, refusing entry when full and never going below empty.
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
    SPACES  EQU 6

    ; The gate log: 1 a car arrived, 2 a car left.
    EVENTS  DB 1,1,1,2,1,1,1,1,1,2,2,1,1,2,2,2,2,2,2,1
    HOWMANY EQU 20

    TAKEN_W DW 0
    TURNED  DW 0                        ; Cars refused because it was full
    ODD_W   DW 0                        ; Departures with nobody parked

    M_TITLE DB 'A car park with six spaces', 0DH, 0AH, '$'
    M_IN    DB 'arrived  $'
    M_OUT   DB 'left     $'
    M_FULL  DB 'arrived  turned away, full', 0DH, 0AH, '$'
    M_EMPTY DB 'left     ignored, already empty', 0DH, 0AH, '$'
    M_TAKEN DB 'taken $'
    M_FREE  DB ', free $'
    M_SUM   DB 0DH, 0AH, 'Finally taken:  $'
    M_TURN  DB 'Turned away:    $'
    M_ODD   DB 'Impossible exits: $'
    M_WHY   DB 0DH, 0AH
            DB 'Both limits are checked before the count changes, so the '
            DB 'occupancy can never leave the range zero to six.', 0DH, 0AH, '$'

; -----------------------------------------------------------------------------
; CODE SEGMENT
; -----------------------------------------------------------------------------
.CODE
START:
    MOV AX, @DATA
    MOV DS, AX

    LEA DX, M_TITLE
    CALL PRINT_MESSAGE

    XOR SI, SI
    MOV CX, HOWMANY

EACH_EVENT:
    CMP EVENTS[SI], 1
    JNE A_DEPARTURE

    ; -------------------------------------------------------------------------
    ; AN ARRIVAL. THE LIMIT IS TESTED FIRST, BECAUSE INCREMENTING AND THEN
    ; CHECKING WOULD LET THE COUNT REACH SEVEN BEFORE BEING CORRECTED.
    ; -------------------------------------------------------------------------
    CMP TAKEN_W, SPACES
    JB LET_IN

    INC TURNED
    LEA DX, M_FULL
    CALL PRINT_MESSAGE
    JMP NEXT_EVENT

LET_IN:
    INC TAKEN_W
    LEA DX, M_IN
    CALL PRINT_MESSAGE
    CALL SHOW_OCCUPANCY
    JMP NEXT_EVENT

A_DEPARTURE:
    ; -------------------------------------------------------------------------
    ; A DEPARTURE. ZERO IS THE OTHER LIMIT. AN UNSIGNED COUNT THAT GOES BELOW
    ; ZERO WRAPS TO 65535, WHICH WOULD READ AS A CATASTROPHICALLY FULL CAR PARK.
    ; -------------------------------------------------------------------------
    CMP TAKEN_W, 0
    JA LET_OUT

    INC ODD_W
    LEA DX, M_EMPTY
    CALL PRINT_MESSAGE
    JMP NEXT_EVENT

LET_OUT:
    DEC TAKEN_W
    LEA DX, M_OUT
    CALL PRINT_MESSAGE
    CALL SHOW_OCCUPANCY

NEXT_EVENT:
    INC SI
    LOOP EACH_EVENT

    LEA DX, M_SUM
    CALL PRINT_MESSAGE
    MOV AX, TAKEN_W
    CALL PRINT_DECIMAL
    CALL NEWLINE

    LEA DX, M_TURN
    CALL PRINT_MESSAGE
    MOV AX, TURNED
    CALL PRINT_DECIMAL
    CALL NEWLINE

    LEA DX, M_ODD
    CALL PRINT_MESSAGE
    MOV AX, ODD_W
    CALL PRINT_DECIMAL
    CALL NEWLINE

    LEA DX, M_WHY
    CALL PRINT_MESSAGE

    MOV AH, 4CH
    INT 21H

; -----------------------------------------------------------------------------
; SHOW_OCCUPANCY
;
; Prints how many spaces are taken and how many remain.
; -----------------------------------------------------------------------------
SHOW_OCCUPANCY PROC
    PUSH AX
    PUSH DX

    LEA DX, M_TAKEN
    CALL PRINT_MESSAGE
    MOV AX, TAKEN_W
    CALL PRINT_DECIMAL

    LEA DX, M_FREE
    CALL PRINT_MESSAGE
    MOV AX, SPACES
    SUB AX, TAKEN_W
    CALL PRINT_DECIMAL
    CALL NEWLINE

    POP DX
    POP AX
    RET
SHOW_OCCUPANCY ENDP

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
; 1. Check before you change:
;    - The limit is tested while the count is still valid.
;    - Incrementing first and correcting afterwards leaves a moment when it is wrong.
;    - In a system with interrupts that moment is long enough to be observed.
; 2. Unsigned counts do not go negative:
;    - DEC on a word holding zero gives 65535, not minus one.
;    - A car park reporting 65535 cars is the visible symptom of a missing check.
;    - JA rather than JG is the right test, because the count is unsigned.
; 3. Count the refusals too:
;    - Cars turned away is the number that justifies building more spaces.
;    - Impossible exits point at a broken sensor rather than a broken program.
;    - Both are cheap to keep and impossible to reconstruct afterwards.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
