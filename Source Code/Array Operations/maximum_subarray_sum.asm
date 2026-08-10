; =============================================================================
; TITLE: Largest Sum of Any Run
; DESCRIPTION: Finds the run of consecutive elements with the greatest total,
;              in one pass, using Kadane's method.
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
    DATA_W  DW -2, 1, -3, 4, -1, 2, 1, -5, 4
    HOWMANY EQU 9

    M_ARRAY DB 'The array:  $'
    M_BEST  DB 'Best total: $'
    M_FROM  DB '   from index $'
    M_TO    DB ' to $'

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
    LEA SI, DATA_W
    MOV CX, HOWMANY
    CALL SHOW_RUN

    ; -------------------------------------------------------------------------
    ; THE INSIGHT: AT EACH ELEMENT THE BEST RUN ENDING THERE IS EITHER THAT
    ; ELEMENT ALONE, OR THAT ELEMENT ADDED TO THE BEST RUN ENDING JUST BEFORE
    ; IT. WHICHEVER IS LARGER. NOTHING ELSE HAS TO BE CONSIDERED, WHICH IS WHY
    ; ONE PASS IS ENOUGH WHERE TRYING EVERY RUN WOULD TAKE THE SQUARE.
    ; -------------------------------------------------------------------------
    LEA SI, DATA_W
    MOV AX, [SI]
    MOV BX, AX                          ; The best run ending here
    MOV DI, AX                          ; The best run anywhere
    MOV BP, 0                           ; Where the current run started
    MOV WORD PTR BEST_FROM, 0
    MOV WORD PTR BEST_TO, 0

    MOV CX, HOWMANY
    DEC CX
    ADD SI, 2
    MOV DX, 1                           ; The index being examined

SCAN:
    JCXZ REPORT

    MOV AX, [SI]

    ; Is it better to extend the run, or to start again here?
    PUSH AX
    ADD AX, BX
    CMP AX, [SI]
    JGE EXTEND

    POP AX                              ; Start afresh at this element
    MOV BX, AX
    MOV BP, DX
    JMP COMPARE_BEST

EXTEND:
    MOV BX, AX                          ; The extended run
    POP AX

COMPARE_BEST:
    CMP BX, DI
    JLE NOT_BETTER

    MOV DI, BX
    MOV BEST_FROM, BP
    MOV BEST_TO, DX

NOT_BETTER:
    ADD SI, 2
    INC DX
    DEC CX
    JMP SCAN

REPORT:
    LEA DX, M_BEST
    MOV AH, 09H
    INT 21H
    MOV AX, DI
    CALL PRINT_SIGNED

    LEA DX, M_FROM
    MOV AH, 09H
    INT 21H
    MOV AX, BEST_FROM
    CALL PRINT_DECIMAL

    LEA DX, M_TO
    MOV AH, 09H
    INT 21H
    MOV AX, BEST_TO
    CALL PRINT_DECIMAL
    CALL NEWLINE

    MOV AX, 4C00H
    INT 21H

; -----------------------------------------------------------------------------
; Where the best run was found. Kept in memory because DX and BP are both
; needed for the scan itself.
; -----------------------------------------------------------------------------
BEST_FROM DW 0
BEST_TO   DW 0

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
; 1. WHY ONE PASS SUFFICES:
;    - A run that ends at a given element either includes the element
;    - before it or does not. Both possibilities are already summarised in
;    - one number, so nothing earlier has to be revisited.
; 2. ALL NEGATIVE VALUES:
;    - The best run is then the single least negative element, which this
;    - version reports correctly because it starts from the first element
;    - rather than from zero. Starting from zero would answer nought.
; 3. SIGNED COMPARISONS THROUGHOUT:
;    - JGE and JLE, not JAE and JBE. The array contains negatives and the
;    - running totals go negative, so an unsigned comparison would
;    - consider -2 larger than 4.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
