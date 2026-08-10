; =============================================================================
; TITLE: First and Last Occurrence of a Value
; DESCRIPTION: Uses two modified binary searches to find both ends of a run of
;              equal values, and so how many there are.
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
    SORTED  DW 2, 4, 8, 8, 8, 8, 11, 15, 15, 20
    HOWMANY EQU 10
    WANTED  DW 8

    M_ARRAY DB 'Sorted:  $'
    M_FIRST DB 'First 8 at index $'
    M_LAST  DB 'Last 8 at index  $'
    M_COUNT DB 'So there are $'
    M_TAIL  DB ' of them', 0DH, 0AH, '$'

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
    LEA SI, SORTED
    MOV CX, HOWMANY
    CALL SHOW_RUN

    ; -------------------------------------------------------------------------
    ; AN ORDINARY BINARY SEARCH STOPS AT WHICHEVER MATCH IT HAPPENS TO MEET.
    ; TO FIND THE FIRST, KEEP GOING LEFT AFTER A MATCH; TO FIND THE LAST, KEEP
    ; GOING RIGHT. THE ONLY DIFFERENCE BETWEEN THE TWO SEARCHES IS THAT ONE
    ; LINE.
    ; -------------------------------------------------------------------------
    MOV BP, 0                           ; Look for the first
    CALL BOUNDED_SEARCH
    MOV FIRST_AT, AX

    PUSH AX
    LEA DX, M_FIRST
    MOV AH, 09H
    INT 21H
    POP AX
    CALL PRINT_DECIMAL
    CALL NEWLINE

    MOV BP, 1                           ; Look for the last
    CALL BOUNDED_SEARCH
    MOV LAST_AT, AX

    PUSH AX
    LEA DX, M_LAST
    MOV AH, 09H
    INT 21H
    POP AX
    CALL PRINT_DECIMAL
    CALL NEWLINE

    MOV AX, LAST_AT
    SUB AX, FIRST_AT
    INC AX

    PUSH AX
    LEA DX, M_COUNT
    MOV AH, 09H
    INT 21H
    POP AX
    CALL PRINT_DECIMAL
    LEA DX, M_TAIL
    MOV AH, 09H
    INT 21H

    MOV AX, 4C00H
    INT 21H

; -----------------------------------------------------------------------------
; BOUNDED_SEARCH
;
; Finds an occurrence of WANTED. BP decides which one: nought for the first,
; anything else for the last. Returns the index in AX, or FFFFh if absent.
; -----------------------------------------------------------------------------
BOUNDED_SEARCH PROC
    PUSH BX
    PUSH CX
    PUSH DX

    XOR BX, BX                          ; low
    MOV DX, HOWMANY
    DEC DX                              ; high
    MOV DI, 0FFFFH                      ; The best index found so far

BS_LOOP:
    CMP BX, DX
    JA  BS_DONE

    MOV CX, BX
    ADD CX, DX
    SHR CX, 1

    MOV SI, CX
    SHL SI, 1
    MOV AX, SORTED[SI]

    CMP AX, WANTED
    JB  BS_GO_RIGHT
    JA  BS_GO_LEFT

    ; A match. Record it, then keep looking on the chosen side.
    MOV DI, CX
    OR  BP, BP
    JZ  BS_GO_LEFT_AFTER_MATCH

    MOV BX, CX                          ; Looking for the last, so go right
    INC BX
    JMP BS_LOOP

BS_GO_LEFT_AFTER_MATCH:
    CMP CX, 0
    JE  BS_DONE
    MOV DX, CX
    DEC DX
    JMP BS_LOOP

BS_GO_RIGHT:
    MOV BX, CX
    INC BX
    JMP BS_LOOP

BS_GO_LEFT:
    CMP CX, 0
    JE  BS_DONE
    MOV DX, CX
    DEC DX
    JMP BS_LOOP

BS_DONE:
    MOV AX, DI

    POP DX
    POP CX
    POP BX
    RET
BOUNDED_SEARCH ENDP

FIRST_AT DW 0
LAST_AT  DW 0

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
; 1. COUNTING WITHOUT COUNTING:
;    - The last index less the first, plus one, gives how many there are.
;    - Two logarithmic searches answer it where a linear scan of the run
;    - would take as long as the run is.
; 2. RECORDING BEFORE CONTINUING:
;    - Each match is remembered before the search moves on, so the answer
;    - survives even though the loop carries on past it.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
