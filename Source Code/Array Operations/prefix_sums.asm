; =============================================================================
; TITLE: Prefix Sums and Range Totals
; DESCRIPTION: Builds a table of running totals once, so that the sum of any
;              stretch of the array afterwards costs one subtraction.
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
    DATA_W  DW 3, 8, 2, 6, 4, 9, 1, 7
    HOWMANY EQU 8

    ; One longer than the array, so that a total up to element nought is
    ; nought and no range needs a special case.
    PREFIX  DW HOWMANY + 1 DUP(0)

    M_ARRAY DB 'The array:    $'
    M_PREFIX DB 'Prefix sums:  $'
    M_RANGE DB 'Sum of elements 2 to 5: $'
    M_CHECK DB 'The same by adding them up: $'

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
    ; EACH PREFIX IS THE ONE BEFORE IT PLUS THE NEXT ELEMENT, SO THE WHOLE
    ; TABLE IS BUILT IN ONE PASS. PREFIX[K] IS THE TOTAL OF THE FIRST K
    ; ELEMENTS, WHICH IS WHY THE TABLE IS ONE LONGER THAN THE ARRAY.
    ; -------------------------------------------------------------------------
    LEA SI, DATA_W
    LEA DI, PREFIX
    MOV WORD PTR [DI], 0
    MOV CX, HOWMANY

BUILD:
    MOV AX, [DI]
    ADD AX, [SI]
    ADD DI, 2
    MOV [DI], AX

    ADD SI, 2
    LOOP BUILD

    LEA DX, M_PREFIX
    MOV AH, 09H
    INT 21H
    LEA SI, PREFIX
    MOV CX, HOWMANY + 1
    CALL SHOW_RUN

    ; -------------------------------------------------------------------------
    ; THE TOTAL FROM ELEMENT A TO ELEMENT B IS PREFIX[B+1] LESS PREFIX[A]. ONE
    ; SUBTRACTION, HOWEVER LONG THE RANGE, WHICH IS THE ENTIRE POINT OF HAVING
    ; BUILT THE TABLE.
    ; -------------------------------------------------------------------------
    MOV SI, 6 * 2                       ; PREFIX[6], being B plus one
    MOV AX, PREFIX[SI]
    MOV SI, 2 * 2                       ; PREFIX[2], being A
    SUB AX, PREFIX[SI]
    MOV BP, AX

    LEA DX, M_RANGE
    MOV AH, 09H
    INT 21H
    MOV AX, BP
    CALL PRINT_DECIMAL
    CALL NEWLINE

    ; The slow way, for comparison
    LEA SI, DATA_W
    ADD SI, 2 * 2
    MOV CX, 4                           ; Elements two, three, four and five
    XOR BX, BX

ADD_UP:
    ADD BX, [SI]
    ADD SI, 2
    LOOP ADD_UP

    LEA DX, M_CHECK
    MOV AH, 09H
    INT 21H
    MOV AX, BX
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
; 1. WHY THE TABLE IS ONE LONGER:
;    - A leading nought means the sum from element nought needs no special
;    - handling. Without it every range starting at the front would be a
;    - separate case.
; 2. BUILT ONCE, USED MANY TIMES:
;    - One pass to build and then one subtraction per question. For a
;    - single range it is not worth it; for hundreds of them it is the
;    - difference between instant and slow.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
