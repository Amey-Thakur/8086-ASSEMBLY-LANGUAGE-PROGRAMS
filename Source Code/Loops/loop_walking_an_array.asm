; =============================================================================
; TITLE: Walking an Array with a Pointer
; DESCRIPTION: Combines a counter in CX with a pointer in SI, the standard shape
;              of every array loop on this processor.
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
    NUMBERS DW 14, 3, 27, 8, 41, 6
    HOWMANY EQU 6
    MSG     DB 'Total: $'
    SEP     DB ' + $'

; -----------------------------------------------------------------------------
; CODE SEGMENT
; -----------------------------------------------------------------------------
.CODE
START:
    MOV AX, @DATA
    MOV DS, AX

    LEA SI, NUMBERS                     ; Where we are
    MOV CX, HOWMANY                     ; How many are left
    XOR BX, BX                          ; Running total

SUM_LOOP:
    ADD BX, [SI]
    ADD SI, 2                           ; Words, so two bytes at a time
    LOOP SUM_LOOP

    LEA DX, MSG
    MOV AH, 09H
    INT 21H
    MOV AX, BX
    CALL PRINT_DECIMAL
    CALL NEWLINE

    MOV AH, 4CH
    INT 21H

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
; 1. TWO THINGS CHANGE EACH PASS:
;    - The count comes down and the pointer goes up. LOOP handles the
;    - first; the second is the ADD SI, 2 that is easy to forget.
; 2. THE STRIDE IS THE ELEMENT SIZE:
;    - Two for a word array, one for a byte array. Using the wrong stride
;    - reads each element half or twice and produces a plausible but
;    - wrong answer.
; 3. WHY NOT INDEX FROM ZERO:
;    - A pointer that advances is cheaper than recomputing base plus
;    - index times size on every pass. It is the reason C has pointer
;    - arithmetic at all.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
