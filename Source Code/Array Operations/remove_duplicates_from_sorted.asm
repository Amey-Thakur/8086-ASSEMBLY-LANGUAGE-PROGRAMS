; =============================================================================
; TITLE: Removing Duplicates from a Sorted Array
; DESCRIPTION: Compacts a sorted array so each value appears once, which needs
;              only one comparison per element because equal values are adjacent.
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
    DATA_W  DW 1, 1, 2, 2, 2, 3, 5, 5, 8, 8
    HOWMANY EQU 10
    LEFT    DW 0

    M_BEFORE DB 'Before: $'
    M_AFTER  DB 'After:  $'
    M_COUNT  DB 'Distinct values: $'

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
    ; IN A SORTED ARRAY EQUAL VALUES SIT NEXT TO EACH OTHER, SO A DUPLICATE IS
    ; RECOGNISED BY COMPARING WITH THE PREVIOUS ONE ALONE. ON UNSORTED DATA
    ; THIS WOULD MISS EVERY DUPLICATE THAT WAS NOT ADJACENT.
    ; -------------------------------------------------------------------------
    LEA SI, DATA_W
    LEA DI, DATA_W
    ADD SI, 2                           ; The first element always survives
    ADD DI, 2
    MOV WORD PTR LEFT, 1
    MOV CX, HOWMANY
    DEC CX

COMPACT:
    JCXZ COMPACTED

    MOV AX, [SI]
    CMP AX, [DI-2]                      ; The last one kept
    JE  SKIP_IT

    MOV [DI], AX
    ADD DI, 2
    INC WORD PTR LEFT

SKIP_IT:
    ADD SI, 2
    DEC CX
    JMP COMPACT

COMPACTED:
    LEA DX, M_AFTER
    MOV AH, 09H
    INT 21H
    LEA SI, DATA_W
    MOV CX, LEFT
    CALL SHOW_RUN

    LEA DX, M_COUNT
    MOV AH, 09H
    INT 21H
    MOV AX, LEFT
    CALL PRINT_DECIMAL
    CALL NEWLINE

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
; 1. COMPARING WITH THE LAST ONE KEPT:
;    - Not with the previous element read. Those differ once a duplicate
;    - has been skipped, and comparing with the wrong one lets a run of
;    - three through as two.
; 2. WHAT IS LEFT BEYOND THE NEW END:
;    - The old values are still there, untouched. Only the count says how
;    - much of the array is meaningful, which is why the count is the real
;    - result.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
