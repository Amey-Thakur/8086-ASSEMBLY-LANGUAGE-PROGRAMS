; =============================================================================
; TITLE: Copying Words Rather Than Bytes
; DESCRIPTION: Copies an array of words with MOVSW and shows that halving the
;              count is what makes it equivalent to the byte form.
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
    SOURCE  DW 100, 200, 300, 400, 500, 600
    HOWMANY EQU 6
    TARGET  DW HOWMANY DUP(0)
    M_COPY  DB 'The copied array: $'
    SPACE   DB ' $'

; -----------------------------------------------------------------------------
; CODE SEGMENT
; -----------------------------------------------------------------------------
.CODE
START:
    MOV AX, @DATA
    MOV DS, AX
    MOV ES, AX

    LEA SI, SOURCE
    LEA DI, TARGET
    MOV CX, HOWMANY                     ; Words, so six and not twelve
    CLD
    REP MOVSW

    LEA DX, M_COPY
    MOV AH, 09H
    INT 21H

    LEA SI, TARGET
    MOV CX, HOWMANY

SHOW_LOOP:
    MOV AX, [SI]
    PUSH CX
    PUSH SI
    CALL PRINT_DECIMAL
    LEA DX, SPACE
    MOV AH, 09H
    INT 21H
    POP SI
    POP CX
    ADD SI, 2
    LOOP SHOW_LOOP

    CALL NEWLINE
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
; 1. WHY THE WORD FORM IS FASTER:
;    - Half as many bus cycles for the same number of bytes. On an 8086
;    - that is close to twice the speed for a large copy.
; 2. THE POINTERS MOVE BY TWO:
;    - SI and DI advance by the element size, not by one. That is handled
;    - by the instruction, which is why the count is in elements.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
