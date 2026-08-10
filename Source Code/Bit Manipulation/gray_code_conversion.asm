; =============================================================================
; TITLE: Convert Between Binary and Gray Code
; DESCRIPTION: Turns a value into the reflected binary code in which successive
;              numbers differ in a single bit, and turns it back again with a
;              running exclusive or.
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
    SAMPLES DW 0B4D2H, 0007H, 0FFFFH, 8000H
    SPAN    EQU $ - SAMPLES             ; Measured, never counted by hand
    HOWMANY EQU SPAN / 2

    ROWS    EQU 16                      ; The whole four bit sequence

    M_HEAD1 DB 'Counting in binary, and the same count in Gray code'
            DB 0DH, 0AH, '$'
    M_HEAD2 DB 'Sixteen bit values, converted and converted back'
            DB 0DH, 0AH, '$'
    M_ARROW DB ' -> $'
    M_BACK  DB 'Every value returned to itself.', 0DH, 0AH, '$'
    M_LOST  DB 'A value failed to return to itself.', 0DH, 0AH, '$'

; -----------------------------------------------------------------------------
; CODE SEGMENT
; -----------------------------------------------------------------------------
.CODE
START:
    ; Context setup
    MOV AX, @DATA
    MOV DS, AX

    LEA DX, M_HEAD1
    CALL PRINT_MESSAGE

    ; -------------------------------------------------------------------------
    ; THE FOUR BIT SEQUENCE
    ;
    ; Printed in binary rather than in hexadecimal, because the property worth
    ; seeing is that exactly one column changes from each line to the next, and
    ; hexadecimal hides it.
    ; -------------------------------------------------------------------------
    XOR SI, SI

GRAY_ROW:
    MOV AX, SI
    CALL SHOW_FOUR_BITS
    LEA DX, M_ARROW
    CALL PRINT_MESSAGE

    MOV AX, SI
    CALL BINARY_TO_GRAY
    CALL SHOW_FOUR_BITS
    CALL NEWLINE

    INC SI
    CMP SI, ROWS
    JB  GRAY_ROW

    ; -------------------------------------------------------------------------
    ; THE ROUND TRIP ON WHOLE WORDS
    ; -------------------------------------------------------------------------
    LEA DX, M_HEAD2
    CALL PRINT_MESSAGE

    XOR SI, SI
    XOR DI, DI                          ; How many values failed to come back
    MOV CX, HOWMANY

EACH_WORD:
    MOV AX, SAMPLES[SI]
    CALL PRINT_HEX
    LEA DX, M_ARROW
    CALL PRINT_MESSAGE

    CALL BINARY_TO_GRAY
    CALL PRINT_HEX
    LEA DX, M_ARROW
    CALL PRINT_MESSAGE

    CALL GRAY_TO_BINARY
    CALL PRINT_HEX
    CALL NEWLINE

    CMP AX, SAMPLES[SI]
    JE  CAME_BACK
    INC DI

CAME_BACK:
    ADD SI, 2
    LOOP EACH_WORD

    OR  DI, DI
    JNZ SOMETHING_LOST
    LEA DX, M_BACK
    JMP REPORT_TRIP

SOMETHING_LOST:
    LEA DX, M_LOST

REPORT_TRIP:
    CALL PRINT_MESSAGE

    ; End process
    MOV AH, 4CH
    INT 21H

; -----------------------------------------------------------------------------
; BINARY_TO_GRAY
;
; Takes a value in AX and returns its Gray code in AX. BX is restored; AX is
; not, because it carries the answer out.
;
; Each Gray bit says whether its binary bit differs from the one above it, and
; an exclusive or against the value shifted down one place asks all sixteen of
; those questions at once.
; -----------------------------------------------------------------------------
BINARY_TO_GRAY PROC
    PUSH BX

    MOV BX, AX
    SHR BX, 1
    XOR AX, BX

    POP BX
    RET
BINARY_TO_GRAY ENDP

; -----------------------------------------------------------------------------
; GRAY_TO_BINARY
;
; Takes a Gray code in AX and returns the value it stands for in AX. BX is
; restored; AX is not, because it carries the answer out.
;
; Going back is not a single exclusive or, because a binary bit depends on
; every Gray bit above it and not merely on its neighbour. Folding the code
; down one place at a time accumulates exactly that running total.
; -----------------------------------------------------------------------------
GRAY_TO_BINARY PROC
    PUSH BX

    MOV BX, AX

GTB_FOLD:
    SHR BX, 1
    JZ  GTB_DONE                        ; Nothing above is left to contribute
    XOR AX, BX
    JMP GTB_FOLD

GTB_DONE:
    POP BX
    RET
GRAY_TO_BINARY ENDP

; -----------------------------------------------------------------------------
; SHOW_FOUR_BITS
;
; Prints the low four bits of AL as ones and zeros, most significant first.
;
; The nibble is lifted to the top of the byte first, so that each shift puts
; the next bit of interest into the carry flag and nothing else appears.
; -----------------------------------------------------------------------------
SHOW_FOUR_BITS PROC
    PUSH AX
    PUSH CX
    PUSH DX

    MOV CX, 4
    SHL AL, 4

SFB_NEXT:
    SHL AL, 1
    MOV DL, '0'                         ; A move leaves the carry alone
    JNC SFB_EMIT
    MOV DL, '1'

SFB_EMIT:
    PUSH AX
    MOV AH, 02H
    INT 21H
    POP AX
    LOOP SFB_NEXT

    POP DX
    POP CX
    POP AX
    RET
SHOW_FOUR_BITS ENDP

; -----------------------------------------------------------------------------
; PRINT_HEX
;
; Prints the value in AX as four hexadecimal digits followed by H.
; -----------------------------------------------------------------------------
PRINT_HEX PROC
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX

    MOV BX, AX                          ; Keep the value; AX is needed for DOS
    MOV CX, 4                           ; Four nibbles, most significant first

PH_NEXT:
    ROL BX, 4                           ; Bring the next nibble to the bottom
    MOV DL, BL
    AND DL, 0FH

    ADD DL, '0'                         ; 0 to 9 sit just after '0'
    CMP DL, '9'
    JBE PH_EMIT
    ADD DL, 7                           ; A to F sit seven further on

PH_EMIT:
    MOV AH, 02H
    INT 21H
    LOOP PH_NEXT

    MOV DL, 'H'
    MOV AH, 02H
    INT 21H

    POP DX
    POP CX
    POP BX
    POP AX
    RET
PRINT_HEX ENDP

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
; 1. WHAT THE CODE IS FOR:
;    - A shaft encoder or a mechanical counter reads its tracks at slightly
;    - different instants, so a plain binary reading taken as 0111 becomes 1000
;    - can be misread as anything between; one changing track removes that.
; 2. WHY THE TWO DIRECTIONS ARE NOT SYMMETRIC:
;    - Forward, each Gray bit depends only on two neighbouring binary bits, so
;    - one shift and one exclusive or finish the whole word.
;    - Backward, each binary bit depends on every Gray bit above it instead.
; 3. WHY THE FOLD ALWAYS STOPS:
;    - Every pass shifts the working copy one place to the right, so after at
;    - most sixteen passes it is zero whatever it began as.
;    - The zero flag left by the shift is the test, so no counter can be wrong.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
