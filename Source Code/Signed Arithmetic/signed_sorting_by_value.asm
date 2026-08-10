; =============================================================================
; TITLE: Sorting Signed Values
; DESCRIPTION: Sorts an array containing negatives into order, which needs the
;              signed comparison an unsigned sort would get wrong.
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
    VALUES  DW 14, -30, 7, -1, 22, -18
    HOWMANY EQU 6
    M_BEFORE DB 'Before: $'
    M_AFTER  DB 'After:  $'
    SPACE    DB ' $'

; -----------------------------------------------------------------------------
; CODE SEGMENT
; -----------------------------------------------------------------------------
.CODE
START:
    MOV AX, @DATA
    MOV DS, AX

    LEA DX, M_BEFORE
    MOV AH, 09H
    INT 21H
    CALL SHOW_ARRAY

    ; -------------------------------------------------------------------------
    ; A BUBBLE SORT WHOSE ONLY SIGNED PART IS THE COMPARISON. USING JBE HERE
    ; WOULD SORT BY BIT PATTERN AND PUT EVERY NEGATIVE VALUE AT THE END.
    ; -------------------------------------------------------------------------
    MOV CX, HOWMANY
    DEC CX

OUTER_PASS:
    PUSH CX
    LEA SI, VALUES

INNER_PASS:
    MOV AX, [SI]
    CMP AX, [SI+2]
    JLE IN_ORDER                        ; Signed: less or equal is fine

    XCHG AX, [SI+2]
    MOV [SI], AX

IN_ORDER:
    ADD SI, 2
    LOOP INNER_PASS

    POP CX
    LOOP OUTER_PASS

    LEA DX, M_AFTER
    MOV AH, 09H
    INT 21H
    CALL SHOW_ARRAY

    MOV AH, 4CH
    INT 21H

; -----------------------------------------------------------------------------
; SHOW_ARRAY
;
; Prints every element on one line, then moves to the next.
; -----------------------------------------------------------------------------
SHOW_ARRAY PROC
    PUSH AX
    PUSH CX
    PUSH DX
    PUSH SI

    LEA SI, VALUES
    MOV CX, HOWMANY

SA_LOOP:
    MOV AX, [SI]
    PUSH CX
    PUSH SI
    CALL PRINT_SIGNED
    LEA DX, SPACE
    MOV AH, 09H
    INT 21H
    POP SI
    POP CX
    ADD SI, 2
    LOOP SA_LOOP

    CALL NEWLINE

    POP SI
    POP DX
    POP CX
    POP AX
    RET
SHOW_ARRAY ENDP

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
; 1. ONE INSTRUCTION DECIDES THE WHOLE SORT:
;    - Everything else about a bubble sort is the same for signed and
;    - unsigned data. Only the branch after the compare has to change.
; 2. THE SYMPTOM WHEN IT IS WRONG:
;    - The output looks sorted but every negative value is at the far
;    - end, because as unsigned patterns they are the largest.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
