; =============================================================================
; TITLE: Lift Controller
; DESCRIPTION: Serves a list of floor requests in the order a real lift would: everything on the way up first, then on the way down.
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
    ; One byte per floor: 1 means somebody is waiting there.
    CALLS   DB 0, 1, 0, 1, 1, 0, 1, 0
    FLOORS  EQU 8

    M_TITLE DB 'A lift serving calls in sweep order', 0DH, 0AH, '$'
    M_CALLS DB 'Calls waiting at floors: $'
    M_START DB 0DH, 0AH, 'Starting at floor 0, going up.', 0DH, 0AH, '$'
    M_STOP  DB 'stopping at floor $'
    M_PASS  DB 'passing floor $'
    M_TURN  DB 0DH, 0AH, 'Top of the sweep reached, reversing.', 0DH, 0AH, '$'
    M_DONE  DB 0DH, 0AH, 'All calls served. Total stops: $'
    M_TRAV  DB 'Floors travelled: $'
    M_SPACE DB ' $'

; -----------------------------------------------------------------------------
; CODE SEGMENT
; -----------------------------------------------------------------------------
.CODE
START:
    MOV AX, @DATA
    MOV DS, AX

    LEA DX, M_TITLE
    CALL PRINT_MESSAGE

    ; -------------------------------------------------------------------------
    ; THE WAITING LIST IS SHOWN FIRST SO THE SWEEP CAN BE CHECKED AGAINST IT.
    ; -------------------------------------------------------------------------
    LEA DX, M_CALLS
    CALL PRINT_MESSAGE
    XOR SI, SI
    MOV CX, FLOORS
LIST_CALLS:
    CMP CALLS[SI], 1
    JNE NOT_CALLING
    MOV AX, SI
    CALL PRINT_DECIMAL
    LEA DX, M_SPACE
    CALL PRINT_MESSAGE
NOT_CALLING:
    INC SI
    LOOP LIST_CALLS

    LEA DX, M_START
    CALL PRINT_MESSAGE

    ; -------------------------------------------------------------------------
    ; THE UPWARD SWEEP. DI COUNTS STOPS AND BP COUNTS FLOORS TRAVELLED, WHICH
    ; TOGETHER ARE THE TWO NUMBERS ANY LIFT CONTROLLER IS JUDGED ON.
    ; -------------------------------------------------------------------------
    XOR DI, DI                          ; Stops made
    XOR BP, BP                          ; Floors travelled
    XOR SI, SI                          ; Current floor
    MOV CX, FLOORS

GOING_UP:
    CALL VISIT_FLOOR
    INC SI
    INC BP
    LOOP GOING_UP

    DEC SI                              ; SI ran one past the top
    DEC BP

    LEA DX, M_TURN
    CALL PRINT_MESSAGE

    ; -------------------------------------------------------------------------
    ; THE DOWNWARD SWEEP. ANY CALL PLACED BEHIND THE LIFT ON THE WAY UP WOULD
    ; BE PICKED UP HERE, WHICH IS THE WHOLE REASON A LIFT SWEEPS RATHER THAN
    ; CHASING THE NEAREST CALL.
    ; -------------------------------------------------------------------------
    MOV CX, FLOORS
    DEC CX                              ; Floor at the top was already visited

GOING_DOWN:
    DEC SI
    INC BP
    CALL VISIT_FLOOR
    LOOP GOING_DOWN

    LEA DX, M_DONE
    CALL PRINT_MESSAGE
    MOV AX, DI
    CALL PRINT_DECIMAL
    CALL NEWLINE

    LEA DX, M_TRAV
    CALL PRINT_MESSAGE
    MOV AX, BP
    CALL PRINT_DECIMAL
    CALL NEWLINE

    MOV AH, 4CH
    INT 21H

; -----------------------------------------------------------------------------
; VISIT_FLOOR
;
; Reports floor SI, stopping if a call is waiting there and clearing it. DI is
; increased for every stop made.
; -----------------------------------------------------------------------------
VISIT_FLOOR PROC
    PUSH AX
    PUSH DX

    CMP CALLS[SI], 1
    JE MAKE_STOP

    LEA DX, M_PASS
    CALL PRINT_MESSAGE
    MOV AX, SI
    CALL PRINT_DECIMAL
    CALL NEWLINE
    JMP VISIT_DONE

MAKE_STOP:
    MOV CALLS[SI], 0                    ; The call has been answered
    INC DI

    LEA DX, M_STOP
    CALL PRINT_MESSAGE
    MOV AX, SI
    CALL PRINT_DECIMAL
    CALL NEWLINE

VISIT_DONE:
    POP DX
    POP AX
    RET
VISIT_FLOOR ENDP

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
; 1. Why sweep and not nearest first:
;    - Serving the nearest call can leave somebody at the far end waiting indefinitely.
;    - A sweep bounds the wait: at worst two traversals of the building.
;    - Real controllers call this the elevator algorithm, and disk schedulers borrowed it.
; 2. The call is cleared when answered:
;    - Setting the byte back to zero is what stops the lift serving it twice.
;    - A real lift clears the request when the doors open, for the same reason.
;    - Leaving it set would make the downward sweep repeat every stop.
; 3. Two numbers to judge it by:
;    - Stops made is the work done for passengers.
;    - Floors travelled is the cost of doing it.
;    - A scheduler is only interesting when those two are in tension.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
