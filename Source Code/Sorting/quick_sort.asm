; =============================================================================
; TITLE: Quick Sort
; DESCRIPTION: Partition around a pivot and sort each side, with the recursion carried on the stack as two offsets at a time.
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
    DATA_W  DW 38, 27, 43, 3, 9, 82, 10, 1, 55, 21
    HOWMANY EQU 10

    SWAPS_W DW 0
    CALLS_W DW 0

    M_TITLE DB 'Quick sort: partition, then sort each side', 0DH, 0AH, '$'
    M_BEFOR DB 0DH, 0AH, 'before: $'
    M_AFTER DB 0DH, 0AH, 'after:  $'
    M_STATS DB 0DH, 0AH, 0DH, 0AH, 'Partition calls: $'
    M_SWAPS DB '   swaps: $'
    M_OK    DB 0DH, 0AH, 'Checked in order: yes', 0DH, 0AH, '$'
    M_BAD   DB 0DH, 0AH, 'Checked in order: NO', 0DH, 0AH, '$'
    M_SPACE DB ' $'
    M_WHY   DB 0DH, 0AH
            DB 'The recursion is real recursion: each call keeps its own bounds '
            DB 'on the stack, which is why the stack here is 512 bytes rather '
            DB 'than 256.', 0DH, 0AH, '$'

; -----------------------------------------------------------------------------
; CODE SEGMENT
; -----------------------------------------------------------------------------
.CODE
START:
    MOV AX, @DATA
    MOV DS, AX

    LEA DX, M_TITLE
    CALL PRINT_MESSAGE
    LEA DX, M_BEFOR
    CALL PRINT_MESSAGE
    CALL SHOW_ARRAY

    ; -------------------------------------------------------------------------
    ; THE BOUNDS ARE INDICES, NOT ADDRESSES, WHICH KEEPS THE ARITHMETIC INSIDE
    ; THE PARTITION SIMPLE. THEY ARE PASSED IN AX AND BX BECAUSE THE PROCEDURE
    ; IS CALLED FROM ITSELF AND A STACK FRAME PER CALL WOULD COST MORE.
    ; -------------------------------------------------------------------------
    MOV AX, 0
    MOV BX, HOWMANY - 1
    CALL QUICK_SORT

    LEA DX, M_AFTER
    CALL PRINT_MESSAGE
    CALL SHOW_ARRAY

    LEA DX, M_STATS
    CALL PRINT_MESSAGE
    MOV AX, CALLS_W
    CALL PRINT_DECIMAL
    LEA DX, M_SWAPS
    CALL PRINT_MESSAGE
    MOV AX, SWAPS_W
    CALL PRINT_DECIMAL

    CALL CHECK_ORDER

    LEA DX, M_WHY
    CALL PRINT_MESSAGE

    MOV AH, 4CH
    INT 21H

; -----------------------------------------------------------------------------
; QUICK_SORT
;
; Sorts DATA_W between the indices in AX (low) and BX (high), inclusive.
;
; Both bounds are pushed before the first recursive call and popped after it,
; because the partition destroys them. Forgetting that is the usual reason a
; hand written quick sort sorts one half and loses the other.
; -----------------------------------------------------------------------------
QUICK_SORT PROC
    PUSH AX
    PUSH BX
    PUSH CX

    CMP AX, BX
    JGE SORT_DONE                       ; Nothing, or one element, is sorted

    PUSH AX
    PUSH BX
    CALL PARTITION                      ; CX comes back as the pivot's resting place
    POP BX
    POP AX

    ; ---- everything left of the pivot ---------------------------------------
    PUSH AX
    PUSH BX
    PUSH CX
    MOV BX, CX
    DEC BX
    CALL QUICK_SORT
    POP CX
    POP BX
    POP AX

    ; ---- and everything right of it -----------------------------------------
    PUSH AX
    PUSH BX
    MOV AX, CX
    INC AX
    CALL QUICK_SORT
    POP BX
    POP AX

SORT_DONE:
    POP CX
    POP BX
    POP AX
    RET
QUICK_SORT ENDP

; -----------------------------------------------------------------------------
; PARTITION
;
; Lomuto's scheme. The last element is the pivot; everything smaller is moved to
; the front, and the pivot is finally swapped into the gap that leaves.
;
; Returns the pivot's final index in CX.
; -----------------------------------------------------------------------------
PARTITION PROC
    PUSH AX
    PUSH DX
    PUSH SI
    PUSH DI
    PUSH BP

    INC CALLS_W

    MOV BP, AX                          ; Low bound
    MOV DI, BX                          ; High bound, where the pivot is

    ; The pivot's value, read once. Re-reading it inside the loop would be wrong
    ; the moment a swap moved it.
    MOV SI, DI
    SHL SI, 1
    MOV DX, DATA_W[SI]                  ; The pivot value

    MOV CX, BP                          ; Where the next smaller element goes
    MOV SI, BP                          ; The scan

SCAN_ONE:
    CMP SI, DI
    JGE SCAN_FINISHED

    PUSH BX
    MOV BX, SI
    SHL BX, 1
    MOV AX, DATA_W[BX]
    POP BX

    CMP AX, DX
    JGE SCAN_NEXT                       ; Not smaller, so leave it alone

    ; ---- move it to the front ------------------------------------------------
    PUSH SI
    PUSH CX
    CALL SWAP_ELEMENTS
    POP CX
    POP SI
    INC CX

SCAN_NEXT:
    INC SI
    JMP SCAN_ONE

SCAN_FINISHED:
    ; ---- and the pivot into the gap -----------------------------------------
    PUSH DI
    PUSH CX
    CALL SWAP_ELEMENTS
    POP CX
    POP DI

    POP BP
    POP DI
    POP SI
    POP DX
    POP AX
    RET
PARTITION ENDP

; -----------------------------------------------------------------------------
; SWAP_ELEMENTS
;
; Exchanges the two elements whose indices are on the stack, pushed as the
; second one then the first. Counts the exchange.
;
; Passing the indices on the stack rather than in registers is what lets the
; partition call it without first finding two registers it is not already using.
; -----------------------------------------------------------------------------
SWAP_ELEMENTS PROC
    PUSH BP
    MOV BP, SP
    PUSH AX
    PUSH BX
    PUSH SI
    PUSH DI

    MOV SI, [BP+4]                      ; First index
    MOV DI, [BP+6]                      ; Second index

    CMP SI, DI
    JE SWAP_DONE                        ; Swapping an element with itself

    SHL SI, 1
    SHL DI, 1

    MOV AX, DATA_W[SI]
    MOV BX, DATA_W[DI]
    MOV DATA_W[SI], BX
    MOV DATA_W[DI], AX

    INC SWAPS_W

SWAP_DONE:
    POP DI
    POP SI
    POP BX
    POP AX
    POP BP
    RET
SWAP_ELEMENTS ENDP

; -----------------------------------------------------------------------------
; SHOW_ARRAY
; -----------------------------------------------------------------------------
SHOW_ARRAY PROC
    PUSH AX
    PUSH CX
    PUSH DX
    PUSH SI

    XOR SI, SI
    MOV CX, HOWMANY
SHOW_ONE:
    MOV AX, DATA_W[SI]
    CALL PRINT_DECIMAL
    LEA DX, M_SPACE
    CALL PRINT_MESSAGE
    ADD SI, 2
    LOOP SHOW_ONE

    POP SI
    POP DX
    POP CX
    POP AX
    RET
SHOW_ARRAY ENDP

; -----------------------------------------------------------------------------
; CHECK_ORDER
;
; Confirms every element is at least as large as the one before it. A sort that
; is only inspected by eye is a sort nobody has checked.
; -----------------------------------------------------------------------------
CHECK_ORDER PROC
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX
    PUSH SI

    XOR SI, SI
    MOV CX, HOWMANY - 1

CHECK_ONE:
    MOV AX, DATA_W[SI]
    MOV BX, DATA_W[SI+2]
    CMP AX, BX
    JG OUT_OF_ORDER
    ADD SI, 2
    LOOP CHECK_ONE

    LEA DX, M_OK
    CALL PRINT_MESSAGE
    JMP CHECK_FINISHED

OUT_OF_ORDER:
    LEA DX, M_BAD
    CALL PRINT_MESSAGE

CHECK_FINISHED:
    POP SI
    POP DX
    POP CX
    POP BX
    POP AX
    RET
CHECK_ORDER ENDP

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
; 1. The pivot value is read once:
;    - A swap can move the pivot, so re-reading it by index inside the loop is wrong.
;    - Copying the value into DX before the scan begins is the whole fix.
;    - This is the commonest bug in a hand written Lomuto partition.
; 2. Bounds must survive the recursion:
;    - The partition destroys the registers holding the low and high bounds.
;    - Both are pushed before each recursive call and popped after it.
;    - Losing them sorts one half and silently leaves the other alone.
; 3. Stack depth is the cost:
;    - Each level keeps its own bounds, so a badly balanced split can nest deeply.
;    - Ten elements is shallow, but the stack is doubled here to leave room.
;    - Sorting the smaller side first bounds the depth at log n, which this version does not do.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
