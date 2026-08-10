; =============================================================================
; TITLE: A Procedure Taking Any Number Of Arguments
; DESCRIPTION: The count is pushed last so the procedure can find it, and the rest are read from there.
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
    M_TITLE DB 'One procedure, called with three different argument counts', 0DH, 0AH, '$'
    M_CALL1 DB 0DH, 0AH, 'SUM_ALL(5)                = $'
    M_CALL2 DB 0DH, 0AH, 'SUM_ALL(10, 20, 30)       = $'
    M_CALL3 DB 0DH, 0AH, 'SUM_ALL(1, 2, 3, 4, 5, 6) = $'
    M_CALL0 DB 0DH, 0AH, 'SUM_ALL()                 = $'
    M_WHY   DB 0DH, 0AH, 0DH, 0AH
            DB 'The count is pushed last, so it sits at a fixed offset from BP '
            DB 'whatever else was pushed. Everything else is found relative to '
            DB 'it.', 0DH, 0AH, '$'
    M_CLEAN DB 'The caller removes the arguments, because only the caller knows '
            DB 'how many there were.', 0DH, 0AH, '$'

; -----------------------------------------------------------------------------
; CODE SEGMENT
; -----------------------------------------------------------------------------
.CODE
START:
    MOV AX, @DATA
    MOV DS, AX

    LEA DX, M_TITLE
    CALL PRINT_MESSAGE

    ; ---- one argument -------------------------------------------------------
    MOV AX, 5
    PUSH AX
    MOV AX, 1                           ; The count, pushed last
    PUSH AX
    CALL SUM_ALL
    ADD SP, 4                           ; One argument and the count

    LEA DX, M_CALL1
    CALL PRINT_MESSAGE
    CALL PRINT_DECIMAL

    ; ---- three arguments ----------------------------------------------------
    MOV AX, 30
    PUSH AX
    MOV AX, 20
    PUSH AX
    MOV AX, 10
    PUSH AX
    MOV AX, 3
    PUSH AX
    CALL SUM_ALL
    ADD SP, 8

    LEA DX, M_CALL2
    CALL PRINT_MESSAGE
    CALL PRINT_DECIMAL

    ; ---- six arguments ------------------------------------------------------
    MOV AX, 6
    PUSH AX
    MOV AX, 5
    PUSH AX
    MOV AX, 4
    PUSH AX
    MOV AX, 3
    PUSH AX
    MOV AX, 2
    PUSH AX
    MOV AX, 1
    PUSH AX
    MOV AX, 6                           ; The count
    PUSH AX
    CALL SUM_ALL
    ADD SP, 14

    LEA DX, M_CALL3
    CALL PRINT_MESSAGE
    CALL PRINT_DECIMAL

    ; ---- and none at all, which must give zero rather than misbehave --------
    MOV AX, 0
    PUSH AX
    CALL SUM_ALL
    ADD SP, 2

    LEA DX, M_CALL0
    CALL PRINT_MESSAGE
    CALL PRINT_DECIMAL

    LEA DX, M_WHY
    CALL PRINT_MESSAGE
    LEA DX, M_CLEAN
    CALL PRINT_MESSAGE

    MOV AH, 4CH
    INT 21H

; -----------------------------------------------------------------------------
; SUM_ALL
;
; Adds however many words were pushed and returns the total in AX.
;
; The frame, from BP upwards:
;     [BP+2]  the return address
;     [BP+4]  the count
;     [BP+6]  the first argument
;     [BP+8]  the second, and so on
;
; The count is at a fixed offset because it was pushed last. Putting it first
; would leave it at an offset that depends on how many arguments followed, which
; is exactly the thing the procedure does not yet know.
; -----------------------------------------------------------------------------
SUM_ALL PROC
    PUSH BP
    MOV BP, SP
    PUSH BX
    PUSH CX
    PUSH SI

    XOR AX, AX                          ; The running total
    MOV CX, [BP+4]                      ; How many there are
    JCXZ SUM_DONE                       ; None is a legal answer, and it is zero

    MOV SI, BP
    ADD SI, 6                           ; The first argument

EACH_ARGUMENT:
    MOV BX, SS:[SI]                     ; The arguments are on the stack
    ADD AX, BX
    ADD SI, 2
    LOOP EACH_ARGUMENT

SUM_DONE:
    POP SI
    POP CX
    POP BX
    POP BP
    RET
SUM_ALL ENDP

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
; 1. The count goes last:
;    - Pushed last means nearest BP, at a fixed offset whatever came before.
;    - Pushed first it would be furthest away, at an offset depending on the count itself.
;    - This is why C puts the format string first and pushes right to left.
; 2. Reading through SS:
;    - The arguments are on the stack, so SS is the segment they live in.
;    - SI defaults to DS, hence the explicit override on the read.
;    - A frame reached through BP needs no override, because BP already defaults to SS.
; 3. The caller cleans up:
;    - Only the caller knows how many words it pushed, so only it can remove them.
;    - RET with a count cannot be used, because the count differs between calls.
;    - That is the whole reason the C calling convention has the caller do the cleaning.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
