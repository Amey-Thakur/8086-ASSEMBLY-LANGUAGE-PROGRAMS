; =============================================================================
; TITLE: Where a Value Would Belong
; DESCRIPTION: Finds the position at which a value should be inserted to keep
;              an array sorted, whether or not it is already present.
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
    SORTED  DW 5, 12, 19, 26, 33, 40
    HOWMANY EQU 6

    TRIALS  DW 1, 19, 30, 50
    COUNT   EQU 4

    M_ARRAY DB 'Sorted: $'
    M_WOULD DB ' would go at index $'
    CRLF    DB 0DH, 0AH, '$'

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

    LEA SI, TRIALS
    MOV CX, COUNT

EACH_TRIAL:
    MOV BP, [SI]

    PUSH CX
    PUSH SI

    MOV AX, BP
    CALL PRINT_DECIMAL

    CALL INSERTION_POINT

    PUSH AX
    LEA DX, M_WOULD
    MOV AH, 09H
    INT 21H
    POP AX
    CALL PRINT_DECIMAL
    CALL NEWLINE

    POP SI
    POP CX
    ADD SI, 2
    LOOP EACH_TRIAL

    MOV AX, 4C00H
    INT 21H

; -----------------------------------------------------------------------------
; INSERTION_POINT
;
; Returns in AX the index at which BP belongs.
;
; The search deliberately has no equality case: it narrows until the two
; bounds meet, and where they meet is the answer. That is what makes it work
; for values that are absent as well as present.
; -----------------------------------------------------------------------------
INSERTION_POINT PROC
    PUSH BX
    PUSH CX
    PUSH DX

    XOR BX, BX                          ; low
    MOV DX, HOWMANY                     ; high, one past the end

IP_LOOP:
    CMP BX, DX
    JAE IP_DONE

    MOV CX, BX
    ADD CX, DX
    SHR CX, 1

    MOV SI, CX
    SHL SI, 1
    MOV AX, SORTED[SI]

    CMP AX, BP
    JAE IP_GO_LEFT

    MOV BX, CX                          ; Everything up to here is smaller
    INC BX
    JMP IP_LOOP

IP_GO_LEFT:
    MOV DX, CX                          ; This one is not smaller, so it could
    JMP IP_LOOP                         ; be the answer; keep it in range

IP_DONE:
    MOV AX, BX

    POP DX
    POP CX
    POP BX
    RET
INSERTION_POINT ENDP

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
; 1. NO EQUALITY CASE AT ALL:
;    - The loop never asks whether it has found the value. It narrows
;    - until the bounds meet, and that point is the answer whether the
;    - value is present or not.
; 2. THE HIGH BOUND IS ONE PAST THE END:
;    - So a value larger than everything answers the length rather than
;    - the last index. That is the position it would be appended at.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
