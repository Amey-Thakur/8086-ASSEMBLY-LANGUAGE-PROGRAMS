; =============================================================================
; TITLE: Find the Longest Word
; DESCRIPTION: Measures every word in a sentence and reports the longest,
;              remembering where it began rather than copying it.
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
    TEXT    DB 'the 8086 microprocessor executes assembly instructions'
    TEXTLEN EQU $ - TEXT
    BEST_AT DW 0
    BEST_LEN DW 0
    M_HEAD  DB 'The longest word is $'
    M_LEN   DB ', at $'
    M_TAIL  DB ' letters', 0DH, 0AH, '$'

; -----------------------------------------------------------------------------
; CODE SEGMENT
; -----------------------------------------------------------------------------
.CODE
START:
    MOV AX, @DATA
    MOV DS, AX

    LEA SI, TEXT
    MOV BX, TEXTLEN                     ; How much of the sentence is left

NEXT_WORD:
    OR  BX, BX
    JZ  REPORT

    ; Step over any spaces before the word
    CMP BYTE PTR [SI], ' '
    JNE MEASURE_WORD
    INC SI
    DEC BX
    JMP NEXT_WORD

MEASURE_WORD:
    MOV DI, SI                          ; Where this word starts
    XOR CX, CX                          ; How long it is
    MOV DX, SI                          ; A cursor that may move freely

SCAN_WORD:
    CMP CX, BX
    JAE WORD_ENDED                      ; Ran out of sentence

    PUSH SI
    MOV SI, DX
    CMP BYTE PTR [SI], ' '
    POP SI
    JE  WORD_ENDED                      ; Reached the space after the word

    INC CX
    INC DX
    JMP SCAN_WORD

WORD_ENDED:
    ; -------------------------------------------------------------------------
    ; ONLY THE POSITION AND THE LENGTH ARE KEPT, NOT THE WORD ITSELF. THERE IS
    ; NO REASON TO COPY IT WHEN IT IS STILL SITTING IN THE SENTENCE.
    ; -------------------------------------------------------------------------
    CMP CX, BEST_LEN
    JBE NOT_LONGER

    MOV BEST_LEN, CX
    MOV BEST_AT, DI

NOT_LONGER:
    ADD SI, CX
    SUB BX, CX
    JMP NEXT_WORD

REPORT:
    LEA DX, M_HEAD
    MOV AH, 09H
    INT 21H
    MOV SI, BEST_AT
    MOV CX, BEST_LEN
    CALL PRINT_TEXT

    LEA DX, M_LEN
    MOV AH, 09H
    INT 21H
    MOV AX, BEST_LEN
    CALL PRINT_DECIMAL
    LEA DX, M_TAIL
    MOV AH, 09H
    INT 21H

    MOV AH, 4CH
    INT 21H

; -----------------------------------------------------------------------------
; PRINT_TEXT
;
; Prints CX characters starting at DS:SI. Both are left as they were found.
; -----------------------------------------------------------------------------
PRINT_TEXT PROC
    PUSH AX
    PUSH CX
    PUSH DX
    PUSH SI

    JCXZ PT_DONE                        ; Nothing to print

PT_LOOP:
    MOV DL, [SI]
    MOV AH, 02H
    INT 21H
    INC SI
    LOOP PT_LOOP

PT_DONE:
    POP SI
    POP DX
    POP CX
    POP AX
    RET
PRINT_TEXT ENDP

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
; 1. A POSITION IS ENOUGH:
;    - Recording where the best word starts and how long it is answers
;    - the question completely, with two words of storage rather than a
;    - buffer the size of the longest possible word.
; 2. STRICTLY LONGER:
;    - JBE keeps the first of two words of equal length. Using JB would
;    - keep the last, which is a different and equally defensible answer,
;    - but it should be a decision rather than an accident.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
