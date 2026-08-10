; =============================================================================
; TITLE: Leaving Two Loops At Once
; DESCRIPTION: Searching a table needs the inner loop and the outer loop to end together, which a single branch cannot do.
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
    GRID    DW  4,  9, 16, 23
            DW 30, 37, 42, 51
            DW 58, 65, 71, 88
    ROWS    EQU 3
    COLS    EQU 4
    STRIDE  EQU COLS * 2

    WANTED  DW 42
    ABSENT  DW 99

    M_TITLE DB 'Ending an inner and an outer loop together', 0DH, 0AH, '$'
    M_LOOK  DB 0DH, 0AH, 'Looking for $'
    M_FOUND DB '   found at row $'
    M_COL   DB ', column $'
    M_NONE  DB '   not present', '$'
    M_SEEN  DB '   cells examined: $'

    HIT_ROW DW 0                        ; Where the match was, captured before
    HIT_COL DW 0                        ; the loop counters are unwound
    M_WHY   DB 0DH, 0AH, 0DH, 0AH
            DB 'A flag word carries the answer out. Jumping straight from the '
            DB 'inner loop to the end would leave the outer count on the stack.'
            DB 0DH, 0AH, '$'

; -----------------------------------------------------------------------------
; CODE SEGMENT
; -----------------------------------------------------------------------------
.CODE
START:
    MOV AX, @DATA
    MOV DS, AX

    LEA DX, M_TITLE
    CALL PRINT_MESSAGE

    MOV AX, WANTED
    CALL SEARCH_GRID

    MOV AX, ABSENT
    CALL SEARCH_GRID

    LEA DX, M_WHY
    CALL PRINT_MESSAGE

    MOV AH, 4CH
    INT 21H

; -----------------------------------------------------------------------------
; SEARCH_GRID
;
; Looks for AX in the grid and reports where it was.
;
; The outer loop keeps its count on the stack while the inner one runs, so the
; inner loop cannot simply jump past the end: the pushed count would be left
; behind and the next RET would return to it. BP carries the verdict out
; instead, and both loops unwind properly.
; -----------------------------------------------------------------------------
SEARCH_GRID PROC
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX
    PUSH SI
    PUSH DI

    MOV DI, AX                          ; What is being looked for

    LEA DX, M_LOOK
    CALL PRINT_MESSAGE
    MOV AX, DI
    CALL PRINT_DECIMAL

    XOR BP, BP                          ; 0 not found, 1 found
    XOR BX, BX                          ; Row offset in bytes
    XOR SI, SI                          ; Cells examined
    MOV CX, ROWS

EACH_ROW:
    PUSH CX
    PUSH BX                             ; The row base, needed after the columns
    XOR DX, DX                          ; Column offset in bytes
    MOV CX, COLS

EACH_COLUMN:
    INC SI

    MOV AX, BX
    ADD AX, DX
    PUSH BX
    MOV BX, AX
    MOV AX, GRID[BX]
    POP BX

    CMP AX, DI
    JE FOUND_IT

    ADD DX, 2
    LOOP EACH_COLUMN

    POP BX
    ADD BX, STRIDE
    POP CX
    LOOP EACH_ROW
    JMP SEARCH_DONE

FOUND_IT:
    ; The inner loop is abandoned, but the two pushed words are still there and
    ; have to come off before anything else happens. The position is copied out
    ; first, because unwinding is about to reuse both registers holding it.
    MOV BP, 1
    MOV HIT_COL, DX
    POP BX                              ; The row base
    MOV HIT_ROW, BX
    POP CX                              ; The outer count

    LEA DX, M_FOUND
    CALL PRINT_MESSAGE
    MOV AX, HIT_ROW
    XOR DX, DX
    MOV CX, STRIDE
    DIV CX
    CALL PRINT_DECIMAL

    LEA DX, M_COL
    CALL PRINT_MESSAGE
    MOV AX, HIT_COL
    SHR AX, 1                           ; Byte offset back to a column number
    CALL PRINT_DECIMAL

SEARCH_DONE:
    CMP BP, 1
    JE REPORT_COUNT

    LEA DX, M_NONE
    CALL PRINT_MESSAGE

REPORT_COUNT:
    LEA DX, M_SEEN
    CALL PRINT_MESSAGE
    MOV AX, SI
    CALL PRINT_DECIMAL

    POP DI
    POP SI
    POP DX
    POP CX
    POP BX
    POP AX
    RET
SEARCH_GRID ENDP

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

; -----------------------------------------------------------------------------
; PRINT_MESSAGE
;
; Prints the dollar terminated string at DS:DX, leaving AX exactly as it was.
;
; Service 09H needs the service number in AH, and AH is the top half of AX. A
; caller that has just computed a result into AX and then sets AH for itself
; destroys that result: 500 becomes 09F4H, which prints as 2548. Doing the call
; in here, around a push and a pop, removes the trap for good.
; -----------------------------------------------------------------------------
PRINT_MESSAGE PROC
    PUSH AX

    MOV AH, 09H
    INT 21H

    POP AX
    RET
PRINT_MESSAGE ENDP

END START

; =============================================================================
; TECHNICAL NOTES
; =============================================================================
; 1. The stack decides where you may jump to:
;    - The outer loop pushes its count, so the inner loop is inside a pushed frame.
;    - Jumping out of both without popping leaves the stack one word deep for ever.
;    - Popping on the way out, as the found path does here, is what keeps RET honest.
; 2. Carry the verdict in a register:
;    - BP says whether the search succeeded, so both exits reach the same reporting code.
;    - Duplicating the report at each exit is how the two copies drift apart later.
;    - A single exit point is worth the extra register on anything but the tightest loop.
; 3. Counting the work:
;    - Cells examined is what shows the early exit actually saved anything.
;    - The absent value costs all twelve; the present one stops at the seventh.
;    - Without the count, an early exit that silently never fires looks the same as one that does.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
