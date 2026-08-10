; =============================================================================
; TITLE: Length of a Collatz Sequence
; DESCRIPTION: Counts how many steps a number takes to reach one under the rule
;              halve if even, otherwise treble and add one.
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
    START_N DW 27
    MSG     DB '27 reaches one in $'
    TAIL    DB ' steps', 0DH, 0AH, '$'
    PEAK_M  DB 'The highest value on the way was $'

; -----------------------------------------------------------------------------
; CODE SEGMENT
; -----------------------------------------------------------------------------
.CODE
START:
    MOV AX, @DATA
    MOV DS, AX

    MOV BX, START_N
    XOR CX, CX                          ; Steps taken
    MOV DI, BX                          ; Highest value seen

COLLATZ_LOOP:
    CMP BX, 1
    JE  FINISHED

    ; -------------------------------------------------------------------------
    ; EVEN OR ODD IS THE LOWEST BIT. TESTING IT COSTS ONE INSTRUCTION, WHERE
    ; DIVIDING BY TWO AND EXAMINING THE REMAINDER WOULD COST FIFTY.
    ; -------------------------------------------------------------------------
    TEST BX, 1
    JNZ  IS_ODD

    SHR BX, 1                           ; Even: halve it
    JMP COUNTED

IS_ODD:
    MOV AX, BX
    ADD AX, AX
    ADD AX, BX                          ; Three times, by addition
    INC AX
    MOV BX, AX

COUNTED:
    INC CX
    CMP BX, DI
    JBE COLLATZ_LOOP
    MOV DI, BX                          ; A new high point
    JMP COLLATZ_LOOP

FINISHED:
    LEA DX, MSG
    MOV AH, 09H
    INT 21H
    MOV AX, CX
    CALL PRINT_DECIMAL
    LEA DX, TAIL
    MOV AH, 09H
    INT 21H

    LEA DX, PEAK_M
    MOV AH, 09H
    INT 21H
    MOV AX, DI
    CALL PRINT_DECIMAL
    CALL NEWLINE

    MOV AH, 4CH
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
; 1. WHY 27 IS THE INTERESTING CASE:
;    - It is small but takes 111 steps and climbs above nine thousand on
;    - the way, which is why it is the example everyone uses.
; 2. THE WORD LIMIT:
;    - The peak has to stay below 65535 or the value wraps. For 27 it
;    - does not, but a slightly larger start would overflow silently.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
