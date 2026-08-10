; =============================================================================
; TITLE: A State Machine Driven By A Table
; DESCRIPTION: The transitions live in data rather than in branches, so the machine can be read and changed without touching the code.
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
    ; A parser for a signed number: states down the side, input classes across.
    ; States:  0 start  1 after sign  2 in digits  3 accepted  4 rejected
    ; Classes: 0 sign   1 digit       2 space      3 anything else
    ;
    ; Reading the table is the whole specification of the machine.
    TABLE   DB 1, 2, 0, 4              ; from start
            DB 4, 2, 4, 4              ; from after sign
            DB 4, 2, 3, 4              ; from in digits
            DB 4, 4, 3, 4              ; from accepted
            DB 4, 4, 4, 4              ; from rejected
    CLASSES EQU 4

    CASE_1  DB '-42 '
    CASE_2  DB '  7 '
    CASE_3  DB '+-1 '
    CASE_4  DB '12x '
    CASE_5  DB '9   '
    WIDTH   EQU 4

    M_TITLE DB 'A parser written as a transition table', 0DH, 0AH, '$'
    M_TEXT  DB 0DH, 0AH, 'text "$'
    M_PATH  DB '"   states: $'
    M_ARROW DB ' $'
    M_OK    DB '   accepted', 0DH, 0AH, '$'
    M_NO    DB '   rejected', 0DH, 0AH, '$'
    M_WHY   DB 0DH, 0AH
            DB 'Twenty bytes hold the entire machine. Adding a state is a row, '
            DB 'and adding an input class is a column.', 0DH, 0AH, '$'

; -----------------------------------------------------------------------------
; CODE SEGMENT
; -----------------------------------------------------------------------------
.CODE
START:
    MOV AX, @DATA
    MOV DS, AX

    LEA DX, M_TITLE
    CALL PRINT_MESSAGE

    LEA SI, CASE_1
    CALL PARSE
    LEA SI, CASE_2
    CALL PARSE
    LEA SI, CASE_3
    CALL PARSE
    LEA SI, CASE_4
    CALL PARSE
    LEA SI, CASE_5
    CALL PARSE

    LEA DX, M_WHY
    CALL PRINT_MESSAGE

    MOV AH, 4CH
    INT 21H

; -----------------------------------------------------------------------------
; PARSE
;
; Runs the machine over the WIDTH characters at DS:SI, printing the states it
; passes through and the verdict.
;
; The whole engine is three instructions: classify the character, look up the
; row and column, and take the new state. Everything else here is reporting.
; -----------------------------------------------------------------------------
PARSE PROC
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX
    PUSH SI
    PUSH DI

    LEA DX, M_TEXT
    CALL PRINT_MESSAGE
    MOV CX, WIDTH
    CALL PRINT_TEXT

    LEA DX, M_PATH
    CALL PRINT_MESSAGE

    XOR DI, DI                          ; The current state, starting at zero
    MOV CX, WIDTH

EACH_CHARACTER:
    MOV AX, DI                          ; Report the state before the step
    CALL PRINT_DECIMAL
    LEA DX, M_ARROW
    CALL PRINT_MESSAGE

    MOV AL, [SI]
    INC SI
    CALL CLASSIFY                       ; AL becomes the class

    ; ---- the lookup: state times the width, plus the class ------------------
    XOR AH, AH
    MOV BX, DI
    PUSH AX
    MOV AX, BX
    MOV BX, CLASSES
    MUL BX
    MOV BX, AX
    POP AX
    ADD BX, AX

    MOV AL, TABLE[BX]
    XOR AH, AH
    MOV DI, AX                          ; The new state

    LOOP EACH_CHARACTER

    MOV AX, DI
    CALL PRINT_DECIMAL

    CMP DI, 3
    JNE PARSE_REJECTED

    LEA DX, M_OK
    CALL PRINT_MESSAGE
    JMP PARSE_DONE

PARSE_REJECTED:
    LEA DX, M_NO
    CALL PRINT_MESSAGE

PARSE_DONE:
    POP DI
    POP SI
    POP DX
    POP CX
    POP BX
    POP AX
    RET
PARSE ENDP

; -----------------------------------------------------------------------------
; CLASSIFY
;
; Turns the character in AL into its input class, which is what the table is
; indexed by. Keeping this separate is what lets the table stay small: a
; hundred and twenty-eight characters become four columns.
; -----------------------------------------------------------------------------
CLASSIFY PROC
    CMP AL, '+'
    JE CLASS_SIGN
    CMP AL, '-'
    JE CLASS_SIGN

    CMP AL, '0'
    JB CLASS_OTHER
    CMP AL, '9'
    JA CLASS_OTHER
    MOV AL, 1                           ; A digit
    RET

CLASS_SIGN:
    MOV AL, 0
    RET

CLASS_OTHER:
    CMP AL, ' '
    JNE NOT_SPACE
    MOV AL, 2
    RET

NOT_SPACE:
    MOV AL, 3
    RET
CLASSIFY ENDP

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
; 1. The table is the specification:
;    - Five states by four classes is twenty bytes, and those bytes are the machine.
;    - Reading them tells you exactly what the parser accepts, with no code to follow.
;    - Changing the language means changing data, which cannot introduce a control flow bug.
; 2. Classify, then look up:
;    - Mapping a character to one of four classes keeps the table four columns wide.
;    - Indexing by the character itself would need two hundred and fifty-six columns per state.
;    - The classifier is the only part that knows about characters at all.
; 3. A rejecting state that cannot be left:
;    - Every entry in the rejected row points back at rejected.
;    - So once the machine fails, nothing later in the input can rescue it.
;    - That is what makes it safe to run the loop to the end rather than breaking out.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
