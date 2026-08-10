; =============================================================================
; TITLE: Insertion Sort
; DESCRIPTION: Grows a sorted region one element at a time by sliding each new
;              value back until it fits, the way a hand of cards is ordered.
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
    ; EVERYTHING TO THE LEFT OF SI IS ALREADY IN ORDER. EACH PASS TAKES THE
    ; NEXT VALUE, SLIDES THE LARGER ONES RIGHT TO MAKE ROOM, AND DROPS IT IN.
    ; -------------------------------------------------------------------------
    MOV CX, HOWMANY
    DEC CX
    LEA SI, DATA_W
    ADD SI, 2                           ; The first element is a sorted region

OUTER:
    MOV AX, [SI]                        ; The value being placed
    MOV DI, SI

SLIDE:
    CMP DI, OFFSET DATA_W
    JBE PLACE_IT                        ; Reached the front

    MOV BX, [DI-2]
    CMP BX, AX
    JBE PLACE_IT                        ; Found where it belongs

    MOV [DI], BX                        ; Shift the larger value right
    SUB DI, 2
    JMP SLIDE

PLACE_IT:
    MOV [DI], AX

    ADD SI, 2
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
; 1. FAST ON NEARLY SORTED DATA:
;    - When each value is already close to its place the inner loop stops
;    - almost at once, and the whole sort approaches one pass. No other
;    - simple sort has that property.
; 2. SHIFTING, NOT SWAPPING:
;    - The value being placed is held in AX while the larger ones move up
;    - one at a time. A swap for each would be twice the memory traffic.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
