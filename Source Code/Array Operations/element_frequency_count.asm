; =============================================================================
; TITLE: How Often Each Element Appears
; DESCRIPTION: Counts the occurrences of every distinct value, marking those
;              already reported so none is counted twice.
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
    DATA_W  DW 4, 7, 4, 2, 7, 4, 9, 2
    HOWMANY EQU 8
    DONE_   DB HOWMANY DUP(0)           ; Which positions have been reported

    M_ARRAY DB 'The array: $'
    M_HEAD  DB 'value  times', 0DH, 0AH, '$'
    GAP     DB '      $'

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

    LEA DX, M_HEAD
    MOV AH, 09H
    INT 21H

    ; -------------------------------------------------------------------------
    ; FOR EACH POSITION NOT YET DEALT WITH, COUNT HOW MANY LATER POSITIONS
    ; HOLD THE SAME VALUE AND MARK THEM ALL. THE MARKS ARE WHAT STOPS THE
    ; SECOND FOUR FROM BEING REPORTED AGAIN AS A FRESH VALUE.
    ; -------------------------------------------------------------------------
    XOR BX, BX                          ; The position being considered

OUTER:
    CMP BX, HOWMANY
    JAE FINISHED

    CMP BYTE PTR DONE_[BX], 0
    JNE NEXT_OUTER                      ; Already counted with an earlier one

    MOV SI, BX
    SHL SI, 1
    MOV BP, DATA_W[SI]                  ; The value being counted
    MOV DI, 1                           ; It occurs at least here

    MOV CX, BX
    INC CX                              ; Start looking at the next one

INNER_SCAN:
    CMP CX, HOWMANY
    JAE REPORT_VALUE

    MOV SI, CX
    SHL SI, 1
    MOV AX, DATA_W[SI]
    CMP AX, BP
    JNE NEXT_INNER

    INC DI
    MOV SI, CX
    MOV BYTE PTR DONE_[SI], 1           ; Mark it so it is not reported again

NEXT_INNER:
    INC CX
    JMP INNER_SCAN

REPORT_VALUE:
    PUSH BX
    MOV AX, BP
    CALL PRINT_DECIMAL
    LEA DX, GAP
    MOV AH, 09H
    INT 21H
    MOV AX, DI
    CALL PRINT_DECIMAL
    CALL NEWLINE
    POP BX

NEXT_OUTER:
    INC BX
    JMP OUTER

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
; 1. MARKING BEATS SEARCHING:
;    - The alternative is to check, before reporting a value, whether it
;    - appeared earlier. Marking as we go answers the same question with
;    - one byte per element and no second search.
; 2. WHEN A TALLY IS BETTER:
;    - If the values are small and bounded, one counter per possible value
;    - turns this into a single pass. That is counting sort, and it needs
;    - to know the range in advance.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
