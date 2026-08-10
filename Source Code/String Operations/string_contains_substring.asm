; =============================================================================
; TITLE: Find a Substring
; DESCRIPTION: Searches for one string inside another and reports where it
;              starts, comparing only where the first character already matches.
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
    HAYSTACK DB 'the 8086 microprocessor and its assembler'
    HAYLEN   EQU $ - HAYSTACK
    NEEDLE   DB 'processor'
    NEEDLELEN EQU $ - NEEDLE
    M_FOUND  DB 'Found at position $'
    M_NONE   DB 'Not present.', 0DH, 0AH, '$'
    M_TRIES  DB 'Positions examined: $'

; -----------------------------------------------------------------------------
; CODE SEGMENT
; -----------------------------------------------------------------------------
.CODE
START:
    MOV AX, @DATA
    MOV DS, AX
    MOV ES, AX

    ; -------------------------------------------------------------------------
    ; THE OUTER LOOP TRIES EACH STARTING POSITION, BUT ONLY AS FAR AS THE
    ; POINT WHERE THE NEEDLE WOULD RUN PAST THE END. TRYING FURTHER WOULD READ
    ; BEYOND THE STRING AND COULD ONLY EVER FAIL.
    ; -------------------------------------------------------------------------
    MOV BX, 0                           ; The position being tried
    MOV BP, HAYLEN
    SUB BP, NEEDLELEN                    ; The last position worth trying
    XOR DI, DI                          ; How many positions were examined

TRY_POSITION:
    CMP BX, BP
    JA  NOT_PRESENT

    INC DI

    ; Compare the needle against the haystack from here
    LEA SI, HAYSTACK
    ADD SI, BX
    LEA DX, NEEDLE
    MOV CX, NEEDLELEN

COMPARE:
    MOV AL, [SI]
    PUSH SI
    MOV SI, DX
    CMP AL, [SI]
    POP SI
    JNE NO_MATCH_HERE

    INC SI
    INC DX
    LOOP COMPARE

    ; The whole needle matched
    LEA DX, M_FOUND
    MOV AH, 09H
    INT 21H
    MOV AX, BX
    CALL PRINT_DECIMAL
    CALL NEWLINE
    JMP SHOW_TRIES

NO_MATCH_HERE:
    INC BX
    JMP TRY_POSITION

NOT_PRESENT:
    LEA DX, M_NONE
    MOV AH, 09H
    INT 21H

SHOW_TRIES:
    LEA DX, M_TRIES
    MOV AH, 09H
    INT 21H
    MOV AX, DI
    CALL PRINT_DECIMAL
    CALL NEWLINE

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
; 1. THE LAST POSITION WORTH TRYING:
;    - A needle of nine characters in a haystack of forty can start at
;    - position 31 at the latest. Looping to the end of the haystack
;    - reads past it, which is the usual bug in a hand written search.
; 2. THIS IS THE NAIVE METHOD:
;    - Every position is tried independently, so a bad case costs the
;    - product of the two lengths. Knuth, Morris and Pratt showed how to
;    - reuse what a failed comparison already revealed, which no assembly
;    - course covers and every library implements.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
