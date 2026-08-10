; =============================================================================
; TITLE: Counting Down Rather Than Up
; DESCRIPTION: Runs the same loop both ways and shows why counting down is
;              shorter: the comparison against zero is free.
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
    TIMES  EQU 5
    M_UP   DB 'Counting up:   $'
    M_DOWN DB 'Counting down: $'
    SPACE  DB ' $'

; -----------------------------------------------------------------------------
; CODE SEGMENT
; -----------------------------------------------------------------------------
.CODE
START:
    MOV AX, @DATA
    MOV DS, AX

    ; -------------------------------------------------------------------------
    ; COUNTING UP NEEDS AN EXPLICIT COMPARISON AGAINST THE LIMIT ON EVERY
    ; PASS, BECAUSE NOTHING ABOUT REACHING FIVE SETS A FLAG.
    ; -------------------------------------------------------------------------
    LEA DX, M_UP
    MOV AH, 09H
    INT 21H

    MOV BX, 1

UP_LOOP:
    MOV AX, BX
    CALL PRINT_DECIMAL
    CALL SHOW_SPACE

    INC BX
    CMP BX, TIMES                       ; The extra instruction
    JBE UP_LOOP

    CALL NEWLINE

    ; -------------------------------------------------------------------------
    ; COUNTING DOWN NEEDS NO COMPARISON. DEC SETS THE ZERO FLAG ITSELF WHEN
    ; THE COUNTER REACHES ZERO, SO THE TEST COMES FREE WITH THE DECREMENT.
    ; -------------------------------------------------------------------------
    LEA DX, M_DOWN
    MOV AH, 09H
    INT 21H

    MOV BX, TIMES

DOWN_LOOP:
    MOV AX, BX
    CALL PRINT_DECIMAL
    CALL SHOW_SPACE

    DEC BX                              ; This sets ZF on its own
    JNZ DOWN_LOOP

    CALL NEWLINE

    MOV AH, 4CH
    INT 21H

; -----------------------------------------------------------------------------
; SHOW_SPACE
; -----------------------------------------------------------------------------
SHOW_SPACE PROC
    PUSH AX
    PUSH DX
    LEA DX, SPACE
    MOV AH, 09H
    INT 21H
    POP DX
    POP AX
    RET
SHOW_SPACE ENDP

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
; 1. WHY DOWNWARD IS CHEAPER:
;    - Reaching zero is the one condition the processor reports without
;    - being asked. Every other limit has to be compared for.
; 2. WHEN IT IS NOT WORTH IT:
;    - If the loop body needs the index in increasing order, counting
;    - down and subtracting to recover it costs more than it saved.
; 3. THIS IS WHY LOOP EXISTS:
;    - The LOOP instruction is the downward form built into one opcode.
;    - There is no upward equivalent, for the same reason.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
