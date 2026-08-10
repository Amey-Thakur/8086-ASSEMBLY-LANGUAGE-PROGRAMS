; =============================================================================
; TITLE: Bubble Sort That Stops Early
; DESCRIPTION: Adds a flag to the ordinary bubble sort so that an array already
;              in order costs one pass instead of all of them.
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
    DATA_W  DW 42, 17, 93, 8, 65, 31, 76, 4
    HOWMANY EQU 8
    M_BEFORE DB 'Before: $'
    M_AFTER  DB 'After:  $'

; -----------------------------------------------------------------------------
; CODE SEGMENT
; -----------------------------------------------------------------------------
.CODE
START:
    MOV AX, @DATA
    MOV DS, AX

    LEA DX, M_BEFORE
    MOV AH, 09H
    INT 21H
    CALL SHOW_ARRAY

    ; -------------------------------------------------------------------------
    ; THE PLAIN BUBBLE SORT ALWAYS RUNS EVERY PASS. RECORDING WHETHER ANY
    ; EXCHANGE HAPPENED TURNS IT INTO A SORT THAT RECOGNISES WHEN IT IS DONE,
    ; WHICH MAKES THE BEST CASE ONE PASS RATHER THAN SEVEN.
    ; -------------------------------------------------------------------------
    MOV CX, HOWMANY
    DEC CX

OUTER:
    PUSH CX
    XOR DX, DX                          ; No exchange yet on this pass
    LEA SI, DATA_W

INNER_PASS:
    MOV AX, [SI]
    CMP AX, [SI+2]
    JBE IN_ORDER

    XCHG AX, [SI+2]
    MOV [SI], AX
    MOV DX, 1                           ; Something moved

IN_ORDER:
    ADD SI, 2
    LOOP INNER_PASS

    POP CX
    OR  DX, DX
    JZ  ALREADY_SORTED                  ; A clean pass means the work is done
    LOOP OUTER

ALREADY_SORTED:

    LEA DX, M_AFTER
    MOV AH, 09H
    INT 21H
    CALL SHOW_ARRAY

    MOV AH, 4CH
    INT 21H

; -----------------------------------------------------------------------------
; SHOW_ARRAY
;
; Prints DATA_W on one line.
; -----------------------------------------------------------------------------
SHOW_ARRAY PROC
    PUSH AX
    PUSH CX
    PUSH DX
    PUSH SI

    LEA SI, DATA_W
    MOV CX, HOWMANY

SA_LOOP:
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
    LOOP SA_LOOP

    CALL NEWLINE

    POP SI
    POP DX
    POP CX
    POP AX
    RET
SHOW_ARRAY ENDP

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
; 1. THE FLAG IS THE WHOLE IMPROVEMENT:
;    - One register and two instructions turn a sort that is always
;    - quadratic into one that is linear on data already in order.
; 2. THE NAME:
;    - Larger values rise toward the end one position per pass, the way
;    - a bubble rises. The smallest value can only move one place per
;    - pass, which is why the worst case is so poor.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
