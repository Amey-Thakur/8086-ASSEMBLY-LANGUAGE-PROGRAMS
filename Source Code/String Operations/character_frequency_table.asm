; =============================================================================
; TITLE: Character Frequency
; DESCRIPTION: Counts how often each letter appears and prints only those that
;              occurred, which is what a frequency analysis needs.
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
    TEXT    DB 'the assessment of the assembly system'
    TEXTLEN EQU $ - TEXT
    TALLY   DW 26 DUP(0)
    M_HEAD  DB 'Letter counts:', 0DH, 0AH, '$'
    M_SEP   DB ' x $'
    M_GAP   DB '   $'

; -----------------------------------------------------------------------------
; CODE SEGMENT
; -----------------------------------------------------------------------------
.CODE
START:
    MOV AX, @DATA
    MOV DS, AX

    LEA DX, M_HEAD
    MOV AH, 09H
    INT 21H

    ; -------------------------------------------------------------------------
    ; ONE COUNTER PER LETTER. ANYTHING THAT IS NOT A LOWER CASE LETTER IS
    ; IGNORED, WHICH IS WHY THE SPACES DO NOT APPEAR IN THE RESULT.
    ; -------------------------------------------------------------------------
    LEA SI, TEXT
    MOV CX, TEXTLEN

COUNT:
    MOV AL, [SI]
    CMP AL, 'a'
    JB  NOT_A_LETTER
    CMP AL, 'z'
    JA  NOT_A_LETTER

    SUB AL, 'a'
    XOR AH, AH
    MOV BX, AX
    SHL BX, 1                           ; Words in the tally
    INC WORD PTR TALLY[BX]

NOT_A_LETTER:
    INC SI
    LOOP COUNT

    ; -------------------------------------------------------------------------
    ; PRINT ONLY THE LETTERS THAT OCCURRED. A TABLE OF TWENTY SIX ROWS WITH
    ; MOST OF THEM ZERO WOULD BE HARDER TO READ THAN THE TEXT IT DESCRIBES.
    ; -------------------------------------------------------------------------
    XOR BX, BX

REPORT:
    CMP BX, 26
    JAE FINISH

    MOV SI, BX
    SHL SI, 1
    MOV AX, TALLY[SI]
    OR  AX, AX
    JZ  NEXT_LETTER

    PUSH AX
    MOV DL, BL
    ADD DL, 'a'
    MOV AH, 02H
    INT 21H

    LEA DX, M_SEP
    MOV AH, 09H
    INT 21H
    POP AX
    CALL PRINT_DECIMAL

    LEA DX, M_GAP
    MOV AH, 09H
    INT 21H

NEXT_LETTER:
    INC BX
    JMP REPORT

FINISH:
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
; 1. WHY WORDS AND NOT BYTES:
;    - A byte counter overflows silently after 255 occurrences. For a long
;    - text that is a real possibility, and a word costs only 26 extra
;    - bytes.
; 2. THE INDEX IS THE LETTER:
;    - Subtracting 'a' turns a character into an index from 0 to 25, which
;    - is the whole reason the alphabet being contiguous in ASCII matters.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
