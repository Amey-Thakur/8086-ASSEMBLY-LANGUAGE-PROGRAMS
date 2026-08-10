; =============================================================================
; TITLE: Anagram Test
; DESCRIPTION: Decides whether two strings use exactly the same letters, by
;              counting each letter rather than sorting either string.
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
    FIRST   DB 'listen'
    SECOND  DB 'silent'
    THIRD   DB 'tinsel'
    FOURTH  DB 'litter'
    WORDLEN EQU 6

    TALLY   DB 26 DUP(0)
    M_AND   DB ' and $'
    M_YES   DB ' are anagrams', 0DH, 0AH, '$'
    M_NO    DB ' are not anagrams', 0DH, 0AH, '$'

; -----------------------------------------------------------------------------
; CODE SEGMENT
; -----------------------------------------------------------------------------
.CODE
START:
    MOV AX, @DATA
    MOV DS, AX

    LEA SI, FIRST
    LEA DI, SECOND
    CALL COMPARE_PAIR

    LEA SI, FIRST
    LEA DI, THIRD
    CALL COMPARE_PAIR

    LEA SI, FIRST
    LEA DI, FOURTH
    CALL COMPARE_PAIR

    MOV AH, 4CH
    INT 21H

; -----------------------------------------------------------------------------
; COMPARE_PAIR
;
; SI and DI point at two words of WORDLEN letters. Reports whether they are
; anagrams of each other.
; -----------------------------------------------------------------------------
COMPARE_PAIR PROC
    PUSH SI
    PUSH DI

    ; Show what is being compared
    MOV CX, WORDLEN
    CALL PRINT_TEXT
    LEA DX, M_AND
    MOV AH, 09H
    INT 21H
    MOV SI, DI
    MOV CX, WORDLEN
    CALL PRINT_TEXT

    POP DI
    POP SI
    PUSH SI
    PUSH DI

    ; -------------------------------------------------------------------------
    ; ADD ONE FOR EVERY LETTER OF THE FIRST WORD AND SUBTRACT ONE FOR EVERY
    ; LETTER OF THE SECOND. IF THEY USE THE SAME LETTERS THE TALLY RETURNS TO
    ; ALL ZEROS, WHICHEVER ORDER THEY WERE IN.
    ; -------------------------------------------------------------------------
    CALL CLEAR_TALLY

    MOV CX, WORDLEN

COUNT_FIRST:
    MOV AL, [SI]
    SUB AL, 'a'
    XOR BH, BH
    MOV BL, AL
    INC BYTE PTR TALLY[BX]
    INC SI
    LOOP COUNT_FIRST

    MOV CX, WORDLEN

COUNT_SECOND:
    MOV AL, [DI]
    SUB AL, 'a'
    XOR BH, BH
    MOV BL, AL
    DEC BYTE PTR TALLY[BX]
    INC DI
    LOOP COUNT_SECOND

    ; Any non zero entry means the letters did not match
    XOR BX, BX
    MOV CX, 26

CHECK_TALLY:
    CMP BYTE PTR TALLY[BX], 0
    JNE NOT_ANAGRAM
    INC BX
    LOOP CHECK_TALLY

    LEA DX, M_YES
    JMP CP_REPORT

NOT_ANAGRAM:
    LEA DX, M_NO

CP_REPORT:
    MOV AH, 09H
    INT 21H

    POP DI
    POP SI
    RET
COMPARE_PAIR ENDP

; -----------------------------------------------------------------------------
; CLEAR_TALLY
; -----------------------------------------------------------------------------
CLEAR_TALLY PROC
    PUSH BX
    PUSH CX

    XOR BX, BX
    MOV CX, 26

CT_LOOP:
    MOV BYTE PTR TALLY[BX], 0
    INC BX
    LOOP CT_LOOP

    POP CX
    POP BX
    RET
CLEAR_TALLY ENDP

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
; 1. COUNTING BEATS SORTING:
;    - Sorting both words and comparing them works but costs far more.
;    - One pass over each word and one over the tally decides it, however
;    - long the words are.
; 2. ADD THEN SUBTRACT:
;    - Using one tally for both words rather than two and comparing them
;    - halves the memory and removes the comparison entirely: the answer
;    - is whether everything came back to zero.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
