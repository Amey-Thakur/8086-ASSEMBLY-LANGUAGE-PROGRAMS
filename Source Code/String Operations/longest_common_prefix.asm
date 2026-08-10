; =============================================================================
; TITLE: The Longest Common Prefix
; DESCRIPTION: How much of the start of several strings is identical, compared one column at a time across all of them.
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
    WORD_LEN EQU 12                     ; Every entry padded to this width

    WORDS   DB 'INTERSTELLAR'
            DB 'INTERNAL    '
            DB 'INTERNET    '
            DB 'INTERVAL    '
    HOWMANY EQU 4

    ; The true length of each, since the padding is not part of the word.
    LENGTHS DW 12, 8, 8, 8

    M_TITLE DB 'The longest common prefix of four words', 0DH, 0AH, '$'
    M_WORD  DB '  $'
    M_FOUND DB 0DH, 0AH, 'Common prefix: "$'
    M_CLOSE DB '"', 0DH, 0AH, '$'
    M_LEN   DB 'Length: $'
    M_NONE  DB 0DH, 0AH, 'There is no common prefix at all.', 0DH, 0AH, '$'
    M_STOP  DB 0DH, 0AH, 'Stopped at column $'
    M_BECAUSE DB ', where the words first differ.', 0DH, 0AH, '$'
    M_WHY   DB 0DH, 0AH
            DB 'The answer can never be longer than the shortest word, so that '
            DB 'is the bound the column loop runs to.', 0DH, 0AH, '$'

; -----------------------------------------------------------------------------
; CODE SEGMENT
; -----------------------------------------------------------------------------
.CODE
START:
    MOV AX, @DATA
    MOV DS, AX

    LEA DX, M_TITLE
    CALL PRINT_MESSAGE

    ; ---- show the words -----------------------------------------------------
    XOR SI, SI
    MOV CX, HOWMANY
SHOW_WORDS:
    PUSH CX
    LEA DX, M_WORD
    CALL PRINT_MESSAGE

    MOV AX, SI
    MOV BX, WORD_LEN
    MUL BX
    PUSH SI
    LEA SI, WORDS
    ADD SI, AX
    MOV BX, SI
    POP SI

    PUSH SI
    MOV DI, SI
    SHL DI, 1
    MOV CX, LENGTHS[DI]
    MOV SI, BX
    CALL PRINT_TEXT
    POP SI
    CALL NEWLINE

    INC SI
    POP CX
    LOOP SHOW_WORDS

    ; -------------------------------------------------------------------------
    ; THE SHORTEST WORD BOUNDS THE ANSWER, SO IT IS FOUND FIRST. WITHOUT IT THE
    ; COLUMN LOOP WOULD READ PAST THE END OF THE SHORT WORDS INTO THEIR PADDING
    ; AND REPORT A PREFIX THAT IS NOT THERE.
    ; -------------------------------------------------------------------------
    MOV BP, 0FFFFH                      ; The shortest length seen
    XOR SI, SI
    MOV CX, HOWMANY
FIND_SHORTEST:
    MOV DI, SI
    SHL DI, 1
    MOV AX, LENGTHS[DI]
    CMP AX, BP
    JAE NOT_SHORTER
    MOV BP, AX
NOT_SHORTER:
    INC SI
    LOOP FIND_SHORTEST

    ; -------------------------------------------------------------------------
    ; ONE COLUMN AT A TIME. EVERY WORD IS COMPARED AGAINST THE FIRST, AND THE
    ; MOMENT ANY OF THEM DIFFERS THE PREFIX HAS ENDED.
    ; -------------------------------------------------------------------------
    XOR DI, DI                          ; The column

EACH_COLUMN:
    CMP DI, BP
    JAE PREFIX_ENDED                    ; Reached the end of the shortest word

    ; ---- the character in the first word ------------------------------------
    MOV BX, DI
    MOV AL, WORDS[BX]
    MOV AH, AL                          ; Keep it to compare against

    MOV SI, 1                           ; Start at the second word
COMPARE_WORDS:
    CMP SI, HOWMANY
    JAE COLUMN_AGREES

    PUSH AX
    MOV AX, SI
    MOV BX, WORD_LEN
    MUL BX
    ADD AX, DI
    MOV BX, AX
    POP AX

    MOV AL, WORDS[BX]
    CMP AL, AH
    JNE PREFIX_ENDED

    INC SI
    JMP COMPARE_WORDS

COLUMN_AGREES:
    INC DI
    JMP EACH_COLUMN

PREFIX_ENDED:
    CMP DI, 0
    JE NO_PREFIX

    LEA DX, M_FOUND
    CALL PRINT_MESSAGE
    LEA SI, WORDS
    MOV CX, DI
    CALL PRINT_TEXT
    LEA DX, M_CLOSE
    CALL PRINT_MESSAGE

    LEA DX, M_LEN
    CALL PRINT_MESSAGE
    MOV AX, DI
    CALL PRINT_DECIMAL

    LEA DX, M_STOP
    CALL PRINT_MESSAGE
    MOV AX, DI
    CALL PRINT_DECIMAL
    LEA DX, M_BECAUSE
    CALL PRINT_MESSAGE
    JMP EXPLAIN

NO_PREFIX:
    LEA DX, M_NONE
    CALL PRINT_MESSAGE

EXPLAIN:
    LEA DX, M_WHY
    CALL PRINT_MESSAGE

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

; -----------------------------------------------------------------------------
; PRINT_MESSAGE
;
; Prints the dollar terminated string at DS:DX, leaving AX exactly as it was.
;
; Service 09H needs the service number in AH, and AH is the top half of AX. A
; caller that has just computed a result into AX and then sets AH for itself
; destroys that result: 500 becomes 09F4H, which prints as 2548. Doing the call
; in here, around a push and a pop, removes the trap for good.
; -----------------------------------------------------------------------------
PRINT_MESSAGE PROC
    PUSH AX

    MOV AH, 09H
    INT 21H

    POP AX
    RET
PRINT_MESSAGE ENDP

END START

; =============================================================================
; TECHNICAL NOTES
; =============================================================================
; 1. Bounded by the shortest word:
;    - No prefix can be longer than the shortest string in the set.
;    - Finding that bound first stops the column loop reading past the end.
;    - Without it a padded buffer would appear to agree well beyond the real word.
; 2. Compare down, not across:
;    - Each column is checked across every word before moving to the next column.
;    - Comparing pairs of whole words instead would need the answers combined afterwards.
;    - This way the first disagreement anywhere ends the search immediately.
; 3. Fixed width entries:
;    - Every word occupies twelve bytes whether it needs them or not.
;    - That makes the address of word n column c a multiply and an add.
;    - The true lengths are kept separately, because the padding is not part of the word.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
