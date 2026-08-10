; =============================================================================
; TITLE: A Table of Procedure Addresses Dispatched by Index
; DESCRIPTION: A short list of coded operations is carried out by looking each
;              opcode up in a table of procedure addresses, so the driver never
;              names any of the five procedures it calls.
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
    ; The little program to be carried out: opcode, first operand, second.
    ; The last step names an opcode that does not exist, on purpose.
    ORDERS  DW 0, 12, 30
            DW 1, 100, 58
            DW 2, 6, 7
            DW 3, 42, 99
            DW 4, 17, 42
            DW 5, 1, 1
    OSPAN   EQU $ - ORDERS              ; Measured, never counted by hand

    ; The dispatch table itself, and the names that run alongside it. Both are
    ; indexed by the same doubled opcode, so they cannot drift apart.
    HANDLERS DW DO_ADD, DO_SUB, DO_MUL, DO_MIN, DO_MAX
    HSPAN    EQU $ - HANDLERS

    N_ADD   DB 'ADD$'
    N_SUB   DB 'SUB$'
    N_MUL   DB 'MUL$'
    N_MIN   DB 'MIN$'
    N_MAX   DB 'MAX$'
    LABELS  DW N_ADD, N_SUB, N_MUL, N_MIN, N_MAX

    ARG_ONE DW ?                        ; The two operands of the current step,
    ARG_TWO DW ?                        ; parked in memory while the name prints

    M_TITLE DB 'Six coded steps, each reaching its procedure through a table'
            DB 0DH, 0AH, '$'
    M_OPEN  DB '($'
    M_COMMA DB ', $'
    M_GIVES DB ') = $'
    M_BAD1  DB 'opcode $'
    M_BAD2  DB ' has no entry in the table, so the step is refused', 0DH, 0AH, '$'
    M_CLOSE DB 0DH, 0AH
            DB 'One bounds check and one indexed call stand in place of a chain '
            DB 'of comparisons, and the cost of the dispatch is the same '
            DB 'whether the table holds five procedures or five hundred.'
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

    XOR SI, SI                          ; Byte position within ORDERS

; -----------------------------------------------------------------------------
; READ ONE STEP. TAKING THE THREE WORDS ONE AT A TIME LEAVES SI ON THE NEXT
; STEP WITHOUT ANY INDEX ARITHMETIC, AND THE OPERANDS GO TO MEMORY BECAUSE THE
; NAME OF THE OPERATION HAS TO BE PRINTED BEFORE THEY ARE USED.
; -----------------------------------------------------------------------------
NEXT_STEP:
    MOV DI, ORDERS[SI]                  ; The opcode
    ADD SI, 2
    MOV AX, ORDERS[SI]
    MOV ARG_ONE, AX
    ADD SI, 2
    MOV AX, ORDERS[SI]
    MOV ARG_TWO, AX
    ADD SI, 2

    ; -------------------------------------------------------------------------
    ; DOUBLE THE OPCODE TO GET A BYTE POSITION, THEN CHECK IT AGAINST THE SIZE
    ; OF THE TABLE. WITHOUT THIS TEST AN OPCODE OF FIVE WOULD CALL WHATEVER
    ; WORD HAPPENS TO FOLLOW THE TABLE IN MEMORY.
    ; -------------------------------------------------------------------------
    MOV BX, DI
    SHL BX, 1                           ; Each entry in the table is a word
    CMP BX, HSPAN
    JAE STEP_REFUSED                    ; Unsigned, both are byte positions

    MOV DX, LABELS[BX]                  ; The address of this opcode's name
    CALL PRINT_MESSAGE
    LEA DX, M_OPEN
    CALL PRINT_MESSAGE
    MOV AX, ARG_ONE
    CALL PRINT_DECIMAL
    LEA DX, M_COMMA
    CALL PRINT_MESSAGE
    MOV AX, ARG_TWO
    CALL PRINT_DECIMAL
    LEA DX, M_GIVES
    CALL PRINT_MESSAGE

    MOV AX, ARG_ONE
    MOV BP, ARG_TWO                     ; BP, because DX belongs to the messages
    CALL HANDLERS[BX]                   ; The dispatch, and the whole point
    CALL PRINT_DECIMAL
    CALL NEWLINE
    JMP STEP_DONE

STEP_REFUSED:
    LEA DX, M_BAD1
    CALL PRINT_MESSAGE
    MOV AX, DI
    CALL PRINT_DECIMAL
    LEA DX, M_BAD2
    CALL PRINT_MESSAGE

STEP_DONE:
    CMP SI, OSPAN
    JB  NEXT_STEP

    LEA DX, M_CLOSE
    CALL PRINT_MESSAGE

    MOV AH, 4CH
    INT 21H

; -----------------------------------------------------------------------------
; DO_ADD
;
; Every handler shares one interface: AX and BP in, AX out, and BX, SI and DI
; left alone because the driver is keeping the table position, the program
; position and the opcode in them.
; -----------------------------------------------------------------------------
DO_ADD PROC
    ADD AX, BP
    RET
DO_ADD ENDP

; -----------------------------------------------------------------------------
; DO_SUB
;
; The operands are chosen so the result never goes below zero, which would
; otherwise print as a very large unsigned number.
; -----------------------------------------------------------------------------
DO_SUB PROC
    SUB AX, BP
    RET
DO_SUB ENDP

; -----------------------------------------------------------------------------
; DO_MUL
;
; MUL writes the high half of the product into DX, so DX is saved and restored
; here. Six times seven fits in AX alone, so nothing is lost by discarding it.
; -----------------------------------------------------------------------------
DO_MUL PROC
    PUSH DX

    MUL BP

    POP DX
    RET
DO_MUL ENDP

; -----------------------------------------------------------------------------
; DO_MIN
;
; JBE is the unsigned test, which is the correct family here because every
; operand in the table is a plain positive count.
; -----------------------------------------------------------------------------
DO_MIN PROC
    CMP AX, BP
    JBE MN_KEEP
    MOV AX, BP
MN_KEEP:
    RET
DO_MIN ENDP

; -----------------------------------------------------------------------------
; DO_MAX
;
; The mirror of DO_MIN, and the one place where getting the jump family wrong
; would still give the right answer for these particular numbers.
; -----------------------------------------------------------------------------
DO_MAX PROC
    CMP AX, BP
    JAE MX_KEEP
    MOV AX, BP
MX_KEEP:
    RET
DO_MAX ENDP

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
; 1. A TABLE OF CALLS, NOT OF JUMPS:
;    - CALL through the table leaves a return address, so control comes back.
;    - JMP through a table hands over for good, which is a switch statement.
;    - The handlers here can therefore be short and share their surroundings.
; 2. WHY THE BOUNDS CHECK IS NOT OPTIONAL:
;    - The table has five entries and the opcode is data, not a constant.
;    - An index past the end would call whatever word follows in memory.
;    - Comparing against a measured size keeps the check right if the table grows.
; 3. WHAT THE PARALLEL TABLE BUYS:
;    - The names are indexed exactly as the addresses are, by doubled opcode.
;    - Adding an operation means one entry in each, in the same position.
;    - Any mismatch shows up immediately as the wrong name against a result.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
