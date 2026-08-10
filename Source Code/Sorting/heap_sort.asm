; =============================================================================
; TITLE: Heap Sort
; DESCRIPTION: Build a heap in the array itself, then repeatedly take the largest off the top, which needs no extra memory at all.
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
    DATA_W  DW 12, 11, 13, 5, 6, 7, 21, 3, 19, 8
    HOWMANY EQU 10

    HEAP_W  DW 0                        ; How much of the array is still a heap
    SIFTS_W DW 0

    M_TITLE DB 'Heap sort: build a heap, then take the top off repeatedly', 0DH, 0AH, '$'
    M_BEFOR DB 0DH, 0AH, 'before:    $'
    M_HEAP  DB 0DH, 0AH, 'as a heap: $'
    M_AFTER DB 0DH, 0AH, 'sorted:    $'
    M_SIFTS DB 0DH, 0AH, 0DH, 0AH, 'Sift operations: $'
    M_OK    DB 0DH, 0AH, 'Checked in order: yes', 0DH, 0AH, '$'
    M_BAD   DB 0DH, 0AH, 'Checked in order: NO', 0DH, 0AH, '$'
    M_SPACE DB ' $'
    M_WHY   DB 0DH, 0AH
            DB 'A heap in an array needs no pointers: the children of element n '
            DB 'are at 2n+1 and 2n+2, so the tree is implied by the arithmetic.'
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
    LEA DX, M_BEFOR
    CALL PRINT_MESSAGE
    CALL SHOW_ARRAY

    ; -------------------------------------------------------------------------
    ; BUILDING THE HEAP. ONLY THE FIRST HALF OF THE ARRAY HAS CHILDREN, SO THE
    ; SECOND HALF IS ALREADY A COLLECTION OF VALID ONE ELEMENT HEAPS AND NEEDS
    ; NO WORK. STARTING FROM THE MIDDLE AND WORKING BACKWARDS IS WHAT MAKES THE
    ; BUILD LINEAR RATHER THAN N LOG N.
    ; -------------------------------------------------------------------------
    MOV HEAP_W, HOWMANY

    MOV SI, HOWMANY
    SHR SI, 1
    DEC SI                              ; The last element that has a child

BUILD_HEAP:
    CMP SI, 0
    JL HEAP_BUILT
    CALL SIFT_DOWN
    DEC SI
    JMP BUILD_HEAP

HEAP_BUILT:
    LEA DX, M_HEAP
    CALL PRINT_MESSAGE
    CALL SHOW_ARRAY

    ; -------------------------------------------------------------------------
    ; NOW REPEATEDLY EXCHANGE THE TOP, WHICH IS THE LARGEST, WITH THE LAST
    ; ELEMENT OF THE HEAP, SHRINK THE HEAP BY ONE, AND RESTORE IT. THE ARRAY
    ; FILLS UP FROM THE RIGHT WITH THE LARGEST VALUES IN ORDER.
    ; -------------------------------------------------------------------------
    MOV CX, HOWMANY
    DEC CX

TAKE_LARGEST:
    MOV BX, HEAP_W
    DEC BX

    PUSH CX
    XOR SI, SI                          ; The top
    MOV DI, BX                          ; The last of the heap
    CALL SWAP_ELEMENTS
    POP CX

    DEC HEAP_W                          ; The largest is now outside the heap

    XOR SI, SI
    CALL SIFT_DOWN

    LOOP TAKE_LARGEST

    LEA DX, M_AFTER
    CALL PRINT_MESSAGE
    CALL SHOW_ARRAY

    LEA DX, M_SIFTS
    CALL PRINT_MESSAGE
    MOV AX, SIFTS_W
    CALL PRINT_DECIMAL

    CALL CHECK_ORDER

    LEA DX, M_WHY
    CALL PRINT_MESSAGE

    MOV AH, 4CH
    INT 21H

; -----------------------------------------------------------------------------
; SIFT_DOWN
;
; Restores the heap property at index SI, pushing the value down until both its
; children are no larger than it.
;
; The children of element n are at 2n+1 and 2n+2, which is what lets a complete
; binary tree live in a flat array with no pointers at all.
; -----------------------------------------------------------------------------
SIFT_DOWN PROC
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX
    PUSH SI
    PUSH DI

    INC SIFTS_W

SIFT_AGAIN:
    MOV BX, SI                          ; The largest so far is the parent

    ; ---- the left child ------------------------------------------------------
    MOV DI, SI
    SHL DI, 1
    INC DI
    CMP DI, HEAP_W
    JGE SIFT_RIGHT                      ; No left child, so no right one either

    PUSH SI
    MOV SI, DI
    SHL SI, 1
    MOV AX, DATA_W[SI]
    MOV SI, BX
    SHL SI, 1
    MOV DX, DATA_W[SI]
    POP SI

    CMP AX, DX
    JLE SIFT_RIGHT
    MOV BX, DI                          ; The left child is larger

SIFT_RIGHT:
    ; ---- the right child -----------------------------------------------------
    MOV DI, SI
    SHL DI, 1
    ADD DI, 2
    CMP DI, HEAP_W
    JGE SIFT_DECIDE

    PUSH SI
    MOV SI, DI
    SHL SI, 1
    MOV AX, DATA_W[SI]
    MOV SI, BX
    SHL SI, 1
    MOV DX, DATA_W[SI]
    POP SI

    CMP AX, DX
    JLE SIFT_DECIDE
    MOV BX, DI                          ; The right child is larger still

SIFT_DECIDE:
    CMP BX, SI
    JE SIFT_FINISHED                    ; The parent was already the largest

    PUSH SI
    MOV DI, BX
    CALL SWAP_ELEMENTS
    POP SI

    MOV SI, BX                          ; Follow the value down
    JMP SIFT_AGAIN

SIFT_FINISHED:
    POP DI
    POP SI
    POP DX
    POP CX
    POP BX
    POP AX
    RET
SIFT_DOWN ENDP

; -----------------------------------------------------------------------------
; SWAP_ELEMENTS
;
; Exchanges the elements at indices SI and DI.
; -----------------------------------------------------------------------------
SWAP_ELEMENTS PROC
    PUSH AX
    PUSH BX
    PUSH SI
    PUSH DI

    CMP SI, DI
    JE SWAP_DONE

    SHL SI, 1
    SHL DI, 1

    MOV AX, DATA_W[SI]
    MOV BX, DATA_W[DI]
    MOV DATA_W[SI], BX
    MOV DATA_W[DI], AX

SWAP_DONE:
    POP DI
    POP SI
    POP BX
    POP AX
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
; 1. The tree is arithmetic, not pointers:
;    - The children of element n are at 2n+1 and 2n+2, and the parent is at (n-1)/2.
;    - So a complete binary tree fits in a flat array with nothing extra stored.
;    - That is what makes heap sort need no memory beyond the array being sorted.
; 2. Build from the middle backwards:
;    - The second half of the array has no children, so it is already heaps of one.
;    - Starting at the last parent and working down makes the build linear.
;    - Sifting every element from the top instead would cost n log n before sorting even starts.
; 3. The heap shrinks as the sort grows:
;    - HEAP_W is the boundary: below it is still a heap, above it is sorted.
;    - Each step moves one element across the boundary, largest first.
;    - The array is therefore sorted in place, from the right hand end backwards.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
