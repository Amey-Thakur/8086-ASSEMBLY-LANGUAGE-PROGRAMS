; =============================================================================
; TITLE: Ternary Search
; DESCRIPTION: Divides the range into three at each step rather than two, and
;              shows why that is slower despite sounding faster.
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
    SORTED  DW 4, 9, 15, 22, 30, 39, 49, 60, 72, 85, 99, 114, 130, 147, 165, 184
    HOWMANY EQU 16
    WANTED  DW 99

    M_ARRAY DB 'Sorted: $'
    M_TERN  DB 'Ternary search: found at $'
    M_TSTEP DB ', comparisons $'
    M_BIN   DB 'Binary search:  found at $'
    M_BSTEP DB ', comparisons $'
    CRLF    DB 0DH, 0AH, '$'

; -----------------------------------------------------------------------------
; CODE SEGMENT
; -----------------------------------------------------------------------------
.CODE
START:
    MOV AX, @DATA
    MOV DS, AX

    LEA DX, M_ARRAY
    MOV AH, 09H
    INT 21H
    LEA SI, SORTED
    MOV CX, HOWMANY
    CALL SHOW_RUN

    ; -------------------------------------------------------------------------
    ; TERNARY SEARCH CUTS THE RANGE TO A THIRD, BUT NEEDS TWO COMPARISONS TO
    ; DO IT WHERE BINARY NEEDS ONE TO HALVE IT. TWO COMPARISONS HALVED TWICE
    ; LEAVES A QUARTER, WHICH IS LESS THAN A THIRD, SO BINARY WINS. THE
    ; PROGRAM COUNTS BOTH RATHER THAN ASSERTING IT.
    ; -------------------------------------------------------------------------
    CALL DO_TERNARY
    CALL DO_BINARY

    MOV AX, 4C00H
    INT 21H

; -----------------------------------------------------------------------------
; DO_TERNARY
; -----------------------------------------------------------------------------
DO_TERNARY PROC
    XOR BX, BX                          ; low
    MOV DX, HOWMANY
    DEC DX                              ; high
    XOR DI, DI                          ; comparisons

T_LOOP:
    CMP BX, DX
    JA  T_ABSENT

    ; The two points a third of the way along
    MOV AX, DX
    SUB AX, BX
    MOV CX, 3
    XOR DX, DX
    PUSH BX
    DIV CX                              ; A third of the span
    POP BX
    MOV CX, AX                          ; The step
    MOV DX, HOWMANY
    DEC DX

    MOV BP, BX
    ADD BP, CX                          ; The first third

    INC DI
    MOV SI, BP
    SHL SI, 1
    MOV AX, SORTED[SI]
    CMP AX, WANTED
    JE  T_FOUND_FIRST

    JA  T_FIRST_TOO_BIG

    ; Look at the second third
    MOV BP, BX
    ADD BP, CX
    ADD BP, CX
    INC BP

    INC DI
    MOV SI, BP
    SHL SI, 1
    MOV AX, SORTED[SI]
    CMP AX, WANTED
    JE  T_FOUND_SECOND
    JA  T_MIDDLE_THIRD

    MOV BX, BP                          ; It is in the last third
    INC BX
    JMP T_LOOP

T_MIDDLE_THIRD:
    MOV DX, BP
    DEC DX
    MOV BX, BX
    ADD BX, CX
    INC BX
    JMP T_LOOP

T_FIRST_TOO_BIG:
    MOV DX, BP
    DEC DX
    JMP T_LOOP

T_FOUND_FIRST:
T_FOUND_SECOND:
    PUSH DI
    LEA DX, M_TERN
    MOV AH, 09H
    INT 21H
    MOV AX, BP
    CALL PRINT_DECIMAL
    LEA DX, M_TSTEP
    MOV AH, 09H
    INT 21H
    POP AX
    CALL PRINT_DECIMAL
    CALL NEWLINE
    RET

T_ABSENT:
    LEA DX, M_TERN
    MOV AH, 09H
    INT 21H
    CALL NEWLINE
    RET
DO_TERNARY ENDP

; -----------------------------------------------------------------------------
; DO_BINARY
; -----------------------------------------------------------------------------
DO_BINARY PROC
    XOR BX, BX
    MOV DX, HOWMANY
    DEC DX
    XOR DI, DI

B_LOOP:
    CMP BX, DX
    JA  B_ABSENT

    MOV CX, BX
    ADD CX, DX
    SHR CX, 1

    INC DI
    MOV SI, CX
    SHL SI, 1
    MOV AX, SORTED[SI]
    CMP AX, WANTED
    JE  B_FOUND
    JB  B_HIGHER

    CMP CX, 0
    JE  B_ABSENT
    MOV DX, CX
    DEC DX
    JMP B_LOOP

B_HIGHER:
    MOV BX, CX
    INC BX
    JMP B_LOOP

B_FOUND:
    PUSH DI
    LEA DX, M_BIN
    MOV AH, 09H
    INT 21H
    MOV AX, CX
    CALL PRINT_DECIMAL
    LEA DX, M_BSTEP
    MOV AH, 09H
    INT 21H
    POP AX
    CALL PRINT_DECIMAL
    CALL NEWLINE
    RET

B_ABSENT:
    LEA DX, M_BIN
    MOV AH, 09H
    INT 21H
    CALL NEWLINE
    RET
DO_BINARY ENDP

; -----------------------------------------------------------------------------
; SHOW_RUN
;
; Prints CX words starting at DS:SI, then a newline.
; -----------------------------------------------------------------------------
SHOW_RUN PROC
    PUSH AX
    PUSH CX
    PUSH DX
    PUSH SI

    JCXZ SR_DONE

SR_LOOP:
    MOV AX, [SI]
    PUSH CX
    PUSH SI
    CALL PRINT_DECIMAL
    MOV DL, ' '
    MOV AH, 02H
    INT 21H
    POP SI
    POP CX
    ADD SI, 2
    LOOP SR_LOOP

SR_DONE:
    CALL NEWLINE

    POP SI
    POP DX
    POP CX
    POP AX
    RET
SHOW_RUN ENDP

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
; 1. FEWER STEPS IS NOT FEWER COMPARISONS:
;    - Ternary search takes fewer iterations and more comparisons in
;    - total. Counting the comparisons rather than the iterations is what
;    - settles which is faster.
; 2. WHERE TERNARY SEARCH DOES BELONG:
;    - Finding the maximum of a function that rises and then falls, where
;    - there is no ordering to bisect against. That is a different problem
;    - with the same name.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
