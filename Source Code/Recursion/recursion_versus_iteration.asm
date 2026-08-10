; =============================================================================
; TITLE: The Same Problem Both Ways
; DESCRIPTION: Computes a factorial recursively and with a loop, and measures
;              how much stack each one uses.
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
    NUMBER  DW 8
    M_REC   DB 'Recursive: $'
    M_ITER  DB 'Iterative: $'
    M_STACK DB '   stack used: $'
    M_BYTES DB ' bytes', 0DH, 0AH, '$'
    LOWEST  DW 0FFFFH
    BASELINE DW 0

; -----------------------------------------------------------------------------
; CODE SEGMENT
; -----------------------------------------------------------------------------
.CODE
START:
    MOV AX, @DATA
    MOV DS, AX

    MOV AX, SP
    MOV BASELINE, AX

    ; ---- the recursive form -------------------------------------------------
    MOV AX, NUMBER
    PUSH AX
    CALL FACT_RECURSIVE
    ADD SP, 2

    PUSH AX
    LEA DX, M_REC
    MOV AH, 09H
    INT 21H
    POP AX
    CALL PRINT_DECIMAL

    LEA DX, M_STACK
    MOV AH, 09H
    INT 21H
    MOV AX, BASELINE
    SUB AX, LOWEST
    CALL PRINT_DECIMAL
    LEA DX, M_BYTES
    MOV AH, 09H
    INT 21H

    ; ---- the iterative form -------------------------------------------------
    MOV LOWEST, 0FFFFH

    MOV AX, NUMBER
    PUSH AX
    CALL FACT_ITERATIVE
    ADD SP, 2

    PUSH AX
    LEA DX, M_ITER
    MOV AH, 09H
    INT 21H
    POP AX
    CALL PRINT_DECIMAL

    LEA DX, M_STACK
    MOV AH, 09H
    INT 21H
    MOV AX, BASELINE
    SUB AX, LOWEST
    CALL PRINT_DECIMAL
    LEA DX, M_BYTES
    MOV AH, 09H
    INT 21H

    MOV AH, 4CH
    INT 21H

; -----------------------------------------------------------------------------
; FACT_RECURSIVE
; -----------------------------------------------------------------------------
FACT_RECURSIVE PROC
    PUSH BP
    MOV BP, SP
    PUSH BX

    MOV BX, SP
    CMP BX, LOWEST
    JAE FR_NOT_DEEPER
    MOV LOWEST, BX

FR_NOT_DEEPER:
    MOV AX, [BP+4]
    CMP AX, 1
    JBE FR_BASE

    DEC AX
    PUSH AX
    CALL FACT_RECURSIVE
    ADD SP, 2
    MUL WORD PTR [BP+4]
    JMP FR_RETURN

FR_BASE:
    MOV AX, 1

FR_RETURN:
    POP BX
    POP BP
    RET
FACT_RECURSIVE ENDP

; -----------------------------------------------------------------------------
; FACT_ITERATIVE
;
; One frame, however large the argument, because the loop replaces the depth.
; -----------------------------------------------------------------------------
FACT_ITERATIVE PROC
    PUSH BP
    MOV BP, SP
    PUSH BX
    PUSH CX

    MOV BX, SP
    CMP BX, LOWEST
    JAE FI_NOT_DEEPER
    MOV LOWEST, BX

FI_NOT_DEEPER:
    MOV CX, [BP+4]
    MOV AX, 1

    JCXZ FI_RETURN

FI_LOOP:
    MUL CX
    LOOP FI_LOOP

FI_RETURN:
    POP CX
    POP BX
    POP BP
    RET
FACT_ITERATIVE ENDP

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
; 1. THE SAME ANSWER, DIFFERENT COST:
;    - Both give 40320. The recursion uses a frame per level; the loop
;    - uses one frame whatever the argument. The measured difference is
;    - printed rather than asserted.
; 2. WHEN RECURSION IS STILL RIGHT:
;    - When the problem branches, as Hanoi and tree walking do. A loop
;    - can only replace recursion cheaply when there is one call per
;    - level.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
