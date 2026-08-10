; =============================================================================
; TITLE: Selection Sort On A Word Array
; DESCRIPTION: Finds the smallest remaining element on each pass and puts it in
;              place, which costs the fewest exchanges of any simple sort.
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
    ; ONE PASS PER POSITION. EACH PASS SCANS WHAT IS LEFT FOR THE SMALLEST
    ; VALUE AND SWAPS IT INTO PLACE, SO THERE IS AT MOST ONE EXCHANGE PER
    ; POSITION HOWEVER DISORDERED THE ARRAY IS.
    ; -------------------------------------------------------------------------
    MOV CX, HOWMANY
    DEC CX                              ; The last element needs no pass
    LEA SI, DATA_W

OUTER:
    PUSH CX
    MOV DI, SI                          ; Assume this position holds the least
    MOV BX, SI
    ADD BX, 2                           ; Start looking at the next one

INNER_SCAN:
    MOV AX, [BX]
    CMP AX, [DI]
    JAE NOT_SMALLER
    MOV DI, BX                          ; A new smallest, remember where

NOT_SMALLER:
    ADD BX, 2
    LOOP INNER_SCAN

    ; Put it where it belongs
    MOV AX, [SI]
    XCHG AX, [DI]
    MOV [SI], AX

    ADD SI, 2
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
; 1. FEW EXCHANGES, MANY COMPARISONS:
;    - Seven swaps at most for eight elements, but twenty eight
;    - comparisons regardless. Worth choosing when writing is expensive
;    - and reading is cheap.
; 2. THE INDEX IS A POINTER:
;    - DI holds the address of the smallest found rather than its index,
;    - which saves converting between the two when the swap happens.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
