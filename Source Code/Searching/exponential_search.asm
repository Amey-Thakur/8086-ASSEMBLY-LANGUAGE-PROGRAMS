; =============================================================================
; TITLE: Exponential Search
; DESCRIPTION: Doubles the range until the value is bracketed, then binary
;              searches inside it, which suits an array of unknown length.
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
    SORTED  DW 2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37, 41, 43, 47, 53
    HOWMANY EQU 16
    WANTED  DW 13

    M_ARRAY DB 'Sorted: $'
    M_BOUND DB 'Bracketed between index $'
    M_AND   DB ' and $'
    M_AT    DB 'Found at index $'
    M_NONE  DB 'Not present', 0DH, 0AH, '$'

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

    ; -------------------------------------------------------------------------
    ; START AT INDEX ONE AND DOUBLE UNTIL THE ELEMENT THERE IS NOT SMALLER
    ; THAN THE TARGET. THE TARGET MUST THEN LIE BETWEEN THAT INDEX AND HALF OF
    ; IT, WHICH IS THE RANGE THE BINARY SEARCH IS GIVEN.
    ;
    ; THE POINT IS THAT THE LENGTH NEVER HAS TO BE KNOWN IN ADVANCE, ONLY WHERE
    ; THE DATA ENDS.
    ; -------------------------------------------------------------------------
    MOV BX, 1                           ; The index being probed

    ; Check index nought first, which the doubling never visits
    MOV AX, SORTED[0]
    CMP AX, WANTED
    JE  FOUND_AT_ZERO

DOUBLE:
    CMP BX, HOWMANY
    JAE BRACKETED

    MOV SI, BX
    SHL SI, 1
    MOV AX, SORTED[SI]
    CMP AX, WANTED
    JAE BRACKETED

    SHL BX, 1                           ; Twice as far
    JMP DOUBLE

BRACKETED:
    MOV DX, BX                          ; The high bound
    CMP DX, HOWMANY
    JB  HIGH_OK
    MOV DX, HOWMANY
    DEC DX

HIGH_OK:
    MOV CX, BX
    SHR CX, 1                           ; The low bound is half the high one

    PUSH CX
    PUSH DX
    LEA DX, M_BOUND
    MOV AH, 09H
    INT 21H
    POP DX
    POP CX
    PUSH CX
    PUSH DX
    MOV AX, CX
    CALL PRINT_DECIMAL
    LEA DX, M_AND
    MOV AH, 09H
    INT 21H
    POP DX
    POP CX
    PUSH CX
    PUSH DX
    MOV AX, DX
    CALL PRINT_DECIMAL
    CALL NEWLINE
    POP DX
    POP CX

    ; Binary search between CX and DX
    MOV BX, CX

BINARY:
    CMP BX, DX
    JA  NOT_PRESENT

    MOV CX, BX
    ADD CX, DX
    SHR CX, 1

    MOV SI, CX
    SHL SI, 1
    MOV AX, SORTED[SI]

    CMP AX, WANTED
    JE  FOUND
    JB  HIGHER

    CMP CX, 0
    JE  NOT_PRESENT
    MOV DX, CX
    DEC DX
    JMP BINARY

HIGHER:
    MOV BX, CX
    INC BX
    JMP BINARY

FOUND_AT_ZERO:
    XOR CX, CX

FOUND:
    PUSH CX
    LEA DX, M_AT
    MOV AH, 09H
    INT 21H
    POP AX
    CALL PRINT_DECIMAL
    CALL NEWLINE
    JMP FINISHED

NOT_PRESENT:
    LEA DX, M_NONE
    MOV AH, 09H
    INT 21H

FINISHED:
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
    CALL PRINT_DECIMAL
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
; 1. FOR AN ARRAY OF UNKNOWN LENGTH:
;    - A binary search needs both bounds before it can start. Doubling
;    - finds an upper bound in logarithmic time, so the two together
;    - search a sequence whose end is not known.
; 2. INDEX NOUGHT IS NEVER PROBED:
;    - The doubling starts at one, so a match at the very front has to be
;    - checked separately. It is the sort of omission that passes every
;    - test except the one where the answer is first.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
