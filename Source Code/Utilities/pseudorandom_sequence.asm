; =============================================================================
; TITLE: Pseudorandom Numbers From A Visible Seed
; DESCRIPTION: A linear congruential generator whose seed is printed and can be
;              set again, so any run of the sequence can be reproduced.
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
    SEED    DW 1                        ; The entire state of the generator
    MULTBY  DW 25173                    ; Multiplier and increment of a period
    ADDEND  DW 13849                    ; sixteen generator, both chosen to be
    FACES   DW 6                        ; odd so the full cycle is reached
    HOWMANY EQU 8

    M_TITLE DB 'A linear congruential generator', 0DH, 0AH, '$'
    M_RULE  DB 'Rule: next = (25173 * current + 13849) mod 65536', 0DH, 0AH, '$'
    M_SEED  DB 'Seed: $'
    M_HEAD  DB 0DH, 0AH
            DB 'value, then a die face taken from the high byte:', 0DH, 0AH, '$'
    M_FACE  DB '   face $'
    M_AGAIN DB 0DH, 0AH
            DB 'Seeded with 1 again, the first three values repeat:'
            DB 0DH, 0AH, '$'
    M_OTHER DB 0DH, 0AH
            DB 'Seeded with 2026, the same three positions differ:'
            DB 0DH, 0AH, '$'
    M_SPACE DB ' $'

; -----------------------------------------------------------------------------
; CODE SEGMENT
; -----------------------------------------------------------------------------
.CODE
START:
    MOV AX, @DATA
    MOV DS, AX

    LEA DX, M_TITLE
    CALL PRINT_MESSAGE
    LEA DX, M_RULE
    CALL PRINT_MESSAGE

    ; -------------------------------------------------------------------------
    ; THE SEED IS PRINTED BEFORE ANYTHING IS DRAWN FROM IT. A GENERATOR WHOSE
    ; SEED IS NOT RECORDED CANNOT BE RUN AGAIN, WHICH MAKES A FAILING TEST
    ; IMPOSSIBLE TO REPEAT.
    ; -------------------------------------------------------------------------
    LEA DX, M_SEED
    CALL PRINT_MESSAGE
    MOV AX, SEED
    CALL PRINT_DECIMAL
    CALL NEWLINE

    LEA DX, M_HEAD
    CALL PRINT_MESSAGE

    MOV CX, HOWMANY

DRAW_LOOP:
    CALL NEXT_RANDOM                    ; AX holds the new state
    CALL PRINT_DECIMAL                  ; and survives the call unchanged

    LEA DX, M_FACE
    CALL PRINT_MESSAGE
    CALL TO_FACE
    CALL PRINT_DECIMAL
    CALL NEWLINE

    LOOP DRAW_LOOP

    ; -------------------------------------------------------------------------
    ; PUTTING THE SEED BACK REWINDS THE SEQUENCE EXACTLY, BECAUSE THE STATE IS
    ; THE SEED AND NOTHING ELSE.
    ; -------------------------------------------------------------------------
    LEA DX, M_AGAIN
    CALL PRINT_MESSAGE
    MOV AX, 1
    MOV SEED, AX
    MOV CX, 3
    CALL SHOW_RUN

    LEA DX, M_OTHER
    CALL PRINT_MESSAGE
    MOV AX, 2026
    MOV SEED, AX
    MOV CX, 3
    CALL SHOW_RUN

    MOV AH, 4CH
    INT 21H

; -----------------------------------------------------------------------------
; NEXT_RANDOM
;
; Advances the generator one step and returns the new state in AX.
;
; MUL leaves the full thirty two bit product in DX:AX. Discarding DX is the
; modulo by 65536, and the carry lost by the addition is discarded for the same
; reason, so no explicit division is needed anywhere.
; -----------------------------------------------------------------------------
NEXT_RANDOM PROC
    PUSH DX

    MOV AX, SEED
    MUL MULTBY                          ; DX:AX, of which only AX is wanted
    ADD AX, ADDEND
    MOV SEED, AX

    POP DX
    RET
NEXT_RANDOM ENDP

; -----------------------------------------------------------------------------
; TO_FACE
;
; Turns the value in AX into a die face from one to six.
;
; The high byte is used rather than the whole word. With a modulus that is a
; power of two the low bit of this generator alternates on every single step,
; so a face taken from the bottom of the word would alternate with it.
; -----------------------------------------------------------------------------
TO_FACE PROC
    PUSH BX
    PUSH DX

    MOV AL, AH                          ; Keep the top byte only
    XOR AH, AH
    XOR DX, DX                          ; DX:AX is the dividend, so clear DX
    MOV BX, FACES
    DIV BX
    MOV AX, DX                          ; The remainder is the face, from 0 to 5
    INC AX

    POP DX
    POP BX
    RET
TO_FACE ENDP

; -----------------------------------------------------------------------------
; SHOW_RUN
;
; Prints the next CX values on one line, separated by spaces.
; -----------------------------------------------------------------------------
SHOW_RUN PROC
    PUSH AX
    PUSH CX
    PUSH DX

    JCXZ SR_DONE                        ; A count of zero would loop 65536 times

SR_LOOP:
    CALL NEXT_RANDOM
    CALL PRINT_DECIMAL
    LEA DX, M_SPACE
    CALL PRINT_MESSAGE
    LOOP SR_LOOP

SR_DONE:
    CALL NEWLINE

    POP DX
    POP CX
    POP AX
    RET
SHOW_RUN ENDP

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
; 1. WHY THE MULTIPLIER AND THE INCREMENT ARE NOT ARBITRARY:
;    - A modulus of 65536 gives the full period only when the increment is
;    - odd and the multiplier leaves a remainder of one when divided by four.
;    - 25173 and 13849 satisfy both, so all 65536 states are visited.
; 2. WHY THE HIGH BYTE IS USED FOR THE DIE:
;    - The low bits of a power of two modulus generator have very short
;    - cycles, the lowest bit merely alternating. The high bits carry the
;    - whole of the state, so a face taken from them looks far more random.
; 3. THE BIAS THAT REMAINS:
;    - 256 is not a multiple of 6, so faces one to four occur 43 times in
;    - the byte range and faces five and six occur 42 times. Rejecting the
;    - four values above 251 would remove that bias at the cost of a retry.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
