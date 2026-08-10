; =============================================================================
; TITLE: The Repeated Number
; DESCRIPTION: Finds which value appears twice in a list of one to n, using the
;              same total comparison in reverse.
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
    ; One to eight with one of them appearing twice, so nine entries
    DATA_W  DW 3, 1, 6, 4, 5, 6, 2, 8, 7
    HOWMANY EQU 9
    LIMIT   EQU 8

    M_ARRAY DB 'The list: $'
    M_DUP   DB 'The repeated number is $'
    M_TALLY DB 'The same answer from a tally: $'
    SEEN    DB LIMIT + 1 DUP(0)

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

    ; -------------------------------------------------------------------------
    ; THE LIST HOLDS ONE MORE ENTRY THAN THE RANGE, SO ITS TOTAL EXCEEDS THE
    ; EXPECTED TOTAL BY EXACTLY THE VALUE THAT APPEARS TWICE.
    ; -------------------------------------------------------------------------
    MOV AX, LIMIT
    INC AX
    MOV BX, LIMIT
    MUL BX
    SHR AX, 1
    MOV BP, AX                          ; The expected total

    LEA SI, DATA_W
    MOV CX, HOWMANY
    XOR BX, BX

TOTAL_UP:
    ADD BX, [SI]
    ADD SI, 2
    LOOP TOTAL_UP

    MOV AX, BX
    SUB AX, BP

    PUSH AX
    LEA DX, M_DUP
    MOV AH, 09H
    INT 21H
    POP AX
    CALL PRINT_DECIMAL
    CALL NEWLINE

    ; -------------------------------------------------------------------------
    ; THE OTHER WAY: MARK EACH VALUE AS IT IS SEEN AND STOP AT THE FIRST ONE
    ; ALREADY MARKED. THIS WORKS WHATEVER THE VALUES ARE, WHERE THE TOTAL
    ; METHOD DEPENDS ON THEM BEING EXACTLY ONE TO N.
    ; -------------------------------------------------------------------------
    LEA SI, DATA_W
    MOV CX, HOWMANY

TALLY_LOOP:
    MOV BX, [SI]
    CMP BYTE PTR SEEN[BX], 0
    JNE FOUND_IT

    MOV BYTE PTR SEEN[BX], 1
    ADD SI, 2
    LOOP TALLY_LOOP

    JMP FINISHED                        ; No duplicate at all

FOUND_IT:
    PUSH BX
    LEA DX, M_TALLY
    MOV AH, 09H
    INT 21H
    POP AX
    CALL PRINT_DECIMAL
    CALL NEWLINE

FINISHED:
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
; 1. THE TOTAL METHOD IS NARROW:
;    - It requires the values to be exactly one to n with one repeat.
;    - Given any other data it produces a number that means nothing.
; 2. THE TALLY IS GENERAL AND STOPS EARLY:
;    - It finds the first repeat wherever it is and works on any values
;    - small enough to index with. That is the trade: one byte per
;    - possible value in exchange for not caring about the data.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
