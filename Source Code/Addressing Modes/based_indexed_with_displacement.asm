; =============================================================================
; TITLE: Based Indexed Addressing With Displacement
; DESCRIPTION: The fullest address the 8086 can form: a base register, an index register and a constant, all added together.
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
    ; Three rows of three, as before.
    GRID    DW 1, 2, 3
            DW 4, 5, 6
            DW 7, 8, 9
    COLS    EQU 3
    STRIDE  EQU COLS * 2

    M_TITLE DB 'Base plus index plus displacement, the widest form', 0DH, 0AH, '$'
    M_CENTRE DB 'The centre cell, row 1 column 1: $'
    M_RIGHT DB 'Its right neighbour, displacement +2: $'
    M_LEFT  DB 'Its left neighbour, displacement -2: $'
    M_BELOW DB 'The cell below it, displacement +6: $'
    M_ABOVE DB 'The cell above it, displacement -6: $'
    M_SUM   DB 'The five of them added up: $'
    M_WHY   DB 'Neither BX nor SI moved. Only the constant changed.', 0DH, 0AH, '$'

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
    ; BOTH REGISTERS ARE AIMED AT THE CENTRE CELL AND THEN LEFT ALONE. THE
    ; FOUR NEIGHBOURS ARE REACHED BY CHANGING ONLY THE DISPLACEMENT, WHICH IS
    ; EXACTLY HOW A STENCIL OR A FILTER KERNEL IS WRITTEN.
    ; -------------------------------------------------------------------------
    MOV BX, 1 * STRIDE                  ; Row 1
    MOV SI, 1 * 2                       ; Column 1

    MOV AX, GRID[BX][SI]
    MOV DI, AX                          ; DI accumulates the total
    LEA DX, M_CENTRE
    CALL PRINT_MESSAGE
    CALL PRINT_DECIMAL
    CALL NEWLINE

    MOV AX, GRID[BX][SI+2]
    ADD DI, AX
    LEA DX, M_RIGHT
    CALL PRINT_MESSAGE
    CALL PRINT_DECIMAL
    CALL NEWLINE

    MOV AX, GRID[BX][SI-2]
    ADD DI, AX
    LEA DX, M_LEFT
    CALL PRINT_MESSAGE
    CALL PRINT_DECIMAL
    CALL NEWLINE

    MOV AX, GRID[BX][SI+STRIDE]
    ADD DI, AX
    LEA DX, M_BELOW
    CALL PRINT_MESSAGE
    CALL PRINT_DECIMAL
    CALL NEWLINE

    MOV AX, GRID[BX][SI-STRIDE]
    ADD DI, AX
    LEA DX, M_ABOVE
    CALL PRINT_MESSAGE
    CALL PRINT_DECIMAL
    CALL NEWLINE

    LEA DX, M_SUM

    CALL PRINT_MESSAGE
    MOV AX, DI
    CALL PRINT_DECIMAL
    CALL NEWLINE
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
; 1. Four parts in one address:
;    - The segment base, a base register, an index register and a displacement.
;    - That is the most the 8086 address adder can combine.
;    - Anything more has to be worked out beforehand and put in a register.
; 2. Why it suits a stencil:
;    - The centre is held in the registers and the neighbours are constants away from it.
;    - Moving the stencil to the next cell changes only the index register.
;    - A blur, an edge filter and a game of life all have this shape.
; 3. The displacement may be negative:
;    - [SI-2] and [SI-STRIDE] reach backwards, and the assembler encodes the sign.
;    - A negative displacement is what makes the left and upper neighbours reachable.
;    - The sum wraps at sixteen bits, so an out of bounds read is silent rather than trapped.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
