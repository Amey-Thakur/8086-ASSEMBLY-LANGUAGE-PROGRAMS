; =============================================================================
; TITLE: Comparing Strings with REPE CMPSB
; DESCRIPTION: Decides whether two strings are identical, and where they first
;              differ, in a handful of instructions.
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
    FIRST   DB 'ASSEMBLY'
    SECOND  DB 'ASSEMBLE'
    THIRD   DB 'ASSEMBLY'
    LENGTH  EQU 8
    M_SAME  DB 'The first and third are identical.', 0DH, 0AH, '$'
    M_DIFF  DB 'The first and second differ at position $'

; -----------------------------------------------------------------------------
; CODE SEGMENT
; -----------------------------------------------------------------------------
.CODE
START:
    MOV AX, @DATA
    MOV DS, AX
    MOV ES, AX

    ; -------------------------------------------------------------------------
    ; REPE CMPSB KEEPS GOING WHILE THE BYTES MATCH AND CX IS NOT EXHAUSTED.
    ; WHEN IT STOPS, ZF SAYS WHICH REASON APPLIED: SET MEANS THE STRINGS RAN
    ; OUT WHILE STILL EQUAL, CLEAR MEANS A DIFFERENCE WAS FOUND.
    ; -------------------------------------------------------------------------
    LEA SI, FIRST
    LEA DI, THIRD
    MOV CX, LENGTH
    CLD
    REPE CMPSB
    JNE NOT_IDENTICAL

    LEA DX, M_SAME
    MOV AH, 09H
    INT 21H

NOT_IDENTICAL:
    LEA SI, FIRST
    LEA DI, SECOND
    MOV CX, LENGTH
    CLD
    REPE CMPSB
    JE  FINISH                          ; They matched after all

    ; -------------------------------------------------------------------------
    ; CX HOLDS HOW MANY WERE STILL TO COME, SO THE POSITION OF THE DIFFERENCE
    ; IS THE LENGTH LESS CX, LESS THE ONE JUST EXAMINED.
    ; -------------------------------------------------------------------------
    MOV AX, LENGTH
    SUB AX, CX
    DEC AX
    MOV BX, AX

    LEA DX, M_DIFF
    MOV AH, 09H
    INT 21H
    MOV AX, BX
    CALL PRINT_DECIMAL
    CALL NEWLINE

FINISH:
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
; 1. READING THE POSITION FROM CX:
;    - The count is what remains, so subtracting it from the length gives
;    - how far the comparison got. One more has to come off because the
;    - element that differed was already consumed.
; 2. THIS IS NOT AN ORDERING:
;    - CMPSB says where two strings diverge, not which sorts first. For
;    - that, the flags from the final comparison are read with JB or JA.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
