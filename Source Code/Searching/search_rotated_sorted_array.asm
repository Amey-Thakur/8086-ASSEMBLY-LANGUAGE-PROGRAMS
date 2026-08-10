; =============================================================================
; TITLE: Searching a Rotated Sorted Array
; DESCRIPTION: Finds a value in an array that was sorted and then rotated,
;              still in logarithmic time, by working out which half is in order.
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
    ; 12 15 18 2 5 6 8 was 2 5 6 8 12 15 18 rotated by four
    DATA_W  DW 12, 15, 18, 2, 5, 6, 8
    HOWMANY EQU 7

    WANTED  DW 5
    ABSENT  DW 13

    M_ARRAY DB 'Rotated: $'
    M_LOOK  DB 'Looking for $'
    M_AT    DB '   at index $'
    M_NONE  DB '   not present', 0DH, 0AH, '$'

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

    MOV AX, WANTED
    CALL ROTATED_SEARCH

    MOV AX, ABSENT
    CALL ROTATED_SEARCH

    MOV AX, 4C00H
    INT 21H

; -----------------------------------------------------------------------------
; ROTATED_SEARCH
;
; Looks for AX. BX is the low bound, DX the high one, CX the middle.
; -----------------------------------------------------------------------------
ROTATED_SEARCH PROC
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX

    PUSH AX
    LEA DX, M_LOOK
    MOV AH, 09H
    INT 21H
    POP AX
    PUSH AX
    CALL PRINT_DECIMAL
    POP AX

    MOV BP, AX                          ; What is sought
    XOR BX, BX
    MOV DX, HOWMANY
    DEC DX

SEARCH:
    CMP BX, DX
    JA  RS_ABSENT

    MOV CX, BX
    ADD CX, DX
    SHR CX, 1                           ; The middle

    MOV SI, CX
    SHL SI, 1
    MOV AX, DATA_W[SI]
    CMP AX, BP
    JE  RS_FOUND

    ; -------------------------------------------------------------------------
    ; ONE OF THE TWO HALVES IS ALWAYS IN ORDER, AND WHICH ONE IS DECIDED BY
    ; COMPARING THE MIDDLE WITH THE LOW END. WITHIN THE ORDERED HALF AN
    ; ORDINARY RANGE TEST SAYS WHETHER THE TARGET COULD BE THERE; IF IT COULD
    ; NOT, IT MUST BE IN THE OTHER HALF.
    ; -------------------------------------------------------------------------
    MOV SI, BX
    SHL SI, 1
    MOV DI, DATA_W[SI]                  ; The low end
    CMP AX, DI
    JB  RIGHT_IS_ORDERED

    ; The left half is in order
    CMP BP, DI
    JB  GO_RIGHT
    CMP BP, AX
    JA  GO_RIGHT

    MOV DX, CX                          ; The target lies in the left half
    DEC DX
    JMP SEARCH

RIGHT_IS_ORDERED:
    MOV SI, DX
    SHL SI, 1
    MOV DI, DATA_W[SI]                  ; The high end

    CMP BP, AX
    JB  GO_LEFT
    CMP BP, DI
    JA  GO_LEFT

    MOV BX, CX                          ; The target lies in the right half
    INC BX
    JMP SEARCH

GO_RIGHT:
    MOV BX, CX
    INC BX
    JMP SEARCH

GO_LEFT:
    MOV DX, CX
    DEC DX
    CMP CX, 0
    JE  RS_ABSENT                       ; DX would have wrapped
    JMP SEARCH

RS_FOUND:
    LEA DX, M_AT
    MOV AH, 09H
    INT 21H
    MOV AX, CX
    CALL PRINT_DECIMAL
    CALL NEWLINE
    JMP RS_DONE

RS_ABSENT:
    LEA DX, M_NONE
    MOV AH, 09H
    INT 21H

RS_DONE:
    POP DX
    POP CX
    POP BX
    POP AX
    RET
ROTATED_SEARCH ENDP

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
; 1. ONE HALF IS ALWAYS SORTED:
;    - A single rotation puts the break in one place, so it can be in only
;    - one of the two halves. The other half is therefore in order and can
;    - be reasoned about normally.
; 2. FINDING THE ROTATION FIRST ALSO WORKS:
;    - Locate the break, then binary search the appropriate half. That is
;    - two searches rather than one, and this method folds them together.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
