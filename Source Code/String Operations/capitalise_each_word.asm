; =============================================================================
; TITLE: Capitalise Each Word
; DESCRIPTION: Puts a capital at the start of every word and lower case
;              everywhere else, by tracking whether the previous character was a space.
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
    TEXT    DB 'the 8086 microPROCESSOR and its assembly LANGUAGE'
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
    ; ONE FLAG DECIDES EVERYTHING: WHETHER THIS CHARACTER BEGINS A WORD. IT
    ; STARTS TRUE, BECOMES TRUE AFTER EVERY SPACE, AND IS FALSE OTHERWISE.
    ; -------------------------------------------------------------------------
    LEA SI, TEXT
    MOV CX, TEXTLEN
    MOV BL, 1                           ; The next letter starts a word

CONVERT:
    MOV AL, [SI]

    CMP AL, ' '
    JNE A_LETTER

    MOV BL, 1                           ; A space, so the next one starts a word
    JMP NEXT_CHARACTER

A_LETTER:
    OR  BL, BL
    JZ  MAKE_LOWER

    ; The first letter of a word: force upper case
    CMP AL, 'a'
    JB  MARK_INSIDE
    CMP AL, 'z'
    JA  MARK_INSIDE
    SUB AL, 32
    MOV [SI], AL

MARK_INSIDE:
    XOR BL, BL                          ; No longer at the start of a word
    JMP NEXT_CHARACTER

MAKE_LOWER:
    CMP AL, 'A'
    JB  NEXT_CHARACTER
    CMP AL, 'Z'
    JA  NEXT_CHARACTER
    ADD AL, 32
    MOV [SI], AL

NEXT_CHARACTER:
    INC SI
    LOOP CONVERT

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
; 1. DIGITS ARE LEFT ALONE:
;    - The range tests mean 8086 passes through untouched, and the flag
;    - is still cleared so the following letter is not capitalised. That
;    - is why "8086 microprocessor" comes out with a lower case m.
; 2. IN PLACE:
;    - Each character is written back only when it changes, so the string
;    - is converted where it lies with no second buffer.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
