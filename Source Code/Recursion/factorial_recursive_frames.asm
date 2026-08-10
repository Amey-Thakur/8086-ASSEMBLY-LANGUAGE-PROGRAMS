; =============================================================================
; TITLE: Factorial by Recursion
; DESCRIPTION: Computes a factorial by calling itself, and shows the stack
;              growing and unwinding through a frame pointer.
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
    NUMBER  DW 7
    M_HEAD  DB '7 factorial, computed recursively: $'
    M_DEPTH DB 'The deepest the stack went: $'
    M_BYTES DB ' bytes', 0DH, 0AH, '$'
    LOWEST  DW 0FFFFH

; -----------------------------------------------------------------------------
; CODE SEGMENT
; -----------------------------------------------------------------------------
.CODE
START:
    MOV AX, @DATA
    MOV DS, AX

    MOV BX, SP                          ; Where the stack stood before

    MOV AX, NUMBER
    PUSH AX
    CALL FACTORIAL
    ADD SP, 2

    PUSH AX
    LEA DX, M_HEAD
    MOV AH, 09H
    INT 21H
    POP AX
    CALL PRINT_DECIMAL
    CALL NEWLINE

    ; -------------------------------------------------------------------------
    ; THE DIFFERENCE BETWEEN WHERE THE STACK STARTED AND THE LOWEST POINT IT
    ; REACHED IS WHAT THE RECURSION COST.
    ; -------------------------------------------------------------------------
    MOV AX, BX
    SUB AX, LOWEST

    PUSH AX
    LEA DX, M_DEPTH
    MOV AH, 09H
    INT 21H
    POP AX
    CALL PRINT_DECIMAL
    LEA DX, M_BYTES
    MOV AH, 09H
    INT 21H

    MOV AH, 4CH
    INT 21H

; -----------------------------------------------------------------------------
; FACTORIAL
;
; [BP+4] holds n. The answer comes back in AX.
; -----------------------------------------------------------------------------
FACTORIAL PROC
    PUSH BP
    MOV BP, SP
    PUSH BX

    ; Record how far down the stack has reached
    MOV BX, SP
    CMP BX, LOWEST
    JAE NOT_DEEPER
    MOV LOWEST, BX

NOT_DEEPER:
    MOV AX, [BP+4]
    CMP AX, 1
    JBE BASE_CASE                       ; 0! and 1! are both one

    ; -------------------------------------------------------------------------
    ; ASK FOR THE FACTORIAL OF ONE LESS, THEN MULTIPLY BY N ON THE WAY BACK
    ; OUT. EVERY LEVEL HOLDS ITS OWN N IN ITS OWN FRAME.
    ; -------------------------------------------------------------------------
    DEC AX
    PUSH AX
    CALL FACTORIAL
    ADD SP, 2

    MUL WORD PTR [BP+4]                 ; result of the deeper call, times n
    JMP FACTORIAL_RETURN

BASE_CASE:
    MOV AX, 1

FACTORIAL_RETURN:
    POP BX
    POP BP
    RET
FACTORIAL ENDP

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
; 1. WHERE THE MULTIPLICATION HAPPENS:
;    - On the way back out, not on the way in. The deepest call returns
;    - one, and each level multiplies by its own n as the stack unwinds.
; 2. THE LIMIT IS THE WORD, NOT THE STACK:
;    - 8 factorial is 40320 and fits; 9 factorial is 362880 and does not.
;    - The recursion would happily go deeper, and the answer would be
;    - quietly wrong long before the stack ran out.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
