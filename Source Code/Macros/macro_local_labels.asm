; =============================================================================
; TITLE: Local Labels Inside A Macro
; DESCRIPTION: A macro containing a loop needs LOCAL, or the second use redefines the label the first one made.
; AUTHOR: Amey Thakur (https://github.com/Amey-Thakur)
; REPOSITORY: https://github.com/Amey-Thakur/8086-ASSEMBLY-LANGUAGE-PROGRAMS
; LICENSE: MIT License
; =============================================================================

.MODEL SMALL
.STACK 100H

; -----------------------------------------------------------------------------
; MACRO DEFINITIONS
; -----------------------------------------------------------------------------

; ---- a macro with a loop, done correctly ------------------------------------
; LOCAL asks the assembler for a fresh private name at every expansion, so two
; uses in the same program cannot collide. Without it the second expansion
; would define AGAIN a second time and the assembly would fail.
COUNT_DOWN_FROM MACRO FIRST
    LOCAL AGAIN
    MOV CX, FIRST
AGAIN:
    MOV AX, CX
    CALL PRINT_DECIMAL
    LEA DX, M_SPACE
    CALL PRINT_MESSAGE
    LOOP AGAIN
ENDM

; ---- a macro that needs no label at all -------------------------------------
; The safest macro is one with no labels in it, because there is nothing to
; collide. Not every body can be written that way.
SHOW_SUM MACRO ONE, TWO
    MOV AX, ONE
    ADD AX, TWO
    CALL PRINT_DECIMAL
    LEA DX, M_SPACE
    CALL PRINT_MESSAGE
ENDM

; -----------------------------------------------------------------------------
; DATA SEGMENT
; -----------------------------------------------------------------------------
.DATA
    M_TITLE DB 'LOCAL gives every expansion its own private labels', 0DH, 0AH, '$'
    M_ONE   DB 'first use, counting from 5:  $'
    M_TWO   DB 'second use, counting from 3: $'
    M_THREE DB 'third use, counting from 7:  $'
    M_SUMS  DB 'a label free macro, three sums: $'
    M_SPACE DB ' $'
    M_WHY   DB 0DH, 0AH
            DB 'All three loops share one source line but assembled to three '
            DB 'separate labels.', 0DH, 0AH, '$'

; -----------------------------------------------------------------------------
; CODE SEGMENT
; -----------------------------------------------------------------------------
.CODE
START:
    MOV AX, @DATA
    MOV DS, AX

    LEA DX, M_TITLE
    CALL PRINT_MESSAGE

    LEA DX, M_ONE
    CALL PRINT_MESSAGE
    COUNT_DOWN_FROM 5
    CALL NEWLINE

    LEA DX, M_TWO
    CALL PRINT_MESSAGE
    COUNT_DOWN_FROM 3
    CALL NEWLINE

    LEA DX, M_THREE
    CALL PRINT_MESSAGE
    COUNT_DOWN_FROM 7
    CALL NEWLINE

    LEA DX, M_SUMS
    CALL PRINT_MESSAGE
    SHOW_SUM 10, 5
    SHOW_SUM 100, 50
    SHOW_SUM 1000, 500
    CALL NEWLINE

    LEA DX, M_WHY
    CALL PRINT_MESSAGE

    MOV AH, 4CH
    INT 21H

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
; 1. What LOCAL actually does:
;    - It declares names that the assembler renames uniquely at each expansion.
;    - A common scheme appends a serial number, so AGAIN becomes AGAIN with a suffix.
;    - The renaming is invisible in the source and visible only in a listing file.
; 2. It must come first:
;    - LOCAL has to be the first statement of the macro body, before any instruction.
;    - Several names can be declared on one LOCAL line, separated by commas.
;    - A label used but not declared is a global label, and the second use will clash.
; 3. The error without it:
;    - The first expansion defines the label and the second tries to define it again.
;    - The message names a duplicate symbol, pointing at a line that looks innocent.
;    - That is why the habit is to write LOCAL as soon as a macro grows a jump.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
