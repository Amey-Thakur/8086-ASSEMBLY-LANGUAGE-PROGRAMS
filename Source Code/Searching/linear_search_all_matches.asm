; =============================================================================
; TITLE: Finding Every Match
; DESCRIPTION: Reports all the positions holding a value rather than stopping
;              at the first, and counts them.
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
    DATA_W  DW 7, 3, 7, 9, 7, 2, 5, 7
    HOWMANY EQU 8
    WANTED  DW 7

    M_ARRAY DB 'The array: $'
    M_FOUND DB '7 is at indices $'
    M_COUNT DB '   count: $'
    M_NONE  DB 'not present', 0DH, 0AH, '$'

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

    LEA DX, M_FOUND
    MOV AH, 09H
    INT 21H

    ; -------------------------------------------------------------------------
    ; THE ONLY DIFFERENCE FROM AN ORDINARY LINEAR SEARCH IS THAT IT DOES NOT
    ; STOP. THE FIRST MATCH IS REPORTED AND THE SCAN CONTINUES, WHICH IS WHY
    ; THE WHOLE ARRAY IS ALWAYS READ.
    ; -------------------------------------------------------------------------
    LEA SI, DATA_W
    XOR BX, BX                          ; The index
    XOR BP, BP                          ; How many were found
    MOV CX, HOWMANY

SCAN:
    MOV AX, [SI]
    CMP AX, WANTED
    JNE NOT_THIS_ONE

    INC BP
    PUSH BX
    PUSH CX
    PUSH SI
    MOV AX, BX
    CALL PRINT_DECIMAL
    MOV DL, ' '
    MOV AH, 02H
    INT 21H
    POP SI
    POP CX
    POP BX

NOT_THIS_ONE:
    ADD SI, 2
    INC BX
    LOOP SCAN

    OR  BP, BP
    JNZ SHOW_COUNT

    LEA DX, M_NONE
    MOV AH, 09H
    INT 21H
    JMP FINISHED

SHOW_COUNT:
    PUSH BP
    LEA DX, M_COUNT
    MOV AH, 09H
    INT 21H
    POP AX
    CALL PRINT_DECIMAL
    CALL NEWLINE

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
; 1. NO EARLY EXIT IS POSSIBLE:
;    - Proving that no further match exists requires reading to the end,
;    - so this always costs the full length. Only a search for the first
;    - match can stop early.
; 2. ON SORTED DATA THERE IS A BETTER WAY:
;    - Two bisections find both ends of the run, which is logarithmic
;    - rather than linear. This method is for data with no order at all.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
