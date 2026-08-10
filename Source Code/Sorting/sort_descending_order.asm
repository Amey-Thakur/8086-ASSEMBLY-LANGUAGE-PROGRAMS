; =============================================================================
; TITLE: Sorting into Descending Order
; DESCRIPTION: The same sort with one branch reversed, which is all that
;              separates ascending from descending.
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
    ; THE ONLY DIFFERENCE FROM AN ASCENDING SORT IS JAE INSTEAD OF JBE. THE
    ; COMPARISON IS THE ORDERING; EVERYTHING ELSE IS BOOKKEEPING.
    ; -------------------------------------------------------------------------
    MOV CX, HOWMANY
    DEC CX

OUTER:
    PUSH CX
    LEA SI, DATA_W

INNER_PASS:
    MOV AX, [SI]
    CMP AX, [SI+2]
    JAE IN_ORDER                        ; Larger first is what we want now

    XCHG AX, [SI+2]
    MOV [SI], AX

IN_ORDER:
    ADD SI, 2
    LOOP INNER_PASS

    POP CX
    LOOP OUTER

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
; 1. ONE INSTRUCTION DECIDES THE ORDER:
;    - Reversing the branch reverses the sort. Nothing else has to
;    - change, which is why a sort routine usually takes the comparison
;    - as a parameter in languages that allow it.
; 2. SIGNED DATA NEEDS JGE:
;    - JAE compares as unsigned. On an array containing negatives it
;    - would place them at the front, and JGE is the correct choice.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
