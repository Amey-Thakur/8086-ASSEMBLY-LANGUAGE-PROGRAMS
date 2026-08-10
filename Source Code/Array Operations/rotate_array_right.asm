; =============================================================================
; TITLE: Rotating an Array Right
; DESCRIPTION: The mirror of the left rotation, which is the same three
;              reversals with the split in the other place.
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
    DATA_W  DW 1, 2, 3, 4, 5, 6, 7
    HOWMANY EQU 7
    SHIFT   EQU 2

    M_BEFORE DB 'Before:  $'
    M_AFTER  DB 'After 2: $'

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
    LEA SI, DATA_W
    MOV CX, HOWMANY
    CALL SHOW_RUN

    ; -------------------------------------------------------------------------
    ; ROTATING RIGHT BY TWO IS ROTATING LEFT BY FIVE, SO THE SPLIT GOES AT THE
    ; COUNT LESS THE SHIFT RATHER THAN AT THE SHIFT. THAT ONE SUBTRACTION IS
    ; THE WHOLE DIFFERENCE BETWEEN THE TWO DIRECTIONS.
    ; -------------------------------------------------------------------------
    LEA SI, DATA_W
    MOV CX, HOWMANY - SHIFT
    CALL REVERSE_RUN

    LEA SI, DATA_W
    ADD SI, (HOWMANY - SHIFT) * 2
    MOV CX, SHIFT
    CALL REVERSE_RUN

    LEA SI, DATA_W
    MOV CX, HOWMANY
    CALL REVERSE_RUN

    LEA DX, M_AFTER
    MOV AH, 09H
    INT 21H
    LEA SI, DATA_W
    MOV CX, HOWMANY
    CALL SHOW_RUN

    MOV AX, 4C00H
    INT 21H

; -----------------------------------------------------------------------------
; REVERSE_RUN
; -----------------------------------------------------------------------------
REVERSE_RUN PROC
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH SI
    PUSH DI

    CMP CX, 1
    JBE RR_DONE

    MOV DI, SI
    ADD DI, CX
    ADD DI, CX
    SUB DI, 2
    SHR CX, 1

RR_SWAP:
    MOV AX, [SI]
    MOV BX, [DI]
    MOV [SI], BX
    MOV [DI], AX
    ADD SI, 2
    SUB DI, 2
    LOOP RR_SWAP

RR_DONE:
    POP DI
    POP SI
    POP CX
    POP BX
    POP AX
    RET
REVERSE_RUN ENDP

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
; 1. RIGHT BY K IS LEFT BY N MINUS K:
;    - So one routine covers both, given the right split point. A rotation
;    - by more than the length is a rotation by the remainder.
; 2. A SHIFT OF ZERO OR N:
;    - Both leave the array unchanged, and both make one of the two
;    - reversals empty. The guard on a count of one or fewer is what makes
;    - that safe rather than a bug.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
