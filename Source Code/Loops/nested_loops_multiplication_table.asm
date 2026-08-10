; =============================================================================
; TITLE: Nested Loops and Saving the Counter
; DESCRIPTION: Prints a multiplication table with a loop inside a loop, which
;              cannot work until the outer counter is saved from the inner one.
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
    ROWS    EQU 4
    COLUMNS EQU 4
    SPACER  DB '  $'

; -----------------------------------------------------------------------------
; CODE SEGMENT
; -----------------------------------------------------------------------------
.CODE
START:
    MOV AX, @DATA
    MOV DS, AX

    MOV CX, ROWS
    MOV BX, 1                           ; The row number

OUTER:
    ; -------------------------------------------------------------------------
    ; BOTH LOOPS WANT CX. THE OUTER COUNT GOES ON THE STACK WHILE THE INNER
    ; LOOP RUNS, AND COMES BACK BEFORE THE OUTER LOOP INSTRUCTION READS IT.
    ; WITHOUT THIS THE OUTER LOOP WOULD SEE THE INNER LOOP'S ZERO AND STOP.
    ; -------------------------------------------------------------------------
    PUSH CX

    MOV CX, COLUMNS
    MOV SI, 1                           ; The column number

INNER_LOOP:
    MOV AX, BX
    MUL SI                              ; AX = row times column

    PUSH CX
    PUSH SI
    CALL PRINT_DECIMAL
    LEA DX, SPACER
    MOV AH, 09H
    INT 21H
    POP SI
    POP CX

    INC SI
    LOOP INNER_LOOP

    CALL NEWLINE

    POP CX                              ; The outer count, unharmed
    INC BX
    LOOP OUTER

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

END START

; =============================================================================
; TECHNICAL NOTES
; =============================================================================
; 1. ONE COUNTER, TWO LOOPS:
;    - The 8086 has one loop counter and it is CX. Nesting means saving
;    - it, and the stack is the natural place because the nesting order
;    - and the stack order are the same.
; 2. THE SYMPTOM WHEN IT IS FORGOTTEN:
;    - The outer loop runs exactly once. The inner loop leaves CX at
;    - zero, the outer LOOP decrements it to FFFFh and then runs 65535
;    - more times, or the whole thing appears to hang.
; 3. MUL WRITES DX:
;    - A word MUL puts the high half in DX whether it is needed or not,
;    - so anything held in DX is lost. Here DX is only used for printing.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
