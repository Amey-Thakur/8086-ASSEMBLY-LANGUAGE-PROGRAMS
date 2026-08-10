; =============================================================================
; TITLE: Counting Occurrences of a Character
; DESCRIPTION: Counts how many times a character appears, repeating the search
;              from where the previous one stopped.
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
    TEXT    DB 'the assessment of the system'
    LENGTH  EQU 28
    WANTED  DB 's'
    M_COUNT DB "The letter 's' appears $"
    M_TAIL  DB ' times', 0DH, 0AH, '$'

; -----------------------------------------------------------------------------
; CODE SEGMENT
; -----------------------------------------------------------------------------
.CODE
START:
    MOV AX, @DATA
    MOV DS, AX
    MOV ES, AX

    LEA DI, TEXT
    MOV CX, LENGTH
    MOV AL, WANTED
    XOR BX, BX                          ; The running count
    CLD

    ; -------------------------------------------------------------------------
    ; EACH REPNE SCASB STOPS AT THE FIRST MATCH AND LEAVES DI JUST PAST IT,
    ; SO THE SEARCH CAN SIMPLY BE REPEATED. CX ALREADY HOLDS HOW MUCH IS
    ; LEFT, WHICH IS WHY NOTHING HAS TO BE RECOMPUTED BETWEEN PASSES.
    ; -------------------------------------------------------------------------
COUNT_LOOP:
    JCXZ DONE_COUNTING                  ; Nothing left to search
    REPNE SCASB
    JNE DONE_COUNTING                   ; Ran out without a match

    INC BX
    JMP COUNT_LOOP

DONE_COUNTING:
    LEA DX, M_COUNT
    MOV AH, 09H
    INT 21H
    MOV AX, BX
    CALL PRINT_DECIMAL
    LEA DX, M_TAIL
    MOV AH, 09H
    INT 21H

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
; 1. THE STATE CARRIES BETWEEN SEARCHES:
;    - DI and CX are left exactly where the next search should begin, so
;    - repeating the instruction continues rather than starting again.
; 2. THE JCXZ GUARD:
;    - Without it, a match on the very last character would leave CX at
;    - zero and the next REPNE would run 65536 times.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
