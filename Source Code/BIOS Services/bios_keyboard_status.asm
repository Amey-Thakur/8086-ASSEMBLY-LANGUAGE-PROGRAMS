; =============================================================================
; TITLE: Checking for a Key Without Waiting
; DESCRIPTION: Asks whether a key is waiting and carries on either way, which
;              is what a program with other work to do needs.
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
    M_START DB 'Counting until a key is pressed.', 0DH, 0AH, '$'
    M_COUNT DB 'Reached $'
    M_STOP  DB ' before a key arrived.', 0DH, 0AH, '$'
    M_NONE  DB 'Counted all the way with nothing pressed.', 0DH, 0AH, '$'
    LIMIT   EQU 500

; -----------------------------------------------------------------------------
; CODE SEGMENT
; -----------------------------------------------------------------------------
.CODE
START:
    MOV AX, @DATA
    MOV DS, AX

    LEA DX, M_START
    MOV AH, 09H
    INT 21H

    XOR BX, BX

WORK_LOOP:
    INC BX
    CMP BX, LIMIT
    JAE RAN_OUT

    ; -------------------------------------------------------------------------
    ; SERVICE 01H LOOKS BUT DOES NOT TAKE. THE ZERO FLAG IS SET WHEN THE
    ; BUFFER IS EMPTY, AND CLEAR WHEN SOMETHING IS WAITING, IN WHICH CASE THE
    ; KEY IS STILL THERE AND HAS TO BE COLLECTED WITH SERVICE 00H.
    ; -------------------------------------------------------------------------
    MOV AH, 01H
    INT 16H
    JZ  WORK_LOOP                       ; Nothing there, so keep working

    ; Something is waiting: take it out of the buffer
    MOV AH, 00H
    INT 16H

    PUSH BX
    LEA DX, M_COUNT
    MOV AH, 09H
    INT 21H
    POP AX
    CALL PRINT_DECIMAL
    LEA DX, M_STOP
    MOV AH, 09H
    INT 21H
    JMP FINISH

RAN_OUT:
    LEA DX, M_NONE
    MOV AH, 09H
    INT 21H

FINISH:
    MOV AX, 4C00H
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

END START

; =============================================================================
; TECHNICAL NOTES
; =============================================================================
; 1. LOOKING IS NOT TAKING:
;    - Service 01h leaves the key in the buffer. A loop that keeps
;    - checking without ever calling 00h sees the same key forever.
; 2. WHY A PROGRAM NEEDS THIS:
;    - Anything that has to keep running while remaining interruptible: a
;    - game, a control loop, a long calculation with an escape key. A
;    - waiting read would stop all of it.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
