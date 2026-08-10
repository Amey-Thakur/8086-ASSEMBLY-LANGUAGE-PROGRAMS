; =============================================================================
; TITLE: Guarding a Loop with JCXZ
; DESCRIPTION: Shows why a LOOP with a count of zero runs 65536 times, and how
;              JCXZ prevents it in one instruction.
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
    COUNT_A DW 4                        ; A sensible count
    COUNT_B DW 0                        ; The dangerous one
    M_A     DB 'With a count of four the body ran $'
    M_B     DB 'With a count of zero the body ran $'
    M_TIMES DB ' times', 0DH, 0AH, '$'

; -----------------------------------------------------------------------------
; CODE SEGMENT
; -----------------------------------------------------------------------------
.CODE
START:
    MOV AX, @DATA
    MOV DS, AX

    MOV CX, COUNT_A
    CALL COUNTED_LOOP
    MOV BX, DI

    LEA DX, M_A
    MOV AH, 09H
    INT 21H
    MOV AX, BX
    CALL PRINT_DECIMAL
    LEA DX, M_TIMES
    MOV AH, 09H
    INT 21H

    MOV CX, COUNT_B
    CALL COUNTED_LOOP
    MOV BX, DI

    LEA DX, M_B
    MOV AH, 09H
    INT 21H
    MOV AX, BX
    CALL PRINT_DECIMAL
    LEA DX, M_TIMES
    MOV AH, 09H
    INT 21H

    MOV AH, 4CH
    INT 21H

; -----------------------------------------------------------------------------
; COUNTED_LOOP
;
; Runs a body CX times and returns the number of passes in DI.
; -----------------------------------------------------------------------------
COUNTED_LOOP PROC
    XOR DI, DI

    ; -------------------------------------------------------------------------
    ; LOOP DECREMENTS CX AND THEN TESTS IT. WITH CX ALREADY ZERO THE FIRST
    ; DECREMENT WRAPS TO FFFFH AND THE LOOP RUNS 65536 TIMES. JCXZ TESTS
    ; BEFORE ANYTHING IS DECREMENTED, WHICH IS THE WHOLE POINT OF IT.
    ; -------------------------------------------------------------------------
    JCXZ CL_DONE

CL_BODY:
    INC DI                              ; The body: count one pass
    LOOP CL_BODY

CL_DONE:
    RET
COUNTED_LOOP ENDP

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
; 1. THE ORDER INSIDE LOOP:
;    - Decrement, then branch if not zero. There is no test before the
;    - decrement, so a count of zero becomes a count of 65536.
; 2. JCXZ IS THE ONLY ONE OF ITS KIND:
;    - It is the only conditional jump that reads a register instead of a
;    - flag. Nothing else on the 8086 tests CX directly.
; 3. REP HAS THE GUARD BUILT IN:
;    - REP tests CX before each element, so REP MOVSB with CX zero copies
;    - nothing. LOOP does not, which is the inconsistency to remember.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
