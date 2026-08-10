; =============================================================================
; TITLE: Gnome Sort
; DESCRIPTION: Sorts with a single loop and a single index, stepping back one
;              place whenever a pair is out of order.
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
    DATA_W  DW 42, 17, 93, 8, 65, 31, 76, 4
    HOWMANY EQU 8
    M_BEFORE DB 'Before: $'
    M_AFTER  DB 'After:  $'

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
    CALL SHOW_ARRAY

    ; -------------------------------------------------------------------------
    ; ONE LOOP, ONE INDEX, NO NESTING. WHEN A PAIR IS IN ORDER THE INDEX GOES
    ; FORWARD; WHEN IT IS NOT, THE PAIR IS SWAPPED AND THE INDEX GOES BACK.
    ; IT IS THE SHORTEST CORRECT SORT THAT CAN BE WRITTEN.
    ; -------------------------------------------------------------------------
    MOV BX, 1                           ; The position under consideration

GNOME:
    CMP BX, HOWMANY
    JAE SORTED                          ; Walked off the end, so it is done

    MOV SI, BX
    SHL SI, 1
    ADD SI, OFFSET DATA_W

    MOV AX, [SI-2]
    CMP AX, [SI]
    JBE STEP_FORWARD                    ; This pair is fine

    XCHG AX, [SI]                       ; Put them right
    MOV [SI-2], AX

    CMP BX, 1
    JBE STEP_FORWARD                    ; Cannot go back past the start
    DEC BX                              ; Re-examine the pair behind
    JMP GNOME

STEP_FORWARD:
    INC BX
    JMP GNOME

SORTED:

    LEA DX, M_AFTER
    MOV AH, 09H
    INT 21H
    CALL SHOW_ARRAY

    MOV AH, 4CH
    INT 21H

; -----------------------------------------------------------------------------
; SHOW_ARRAY
;
; Prints DATA_W on one line.
; -----------------------------------------------------------------------------
SHOW_ARRAY PROC
    PUSH AX
    PUSH CX
    PUSH DX
    PUSH SI

    LEA SI, DATA_W
    MOV CX, HOWMANY

SA_LOOP:
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
    LOOP SA_LOOP

    CALL NEWLINE

    POP SI
    POP DX
    POP CX
    POP AX
    RET
SHOW_ARRAY ENDP

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
; 1. WHY IT TERMINATES:
;    - Every backward step is preceded by an exchange that reduces the
;    - number of out of order pairs, and that number can only fall to
;    - zero. The index cannot retreat forever.
; 2. IT IS INSERTION SORT IN DISGUISE:
;    - Walking back to find the right place is what insertion sort does
;    - with an inner loop. Gnome sort does it with the outer index, which
;    - is shorter to write and slower to run.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
