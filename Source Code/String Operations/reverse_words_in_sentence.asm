; =============================================================================
; TITLE: Reverse the Words of a Sentence
; DESCRIPTION: Reverses the order of the words while leaving each word itself
;              the right way round, by reversing twice.
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
    TEXT    DB 'the quick brown fox'
    TEXTLEN EQU $ - TEXT
    M_IN    DB 'Before: $'
    M_OUT   DB 'After:  $'

; -----------------------------------------------------------------------------
; CODE SEGMENT
; -----------------------------------------------------------------------------
.CODE
START:
    MOV AX, @DATA
    MOV DS, AX

    LEA DX, M_IN
    MOV AH, 09H
    INT 21H
    LEA SI, TEXT
    MOV CX, TEXTLEN
    CALL PRINT_TEXT
    CALL NEWLINE

    ; -------------------------------------------------------------------------
    ; THE TRICK IS TO REVERSE TWICE. REVERSING THE WHOLE SENTENCE PUTS THE
    ; WORDS IN THE RIGHT ORDER AND EVERY WORD BACKWARDS; REVERSING EACH WORD
    ; IN PLACE THEN PUTS THE LETTERS BACK. NO SECOND BUFFER IS NEEDED.
    ; -------------------------------------------------------------------------
    LEA SI, TEXT
    MOV CX, TEXTLEN
    CALL REVERSE_RUN

    ; Now reverse each word within the sentence
    LEA SI, TEXT
    MOV BX, TEXTLEN                     ; How much of the sentence remains

NEXT_WORD:
    OR  BX, BX
    JZ  ALL_DONE

    ; Measure this word, up to the next space
    XOR CX, CX
    MOV DI, SI

MEASURE:
    CMP BX, CX
    JBE HAVE_WORD                       ; Reached the end of the sentence
    CMP BYTE PTR [DI], ' '
    JE  HAVE_WORD
    INC CX
    INC DI
    JMP MEASURE

HAVE_WORD:
    PUSH CX
    CALL REVERSE_RUN                    ; SI and CX describe the word
    POP CX

    ; Step over the word and the space that follows it
    ADD SI, CX
    SUB BX, CX

    OR  BX, BX
    JZ  ALL_DONE
    INC SI                              ; The space
    DEC BX
    JMP NEXT_WORD

ALL_DONE:
    LEA DX, M_OUT
    MOV AH, 09H
    INT 21H
    LEA SI, TEXT
    MOV CX, TEXTLEN
    CALL PRINT_TEXT
    CALL NEWLINE

    MOV AH, 4CH
    INT 21H

; -----------------------------------------------------------------------------
; REVERSE_RUN
;
; Reverses CX bytes starting at DS:SI, in place.
; -----------------------------------------------------------------------------
REVERSE_RUN PROC
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH SI
    PUSH DI

    CMP CX, 1
    JBE RR_DONE                         ; Nothing to do for none or one

    MOV DI, SI
    ADD DI, CX
    DEC DI                              ; The last byte
    SHR CX, 1                           ; Half as many swaps as bytes

RR_SWAP:
    MOV AL, [SI]
    MOV BL, [DI]
    MOV [SI], BL
    MOV [DI], AL
    INC SI
    DEC DI
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
; 1. TWO REVERSALS, NO COPY:
;    - Reversing everything and then reversing each part is the standard
;    - way to rotate or reorder a sequence without allocating a second
;    - one. It is the same idea behind rotating an array in place.
; 2. THE WORD MEASUREMENT:
;    - A word ends at a space or at the end of the sentence, so both have
;    - to be tested. Checking only for the space walks past the end.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
