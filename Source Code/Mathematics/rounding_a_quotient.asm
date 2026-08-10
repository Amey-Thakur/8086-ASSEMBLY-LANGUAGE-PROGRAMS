; =============================================================================
; TITLE: Rounding a Quotient Three Different Ways
; DESCRIPTION: DIV always rounds towards zero. The remainder it leaves behind
;              carries everything needed to round up instead, or to round to
;              the nearest, without ever risking an overflow.
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
    TOP_W   DW 7, 100, 100, 50000, 65530
    BOT_W   DW 2,   7,   8,     3,    20
    HOWMANY EQU 5

    TOP_V   DW ?                        ; The dividend of the case being worked
    BOT_V   DW ?
    QUOT    DW ?                        ; What DIV gave, before any rounding
    REMD    DW ?

    M_TITLE DB 'One division, three roundings and a shortcut', 0DH, 0AH, '$'
    M_SLASH DB ' / $'
    M_QUOT  DB '   quotient $'
    M_REMD  DB ' remainder $'
    M_DOWN  DB '   down: $'
    M_UP    DB '   up: $'
    M_NEAR  DB '   nearest: $'
    M_SHORT DB '   half added first: $'
    M_CARRY DB ' (the addition carried out of sixteen bits, so this is wrong)$'

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

EACH_CASE:
    MOV AX, TOP_W[SI]
    MOV TOP_V, AX
    MOV AX, BOT_W[SI]
    MOV BOT_V, AX

    CALL DIVIDE_ONCE
    CALL SHOW_ROUNDINGS
    CALL SHOW_SHORTCUT

    ADD SI, 2
    LOOP EACH_CASE

    MOV AH, 4CH
    INT 21H

; -----------------------------------------------------------------------------
; DIVIDE_ONCE
;
; Divides TOP_V by BOT_V and keeps both halves of the answer, since every
; rounding rule that follows is decided by the remainder alone.
; -----------------------------------------------------------------------------
DIVIDE_ONCE PROC
    PUSH AX
    PUSH BX
    PUSH DX

    MOV AX, TOP_V
    XOR DX, DX                          ; DIV reads DX:AX, so the top must be clear
    MOV BX, BOT_V
    DIV BX
    MOV QUOT, AX
    MOV REMD, DX

    POP DX
    POP BX
    POP AX
    RET
DIVIDE_ONCE ENDP

; -----------------------------------------------------------------------------
; SHOW_ROUNDINGS
;
; Prints the case, then the quotient rounded down, up and to the nearest.
;
; Rounding to the nearest asks whether twice the remainder has reached the
; divisor. Doubling the remainder could pass sixteen bits, so the test is put
; the other way about: the remainder is compared with what is left of the
; divisor above it. Neither quantity can overflow, because both are smaller
; than the divisor itself.
; -----------------------------------------------------------------------------
SHOW_ROUNDINGS PROC
    PUSH AX
    PUSH BX
    PUSH DX

    MOV AX, TOP_V
    CALL PRINT_DECIMAL
    LEA DX, M_SLASH
    CALL PRINT_MESSAGE
    MOV AX, BOT_V
    CALL PRINT_DECIMAL

    LEA DX, M_QUOT
    CALL PRINT_MESSAGE
    MOV AX, QUOT
    CALL PRINT_DECIMAL
    LEA DX, M_REMD
    CALL PRINT_MESSAGE
    MOV AX, REMD
    CALL PRINT_DECIMAL
    CALL NEWLINE

    LEA DX, M_DOWN
    CALL PRINT_MESSAGE
    MOV AX, QUOT                        ; What DIV gave is already rounded down
    CALL PRINT_DECIMAL

    LEA DX, M_UP
    CALL PRINT_MESSAGE
    MOV AX, QUOT
    MOV BX, REMD
    OR  BX, BX
    JZ  SR_EXACT_UP                     ; An exact division is already up as well
    INC AX

SR_EXACT_UP:
    CALL PRINT_DECIMAL

    LEA DX, M_NEAR
    CALL PRINT_MESSAGE
    MOV AX, QUOT
    MOV BX, BOT_V
    SUB BX, REMD                        ; How far the next whole one still is
    CMP BX, REMD
    JA  SR_STAY                         ; The lower answer is genuinely closer
    INC AX                              ; A tie rounds up, as arithmetic expects

SR_STAY:
    CALL PRINT_DECIMAL
    CALL NEWLINE

    POP DX
    POP BX
    POP AX
    RET
SHOW_ROUNDINGS ENDP

; -----------------------------------------------------------------------------
; SHOW_SHORTCUT
;
; The usual shortcut for rounding to the nearest is to add half the divisor to
; the dividend before dividing. It agrees with the remainder test whenever it
; can be computed at all, but the addition happens in sixteen bits and a large
; dividend pushes it straight over the top.
; -----------------------------------------------------------------------------
SHOW_SHORTCUT PROC
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX

    LEA DX, M_SHORT
    CALL PRINT_MESSAGE

    MOV AX, BOT_V
    SHR AX, 1                           ; Half the divisor, rounded down
    ADD AX, TOP_V
    MOV CX, 0
    ADC CX, 0                           ; MOV leaves the carry alone, so CX keeps it

    XOR DX, DX
    MOV BX, BOT_V
    DIV BX
    CALL PRINT_DECIMAL

    OR  CX, CX
    JZ  SS_FINE
    LEA DX, M_CARRY
    CALL PRINT_MESSAGE

SS_FINE:
    CALL NEWLINE

    POP DX
    POP CX
    POP BX
    POP AX
    RET
SHOW_SHORTCUT ENDP

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
; 1. The remainder holds the whole answer:
;    - A remainder of zero means the division was exact and nothing may move.
;    - Any other remainder means the true value lies between two whole numbers.
;    - Which of the two is nearer is decided by comparing it with the divisor.
; 2. Comparing without doubling:
;    - Twice the remainder can pass sixteen bits when the divisor is large.
;    - Subtracting the remainder from the divisor gives the distance upward.
;    - Comparing the two distances answers the same question and cannot overflow.
; 3. Where the shortcut fails:
;    - Adding half the divisor first is shorter and usually correct.
;    - It fails silently once the dividend is near the top of the range.
;    - The same fault waits in the ceiling written as dividend plus divisor less one.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
