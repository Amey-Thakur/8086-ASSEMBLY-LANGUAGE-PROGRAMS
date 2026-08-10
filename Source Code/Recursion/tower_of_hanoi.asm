; =============================================================================
; TITLE: Tower of Hanoi
; DESCRIPTION: Solves the three peg puzzle recursively and prints every move,
;              passing its four arguments on the stack in a proper frame.
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
    DISKS   EQU 3
    M_HEAD  DB 'Moving 3 disks from A to C:', 0DH, 0AH, '$'
    M_MOVE  DB 'Move disk from $'
    M_TO    DB ' to $'
    M_COUNT DB 'Total moves: $'
    MOVES   DW 0

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

    ; -------------------------------------------------------------------------
    ; FOUR ARGUMENTS GO ON THE STACK BEFORE THE CALL, AND THE CALLER TAKES
    ; THEM OFF AFTERWARDS WITH ADD SP. PUSHING THEM IN THIS ORDER PUTS THE
    ; DISK COUNT FURTHEST FROM BP INSIDE THE PROCEDURE.
    ; -------------------------------------------------------------------------
    MOV AX, DISKS
    PUSH AX
    MOV AX, 'A'                         ; from
    PUSH AX
    MOV AX, 'C'                         ; to
    PUSH AX
    MOV AX, 'B'                         ; spare
    PUSH AX
    CALL HANOI
    ADD SP, 8

    LEA DX, M_COUNT
    MOV AH, 09H
    INT 21H
    MOV AX, MOVES
    CALL PRINT_DECIMAL
    CALL NEWLINE

    MOV AH, 4CH
    INT 21H

; -----------------------------------------------------------------------------
; HANOI
;
; Arguments on the stack, reached through BP:
;     [BP+10]  how many disks
;     [BP+8]   the peg they are on
;     [BP+6]   the peg they must reach
;     [BP+4]   the peg available as a resting place
; -----------------------------------------------------------------------------
HANOI PROC
    PUSH BP
    MOV BP, SP                          ; The frame pointer for this call
    PUSH AX
    PUSH DX

    MOV AX, [BP+10]
    OR  AX, AX
    JZ  HANOI_RETURN                    ; No disks left: nothing to do

    ; -------------------------------------------------------------------------
    ; MOVE EVERYTHING ABOVE THE BOTTOM DISK OUT OF THE WAY, ONTO THE SPARE
    ; PEG. THE DESTINATION AND THE SPARE SWAP ROLES FOR THIS CALL.
    ; -------------------------------------------------------------------------
    DEC AX
    PUSH AX
    PUSH [BP+8]                         ; from, unchanged
    PUSH [BP+4]                         ; the spare becomes the destination
    PUSH [BP+6]                         ; the destination becomes the spare
    CALL HANOI
    ADD SP, 8

    ; The bottom disk can now move straight across
    LEA DX, M_MOVE
    MOV AH, 09H
    INT 21H
    MOV DX, [BP+8]
    MOV AH, 02H
    INT 21H
    LEA DX, M_TO
    MOV AH, 09H
    INT 21H
    MOV DX, [BP+6]
    MOV AH, 02H
    INT 21H
    CALL NEWLINE

    INC MOVES

    ; -------------------------------------------------------------------------
    ; BRING THE PILE BACK ON TOP OF IT. THIS TIME THE SPARE PEG IS WHERE THEY
    ; ARE, AND THE PEG THEY CAME FROM IS THE SPARE.
    ; -------------------------------------------------------------------------
    MOV AX, [BP+10]
    DEC AX
    PUSH AX
    PUSH [BP+4]                         ; they are on the old spare
    PUSH [BP+6]                         ; to, unchanged
    PUSH [BP+8]                         ; the original peg is now the spare
    CALL HANOI
    ADD SP, 8

HANOI_RETURN:
    POP DX
    POP AX
    POP BP
    RET
HANOI ENDP

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
; 1. WHY A STACK FRAME AND NOT REGISTERS:
;    - Four arguments and two recursive calls per level. Registers would
;    - have to be saved and restored around each call anyway, and the
;    - frame makes the arguments readable at every depth without it.
; 2. THE MOVE COUNT:
;    - Three disks take seven moves, and n disks take two to the n less
;    - one. Each level makes one move and asks for two smaller problems,
;    - which is exactly where the doubling comes from.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
