; =============================================================================
; TITLE: Smallest and Largest Signed Values
; DESCRIPTION: Finds the extremes of a signed array, using the signed branches
;              that a set containing negatives requires.
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
    READINGS DW -12, 45, -80, 3, 27, -5
    HOWMANY  EQU 6
    M_MIN    DB 'Lowest:  $'
    M_MAX    DB 'Highest: $'

; -----------------------------------------------------------------------------
; CODE SEGMENT
; -----------------------------------------------------------------------------
.CODE
START:
    MOV AX, @DATA
    MOV DS, AX

    LEA SI, READINGS
    MOV BX, [SI]                        ; Assume the first is both
    MOV DI, [SI]
    MOV CX, HOWMANY
    DEC CX                              ; It has already been considered
    ADD SI, 2

SCAN_LOOP:
    MOV AX, [SI]

    ; -------------------------------------------------------------------------
    ; JL AND JG, NOT JB AND JA. THE UNSIGNED BRANCHES WOULD PUT -80 ABOVE 45,
    ; BECAUSE ITS BIT PATTERN IS THE LARGER NUMBER.
    ; -------------------------------------------------------------------------
    CMP AX, BX
    JGE NOT_LOWER
    MOV BX, AX

NOT_LOWER:
    CMP AX, DI
    JLE NOT_HIGHER
    MOV DI, AX

NOT_HIGHER:
    ADD SI, 2
    LOOP SCAN_LOOP

    LEA DX, M_MIN
    MOV AH, 09H
    INT 21H
    MOV AX, BX
    CALL PRINT_SIGNED
    CALL NEWLINE

    LEA DX, M_MAX
    MOV AH, 09H
    INT 21H
    MOV AX, DI
    CALL PRINT_SIGNED
    CALL NEWLINE

    MOV AH, 4CH
    INT 21H

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
; 1. STARTING FROM THE FIRST ELEMENT:
;    - Beginning with zero would be wrong for an array where every value
;    - is negative. Taking the first element as both extremes needs no
;    - assumption about the data.
; 2. THE COUNT IS ONE SHORT:
;    - The first element has already been used, so the loop examines the
;    - remaining five. Forgetting the DEC compares it against itself,
;    - which is harmless here but reads past the array.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
