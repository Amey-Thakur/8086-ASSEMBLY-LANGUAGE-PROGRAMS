; =============================================================================
; TITLE: Pascal's Triangle
; DESCRIPTION: Builds each row from the one above it, where every entry is the
;              sum of the two diagonally over it.
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
    ROWS    EQU 8
    ROW     DW ROWS DUP(0)
    M_HEAD  DB "Pascal's triangle, eight rows:", 0DH, 0AH, '$'

; -----------------------------------------------------------------------------
; CODE SEGMENT
; -----------------------------------------------------------------------------
.CODE
START:
    MOV AX, @DATA
    MOV DS, AX

    LEA DX, M_HEAD
    MOV AH, 09H
    INT 21H

    MOV WORD PTR ROW[0], 1              ; The first row is a single one
    XOR BX, BX                          ; Which row is being printed

EACH_ROW:
    CMP BX, ROWS
    JAE FINISHED

    ; Indent so the triangle is centred
    MOV CX, ROWS
    SUB CX, BX
    SHL CX, 1
    MOV DL, ' '
    CALL REPEAT_CHAR

    ; Print the row
    MOV CX, BX
    INC CX
    XOR SI, SI

PRINT_ROW:
    MOV AX, ROW[SI]
    PUSH BX
    PUSH CX
    PUSH SI
    CALL PRINT_CELL
    POP SI
    POP CX
    POP BX

    ADD SI, 2
    LOOP PRINT_ROW

    CALL NEWLINE

    ; -------------------------------------------------------------------------
    ; BUILD THE NEXT ROW IN PLACE, WORKING FROM THE RIGHT. GOING LEFT TO RIGHT
    ; WOULD OVERWRITE AN ENTRY BEFORE THE NEXT SUM STILL NEEDED IT, WHICH IS
    ; THE SAME HAZARD AS COPYING OVERLAPPING MEMORY FORWARD.
    ; -------------------------------------------------------------------------
    MOV SI, BX
    INC SI
    SHL SI, 1                           ; The new last entry

BUILD:
    CMP SI, 0
    JE  ROW_BUILT

    MOV AX, ROW[SI-2]
    ADD AX, ROW[SI]
    MOV ROW[SI], AX

    SUB SI, 2
    JMP BUILD

ROW_BUILT:
    INC BX
    JMP EACH_ROW

FINISHED:
    MOV AH, 4CH
    INT 21H

; -----------------------------------------------------------------------------
; REPEAT_CHAR
;
; Prints the character in DL, CX times. A count of nought prints nothing,
; which is what makes the first row of most patterns come out right.
; -----------------------------------------------------------------------------
REPEAT_CHAR PROC
    PUSH AX
    PUSH CX
    PUSH DX

    JCXZ RC_DONE

RC_LOOP:
    MOV AH, 02H
    INT 21H
    LOOP RC_LOOP

RC_DONE:
    POP DX
    POP CX
    POP AX
    RET
REPEAT_CHAR ENDP

; -----------------------------------------------------------------------------
; PRINT_CELL
;
; Prints AX followed by enough spaces to fill four columns, so that a grid of
; numbers lines up whether the values are one digit or three.
; -----------------------------------------------------------------------------
PRINT_CELL PROC
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX

    MOV BX, AX

    ; How many digits will it take
    MOV CX, 1
    MOV AX, BX

PC_COUNT:
    CMP AX, 10
    JB  PC_EMIT
    PUSH BX
    XOR DX, DX
    MOV BX, 10
    DIV BX
    POP BX
    INC CX
    JMP PC_COUNT

PC_EMIT:
    PUSH CX
    MOV AX, BX
    CALL PRINT_DECIMAL
    POP CX

    MOV AX, 4
    CMP AX, CX
    JBE PC_DONE
    SUB AX, CX
    MOV CX, AX
    MOV DL, ' '
    CALL REPEAT_CHAR

PC_DONE:
    POP DX
    POP CX
    POP BX
    POP AX
    RET
PRINT_CELL ENDP

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
; 1. BUILDING RIGHT TO LEFT:
;    - Each new entry needs the old value of the one to its left. Working
;    - from the right means that value is still there when it is wanted.
;    - Left to right would read a value already replaced.
; 2. ONE ROW OF STORAGE:
;    - Only the current row is kept, because that is all the next one
;    - needs. Storing the whole triangle would cost the square of the
;    - height for no benefit.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
