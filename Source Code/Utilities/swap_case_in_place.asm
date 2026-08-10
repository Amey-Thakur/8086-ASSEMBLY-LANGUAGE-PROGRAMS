; =============================================================================
; TITLE: Swapping The Case Of Every Letter In Place
; DESCRIPTION: Turns every capital into a small letter and every small letter
;              into a capital, in the buffer itself, by toggling the one bit
;              that separates the two cases.
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
    TEXTB   DB 'Amey Thakur, 8086 Assembly.'
    SPAN    EQU $ - TEXTB               ; Measured, never counted by hand

    RAISED  DW 0                        ; Small letters made capital
    DROPPED DW 0                        ; Capitals made small

    M_TITLE DB 'Every letter changes case, the rest is left alone'
            DB 0DH, 0AH, 0DH, 0AH, '$'
    M_FIRST DB 'Original:      $'
    M_SECND DB 'Swapped:       $'
    M_THIRD DB 'Swapped again: $'
    M_UP    DB 'Raised to capitals:   $'
    M_DOWN  DB 'Dropped to small:     $'
    M_LEFT  DB 'Left untouched:       $'
    M_BACK  DB 0DH, 0AH
            DB 'The second pass returns the buffer to what it was, because '
            DB 'toggling one bit twice restores it.', 0DH, 0AH, '$'

; -----------------------------------------------------------------------------
; CODE SEGMENT
; -----------------------------------------------------------------------------
.CODE
START:
    MOV AX, @DATA
    MOV DS, AX

    LEA DX, M_TITLE
    CALL PRINT_MESSAGE

    LEA DX, M_FIRST
    CALL PRINT_MESSAGE
    LEA SI, TEXTB
    MOV CX, SPAN
    CALL PRINT_TEXT
    CALL NEWLINE

    CALL SWAP_CASE

    LEA DX, M_SECND
    CALL PRINT_MESSAGE
    LEA SI, TEXTB
    MOV CX, SPAN
    CALL PRINT_TEXT
    CALL NEWLINE
    CALL SHOW_COUNTS

    CALL SWAP_CASE

    LEA DX, M_THIRD
    CALL PRINT_MESSAGE
    LEA SI, TEXTB
    MOV CX, SPAN
    CALL PRINT_TEXT
    CALL NEWLINE
    CALL SHOW_COUNTS

    LEA DX, M_BACK
    CALL PRINT_MESSAGE

    MOV AH, 4CH
    INT 21H

; -----------------------------------------------------------------------------
; SWAP_CASE
;
; Rewrites the buffer in place and records how many letters moved each way.
;
; A capital and its small letter differ in bit five alone, so one XOR does the
; conversion in either direction. The test for a letter has to come first: bit
; five means nothing in a digit or a comma, and toggling it there would turn
; the digits into punctuation.
; -----------------------------------------------------------------------------
SWAP_CASE PROC
    PUSH AX
    PUSH CX
    PUSH SI

    XOR AX, AX
    MOV RAISED, AX
    MOV DROPPED, AX

    LEA SI, TEXTB
    MOV CX, SPAN
    JCXZ SC_DONE                        ; A count of zero would loop 65536 times

SC_LOOP:
    MOV AL, [SI]

    ; Character codes are unsigned, so the unsigned family is the right one
    CMP AL, 'A'
    JB  SC_NEXT
    CMP AL, 'Z'
    JBE SC_CAPITAL
    CMP AL, 'a'
    JB  SC_NEXT                         ; The six codes between Z and a
    CMP AL, 'z'
    JA  SC_NEXT

    INC RAISED
    JMP SC_TOGGLE

SC_CAPITAL:
    INC DROPPED

SC_TOGGLE:
    XOR AL, 20H
    MOV [SI], AL

SC_NEXT:
    INC SI
    LOOP SC_LOOP

SC_DONE:
    POP SI
    POP CX
    POP AX
    RET
SWAP_CASE ENDP

; -----------------------------------------------------------------------------
; SHOW_COUNTS
;
; Reports the two counters and how many bytes the pass did not alter.
; -----------------------------------------------------------------------------
SHOW_COUNTS PROC
    PUSH AX
    PUSH DX

    LEA DX, M_UP
    CALL PRINT_MESSAGE
    MOV AX, RAISED
    CALL PRINT_DECIMAL
    CALL NEWLINE

    LEA DX, M_DOWN
    CALL PRINT_MESSAGE
    MOV AX, DROPPED
    CALL PRINT_DECIMAL
    CALL NEWLINE

    LEA DX, M_LEFT
    CALL PRINT_MESSAGE
    MOV AX, SPAN
    SUB AX, RAISED
    SUB AX, DROPPED
    CALL PRINT_DECIMAL
    CALL NEWLINE

    POP DX
    POP AX
    RET
SHOW_COUNTS ENDP

; -----------------------------------------------------------------------------
; PRINT_TEXT
;
; Prints CX characters starting at DS:SI. The buffer has no terminator, so the
; length has to be carried separately.
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
; 1. WHY BIT FIVE:
;    - ASCII was laid out so that a capital and its small letter differ in
;    - that bit alone, A being 41H and a being 61H. Adding or subtracting
;    - 32 does the same thing, but XOR needs no knowledge of the direction.
; 2. WHY THE RANGE TEST CANNOT BE SKIPPED:
;    - Bit five is set in most punctuation and in every digit. Toggling it
;    - in the digit 8, 38H, would give 18H, a control code. Only the two
;    - letter ranges may be touched.
; 3. WHY THE PASS IS ITS OWN INVERSE:
;    - Toggling a bit twice leaves it as it was, and the range test picks
;    - out the same bytes on the way back, so a second pass restores the
;    - buffer exactly. The two counters simply exchange values.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
