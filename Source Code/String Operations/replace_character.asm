; =============================================================================
; TITLE: Replace Every Occurrence of a Character
; DESCRIPTION: Substitutes one character for another throughout a string, and
;              counts how many replacements were made.
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
    TEXT    DB 'data_transfer_and_string_operations'
    TEXTLEN EQU $ - TEXT
    FIND_C  DB '_'
    PUT_C   DB ' '
    M_IN    DB 'Before: $'
    M_OUT   DB 'After:  $'
    M_COUNT DB 'Replacements: $'

; -----------------------------------------------------------------------------
; CODE SEGMENT
; -----------------------------------------------------------------------------
.CODE
START:
    MOV AX, @DATA
    MOV DS, AX

    LEA DX, M_IN
    MOV AH, 09H
    INT 21H
    LEA SI, TEXT
    MOV CX, TEXTLEN
    CALL PRINT_TEXT
    CALL NEWLINE

    LEA SI, TEXT
    MOV CX, TEXTLEN
    MOV AL, FIND_C
    MOV BL, PUT_C
    XOR DI, DI                          ; How many were replaced

REPLACE:
    CMP [SI], AL
    JNE NOT_THIS_ONE

    MOV [SI], BL
    INC DI

NOT_THIS_ONE:
    INC SI
    LOOP REPLACE

    LEA DX, M_OUT
    MOV AH, 09H
    INT 21H
    LEA SI, TEXT
    MOV CX, TEXTLEN
    CALL PRINT_TEXT
    CALL NEWLINE

    LEA DX, M_COUNT
    MOV AH, 09H
    INT 21H
    MOV AX, DI
    CALL PRINT_DECIMAL
    CALL NEWLINE

    MOV AH, 4CH
    INT 21H

; -----------------------------------------------------------------------------
; PRINT_TEXT
;
; Prints CX characters starting at DS:SI. Both are left as they were found.
; -----------------------------------------------------------------------------
PRINT_TEXT PROC
    PUSH AX
    PUSH CX
    PUSH DX
    PUSH SI

    JCXZ PT_DONE                        ; Nothing to print

PT_LOOP:
    MOV DL, [SI]
    MOV AH, 02H
    INT 21H
    INC SI
    LOOP PT_LOOP

PT_DONE:
    POP SI
    POP DX
    POP CX
    POP AX
    RET
PRINT_TEXT ENDP

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
; 1. SAME LENGTH, SO IN PLACE:
;    - One character for one character means nothing has to move.
;    - Replacing a character with a longer sequence would need a second
;    - buffer and a different algorithm entirely.
; 2. CMP AGAINST A REGISTER:
;    - Holding the character being sought in AL rather than reading it
;    - from memory on every pass saves a memory access per character.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
