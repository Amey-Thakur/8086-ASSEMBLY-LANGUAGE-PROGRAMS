; =============================================================================
; TITLE: A Word Used As A Set
; DESCRIPTION: Sixteen members held in one word, with adding, removing, testing, union and intersection as single instructions.
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
    ; Bit n means day n is selected. Bit 0 is Monday.
    WEEKDAYS EQU 00011111B              ; Monday to Friday
    WEEKEND  EQU 01100000B              ; Saturday and Sunday

    DAYS    DB 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'
    NAME_W  EQU 3
    HOWMANY EQU 7

    WORKING DW 0

    M_TITLE DB 'One word holding a set of sixteen possible members', 0DH, 0AH, '$'
    M_START DB 0DH, 0AH, 'weekdays:      $'
    M_ADD   DB 0DH, 0AH, 'add Saturday:  $'
    M_DROP  DB 0DH, 0AH, 'drop Wednesday: $'
    M_UNION DB 0DH, 0AH, 'union with the weekend: $'
    M_INTER DB 0DH, 0AH, 'intersect with the weekend: $'
    M_DIFF  DB 0DH, 0AH, 'weekdays minus the set: $'
    M_COUNT DB 0DH, 0AH, 0DH, 0AH, 'Members in the final set: $'
    M_TEST  DB 0DH, 0AH, 'Is Friday in it? $'
    M_YES   DB 'yes', 0DH, 0AH, '$'
    M_NO    DB 'no', 0DH, 0AH, '$'
    M_SPACE DB ' $'
    M_NONE  DB '(empty)$'
    M_WHY   DB 0DH, 0AH
            DB 'Adding is OR, removing is AND with the complement, membership is '
            DB 'TEST, union is OR and intersection is AND.', 0DH, 0AH, '$'

; -----------------------------------------------------------------------------
; CODE SEGMENT
; -----------------------------------------------------------------------------
.CODE
START:
    MOV AX, @DATA
    MOV DS, AX

    LEA DX, M_TITLE
    CALL PRINT_MESSAGE

    MOV WORKING, WEEKDAYS
    LEA DX, M_START
    CALL PRINT_MESSAGE
    CALL SHOW_SET

    ; ---- adding a member is a single OR -------------------------------------
    MOV AX, WORKING
    OR AX, 00100000B                    ; Saturday
    MOV WORKING, AX
    LEA DX, M_ADD
    CALL PRINT_MESSAGE
    CALL SHOW_SET

    ; ---- removing one is an AND with the complement -------------------------
    MOV AX, WORKING
    AND AX, NOT 00000100B               ; Wednesday
    MOV WORKING, AX
    LEA DX, M_DROP
    CALL PRINT_MESSAGE
    CALL SHOW_SET

    ; ---- union and intersection --------------------------------------------
    MOV AX, WORKING
    OR AX, WEEKEND
    LEA DX, M_UNION
    CALL PRINT_MESSAGE
    PUSH WORKING
    MOV WORKING, AX
    CALL SHOW_SET
    POP WORKING

    MOV AX, WORKING
    AND AX, WEEKEND
    LEA DX, M_INTER
    CALL PRINT_MESSAGE
    PUSH WORKING
    MOV WORKING, AX
    CALL SHOW_SET
    POP WORKING

    ; ---- difference: in the first and not in the second ---------------------
    MOV AX, WEEKDAYS
    MOV BX, WORKING
    NOT BX
    AND AX, BX
    LEA DX, M_DIFF
    CALL PRINT_MESSAGE
    PUSH WORKING
    MOV WORKING, AX
    CALL SHOW_SET
    POP WORKING

    ; ---- membership is a TEST, which writes nothing -------------------------
    LEA DX, M_TEST
    CALL PRINT_MESSAGE
    MOV AX, WORKING
    TEST AX, 00010000B                  ; Friday
    JZ NOT_A_MEMBER
    LEA DX, M_YES
    CALL PRINT_MESSAGE
    JMP COUNT_THEM
NOT_A_MEMBER:
    LEA DX, M_NO
    CALL PRINT_MESSAGE

COUNT_THEM:
    LEA DX, M_COUNT
    CALL PRINT_MESSAGE
    MOV AX, WORKING
    CALL COUNT_MEMBERS
    CALL PRINT_DECIMAL

    LEA DX, M_WHY
    CALL PRINT_MESSAGE

    MOV AH, 4CH
    INT 21H

; -----------------------------------------------------------------------------
; SHOW_SET
;
; Prints the names of every day whose bit is set in WORKING.
; -----------------------------------------------------------------------------
SHOW_SET PROC
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX
    PUSH SI

    MOV BX, WORKING
    XOR SI, SI
    XOR DI, DI                          ; How many printed
    MOV CX, HOWMANY

EACH_DAY:
    TEST BX, 1
    JZ DAY_ABSENT

    INC DI
    PUSH CX
    PUSH SI
    MOV AX, SI
    MOV CX, NAME_W
    MUL CX
    LEA SI, DAYS
    ADD SI, AX
    MOV CX, NAME_W
    CALL PRINT_TEXT
    POP SI
    POP CX

    LEA DX, M_SPACE
    CALL PRINT_MESSAGE

DAY_ABSENT:
    SHR BX, 1
    INC SI
    LOOP EACH_DAY

    CMP DI, 0
    JNE SHOW_DONE
    LEA DX, M_NONE
    CALL PRINT_MESSAGE

SHOW_DONE:
    POP SI
    POP DX
    POP CX
    POP BX
    POP AX
    RET
SHOW_SET ENDP

; -----------------------------------------------------------------------------
; COUNT_MEMBERS
;
; How many bits are set in AX, by Kernighan's method: clearing the lowest set
; bit each time, so the loop runs once per member rather than once per bit.
; -----------------------------------------------------------------------------
COUNT_MEMBERS PROC
    PUSH BX
    PUSH CX

    XOR CX, CX

COUNT_AGAIN:
    CMP AX, 0
    JE COUNT_DONE

    MOV BX, AX
    DEC BX
    AND AX, BX                          ; Clears the lowest set bit
    INC CX
    JMP COUNT_AGAIN

COUNT_DONE:
    MOV AX, CX

    POP CX
    POP BX
    RET
COUNT_MEMBERS ENDP

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
; PRINT_TEXT
;
; Prints CX characters starting at DS:SI. Both are left as they were found.
; -----------------------------------------------------------------------------
PRINT_TEXT PROC
    PUSH AX
    PUSH CX
    PUSH DX
    PUSH SI

    JCXZ PT_DONE                        ; Nothing to print

PT_LOOP:
    MOV DL, [SI]
    MOV AH, 02H
    INT 21H
    INC SI
    LOOP PT_LOOP

PT_DONE:
    POP SI
    POP DX
    POP CX
    POP AX
    RET
PRINT_TEXT ENDP

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
; 1. Every set operation is one instruction:
;    - Union is OR, intersection is AND, and difference is AND with the complement.
;    - Membership is TEST, which sets the flags and writes nothing.
;    - A set of sixteen members therefore costs one word and one instruction per operation.
; 2. NOT at assembly time and at run time:
;    - AND AX, NOT 4 has the assembler compute the complement, so it costs nothing.
;    - NOT BX complements a register while the program runs, which is a real instruction.
;    - The first form is what a named constant mask should always use.
; 3. Clearing the lowest set bit:
;    - A value ANDed with one less than itself loses exactly its lowest set bit.
;    - So the counting loop runs once per member, not once per bit position.
;    - For a sparse set that is the difference between three iterations and sixteen.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
