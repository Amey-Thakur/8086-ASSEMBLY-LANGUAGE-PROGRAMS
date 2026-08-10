; =============================================================================
; TITLE: Radix Sort
; DESCRIPTION: Sorts by one digit at a time using counting sort, which makes it linear in the number of digits rather than logarithmic.
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
    DATA_W  DW 170, 45, 75, 90, 802, 24, 2, 66
    HOWMANY EQU 8

    BUCKET  DW 10 DUP (0)               ; How many of each digit
    OUTPUT  DW HOWMANY DUP (0)          ; Where a pass writes its result

    PASSES  DW 0

    M_TITLE DB 'Radix sort: one digit at a time, least significant first', 0DH, 0AH, '$'
    M_BEFOR DB 0DH, 0AH, 'before:      $'
    M_PASS  DB 0DH, 0AH, 'after place $'
    M_COLON DB ': $'
    M_AFTER DB 0DH, 0AH, 0DH, 0AH, 'sorted:      $'
    M_OK    DB 0DH, 0AH, 'Checked in order: yes', 0DH, 0AH, '$'
    M_BAD   DB 0DH, 0AH, 'Checked in order: NO', 0DH, 0AH, '$'
    M_SPACE DB ' $'
    M_WHY   DB 0DH, 0AH
            DB 'Each pass must be stable, or the order established by the '
            DB 'previous digit is lost. Walking the input backwards while '
            DB 'filling from the end of each bucket is what makes it so.'
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
    ; BP IS THE PLACE VALUE: ONES, THEN TENS, THEN HUNDREDS. THE LARGEST VALUE
    ; HERE IS 802, SO THREE PASSES ARE ENOUGH, AND THE LOOP STOPS WHEN THE PLACE
    ; VALUE EXCEEDS THE LARGEST NUMBER.
    ; -------------------------------------------------------------------------
    MOV BP, 1

EACH_PLACE:
    CALL LARGEST_VALUE                  ; AX = the largest still to be covered
    XOR DX, DX
    MOV BX, BP
    DIV BX                              ; largest / place
    CMP AX, 0
    JE SORTING_DONE                     ; The place is past the top digit

    CALL COUNTING_PASS
    INC PASSES

    LEA DX, M_PASS
    CALL PRINT_MESSAGE
    MOV AX, BP
    CALL PRINT_DECIMAL
    LEA DX, M_COLON
    CALL PRINT_MESSAGE
    CALL SHOW_ARRAY

    ; The next place value up. A multiply, because the base is ten.
    MOV AX, BP
    MOV BX, 10
    MUL BX
    MOV BP, AX
    JMP EACH_PLACE

SORTING_DONE:
    LEA DX, M_AFTER
    CALL PRINT_MESSAGE
    CALL SHOW_ARRAY

    CALL CHECK_ORDER

    LEA DX, M_WHY
    CALL PRINT_MESSAGE

    MOV AH, 4CH
    INT 21H

; -----------------------------------------------------------------------------
; COUNTING_PASS
;
; One stable counting sort on the digit selected by the place value in BP.
;
; Three steps: count how many of each digit there are, turn the counts into
; positions by running totals, then place each element. The placing walks the
; input BACKWARDS, which is what keeps equal digits in the order they arrived.
; -----------------------------------------------------------------------------
COUNTING_PASS PROC
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX
    PUSH SI
    PUSH DI

    ; ---- clear the buckets ---------------------------------------------------
    XOR SI, SI
    MOV CX, 10
CLEAR_BUCKETS:
    MOV BUCKET[SI], 0
    ADD SI, 2
    LOOP CLEAR_BUCKETS

    ; ---- count each digit ----------------------------------------------------
    XOR SI, SI
    MOV CX, HOWMANY
COUNT_DIGITS:
    MOV AX, DATA_W[SI]
    CALL DIGIT_OF                       ; AX becomes the digit
    SHL AX, 1
    MOV DI, AX
    INC BUCKET[DI]
    ADD SI, 2
    LOOP COUNT_DIGITS

    ; ---- running totals, so each bucket holds where its run ends -------------
    XOR SI, SI
    XOR BX, BX
    MOV CX, 10
RUNNING_TOTAL:
    MOV AX, BUCKET[SI]
    ADD BX, AX
    MOV BUCKET[SI], BX
    ADD SI, 2
    LOOP RUNNING_TOTAL

    ; ---- place each element, walking backwards for stability ----------------
    MOV SI, HOWMANY
    DEC SI
    SHL SI, 1                           ; The last element

PLACE_EACH:
    MOV AX, DATA_W[SI]
    PUSH AX
    CALL DIGIT_OF
    SHL AX, 1
    MOV DI, AX

    DEC BUCKET[DI]                      ; One fewer of this digit to place
    MOV BX, BUCKET[DI]
    SHL BX, 1

    POP AX
    MOV OUTPUT[BX], AX

    SUB SI, 2
    CMP SI, 0
    JGE PLACE_EACH

    ; ---- and copy the result back -------------------------------------------
    XOR SI, SI
    MOV CX, HOWMANY
COPY_BACK:
    MOV AX, OUTPUT[SI]
    MOV DATA_W[SI], AX
    ADD SI, 2
    LOOP COPY_BACK

    POP DI
    POP SI
    POP DX
    POP CX
    POP BX
    POP AX
    RET
COUNTING_PASS ENDP

; -----------------------------------------------------------------------------
; DIGIT_OF
;
; The digit of AX at the place value in BP. Divide by the place, then take the
; remainder on ten.
; -----------------------------------------------------------------------------
DIGIT_OF PROC
    PUSH BX
    PUSH DX

    XOR DX, DX
    MOV BX, BP
    DIV BX                              ; AX = value / place

    XOR DX, DX
    MOV BX, 10
    DIV BX                              ; DX = that mod ten

    MOV AX, DX

    POP DX
    POP BX
    RET
DIGIT_OF ENDP

; -----------------------------------------------------------------------------
; LARGEST_VALUE
;
; The largest element, returned in AX. Used only to decide how many passes are
; needed, which is why it is recomputed rather than cached.
; -----------------------------------------------------------------------------
LARGEST_VALUE PROC
    PUSH BX
    PUSH CX
    PUSH SI

    XOR AX, AX
    XOR SI, SI
    MOV CX, HOWMANY
LARGEST_ONE:
    MOV BX, DATA_W[SI]
    CMP BX, AX
    JBE NOT_LARGER
    MOV AX, BX
NOT_LARGER:
    ADD SI, 2
    LOOP LARGEST_ONE

    POP SI
    POP CX
    POP BX
    RET
LARGEST_VALUE ENDP

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
    JA OUT_OF_ORDER
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
; 1. Stability is the whole requirement:
;    - Each pass must leave equal digits in the order the previous pass established.
;    - Walking the input backwards while taking positions from the end of each bucket does that.
;    - Walking forwards sorts the digits correctly and destroys everything below them.
; 2. Least significant digit first:
;    - Starting from the ones place means later passes refine an already ordered list.
;    - Starting from the most significant would need the buckets sorted separately.
;    - Three passes here, because the largest value has three digits.
; 3. Not a comparison sort:
;    - No two elements are ever compared with each other.
;    - That is how it escapes the n log n bound that every comparison sort obeys.
;    - The cost is the buckets, and knowing the range in advance.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
