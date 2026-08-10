; =============================================================================
; TITLE: Merge Sort, Bottom Up
; DESCRIPTION: Sorts by merging runs of one into runs of two, then four, and so
;              on, which avoids recursion entirely.
; AUTHOR: Amey Thakur (https://github.com/Amey-Thakur)
; REPOSITORY: https://github.com/Amey-Thakur/8086-ASSEMBLY-LANGUAGE-PROGRAMS
; LICENSE: MIT License
; =============================================================================

.MODEL SMALL
.STACK 200H

; -----------------------------------------------------------------------------
; DATA SEGMENT
; -----------------------------------------------------------------------------
.DATA
    DATA_W   DW 42, 17, 93, 8, 65, 31, 76, 4
    HOWMANY  EQU 8
    SCRATCH  DW HOWMANY DUP(0)

    ; The cursors live in memory rather than in registers. There are seven of
    ; them and only four registers that could hold one, and a merge that spills
    ; half its state to the stack is harder to read than one that keeps it all
    ; in named words.
    WIDTH    DW 1                       ; The length of the runs being merged
    LSTART   DW 0                       ; Where the left run begins
    MID      DW 0                       ; Where the left ends and the right starts
    REND     DW 0                       ; Where the right run ends
    LI       DW 0                       ; Cursor into the left run
    RI       DW 0                       ; Cursor into the right run
    OI       DW 0                       ; Cursor into the scratch array

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
    ; RUNS OF ONE ARE ALREADY SORTED. MERGING NEIGHBOURING RUNS DOUBLES THEIR
    ; LENGTH, AND AFTER THREE ROUNDS OF DOUBLING EIGHT ELEMENTS ARE ONE RUN.
    ; THE RECURSION OF THE USUAL MERGE SORT IS REPLACED BY THIS DOUBLING.
    ; -------------------------------------------------------------------------
    MOV WORD PTR WIDTH, 1

ROUND:
    MOV AX, WIDTH
    CMP AX, HOWMANY
    JAE ALL_MERGED

    MOV WORD PTR LSTART, 0

PAIRS:
    MOV AX, LSTART
    CMP AX, HOWMANY
    JAE ROUND_DONE

    ; -------------------------------------------------------------------------
    ; THE LEFT RUN IS [LSTART, MID) AND THE RIGHT IS [MID, REND). BOTH ENDS
    ; ARE CLAMPED TO THE ARRAY, BECAUSE THE LAST PAIR OF RUNS IN A ROUND IS
    ; OFTEN SHORT AND MAY HAVE NO RIGHT HALF AT ALL.
    ; -------------------------------------------------------------------------
    MOV AX, LSTART
    ADD AX, WIDTH
    CMP AX, HOWMANY
    JBE MID_OK
    MOV AX, HOWMANY

MID_OK:
    MOV MID, AX

    MOV AX, WIDTH
    SHL AX, 1
    ADD AX, LSTART
    CMP AX, HOWMANY
    JBE REND_OK
    MOV AX, HOWMANY

REND_OK:
    MOV REND, AX

    ; Three cursors: one into each run, one into the scratch
    MOV AX, LSTART
    MOV LI, AX
    MOV OI, AX
    MOV AX, MID
    MOV RI, AX

TAKE_NEXT:
    MOV AX, LI
    CMP AX, MID
    JAE TAKE_FROM_RIGHT                 ; The left run is spent

    MOV AX, RI
    CMP AX, REND
    JAE TAKE_FROM_LEFT                  ; The right run is spent

    ; Both still have elements, so compare their heads
    MOV SI, LI
    SHL SI, 1
    MOV AX, DATA_W[SI]
    MOV DI, RI
    SHL DI, 1
    CMP AX, DATA_W[DI]
    JA  TAKE_FROM_RIGHT

TAKE_FROM_LEFT:
    MOV AX, LI
    CMP AX, MID
    JAE PAIR_DONE

    MOV SI, LI
    SHL SI, 1
    MOV AX, DATA_W[SI]
    MOV DI, OI
    SHL DI, 1
    MOV SCRATCH[DI], AX

    INC WORD PTR LI
    INC WORD PTR OI
    JMP TAKE_NEXT

TAKE_FROM_RIGHT:
    MOV AX, RI
    CMP AX, REND
    JAE TAKE_FROM_LEFT_ONLY

    MOV SI, RI
    SHL SI, 1
    MOV AX, DATA_W[SI]
    MOV DI, OI
    SHL DI, 1
    MOV SCRATCH[DI], AX

    INC WORD PTR RI
    INC WORD PTR OI
    JMP TAKE_NEXT

TAKE_FROM_LEFT_ONLY:
    MOV AX, LI
    CMP AX, MID
    JAE PAIR_DONE
    JMP TAKE_FROM_LEFT

PAIR_DONE:
    MOV AX, WIDTH
    SHL AX, 1
    ADD AX, LSTART
    MOV LSTART, AX                      ; On to the next pair of runs
    JMP PAIRS

ROUND_DONE:
    ; Copy the scratch back and double the run length
    LEA SI, SCRATCH
    LEA DI, DATA_W
    MOV CX, HOWMANY

COPY_BACK:
    MOV AX, [SI]
    MOV [DI], AX
    ADD SI, 2
    ADD DI, 2
    LOOP COPY_BACK

    SHL WORD PTR WIDTH, 1
    JMP ROUND

ALL_MERGED:
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
; 1. WHY BOTTOM UP:
;    - The recursive form splits until the runs are single elements, then
;    - merges on the way back. Starting from single elements and doubling
;    - reaches the same place with no stack at all.
; 2. THE SCRATCH ARRAY:
;    - A merge cannot be done in place without a great deal of extra
;    - work, so a second array of the same size is the usual price.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
