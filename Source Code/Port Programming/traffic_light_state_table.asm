; =============================================================================
; TITLE: A Traffic Light Driven by a State Table
; DESCRIPTION: Runs a junction through its phases from a table of port values,
;              which keeps the sequence in the data rather than in the code.
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
    LIGHTS  EQU 4

    ; Bits, from the lowest: north red, north amber, north green,
    ; east red, east amber, east green.
    ;
    ; Every phase is one byte, and the safety property that both directions
    ; are never green at once is a property of the table rather than of the
    ; code, which is what makes it checkable by inspection.
    PHASES  DB 00001100B                ; north green,  east red
            DB 00001010B                ; north amber,  east red
            DB 00100001B                ; north red,    east green
            DB 00010001B                ; north red,    east amber
    COUNT   EQU 4
    CYCLES  EQU 2

    M_HEAD  DB 'phase  port     north      east', 0DH, 0AH, '$'
    GAP     DB '  $'
    M_RED   DB 'red    $'
    M_AMBER DB 'amber  $'
    M_GREEN DB 'green  $'
    M_OFF   DB 'off    $'

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

    MOV BP, CYCLES

CYCLE:
    XOR BX, BX

EACH_PHASE:
    CMP BX, COUNT
    JAE CYCLE_DONE

    MOV AL, PHASES[BX]
    OUT LIGHTS, AL

    ; Report the phase number and the port value
    MOV AX, BX
    PUSH BX
    CALL PRINT_DECIMAL
    LEA DX, GAP
    MOV AH, 09H
    INT 21H
    POP BX

    PUSH BX
    MOV AL, PHASES[BX]
    CALL SHOW_BITS
    LEA DX, GAP
    MOV AH, 09H
    INT 21H
    POP BX

    ; Name the state of each direction
    PUSH BX
    MOV AL, PHASES[BX]
    AND AL, 00000111B                   ; The north lamps
    CALL NAME_LAMP
    POP BX

    PUSH BX
    MOV AL, PHASES[BX]
    SHR AL, 3
    AND AL, 00000111B                   ; The east lamps
    CALL NAME_LAMP
    POP BX

    CALL NEWLINE

    INC BX
    JMP EACH_PHASE

CYCLE_DONE:
    DEC BP
    JNZ CYCLE

    ; Leave the junction on red in both directions
    MOV AL, 00001001B
    OUT LIGHTS, AL

    MOV AX, 4C00H
    INT 21H

; -----------------------------------------------------------------------------
; NAME_LAMP
;
; Given three lamp bits in AL, prints which one is lit.
; -----------------------------------------------------------------------------
NAME_LAMP PROC
    PUSH AX
    PUSH DX

    TEST AL, 00000100B
    JNZ NL_GREEN
    TEST AL, 00000010B
    JNZ NL_AMBER
    TEST AL, 00000001B
    JNZ NL_RED

    LEA DX, M_OFF
    JMP NL_SHOW

NL_GREEN:
    LEA DX, M_GREEN
    JMP NL_SHOW

NL_AMBER:
    LEA DX, M_AMBER
    JMP NL_SHOW

NL_RED:
    LEA DX, M_RED

NL_SHOW:
    MOV AH, 09H
    INT 21H

    POP DX
    POP AX
    RET
NAME_LAMP ENDP

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
; 1. THE SAFETY RULE LIVES IN THE TABLE:
;    - No phase has both greens set, and that can be checked by reading
;    - four bytes. Spread across the code as a sequence of OUT
;    - instructions it would have to be checked by reasoning.
; 2. ENDING ON RED:
;    - A controller that stops mid phase leaves a green showing. Ending
;    - with both directions red is the only safe final state.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
