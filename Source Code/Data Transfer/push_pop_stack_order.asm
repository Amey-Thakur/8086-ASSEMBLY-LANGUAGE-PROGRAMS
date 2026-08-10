; =============================================================================
; TITLE: PUSH and POP, and the Order They Impose
; DESCRIPTION: Pushes three values and pops them back, showing that the stack
;              returns them in the opposite order and that SP moves downward.
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
    MSG_IN  DB 'Pushed:  10 20 30', 0DH, 0AH, '$'
    MSG_OUT DB 'Popped:  $'
    SPACE   DB ' $'
    MSG_SP  DB 'SP returned to where it started.', 0DH, 0AH, '$'
    MSG_BAD DB 'SP did not balance.', 0DH, 0AH, '$'

; -----------------------------------------------------------------------------
; CODE SEGMENT
; -----------------------------------------------------------------------------
.CODE
START:
    MOV AX, @DATA
    MOV DS, AX

    MOV BP, SP                          ; Remember where the stack stood

    LEA DX, MSG_IN
    MOV AH, 09H
    INT 21H

    MOV AX, 10
    PUSH AX
    MOV AX, 20
    PUSH AX
    MOV AX, 30
    PUSH AX

    LEA DX, MSG_OUT
    MOV AH, 09H
    INT 21H

    ; -------------------------------------------------------------------------
    ; LAST IN, FIRST OUT. THE THIRTY THAT WENT ON LAST IS THE FIRST TO COME
    ; BACK, WHICH IS WHY A PROCEDURE MUST POP IN THE REVERSE ORDER IT PUSHED.
    ; -------------------------------------------------------------------------
    POP AX
    CALL PRINT_DECIMAL
    CALL SHOW_SPACE
    POP AX
    CALL PRINT_DECIMAL
    CALL SHOW_SPACE
    POP AX
    CALL PRINT_DECIMAL
    CALL NEWLINE

    ; Three pushes and three pops should leave SP exactly as it was
    MOV AX, SP
    CMP AX, BP
    JNE UNBALANCED

    LEA DX, MSG_SP
    JMP REPORT

UNBALANCED:
    LEA DX, MSG_BAD

REPORT:
    MOV AH, 09H
    INT 21H

    MOV AH, 4CH
    INT 21H

; -----------------------------------------------------------------------------
; SHOW_SPACE
; -----------------------------------------------------------------------------
SHOW_SPACE PROC
    PUSH AX
    PUSH DX
    LEA DX, SPACE
    MOV AH, 09H
    INT 21H
    POP DX
    POP AX
    RET
SHOW_SPACE ENDP

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
; 1. THE STACK GROWS DOWNWARD:
;    - PUSH subtracts two from SP and then writes. POP reads and then adds
;    - two. Doing either in the other order leaves the stack off by two.
; 2. WORDS ONLY:
;    - The 8086 stack works in words. There is no PUSH of a single byte,
;    - which is why SP always moves by two.
; 3. WHY BALANCE MATTERS:
;    - RET takes its return address from the stack. A procedure that
;    - pushes more than it pops returns to whatever is left on top, which
;    - is rarely anywhere useful.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
