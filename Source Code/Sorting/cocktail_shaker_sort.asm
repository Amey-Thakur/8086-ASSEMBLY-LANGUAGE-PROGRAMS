; =============================================================================
; TITLE: Cocktail Shaker Sort
; DESCRIPTION: A bubble sort that alternates direction, so a small value near
;              the end reaches the front in one pass rather than seven.
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
    ; THE WEAKNESS OF A BUBBLE SORT IS THAT SMALL VALUES MOVE LEFT ONLY ONE
    ; PLACE PER PASS. ALTERNATING THE DIRECTION FIXES THAT: EACH ROUND SENDS
    ; THE LARGEST TO THE END AND THEN THE SMALLEST TO THE FRONT.
    ; -------------------------------------------------------------------------
    MOV BX, 0                           ; The first unsorted position
    MOV DI, HOWMANY
    DEC DI                              ; The last unsorted position

SHAKE:
    CMP BX, DI
    JAE SORTED

    ; ---- forward: carry the largest to the end ----------------------------
    MOV SI, BX
    SHL SI, 1
    ADD SI, OFFSET DATA_W
    MOV CX, DI
    SUB CX, BX

FORWARD:
    MOV AX, [SI]
    CMP AX, [SI+2]
    JBE F_ORDERED
    XCHG AX, [SI+2]
    MOV [SI], AX

F_ORDERED:
    ADD SI, 2
    LOOP FORWARD

    DEC DI                              ; The end is now settled
    CMP BX, DI
    JAE SORTED

    ; ---- backward: carry the smallest to the front ------------------------
    MOV SI, DI
    SHL SI, 1
    ADD SI, OFFSET DATA_W
    MOV CX, DI
    SUB CX, BX

BACKWARD:
    MOV AX, [SI-2]
    CMP AX, [SI]
    JBE B_ORDERED
    XCHG AX, [SI]
    MOV [SI-2], AX

B_ORDERED:
    SUB SI, 2
    LOOP BACKWARD

    INC BX                              ; The front is now settled
    JMP SHAKE

SORTED:

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
; 1. THE SORTED REGION GROWS FROM BOTH ENDS:
;    - BX and DI close in on each other, and everything outside them is
;    - already final. The sort ends when they meet.
; 2. STILL QUADRATIC:
;    - The constant is better but the shape is the same. It is an
;    - improvement on bubble sort, not an escape from it.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
