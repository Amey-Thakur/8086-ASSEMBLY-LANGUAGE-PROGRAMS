; =============================================================================
; TITLE: Classify Every Character
; DESCRIPTION: Counts the letters, digits, spaces and everything else in a
;              string, which is the first step of any input validation.
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
    TEXT     DB 'Amey Thakur, 2022! 8086 asm.'
    TEXTLEN  EQU $ - TEXT
    ; The five totals live in memory, not in registers.
    ;
    ; The first version of this program kept them in BX, DX, DI and BP, and
    ; reported them one after another. Printing a message needs DX for the
    ; address of that message, so the very first report destroyed the lower
    ; case count before the second could read it, and 11 was printed as 28.
    ; Anything that has to survive a DOS call belongs in memory.
    N_UPPER  DW 0
    N_LOWER  DW 0
    N_DIGIT  DW 0
    N_SPACE  DW 0
    N_OTHER  DW 0

    M_UPPER  DB 'Upper case: $'
    M_LOWER  DB 'Lower case: $'
    M_DIGIT  DB 'Digits:     $'
    M_SPACE  DB 'Spaces:     $'
    M_OTHER  DB 'Other:      $'

; -----------------------------------------------------------------------------
; CODE SEGMENT
; -----------------------------------------------------------------------------
.CODE
START:
    MOV AX, @DATA
    MOV DS, AX

    LEA SI, TEXT
    MOV CX, TEXTLEN

CLASSIFY:
    MOV AL, [SI]

    ; -------------------------------------------------------------------------
    ; THE RANGES ARE TESTED IN ORDER, EACH FALLING THROUGH TO THE NEXT, SO
    ; EVERY CHARACTER IS COUNTED EXACTLY ONCE AND NOTHING IS COUNTED TWICE.
    ; -------------------------------------------------------------------------
    CMP AL, ' '
    JE  IS_SPACE

    CMP AL, '0'
    JB  IS_OTHER
    CMP AL, '9'
    JBE IS_DIGIT

    CMP AL, 'A'
    JB  IS_OTHER
    CMP AL, 'Z'
    JBE IS_UPPER

    CMP AL, 'a'
    JB  IS_OTHER
    CMP AL, 'z'
    JBE IS_LOWER

IS_OTHER:
    INC WORD PTR N_OTHER
    JMP NEXT_CHAR

IS_SPACE:
    INC WORD PTR N_SPACE
    JMP NEXT_CHAR

IS_DIGIT:
    INC WORD PTR N_DIGIT
    JMP NEXT_CHAR

IS_UPPER:
    INC WORD PTR N_UPPER
    JMP NEXT_CHAR

IS_LOWER:
    INC WORD PTR N_LOWER

NEXT_CHAR:
    INC SI
    LOOP CLASSIFY

    ; Report each in turn. Nothing needed by the reports is in a register.
    LEA DX, M_UPPER
    MOV AX, N_UPPER
    CALL SHOW_COUNT

    LEA DX, M_LOWER
    MOV AX, N_LOWER
    CALL SHOW_COUNT

    LEA DX, M_DIGIT
    MOV AX, N_DIGIT
    CALL SHOW_COUNT

    LEA DX, M_SPACE
    MOV AX, N_SPACE
    CALL SHOW_COUNT

    LEA DX, M_OTHER
    MOV AX, N_OTHER
    CALL SHOW_COUNT

    MOV AH, 4CH
    INT 21H

; -----------------------------------------------------------------------------
; SHOW_COUNT
;
; Prints the label at DS:DX followed by the value in AX. The value is stacked
; before the DOS call, because AH is the top half of the number being printed.
; -----------------------------------------------------------------------------
SHOW_COUNT PROC
    PUSH AX

    MOV AH, 09H
    INT 21H

    POP AX
    CALL PRINT_DECIMAL
    CALL NEWLINE
    RET
SHOW_COUNT ENDP

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
; 1. THE ORDER OF THE TESTS MATTERS:
;    - Digits come before letters in ASCII, so testing for them first
;    - means each range test can assume everything smaller has already
;    - been dealt with.
; 2. THE LAST COUNT IS FREE:
;    - Anything not in the four categories is the length less the other
;    - four totals, so it needs no counter and cannot disagree with them.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
