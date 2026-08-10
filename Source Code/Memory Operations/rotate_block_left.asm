; =============================================================================
; TITLE: Rotate A Block Left By N Places
; DESCRIPTION: Lifts the leading bytes aside, slides the remainder down to the
;              front and puts the lifted bytes on the end, having first reduced
;              the requested distance modulo the length of the block.
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
    RING    DB 'ABCDEFGHIJ'
    SPAN    EQU $ - RING                 ; Measured, so the modulus is never wrong
    HOLD    DB SPAN DUP(?)               ; Room for the bytes lifted off the front

    M_START DB 'At the start:   $'
    M_ASK   DB 'Rotate left by $'
    M_EFF   DB ', which on ten bytes means $'
    M_GIVES DB ':   $'
    M_ROUND DB 'Three places and then seven make a whole turn, which is why the'
            DB 0DH, 0AH
            DB 'block has come back to the order it started in.', 0DH, 0AH, '$'

; -----------------------------------------------------------------------------
; CODE SEGMENT
; -----------------------------------------------------------------------------
.CODE
START:
    MOV AX, @DATA
    MOV DS, AX
    MOV ES, AX                          ; MOVSB writes to ES:DI and nowhere else

    LEA DX, M_START
    CALL PRINT_MESSAGE
    LEA SI, RING
    MOV CX, SPAN
    CALL PRINT_TEXT
    CALL NEWLINE

    MOV AX, 13                          ; More than the block is long, on purpose
    CALL ROTATE_LEFT

    MOV AX, 7                           ; Three already done, so this completes a turn
    CALL ROTATE_LEFT

    LEA DX, M_ROUND
    CALL PRINT_MESSAGE

    MOV AH, 4CH
    INT 21H

; -----------------------------------------------------------------------------
; ROTATE_LEFT
;
; Rotates RING left by the number of places in AX, reporting the distance asked
; for, the distance that distance reduces to, and the block that results.
; -----------------------------------------------------------------------------
ROTATE_LEFT PROC
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX
    PUSH BP
    PUSH SI
    PUSH DI

    LEA DX, M_ASK
    CALL PRINT_MESSAGE                  ; PRINT_MESSAGE leaves AX alone, so the
    CALL PRINT_DECIMAL                  ; distance asked for is still there

    ; -------------------------------------------------------------------------
    ; TURNING A BLOCK BY ITS OWN LENGTH LEAVES IT WHERE IT WAS, SO ONLY THE
    ; REMAINDER MATTERS. WITHOUT THE REDUCTION A DISTANCE LARGER THAN THE BLOCK
    ; WOULD DRIVE THE COUNTS NEGATIVE AND THE COPIES OFF THE END.
    ; -------------------------------------------------------------------------
    XOR DX, DX                          ; DX:AX is the dividend, so clear DX
    MOV BX, SPAN
    DIV BX                              ; AX is the whole turns, DX the remainder
    MOV BP, DX                          ; DX has to carry a message address next

    LEA DX, M_EFF
    CALL PRINT_MESSAGE
    MOV AX, BP
    CALL PRINT_DECIMAL
    LEA DX, M_GIVES
    CALL PRINT_MESSAGE

    MOV CX, BP
    JCXZ RL_SHOW                        ; A rotation of none is no rotation at all

    ; ---- lift the leading bytes out of the way ------------------------------
    LEA SI, RING
    LEA DI, HOLD
    CLD
    REP MOVSB

    ; ---- slide the rest down to the front ------------------------------------
    ; The destination is below the source here, so a forward copy never reads a
    ; byte it has already written even though the two regions overlap.
    LEA SI, RING
    ADD SI, BP
    LEA DI, RING
    MOV CX, SPAN
    SUB CX, BP
    REP MOVSB

    ; ---- and the lifted bytes go on the end ----------------------------------
    ; DI was left pointing at the gap by the copy above, so it needs no setting.
    LEA SI, HOLD
    MOV CX, BP
    REP MOVSB

RL_SHOW:
    LEA SI, RING
    MOV CX, SPAN
    CALL PRINT_TEXT
    CALL NEWLINE

    POP DI
    POP SI
    POP BP
    POP DX
    POP CX
    POP BX
    POP AX
    RET
ROTATE_LEFT ENDP

; -----------------------------------------------------------------------------
; PRINT_TEXT
;
; Prints CX characters starting at DS:SI. Both are left as they were found.
; -----------------------------------------------------------------------------
PRINT_TEXT PROC
    PUSH AX
    PUSH CX
    PUSH DX
    PUSH SI

    JCXZ PT_DONE                        ; Nothing to print

PT_LOOP:
    MOV DL, [SI]
    MOV AH, 02H
    INT 21H
    INC SI
    LOOP PT_LOOP

PT_DONE:
    POP SI
    POP DX
    POP CX
    POP AX
    RET
PRINT_TEXT ENDP

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
; 1. Reducing the distance first:
;    - A rotation by the length of the block puts every byte back where it was.
;    - So only the remainder after division by the length has any effect.
;    - Without it, SPAN less the distance goes negative and the copy runs away.
; 2. Why DX is emptied before printing:
;    - DIV returns the remainder in DX, and DOS wants a message address in DX.
;    - Whichever is written second destroys the other.
;    - Moving the remainder to BP the instant it appears settles the argument.
; 3. The cost of the scratch area:
;    - This method needs room for the bytes lifted off the front, and no more.
;    - Reversing the two parts and then the whole block would need none at all.
;    - That trades the memory for three passes over the block instead of one.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
