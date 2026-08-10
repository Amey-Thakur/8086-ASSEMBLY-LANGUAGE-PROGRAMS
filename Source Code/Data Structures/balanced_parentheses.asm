; =============================================================================
; TITLE: Balanced Brackets
; DESCRIPTION: Checks that every bracket is closed by the right kind in the
;              right order, using a stack, and says where the first fault is.
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
    GOOD    DB '{ a[i] = (b + c) * d; }'
    GOODLEN EQU $ - GOOD

    BAD     DB '{ a[i) = (b + c] * d; }'
    BADLEN  EQU $ - BAD

    SHORT_  DB '(a + b'
    SHORTLEN EQU $ - SHORT_

    STACK_  DB 40 DUP(0)
    DEPTH   DW 0

    M_ONE   DB 'First:  $'
    M_TWO   DB 'Second: $'
    M_THREE DB 'Third:  $'
    M_OK    DB '  balanced', 0DH, 0AH, '$'
    M_BAD   DB '  mismatched at position $'
    M_OPEN  DB '  ended with brackets still open', 0DH, 0AH, '$'

; -----------------------------------------------------------------------------
; CODE SEGMENT
; -----------------------------------------------------------------------------
.CODE
START:
    MOV AX, @DATA
    MOV DS, AX

    LEA DX, M_ONE
    MOV AH, 09H
    INT 21H
    LEA SI, GOOD
    MOV CX, GOODLEN
    CALL PRINT_TEXT
    LEA SI, GOOD
    MOV CX, GOODLEN
    CALL CHECK_BRACKETS

    LEA DX, M_TWO
    MOV AH, 09H
    INT 21H
    LEA SI, BAD
    MOV CX, BADLEN
    CALL PRINT_TEXT
    LEA SI, BAD
    MOV CX, BADLEN
    CALL CHECK_BRACKETS

    LEA DX, M_THREE
    MOV AH, 09H
    INT 21H
    LEA SI, SHORT_
    MOV CX, SHORTLEN
    CALL PRINT_TEXT
    LEA SI, SHORT_
    MOV CX, SHORTLEN
    CALL CHECK_BRACKETS

    MOV AH, 4CH
    INT 21H

; -----------------------------------------------------------------------------
; CHECK_BRACKETS
;
; SI points at CX characters. Reports whether the brackets are balanced.
; -----------------------------------------------------------------------------
CHECK_BRACKETS PROC
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX
    PUSH SI

    MOV WORD PTR DEPTH, 0
    XOR DI, DI                          ; The position being examined

CB_LOOP:
    JCXZ CB_ENDED

    MOV AL, [SI]

    ; -------------------------------------------------------------------------
    ; AN OPENING BRACKET IS PUSHED. A CLOSING ONE HAS TO MATCH WHATEVER IS ON
    ; TOP, WHICH IS WHAT MAKES THE ORDER MATTER: A STACK REMEMBERS NOT ONLY
    ; HOW MANY ARE OPEN BUT WHICH KIND, AND IN WHAT ORDER.
    ; -------------------------------------------------------------------------
    CMP AL, '('
    JE  CB_PUSH
    CMP AL, '['
    JE  CB_PUSH
    CMP AL, '{'
    JE  CB_PUSH

    CMP AL, ')'
    JE  CB_CLOSE
    CMP AL, ']'
    JE  CB_CLOSE
    CMP AL, '}'
    JE  CB_CLOSE
    JMP CB_NEXT                         ; Anything else is not our concern

CB_PUSH:
    MOV BX, DEPTH
    MOV STACK_[BX], AL
    INC WORD PTR DEPTH
    JMP CB_NEXT

CB_CLOSE:
    CMP WORD PTR DEPTH, 0
    JE  CB_MISMATCH                     ; A closer with nothing open

    DEC WORD PTR DEPTH
    MOV BX, DEPTH
    MOV AH, STACK_[BX]                  ; What was opened last

    ; Does the closer match the opener?
    CMP AL, ')'
    JNE CB_TRY_SQUARE
    CMP AH, '('
    JNE CB_MISMATCH
    JMP CB_NEXT

CB_TRY_SQUARE:
    CMP AL, ']'
    JNE CB_TRY_BRACE
    CMP AH, '['
    JNE CB_MISMATCH
    JMP CB_NEXT

CB_TRY_BRACE:
    CMP AH, '{'
    JNE CB_MISMATCH

CB_NEXT:
    INC SI
    INC DI
    DEC CX
    JMP CB_LOOP

CB_ENDED:
    CMP WORD PTR DEPTH, 0
    JNE CB_STILL_OPEN

    LEA DX, M_OK
    MOV AH, 09H
    INT 21H
    JMP CB_DONE

CB_STILL_OPEN:
    LEA DX, M_OPEN
    MOV AH, 09H
    INT 21H
    JMP CB_DONE

CB_MISMATCH:
    PUSH DI
    LEA DX, M_BAD
    MOV AH, 09H
    INT 21H
    POP AX
    CALL PRINT_DECIMAL
    CALL NEWLINE

CB_DONE:
    POP SI
    POP DX
    POP CX
    POP BX
    POP AX
    RET
CHECK_BRACKETS ENDP

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
; 1. A COUNTER IS NOT ENOUGH:
;    - Counting openers and closers would accept "(a]" happily. The stack
;    - is what records which kind was opened, so the closer can be
;    - checked against it.
; 2. TWO WAYS TO FAIL:
;    - A closer that does not match, and a string that ends with
;    - something still open. Both have to be tested, and a program that
;    - checks only the first accepts an unterminated bracket.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
