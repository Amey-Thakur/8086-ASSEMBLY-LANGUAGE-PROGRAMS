; =============================================================================
; TITLE: A Stack Frame Built With BP
; DESCRIPTION: The standard entry and exit sequence, and why BP rather than SP is used to reach into the frame.
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
    M_TITLE DB 'A stack frame: PUSH BP, MOV BP SP, work, POP BP, RET', 0DH, 0AH, '$'
    M_CALL  DB 'AREA called with width 12 and height 7', 0DH, 0AH, '$'
    M_FIRST DB '[BP+4] the first argument pushed:  $'
    M_SECND DB '[BP+6] the second argument:        $'
    M_LOCAL DB 'a local kept at [BP-2]:            $'
    M_AREA  DB 'the product returned in AX:        $'
    M_CLEAN DB 'The caller removed both arguments with ADD SP, 4.', 0DH, 0AH, '$'
    M_WHY   DB 'BP stays still while SP moves, so the offsets never change.', 0DH, 0AH, '$'

; -----------------------------------------------------------------------------
; CODE SEGMENT
; -----------------------------------------------------------------------------
.CODE
START:
    MOV AX, @DATA
    MOV DS, AX

    LEA DX, M_TITLE
    CALL PRINT_MESSAGE
    LEA DX, M_CALL
    CALL PRINT_MESSAGE

    ; -------------------------------------------------------------------------
    ; THE ARGUMENTS GO ON IN THE ORDER WRITTEN, SO THE FIRST ONE PUSHED ENDS UP
    ; DEEPEST AND IS THEREFORE THE ONE FURTHEST FROM BP.
    ; -------------------------------------------------------------------------
    MOV AX, 7
    PUSH AX                             ; Second argument, at [BP+6]
    MOV AX, 12
    PUSH AX                             ; First argument, at [BP+4]
    CALL AREA
    ADD SP, 4                           ; The caller cleans up

    LEA DX, M_AREA
    CALL PRINT_MESSAGE
    CALL PRINT_DECIMAL
    CALL NEWLINE
    CALL NEWLINE

    LEA DX, M_CLEAN
    CALL PRINT_MESSAGE
    LEA DX, M_WHY
    CALL PRINT_MESSAGE

    MOV AH, 4CH
    INT 21H

; -----------------------------------------------------------------------------
; AREA
;
; Multiplies two words passed on the stack and returns the product in AX.
;
; The frame, from the top down:
;     [BP-2]  one local word
;     [BP+0]  the saved BP
;     [BP+2]  the return address
;     [BP+4]  the first argument
;     [BP+6]  the second argument
; -----------------------------------------------------------------------------
AREA PROC
    PUSH BP
    MOV BP, SP
    SUB SP, 2                           ; Room for one local word

    PUSH BX
    PUSH DX

    MOV AX, [BP+4]
    LEA DX, M_FIRST
    CALL PRINT_MESSAGE
    CALL PRINT_DECIMAL
    CALL NEWLINE

    MOV AX, [BP+6]
    LEA DX, M_SECND
    CALL PRINT_MESSAGE
    CALL PRINT_DECIMAL
    CALL NEWLINE

    ; The local holds the running product, purely to show the negative side of
    ; the frame being written and read back.
    MOV AX, [BP+4]
    MOV BX, [BP+6]
    MUL BX
    MOV [BP-2], AX

    MOV AX, [BP-2]
    LEA DX, M_LOCAL
    CALL PRINT_MESSAGE
    CALL PRINT_DECIMAL
    CALL NEWLINE

    MOV AX, [BP-2]                      ; The return value

    POP DX
    POP BX

    MOV SP, BP                          ; Discard the locals
    POP BP
    RET
AREA ENDP

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
; 1. The layout is fixed by the call:
;    - CALL pushes the return address, so it sits at [BP+2] once BP is set.
;    - Arguments are above that, at [BP+4] and upwards, deepest first.
;    - Locals are below BP, at [BP-2] and downwards.
; 2. Why not use SP directly:
;    - Every push inside the procedure moves SP, so a fixed SP offset would drift.
;    - BP is set once and left alone, so [BP+4] means the same thing throughout.
;    - This is the reason BP exists as a separate register at all.
; 3. Who cleans up:
;    - Here the caller does it with ADD SP, 4 after the call returns.
;    - RET 4 would have the procedure do it instead, which is the Pascal convention.
;    - Mixing the two leaks or over-pops the stack, and the next RET goes somewhere wrong.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
