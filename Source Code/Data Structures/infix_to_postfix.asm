; =============================================================================
; TITLE: Converting Infix to Postfix
; DESCRIPTION: Rewrites an ordinary expression into postfix by holding operators
;              on a stack until something of lower precedence arrives.
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
    INFIX    DB 'a+b*c-d/e'
    INFIXLEN EQU $ - INFIX

    OUTPUT   DB 40 DUP(0)
    OUTLEN   DW 0

    OPS      DB 40 DUP(0)
    OPDEPTH  DW 0

    M_IN     DB 'Infix:   $'
    M_OUT    DB 'Postfix: $'

; -----------------------------------------------------------------------------
; CODE SEGMENT
; -----------------------------------------------------------------------------
.CODE
START:
    MOV AX, @DATA
    MOV DS, AX

    LEA DX, M_IN
    MOV AH, 09H
    INT 21H
    LEA SI, INFIX
    MOV CX, INFIXLEN
    CALL PRINT_TEXT
    CALL NEWLINE

    ; -------------------------------------------------------------------------
    ; THE SHUNTING YARD, IN ITS SIMPLEST FORM. AN OPERAND GOES STRAIGHT TO THE
    ; OUTPUT. AN OPERATOR WAITS ON THE STACK, BUT FIRST IT TURNS OUT ANYTHING
    ; ALREADY THERE OF EQUAL OR HIGHER PRECEDENCE, WHICH IS WHAT PUTS TIMES
    ; BEFORE PLUS WITHOUT ANY BRACKETS BEING INVOLVED.
    ; -------------------------------------------------------------------------
    LEA SI, INFIX
    MOV CX, INFIXLEN

CONVERT:
    JCXZ DRAIN

    MOV AL, [SI]

    ; A letter or a digit is an operand
    CMP AL, 'a'
    JB  MAYBE_OPERATOR
    CMP AL, 'z'
    JA  MAYBE_OPERATOR

    CALL EMIT
    JMP NEXT_TOKEN

MAYBE_OPERATOR:
    CALL PRECEDENCE                     ; AH = how tightly AL binds
    OR  AH, AH
    JZ  NEXT_TOKEN                      ; Not an operator at all

    MOV BL, AH                          ; The precedence of the arriving one

TURN_OUT:
    CMP WORD PTR OPDEPTH, 0
    JE  STACK_IT

    MOV DI, OPDEPTH
    DEC DI
    MOV AL, OPS[DI]                     ; What is on top
    CALL PRECEDENCE
    CMP AH, BL
    JB  STACK_IT                        ; It binds less tightly, so it stays

    DEC WORD PTR OPDEPTH
    CALL EMIT                           ; AL still holds it
    JMP TURN_OUT

STACK_IT:
    MOV AL, [SI]
    MOV DI, OPDEPTH
    MOV OPS[DI], AL
    INC WORD PTR OPDEPTH

NEXT_TOKEN:
    INC SI
    DEC CX
    JMP CONVERT

DRAIN:
    ; Whatever is left on the stack goes to the output, top first
    CMP WORD PTR OPDEPTH, 0
    JE  CONVERTED

    DEC WORD PTR OPDEPTH
    MOV DI, OPDEPTH
    MOV AL, OPS[DI]
    CALL EMIT
    JMP DRAIN

CONVERTED:
    LEA DX, M_OUT
    MOV AH, 09H
    INT 21H
    LEA SI, OUTPUT
    MOV CX, OUTLEN
    CALL PRINT_TEXT
    CALL NEWLINE

    MOV AH, 4CH
    INT 21H

; -----------------------------------------------------------------------------
; PRECEDENCE
;
; Given a character in AL, returns in AH how tightly it binds: two for times
; and divide, one for plus and minus, zero for anything that is not an
; operator at all.
; -----------------------------------------------------------------------------
PRECEDENCE PROC
    CMP AL, '*'
    JE  P_HIGH
    CMP AL, '/'
    JE  P_HIGH
    CMP AL, '+'
    JE  P_LOW
    CMP AL, '-'
    JE  P_LOW

    MOV AH, 0
    RET

P_HIGH:
    MOV AH, 2
    RET

P_LOW:
    MOV AH, 1
    RET
PRECEDENCE ENDP

; -----------------------------------------------------------------------------
; EMIT
;
; Appends the character in AL to the output.
; -----------------------------------------------------------------------------
EMIT PROC
    PUSH DI
    MOV DI, OUTLEN
    MOV OUTPUT[DI], AL
    INC WORD PTR OUTLEN
    POP DI
    RET
EMIT ENDP

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

END START

; =============================================================================
; TECHNICAL NOTES
; =============================================================================
; 1. WHY EQUAL PRECEDENCE IS ALSO TURNED OUT:
;    - a-b-c must become ab-c- and not abc--. Turning out an operator of
;    - equal precedence is what makes the operators associate to the
;    - left, which is how subtraction and division are read.
; 2. WHAT IS LEFT OUT:
;    - Brackets, which push a marker that stops the turning out and is
;    - removed by the closing one. The shape of the algorithm is the
;    - same; only that one case is missing here.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
