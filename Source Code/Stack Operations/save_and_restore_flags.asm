; =============================================================================
; TITLE: Saving And Restoring The Flags
; DESCRIPTION: PUSHF and POPF put the whole flag word on the stack, which lets a routine test something without disturbing a result.
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
    M_TITLE DB 'PUSHF and POPF carry all nine flags at once', 0DH, 0AH, '$'
    M_SET   DB 'After SUB AX, AX the zero flag is set.', 0DH, 0AH, '$'
    M_KEPT  DB 'PUSHF saved it, a CMP that clears it ran, POPF put it back.', 0DH, 0AH, '$'
    M_YES   DB 'The zero flag survived: correct.', 0DH, 0AH, '$'
    M_NO    DB 'The zero flag was lost: wrong.', 0DH, 0AH, '$'
    M_WORD  DB 'The flag word itself, as a hex number: $'
    M_CARRY DB 'STC then PUSHF then CLC then POPF leaves carry: $'
    M_ONE   DB 'set', 0DH, 0AH, '$'
    M_ZERO  DB 'clear', 0DH, 0AH, '$'

; -----------------------------------------------------------------------------
; CODE SEGMENT
; -----------------------------------------------------------------------------
.CODE
START:
    MOV AX, @DATA
    MOV DS, AX

    LEA DX, M_TITLE
    CALL PRINT_MESSAGE

    ; -------------------------------------------------------------------------
    ; A CONDITION IS OFTEN ESTABLISHED IN ONE PLACE AND ACTED ON IN ANOTHER,
    ; WITH WORK IN BETWEEN THAT WOULD OVERWRITE IT. PUSHF IS HOW THAT WORK IS
    ; MADE HARMLESS.
    ; -------------------------------------------------------------------------
    SUB AX, AX                          ; Zero flag set
    LEA DX, M_SET
    CALL PRINT_MESSAGE

    PUSHF                               ; Keep the condition
    MOV BX, 5
    CMP BX, 3                           ; Clears the zero flag
    POPF                                ; And put it back

    LEA DX, M_KEPT
    CALL PRINT_MESSAGE

    JZ SURVIVED
    LEA DX, M_NO
    CALL PRINT_MESSAGE
    JMP FLAG_WORD

SURVIVED:
    LEA DX, M_YES
    CALL PRINT_MESSAGE

FLAG_WORD:
    ; -------------------------------------------------------------------------
    ; POPPING THE SAVED WORD INTO A GENERAL REGISTER INSTEAD OF BACK INTO THE
    ; FLAGS IS HOW A PROGRAM READS ITS OWN FLAGS. THERE IS NO OTHER WAY TO GET
    ; ALL OF THEM AT ONCE.
    ; -------------------------------------------------------------------------
    PUSHF
    POP AX
    LEA DX, M_WORD
    CALL PRINT_MESSAGE
    CALL PRINT_HEX
    CALL NEWLINE

    ; -------------------------------------------------------------------------
    ; THE SAME TRICK WITH THE CARRY FLAG, WHICH IS THE ONE MOST OFTEN CARRIED
    ; ACROSS A CALL BY MULTIPLE PRECISION ARITHMETIC.
    ; -------------------------------------------------------------------------
    STC
    PUSHF
    CLC                                 ; Deliberately destroy it
    POPF                                ; And recover it

    LEA DX, M_CARRY
    CALL PRINT_MESSAGE
    JC CARRY_SET
    LEA DX, M_ZERO
    CALL PRINT_MESSAGE
    JMP DONE

CARRY_SET:
    LEA DX, M_ONE
    CALL PRINT_MESSAGE

DONE:
    MOV AH, 4CH
    INT 21H

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
; 1. One word, nine flags:
;    - Carry, parity, auxiliary, zero, sign, trap, interrupt, direction and overflow.
;    - The unused bits read back as whatever the processor puts there.
;    - PUSHF and POPF move all of them together; there is no way to save just one.
; 2. Reading your own flags:
;    - PUSHF followed by POP AX is the only way to see the flag word as data.
;    - LAHF loads the low byte into AH, which covers five of the flags but not overflow.
;    - The reverse pair, PUSH AX and POPF, sets the flags from a computed value.
; 3. Where it earns its place:
;    - An interrupt handler must leave the flags exactly as it found them.
;    - A procedure that compares something internally would otherwise clobber the caller test.
;    - Multiple precision addition needs the carry to survive anything between the two adds.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
