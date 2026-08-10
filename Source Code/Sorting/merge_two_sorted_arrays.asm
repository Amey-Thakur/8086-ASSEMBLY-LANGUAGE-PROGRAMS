; =============================================================================
; TITLE: Merging Two Sorted Arrays
; DESCRIPTION: Combines two ordered arrays into one in a single pass, the step
;              every merge sort is built from.
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
    LEFT     DW 2, 5, 9, 14, 20
    LEFT_N   EQU 5
    RIGHT    DW 1, 6, 7, 15, 30, 44
    RIGHT_N  EQU 6
    MERGED   DW LEFT_N + RIGHT_N DUP(0)
    M_LEFT   DB 'Left:   $'
    M_RIGHT  DB 'Right:  $'
    M_OUT    DB 'Merged: $'

; -----------------------------------------------------------------------------
; CODE SEGMENT
; -----------------------------------------------------------------------------
.CODE
START:
    MOV AX, @DATA
    MOV DS, AX

    LEA DX, M_LEFT
    MOV AH, 09H
    INT 21H
    LEA SI, LEFT
    MOV CX, LEFT_N
    CALL SHOW_RUN

    LEA DX, M_RIGHT
    MOV AH, 09H
    INT 21H
    LEA SI, RIGHT
    MOV CX, RIGHT_N
    CALL SHOW_RUN

    ; -------------------------------------------------------------------------
    ; THREE POINTERS: ONE INTO EACH SOURCE AND ONE INTO THE RESULT. AT EVERY
    ; STEP THE SMALLER OF THE TWO HEADS IS TAKEN, SO THE OUTPUT IS ORDERED
    ; AFTER A SINGLE PASS OVER BOTH INPUTS.
    ; -------------------------------------------------------------------------
    LEA SI, LEFT
    LEA DI, RIGHT
    LEA BX, MERGED
    MOV CX, LEFT_N                      ; How much of the left remains
    MOV DX, RIGHT_N                     ; How much of the right remains

MERGE:
    OR  CX, CX
    JZ  DRAIN_RIGHT
    OR  DX, DX
    JZ  DRAIN_LEFT

    MOV AX, [SI]
    CMP AX, [DI]
    JA  TAKE_RIGHT

    MOV [BX], AX                        ; The left head is smaller
    ADD SI, 2
    DEC CX
    JMP ADVANCE

TAKE_RIGHT:
    MOV AX, [DI]
    MOV [BX], AX
    ADD DI, 2
    DEC DX

ADVANCE:
    ADD BX, 2
    JMP MERGE

    ; -------------------------------------------------------------------------
    ; WHEN ONE SIDE RUNS OUT THE OTHER IS ALREADY IN ORDER, SO WHAT IS LEFT
    ; OF IT IS COPIED STRAIGHT ACROSS.
    ; -------------------------------------------------------------------------
DRAIN_LEFT:
    OR  CX, CX
    JZ  MERGED_DONE
    MOV AX, [SI]
    MOV [BX], AX
    ADD SI, 2
    ADD BX, 2
    DEC CX
    JMP DRAIN_LEFT

DRAIN_RIGHT:
    OR  DX, DX
    JZ  MERGED_DONE
    MOV AX, [DI]
    MOV [BX], AX
    ADD DI, 2
    ADD BX, 2
    DEC DX
    JMP DRAIN_RIGHT

MERGED_DONE:
    LEA DX, M_OUT
    MOV AH, 09H
    INT 21H
    LEA SI, MERGED
    MOV CX, LEFT_N + RIGHT_N
    CALL SHOW_RUN

    MOV AH, 4CH
    INT 21H

; -----------------------------------------------------------------------------
; SHOW_RUN
;
; Prints CX words starting at SI.
; -----------------------------------------------------------------------------
SHOW_RUN PROC
    PUSH AX
    PUSH DX
    PUSH SI
    PUSH CX

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

    CALL NEWLINE

    POP CX
    POP SI
    POP DX
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
; 1. ONE PASS, NOT TWO:
;    - Every element is examined once and written once. Concatenating and
;    - then sorting would cost far more and throw away the ordering the
;    - inputs already had.
; 2. THE DRAIN IS NOT OPTIONAL:
;    - The main loop stops as soon as either side empties, and whatever
;    - remains on the other has to be copied. Leaving it out loses the
;    - tail, which is the usual bug in a hand written merge.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
