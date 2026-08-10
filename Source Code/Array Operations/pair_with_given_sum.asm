; =============================================================================
; TITLE: Finding Two Elements That Add to a Target
; DESCRIPTION: Searches a sorted array for a pair summing to a given value, by
;              closing in from both ends.
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
    SORTED  DW 2, 7, 11, 15, 19, 24, 30
    HOWMANY EQU 7
    TARGET  EQU 26

    M_ARRAY DB 'Sorted array: $'
    M_LOOK  DB 'Looking for a pair adding to 26', 0DH, 0AH, '$'
    M_FOUND DB 'Found $'
    M_PLUS  DB ' + $'
    M_EQ    DB ' = 26', 0DH, 0AH, '$'
    M_NONE  DB 'No such pair exists.', 0DH, 0AH, '$'
    M_STEPS DB 'Comparisons made: $'

; -----------------------------------------------------------------------------
; CODE SEGMENT
; -----------------------------------------------------------------------------
.CODE
START:
    MOV AX, @DATA
    MOV DS, AX

    LEA DX, M_ARRAY
    MOV AH, 09H
    INT 21H
    LEA SI, SORTED
    MOV CX, HOWMANY
    CALL SHOW_RUN

    LEA DX, M_LOOK
    MOV AH, 09H
    INT 21H

    ; -------------------------------------------------------------------------
    ; ONE POINTER AT EACH END. IF THE PAIR IS TOO SMALL ONLY MOVING THE LOWER
    ; ONE UP CAN HELP, AND IF IT IS TOO LARGE ONLY MOVING THE UPPER ONE DOWN
    ; CAN. EVERY COMPARISON THEREFORE ELIMINATES A WHOLE ROW OR COLUMN OF
    ; POSSIBILITIES, WHICH IS WHY ONE PASS IS ENOUGH.
    ;
    ; THIS ONLY WORKS BECAUSE THE ARRAY IS SORTED. ON UNSORTED DATA IT RETURNS
    ; QUICKLY AND IS SIMPLY WRONG.
    ; -------------------------------------------------------------------------
    LEA SI, SORTED
    LEA DI, SORTED
    ADD DI, (HOWMANY - 1) * 2
    XOR BP, BP                          ; How many comparisons were made

SEARCH:
    CMP SI, DI
    JAE NOT_FOUND                       ; The pointers met

    INC BP

    MOV AX, [SI]
    ADD AX, [DI]

    CMP AX, TARGET
    JE  FOUND
    JB  TOO_SMALL

    SUB DI, 2                           ; Too large, so lower the top
    JMP SEARCH

TOO_SMALL:
    ADD SI, 2                           ; Too small, so raise the bottom
    JMP SEARCH

FOUND:
    LEA DX, M_FOUND
    MOV AH, 09H
    INT 21H
    MOV AX, [SI]
    CALL PRINT_DECIMAL
    LEA DX, M_PLUS
    MOV AH, 09H
    INT 21H
    MOV AX, [DI]
    CALL PRINT_DECIMAL
    LEA DX, M_EQ
    MOV AH, 09H
    INT 21H
    JMP SHOW_STEPS

NOT_FOUND:
    LEA DX, M_NONE
    MOV AH, 09H
    INT 21H

SHOW_STEPS:
    LEA DX, M_STEPS
    MOV AH, 09H
    INT 21H
    MOV AX, BP
    CALL PRINT_DECIMAL
    CALL NEWLINE

    MOV AX, 4C00H
    INT 21H

; -----------------------------------------------------------------------------
; SHOW_RUN
;
; Prints CX words starting at DS:SI, then a newline.
; -----------------------------------------------------------------------------
SHOW_RUN PROC
    PUSH AX
    PUSH CX
    PUSH DX
    PUSH SI

    JCXZ SR_DONE

SR_LOOP:
    MOV AX, [SI]
    PUSH CX
    PUSH SI
    CALL PRINT_SIGNED
    MOV DL, ' '
    MOV AH, 02H
    INT 21H
    POP SI
    POP CX

    ADD SI, 2
    LOOP SR_LOOP

SR_DONE:
    CALL NEWLINE

    POP SI
    POP DX
    POP CX
    POP AX
    RET
SHOW_RUN ENDP

; -----------------------------------------------------------------------------
; PRINT_SIGNED
;
; Prints AX as a signed value, with a minus sign when it is negative.
; -----------------------------------------------------------------------------
PRINT_SIGNED PROC
    PUSH AX
    PUSH DX

    OR  AX, AX
    JNS PS_POSITIVE                     ; Sign flag clear means not negative

    PUSH AX
    MOV DL, '-'
    MOV AH, 02H
    INT 21H
    POP AX
    NEG AX                              ; Print the magnitude

PS_POSITIVE:
    CALL PRINT_DECIMAL

    POP DX
    POP AX
    RET
PRINT_SIGNED ENDP

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
; 1. SORTED IS THE WHOLE PRECONDITION:
;    - Knowing which way to move depends entirely on the order. Sorting
;    - first and then doing this is still far cheaper than examining every
;    - pair.
; 2. AT MOST N COMPARISONS:
;    - Each one moves a pointer, and the pointers can only travel the
;    - length of the array between them. Checking every pair would be the
;    - square of that.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
