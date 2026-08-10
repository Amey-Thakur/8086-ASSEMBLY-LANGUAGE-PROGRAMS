; =============================================================================
; TITLE: Unrolling a Loop
; DESCRIPTION: Does four elements per pass instead of one, trading code size for
;              a quarter of the loop overhead.
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
    DATA_W  DW 5, 10, 15, 20, 25, 30, 35, 40
    HOWMANY EQU 8
    M_ROLL  DB 'Rolled total:   $'
    M_UNROL DB 'Unrolled total: $'

; -----------------------------------------------------------------------------
; CODE SEGMENT
; -----------------------------------------------------------------------------
.CODE
START:
    MOV AX, @DATA
    MOV DS, AX

    ; The ordinary loop: one element, one LOOP, eight times
    LEA SI, DATA_W
    MOV CX, HOWMANY
    XOR BX, BX

ROLLED:
    ADD BX, [SI]
    ADD SI, 2
    LOOP ROLLED

    LEA DX, M_ROLL
    MOV AH, 09H
    INT 21H
    MOV AX, BX
    CALL PRINT_DECIMAL
    CALL NEWLINE

    ; -------------------------------------------------------------------------
    ; THE SAME SUM, FOUR ELEMENTS AT A TIME. THE LOOP INSTRUCTION NOW RUNS
    ; TWICE INSTEAD OF EIGHT TIMES, AND THE POINTER ADVANCES ONCE PER GROUP
    ; RATHER THAN ONCE PER ELEMENT.
    ; -------------------------------------------------------------------------
    LEA SI, DATA_W
    MOV CX, HOWMANY / 4                 ; Groups, not elements
    XOR BX, BX

UNROLLED:
    ADD BX, [SI]
    ADD BX, [SI+2]
    ADD BX, [SI+4]
    ADD BX, [SI+6]
    ADD SI, 8
    LOOP UNROLLED

    LEA DX, M_UNROL
    MOV AH, 09H
    INT 21H
    MOV AX, BX
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
; 1. WHAT IS ACTUALLY SAVED:
;    - Six LOOP instructions and six pointer advances. On an 8086 that is
;    - around a hundred cycles out of a loop that did very little work.
; 2. THE COUNT MUST DIVIDE EVENLY:
;    - Eight elements in groups of four is exact. Nine would need the
;    - odd one handled separately, which is where unrolled code usually
;    - goes wrong.
; 3. THE DISPLACEMENTS COST NOTHING EXTRA:
;    - [SI+2] and [SI] take the same time to compute, because the
;    - displacement is part of the instruction. That is what makes
;    - unrolling worth doing at all.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
