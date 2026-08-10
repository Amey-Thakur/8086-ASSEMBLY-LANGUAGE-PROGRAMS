; =============================================================================
; TITLE: Passing Arguments On The Stack
; DESCRIPTION: A procedure taking four arguments, more than the registers would comfortably carry, with the caller clearing them.
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
    M_TITLE DB 'Four arguments on the stack, none in a register', 0DH, 0AH, '$'
    M_CALL1 DB 'SUM_FOUR(1, 2, 3, 4)   = $'
    M_CALL2 DB 'SUM_FOUR(10, 20, 30, 40) = $'
    M_CALL3 DB 'SUM_FOUR(100, 200, 300, 400) = $'
    M_LARGE DB 'A fifth or a fiftieth argument needs no new mechanism.', 0DH, 0AH, '$'
    M_RET   DB 'This version ends with RET 8, so the procedure cleans up.', 0DH, 0AH, '$'

; -----------------------------------------------------------------------------
; CODE SEGMENT
; -----------------------------------------------------------------------------
.CODE
START:
    MOV AX, @DATA
    MOV DS, AX

    LEA DX, M_TITLE
    CALL PRINT_MESSAGE

    ; -------------------------------------------------------------------------
    ; THE ARGUMENTS ARE PUSHED LAST TO FIRST, WHICH PUTS THE FIRST ONE NEAREST
    ; BP AND LETS A PROCEDURE READ THEM LEFT TO RIGHT AT ASCENDING OFFSETS.
    ; THAT IS THE ORDER A C COMPILER USES, AND FOR THE SAME REASON.
    ; -------------------------------------------------------------------------
    MOV AX, 4
    PUSH AX
    MOV AX, 3
    PUSH AX
    MOV AX, 2
    PUSH AX
    MOV AX, 1
    PUSH AX
    CALL SUM_FOUR                       ; RET 8 removes the arguments

    LEA DX, M_CALL1
    CALL PRINT_MESSAGE
    CALL PRINT_DECIMAL
    CALL NEWLINE

    MOV AX, 40
    PUSH AX
    MOV AX, 30
    PUSH AX
    MOV AX, 20
    PUSH AX
    MOV AX, 10
    PUSH AX
    CALL SUM_FOUR

    LEA DX, M_CALL2
    CALL PRINT_MESSAGE
    CALL PRINT_DECIMAL
    CALL NEWLINE

    MOV AX, 400
    PUSH AX
    MOV AX, 300
    PUSH AX
    MOV AX, 200
    PUSH AX
    MOV AX, 100
    PUSH AX
    CALL SUM_FOUR

    LEA DX, M_CALL3
    CALL PRINT_MESSAGE
    CALL PRINT_DECIMAL
    CALL NEWLINE
    CALL NEWLINE

    LEA DX, M_LARGE
    CALL PRINT_MESSAGE
    LEA DX, M_RET
    CALL PRINT_MESSAGE

    MOV AH, 4CH
    INT 21H

; -----------------------------------------------------------------------------
; SUM_FOUR
;
; Adds four words passed on the stack and returns the total in AX. The four
; arguments are removed by the RET itself, so the caller does nothing after.
;
;     [BP+4]  first    [BP+6]  second    [BP+8]  third    [BP+10] fourth
; -----------------------------------------------------------------------------
SUM_FOUR PROC
    PUSH BP
    MOV BP, SP
    PUSH BX

    MOV AX, [BP+4]
    ADD AX, [BP+6]
    ADD AX, [BP+8]
    ADD AX, [BP+10]

    POP BX
    POP BP
    RET 8                               ; Return and drop four words
SUM_FOUR ENDP

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
; 1. Why last to first:
;    - Pushing in reverse puts the first argument at the lowest offset from BP.
;    - The procedure then reads its arguments in the order they were written.
;    - A variable argument list also needs the first one at a known fixed place.
; 2. RET with a count:
;    - RET 8 pops the return address and then adds eight to SP.
;    - The count must match the bytes of arguments exactly: four words is eight bytes.
;    - A wrong count corrupts the stack for the caller, not for the procedure.
; 3. No limit worth worrying about:
;    - Registers run out after four or five arguments; the stack does not.
;    - The cost is a memory access per argument instead of a register read.
;    - Recursion needs the stack anyway, because registers cannot nest.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
