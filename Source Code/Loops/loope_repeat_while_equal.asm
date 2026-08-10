; =============================================================================
; TITLE: LOOPE: Repeat While Equal
; DESCRIPTION: Scans a run of bytes for the first one that is not a space,
;              stopping either at the difference or when the count runs out.
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
    LINE    DB '     Amey'
    LENGTH  EQU 9
    MSG     DB 'Leading spaces: $'

; -----------------------------------------------------------------------------
; CODE SEGMENT
; -----------------------------------------------------------------------------
.CODE
START:
    MOV AX, @DATA
    MOV DS, AX

    LEA SI, LINE
    MOV CX, LENGTH
    XOR BX, BX                          ; How many spaces have been seen

    ; -------------------------------------------------------------------------
    ; LOOPE CONTINUES ONLY WHILE TWO CONDITIONS HOLD: CX IS STILL NON ZERO
    ; AND THE ZERO FLAG IS STILL SET. THE BODY SETS ZF BY COMPARING, SO THE
    ; LOOP RUNS WHILE THE CHARACTERS KEEP MATCHING.
    ; -------------------------------------------------------------------------
SCAN:
    CMP BYTE PTR [SI], ' '
    JNE FOUND                           ; Stop before counting a non space

    INC BX
    INC SI
    CMP BYTE PTR [SI], ' '              ; Set ZF for LOOPE to read
    LOOPE SCAN

FOUND:
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
; 1. TWO EXITS, ONE INSTRUCTION:
;    - LOOPE leaves either because the count reached zero or because the
;    - comparison failed. Which one happened has to be worked out
;    - afterwards, usually by testing CX or the flags.
; 2. THE FLAGS MUST BE FRESH:
;    - LOOPE reads ZF as it stands when the instruction executes, so the
;    - comparison has to be the last thing the body does.
; 3. LOOPZ IS THE SAME INSTRUCTION:
;    - As with JE and JZ, the two names describe the same test from two
;    - points of view.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
