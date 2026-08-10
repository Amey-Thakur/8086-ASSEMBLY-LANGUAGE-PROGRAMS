; =============================================================================
; TITLE: Evaluating a Postfix Expression
; DESCRIPTION: Works out the value of an expression written in postfix, which
;              needs a stack and no precedence rules at all.
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
    ; 5 3 + 8 2 - * is (5 + 3) * (8 - 2), which is 48
    EXPR    DB '53+82-*'
    EXPRLEN EQU $ - EXPR

    VALUES  DW 20 DUP(0)
    DEPTH   DW 0

    M_EXPR  DB 'Postfix:  $'
    M_VALUE DB 'Value:    $'
    M_ERROR DB 'The expression is malformed.', 0DH, 0AH, '$'

; -----------------------------------------------------------------------------
; CODE SEGMENT
; -----------------------------------------------------------------------------
.CODE
START:
    MOV AX, @DATA
    MOV DS, AX

    LEA DX, M_EXPR
    MOV AH, 09H
    INT 21H
    LEA SI, EXPR
    MOV CX, EXPRLEN
    CALL PRINT_TEXT
    CALL NEWLINE

    ; -------------------------------------------------------------------------
    ; POSTFIX NEEDS NO PRECEDENCE AND NO BRACKETS, BECAUSE THE ORDER IS
    ; ALREADY IN THE WRITING. A DIGIT IS PUSHED; AN OPERATOR TAKES THE TOP TWO
    ; VALUES AND PUSHES WHAT IT MAKES OF THEM.
    ; -------------------------------------------------------------------------
    LEA SI, EXPR
    MOV CX, EXPRLEN
    MOV WORD PTR DEPTH, 0

EVALUATE:
    JCXZ FINISHED

    MOV AL, [SI]

    CMP AL, '0'
    JB  AN_OPERATOR
    CMP AL, '9'
    JA  AN_OPERATOR

    ; A digit: push its value
    SUB AL, '0'
    XOR AH, AH
    CALL PUSH_VALUE
    JMP NEXT_TOKEN

AN_OPERATOR:
    CMP WORD PTR DEPTH, 2
    JB  MALFORMED                       ; An operator needs two operands

    PUSH AX
    CALL POP_VALUE                      ; The right hand operand
    MOV BX, AX
    CALL POP_VALUE                      ; The left hand one
    POP DX                              ; DL holds the operator

    CMP DL, '+'
    JNE TRY_MINUS
    ADD AX, BX
    JMP PUSH_RESULT

TRY_MINUS:
    CMP DL, '-'
    JNE TRY_TIMES
    SUB AX, BX
    JMP PUSH_RESULT

TRY_TIMES:
    CMP DL, '*'
    JNE TRY_DIVIDE
    PUSH DX
    MOV DX, 0
    MUL BX
    POP DX
    JMP PUSH_RESULT

TRY_DIVIDE:
    CMP DL, '/'
    JNE MALFORMED
    OR  BX, BX
    JZ  MALFORMED                       ; Division by zero
    PUSH DX
    XOR DX, DX
    DIV BX
    POP DX

PUSH_RESULT:
    CALL PUSH_VALUE

NEXT_TOKEN:
    INC SI
    DEC CX
    JMP EVALUATE

FINISHED:
    ; -------------------------------------------------------------------------
    ; A WELL FORMED EXPRESSION LEAVES EXACTLY ONE VALUE BEHIND. ANY OTHER
    ; NUMBER MEANS THE OPERATORS AND OPERANDS DID NOT BALANCE.
    ; -------------------------------------------------------------------------
    CMP WORD PTR DEPTH, 1
    JNE MALFORMED

    CALL POP_VALUE
    PUSH AX
    LEA DX, M_VALUE
    MOV AH, 09H
    INT 21H
    POP AX
    CALL PRINT_DECIMAL
    CALL NEWLINE
    JMP DONE

MALFORMED:
    LEA DX, M_ERROR
    MOV AH, 09H
    INT 21H

DONE:
    MOV AH, 4CH
    INT 21H

; -----------------------------------------------------------------------------
; PUSH_VALUE and POP_VALUE
;
; A stack of words held in the data segment, separate from the processor's own
; stack, so that the expression's operands and the return addresses cannot
; interfere with one another.
; -----------------------------------------------------------------------------
PUSH_VALUE PROC
    PUSH BX
    MOV BX, DEPTH
    SHL BX, 1
    MOV VALUES[BX], AX
    INC WORD PTR DEPTH
    POP BX
    RET
PUSH_VALUE ENDP

POP_VALUE PROC
    PUSH BX
    DEC WORD PTR DEPTH
    MOV BX, DEPTH
    SHL BX, 1
    MOV AX, VALUES[BX]
    POP BX
    RET
POP_VALUE ENDP

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
; 1. THE ORDER OF THE OPERANDS:
;    - The first value popped is the right hand operand, because it was
;    - pushed last. Getting this backwards gives the right answer for
;    - addition and multiplication and the wrong one for the other two.
; 2. WHY A SEPARATE STACK:
;    - The processor stack is holding return addresses. Mixing operands
;    - into it works only while nothing calls anything, which is a
;    - constraint not worth accepting.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
