; =============================================================================
; TITLE: Absolute Value
; DESCRIPTION: Takes the magnitude of several signed values, and names the one
;              input for which the operation cannot succeed.
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
    VALUES  DW -47, 0, 190, -1
    HOWMANY EQU 4
    ARROW   DB ' -> $'
    M_EDGE  DB '-32768 has no positive counterpart in a word.', 0DH, 0AH, '$'

; -----------------------------------------------------------------------------
; CODE SEGMENT
; -----------------------------------------------------------------------------
.CODE
START:
    MOV AX, @DATA
    MOV DS, AX

    LEA SI, VALUES
    MOV CX, HOWMANY

ABS_LOOP:
    MOV AX, [SI]

    PUSH CX
    PUSH SI
    PUSH AX

    CALL PRINT_SIGNED
    LEA DX, ARROW
    MOV AH, 09H
    INT 21H

    ; -------------------------------------------------------------------------
    ; ONLY NEGATIVE VALUES NEED CHANGING, SO THE SIGN IS TESTED FIRST AND NEG
    ; IS SKIPPED ENTIRELY WHEN THE VALUE IS ALREADY POSITIVE.
    ; -------------------------------------------------------------------------
    POP AX
    OR  AX, AX
    JNS ALREADY_POSITIVE
    NEG AX

ALREADY_POSITIVE:
    CALL PRINT_SIGNED
    CALL NEWLINE

    POP SI
    POP CX
    ADD SI, 2
    LOOP ABS_LOOP

    LEA DX, M_EDGE
    MOV AH, 09H
    INT 21H

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
; 1. THE ONE VALUE THAT FAILS:
;    - NEG on 8000h gives 8000h back, because +32768 has no encoding.
;    - The overflow flag is set to say so, and code that matters should
;    - test it.
; 2. THE BRANCHLESS ALTERNATIVE:
;    - CWD then XOR AX, DX then SUB AX, DX gives the same answer with no
;    - branch at all, which is faster where the sign is unpredictable.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
