; =============================================================================
; TITLE: Sorting an Array of Bytes
; DESCRIPTION: Sorts byte sized values, where the stride is one and the
;              comparison is eight bits wide.
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
    BYTES    DB 52, 11, 87, 3, 66, 24, 90, 15
    HOWMANY  EQU 8
    M_BEFORE DB 'Before: $'
    M_AFTER  DB 'After:  $'

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
    CALL SHOW_BYTES

    ; -------------------------------------------------------------------------
    ; EVERYTHING IS THE SAME AS THE WORD VERSION EXCEPT THAT THE POINTER
    ; ADVANCES BY ONE AND THE COMPARISON USES AL RATHER THAN AX.
    ; -------------------------------------------------------------------------
    MOV CX, HOWMANY
    DEC CX

OUTER:
    PUSH CX
    LEA SI, BYTES

INNER_PASS:
    MOV AL, [SI]
    CMP AL, [SI+1]
    JBE IN_ORDER

    XCHG AL, [SI+1]
    MOV [SI], AL

IN_ORDER:
    INC SI
    LOOP INNER_PASS

    POP CX
    LOOP OUTER

    LEA DX, M_AFTER
    MOV AH, 09H
    INT 21H
    CALL SHOW_BYTES

    MOV AH, 4CH
    INT 21H

; -----------------------------------------------------------------------------
; SHOW_BYTES
; -----------------------------------------------------------------------------
SHOW_BYTES PROC
    PUSH AX
    PUSH CX
    PUSH DX
    PUSH SI

    LEA SI, BYTES
    MOV CX, HOWMANY

SB_LOOP:
    MOV AL, [SI]
    XOR AH, AH
    PUSH CX
    PUSH SI
    CALL PRINT_DECIMAL
    MOV DL, ' '
    MOV AH, 02H
    INT 21H
    POP SI
    POP CX
    INC SI
    LOOP SB_LOOP

    CALL NEWLINE

    POP SI
    POP DX
    POP CX
    POP AX
    RET
SHOW_BYTES ENDP

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
; 1. THE STRIDE FOLLOWS THE ELEMENT:
;    - One byte per element means INC SI rather than ADD SI, 2. Using
;    - the word stride on a byte array reads every other element and
;    - produces a result that is sorted but wrong.
; 2. XCHG WORKS ON BYTES TOO:
;    - XCHG AL, [SI+1] exchanges a byte register with a byte in memory,
;    - exactly as the word form does.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
