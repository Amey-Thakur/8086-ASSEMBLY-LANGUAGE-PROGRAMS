; =============================================================================
; TITLE: Fill A Block With A Repeating Word Pattern
; DESCRIPTION: Lays a two byte pattern across a block with STOSW, which does
;              half as many stores as STOSB, and stores the odd byte on its own
;              when the block does not divide evenly into words.
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
    WIDE_B  DB 32 DUP('.')               ; Stops, so an unfilled byte would show
    WIDE_W  EQU $ - WIDE_B               ; 32 bytes
    WIDE_P  EQU WIDE_W / 2               ; and so 16 whole words

    ODD_B   DB 9 DUP('.')
    ODD_W   EQU $ - ODD_B                ; 9 bytes, which words cannot cover
    ODD_P   EQU ODD_W / 2                ; 4 whole words, one byte left over

    PAIR    DW 4241H                     ; 41H is 'A' and 42H is 'B'
    PAIR2   DW 5958H                     ; 58H is 'X' and 59H is 'Y'

    M_WIDE  DB 'Even block, bytes: $'
    M_ODD   DB 'Odd block, bytes:  $'
    M_WORDS DB '   words stored: $'
    M_TAIL  DB '   lone bytes stored: $'

; -----------------------------------------------------------------------------
; CODE SEGMENT
; -----------------------------------------------------------------------------
.CODE
START:
    MOV AX, @DATA
    MOV DS, AX
    MOV ES, AX                          ; STOSW stores at ES:DI and nowhere else

    ; -------------------------------------------------------------------------
    ; A WORD IS HELD LOW BYTE FIRST, SO THE WORD 4241H PUTS 'A' DOWN AND THEN
    ; 'B'. READ BACK AS TEXT THE BLOCK THEREFORE SPELLS THE PAIR OVER AND OVER,
    ; WHICH MAKES THE ORDER OF THE TWO BYTES VISIBLE RATHER THAN ASSUMED.
    ; -------------------------------------------------------------------------
    MOV AX, PAIR
    LEA DI, WIDE_B
    MOV CX, WIDE_P
    CLD
    REP STOSW                           ; REP tests CX first, so a count of none
                                        ; stores nothing, unlike LOOP

    LEA DX, M_WIDE
    CALL PRINT_MESSAGE
    MOV AX, WIDE_W
    CALL PRINT_DECIMAL
    LEA DX, M_WORDS
    CALL PRINT_MESSAGE
    MOV AX, WIDE_P
    CALL PRINT_DECIMAL
    CALL NEWLINE

    LEA SI, WIDE_B
    MOV CX, WIDE_W
    CALL PRINT_TEXT
    CALL NEWLINE

    ; -------------------------------------------------------------------------
    ; AN ODD COUNT CANNOT BE COVERED BY WORDS ALONE. THE REMAINDER IS FOUND BY
    ; TESTING THE BOTTOM BIT, WHICH IS CHEAPER THAN A DIVISION AND CANNOT FAIL.
    ; -------------------------------------------------------------------------
    MOV AX, ODD_W
    AND AX, 1
    MOV BP, AX                          ; One when a lone byte is left over

    MOV AX, PAIR2
    LEA DI, ODD_B
    MOV CX, ODD_P
    CLD
    REP STOSW

    ; STOSW never alters AX, so the low half of the pattern is still in AL and
    ; the remaining byte can be stored straight away. DI is already in place.
    CMP BP, 0
    JE  ODD_FILLED
    STOSB

ODD_FILLED:
    LEA DX, M_ODD
    CALL PRINT_MESSAGE
    MOV AX, ODD_W
    CALL PRINT_DECIMAL
    LEA DX, M_WORDS
    CALL PRINT_MESSAGE
    MOV AX, ODD_P
    CALL PRINT_DECIMAL
    LEA DX, M_TAIL
    CALL PRINT_MESSAGE
    MOV AX, BP
    CALL PRINT_DECIMAL
    CALL NEWLINE

    LEA SI, ODD_B
    MOV CX, ODD_W
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
; 1. Why the pattern reads the way it does:
;    - The 8086 stores the low byte of a word at the lower address.
;    - So 4241H places 41H first and 42H second, which spells A then B.
;    - Writing 4142H instead would fill the block with B then A throughout.
; 2. Words against bytes:
;    - STOSW moves two bytes per store, so the count in CX is halved.
;    - Halving the number of stores halves the loop overhead with them.
;    - The saving is only available while the count divides evenly by two.
; 3. The odd byte at the end:
;    - Testing the bottom bit answers the question with one instruction.
;    - STOSW leaves AX alone, so AL still holds the byte that has to go down.
;    - DI is left pointing at the gap, so the single STOSB needs no setting up.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
