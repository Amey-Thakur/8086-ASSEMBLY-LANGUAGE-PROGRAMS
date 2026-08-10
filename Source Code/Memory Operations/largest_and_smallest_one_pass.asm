; =============================================================================
; TITLE: Largest And Smallest In One Pass
; DESCRIPTION: Finds both extremes of a block in a single walk by taking the
;              values two at a time, so that three comparisons settle a pair
;              where the obvious method spends four.
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
    VALUES   DW 47, 3, 91, 25, 68, 12, 84, 39, 7, 56
    VALUES_B EQU $ - VALUES              ; Bytes occupied, measured not counted
    HOWMANY  EQU VALUES_B / 2            ; and so how many words there are

    SMALLEST DW 0                        ; The largest lives in BP, this one in memory

    M_LIST   DB 'Values: $'
    M_BIG    DB 'Largest:  $'
    M_SMALL  DB 'Smallest: $'
    M_MADE   DB 'Comparisons made: $'
    M_NAIVE  DB 'Testing each value against both extremes would have made: $'

; -----------------------------------------------------------------------------
; CODE SEGMENT
; -----------------------------------------------------------------------------
.CODE
START:
    MOV AX, @DATA
    MOV DS, AX

    LEA DX, M_LIST
    CALL PRINT_MESSAGE
    LEA SI, VALUES
    MOV CX, HOWMANY
    CALL SHOW_RUN

    XOR SI, SI                          ; Byte index into the block
    XOR DI, DI                          ; Comparisons made so far
    MOV CX, HOWMANY

    ; -------------------------------------------------------------------------
    ; AN ODD COUNT CANNOT BE WALKED TWO AT A TIME, SO A SINGLE LEADING VALUE
    ; SEEDS BOTH EXTREMES AND WHAT REMAINS IS EVEN. AN EVEN COUNT IS SEEDED BY
    ; ITS FIRST PAIR INSTEAD, WHICH COSTS ONE COMPARISON RATHER THAN NONE.
    ; -------------------------------------------------------------------------
    TEST CX, 1
    JZ  SEED_FROM_PAIR

    MOV AX, VALUES[SI]
    ADD SI, 2
    DEC CX
    MOV SMALLEST, AX
    MOV BP, AX
    JMP PAIRS_READY

SEED_FROM_PAIR:
    MOV AX, VALUES[SI]
    ADD SI, 2
    MOV BX, VALUES[SI]
    ADD SI, 2
    SUB CX, 2
    INC DI
    CMP AX, BX                          ; Unsigned: every value here is positive
    JBE SEED_ORDERED
    XCHG AX, BX                         ; AX now holds the smaller of the two
SEED_ORDERED:
    MOV SMALLEST, AX
    MOV BP, BX

PAIRS_READY:
    SHR CX, 1                           ; What is left divides into whole pairs
    JCXZ EXTREMES_DONE                  ; Two values may be all there were

    ; -------------------------------------------------------------------------
    ; THE SAVING IS HERE. ORDERING THE PAIR AGAINST ITSELF COSTS ONE COMPARISON
    ; AND THEN PROVES THAT ONLY THE SMALLER CAN BEAT THE MINIMUM AND ONLY THE
    ; LARGER CAN BEAT THE MAXIMUM, SO TWO MORE FINISH THE PAIR RATHER THAN FOUR.
    ; -------------------------------------------------------------------------
EACH_PAIR:
    MOV AX, VALUES[SI]
    ADD SI, 2
    MOV BX, VALUES[SI]
    ADD SI, 2

    INC DI
    CMP AX, BX
    JBE PAIR_ORDERED
    XCHG AX, BX
PAIR_ORDERED:

    INC DI
    CMP AX, SMALLEST
    JAE NOT_SMALLER
    MOV SMALLEST, AX
NOT_SMALLER:

    INC DI
    CMP BX, BP
    JBE NOT_LARGER
    MOV BP, BX
NOT_LARGER:

    LOOP EACH_PAIR

EXTREMES_DONE:
    LEA DX, M_BIG
    CALL PRINT_MESSAGE
    MOV AX, BP
    CALL PRINT_DECIMAL
    CALL NEWLINE

    LEA DX, M_SMALL
    CALL PRINT_MESSAGE
    MOV AX, SMALLEST
    CALL PRINT_DECIMAL
    CALL NEWLINE

    LEA DX, M_MADE
    CALL PRINT_MESSAGE
    MOV AX, DI
    CALL PRINT_DECIMAL
    CALL NEWLINE

    ; The plain method seeds from the first value and then tests every one of
    ; the others against both extremes, which is two comparisons each.
    LEA DX, M_NAIVE
    CALL PRINT_MESSAGE
    MOV AX, HOWMANY
    DEC AX
    SHL AX, 1
    CALL PRINT_DECIMAL
    CALL NEWLINE

    MOV AH, 4CH
    INT 21H

; -----------------------------------------------------------------------------
; SHOW_RUN
;
; Prints CX words starting at DS:SI, then a newline.
; -----------------------------------------------------------------------------
SHOW_RUN PROC
    PUSH AX
    PUSH CX
    PUSH DX
    PUSH SI

    JCXZ SR_DONE

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

SR_DONE:
    CALL NEWLINE

    POP SI
    POP DX
    POP CX
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
; 1. Where the comparisons go:
;    - One orders the pair, and then each half is tested against one extreme only.
;    - Three comparisons settle two values, against four for the plain method.
;    - For ten values that is thirteen against eighteen, a quarter of the work saved.
; 2. Why the smaller cannot beat the maximum:
;    - The pair has already been ordered, so the smaller is no larger than its partner.
;    - If it beat the running maximum, its partner would beat it too.
;    - Testing it against the maximum can therefore only ever waste a comparison.
; 3. Choosing the jump family:
;    - JBE and JAE read the carry flag, which is what an unsigned compare sets.
;    - JLE and JGE read the sign and overflow flags instead, for signed values.
;    - The wrong family gives the right answer on small positives and fails silently
;      the moment a value crosses 32767.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
