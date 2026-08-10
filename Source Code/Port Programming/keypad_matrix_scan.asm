; =============================================================================
; TITLE: Scanning a Keypad Matrix
; DESCRIPTION: Finds which key is pressed on a four by four keypad by driving
;              one row at a time and reading the columns.
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
    ROW_PORT EQU 60
    COL_PORT EQU 61

    ; What each position on the pad means
    KEYS    DB '123A'
            DB '456B'
            DB '789C'
            DB '*0#D'

    ; The simulator has no keypad, so a column reading is planted for each
    ; row before it is read. Row two returning column two is the key at that
    ; crossing, which the table below shows is '9'.
    PLANTED DB 0, 0, 00000100B, 0

    M_HEAD  DB 'Scanning the four rows:', 0DH, 0AH, '$'
    M_ROW   DB 'row $'
    M_COLS  DB '  columns $'
    M_KEY   DB '   key: $'
    M_NONE  DB '   nothing', 0DH, 0AH, '$'
    CRLF    DB 0DH, 0AH, '$'

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

    XOR BX, BX                          ; The row being driven

EACH_ROW:
    CMP BX, 4
    JAE FINISHED

    ; -------------------------------------------------------------------------
    ; DRIVE ONE ROW AND READ THE COLUMNS. A KEY CONNECTS ONE ROW TO ONE
    ; COLUMN, SO A COLUMN THAT READS BACK MEANS A KEY ON THIS ROW IS DOWN.
    ; SIXTEEN KEYS ARE REACHED WITH EIGHT LINES RATHER THAN SIXTEEN.
    ; -------------------------------------------------------------------------
    MOV AL, 1
    MOV CL, BL
    SHL AL, CL                          ; One bit for this row
    OUT ROW_PORT, AL

    ; Stand in for the hardware: plant what this row would return
    MOV AL, PLANTED[BX]
    OUT COL_PORT, AL

    IN  AL, COL_PORT                    ; The columns that came back
    MOV BP, AX

    ; Report
    PUSH BX
    LEA DX, M_ROW
    MOV AH, 09H
    INT 21H
    POP BX
    PUSH BX
    MOV AX, BX
    CALL PRINT_DECIMAL

    LEA DX, M_COLS
    MOV AH, 09H
    INT 21H
    MOV AX, BP
    CALL SHOW_BITS
    POP BX

    MOV AX, BP
    AND AL, 0FH
    JZ  NOTHING_HERE

    ; Which column is it
    XOR DI, DI

FIND_COLUMN:
    SHR AL, 1
    JC  FOUND_COLUMN
    INC DI
    JMP FIND_COLUMN

FOUND_COLUMN:
    ; -------------------------------------------------------------------------
    ; THE KEY IS AT ROW TIMES FOUR PLUS COLUMN IN THE TABLE, WHICH IS THE
    ; ORDINARY TWO DIMENSIONAL ADDRESS CALCULATION.
    ; -------------------------------------------------------------------------
    PUSH BX
    LEA DX, M_KEY
    MOV AH, 09H
    INT 21H
    POP BX

    MOV AX, BX
    SHL AX, 2                           ; Four keys per row
    ADD AX, DI
    MOV SI, AX
    MOV DL, KEYS[SI]
    MOV AH, 02H
    INT 21H

    PUSH BX
    LEA DX, CRLF
    MOV AH, 09H
    INT 21H
    POP BX
    JMP NEXT_ROW

NOTHING_HERE:
    PUSH BX
    LEA DX, M_NONE
    MOV AH, 09H
    INT 21H
    POP BX

NEXT_ROW:
    INC BX
    JMP EACH_ROW

FINISHED:
    MOV AL, 0
    OUT ROW_PORT, AL

    MOV AX, 4C00H
    INT 21H

; -----------------------------------------------------------------------------
; SHOW_BITS
;
; Prints AL as eight ones and zeros, most significant first. A port value is
; a set of independent lines rather than a number, so binary is the form that
; says what it means.
; -----------------------------------------------------------------------------
SHOW_BITS PROC
    PUSH AX
    PUSH CX
    PUSH DX

    MOV CX, 8

SB_LOOP:
    SHL AL, 1
    MOV DL, '0'
    JNC SB_EMIT
    MOV DL, '1'

SB_EMIT:
    PUSH AX
    MOV AH, 02H
    INT 21H
    POP AX
    LOOP SB_LOOP

    POP DX
    POP CX
    POP AX
    RET
SHOW_BITS ENDP

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
; 1. EIGHT LINES FOR SIXTEEN KEYS:
;    - A key is the crossing of a row and a column, so four of each
;    - reaches sixteen. Wiring each key separately would need sixteen
;    - lines and a larger port.
; 2. TWO KEYS AT ONCE CONFUSE IT:
;    - Three keys forming a rectangle make a fourth appear to be pressed,
;    - because the current finds a path around. Real keypads add a diode
;    - per key, or the software refuses to report more than one.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
