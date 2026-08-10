; =============================================================================
; TITLE: Keeping The Flags Across A Call
; DESCRIPTION: A procedure that leaves the flags as it found them, and the same one that does not, compared on the same condition.
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
    M_TITLE DB 'A condition set before a call, and tested after it', 0DH, 0AH, '$'
    M_SET   DB 0DH, 0AH, 'SUB AX, AX sets the zero flag.', 0DH, 0AH, '$'
    M_CARE  DB 0DH, 0AH, 'After the careful procedure:  $'
    M_CARELESS DB 0DH, 0AH, 'After the careless one:       $'
    M_KEPT  DB 'still set, as it should be', 0DH, 0AH, '$'
    M_LOST  DB 'lost, and the test below is now wrong', 0DH, 0AH, '$'
    M_WORD  DB 0DH, 0AH, 'The flag word before the call: $'
    M_AFTER DB 0DH, 0AH, 'The flag word after the careful one: $'
    M_WHY   DB 0DH, 0AH, 0DH, 0AH
            DB 'PUSHF and POPF cost four bytes and two memory accesses. A '
            DB 'procedure that does arithmetic and does not save them cannot be '
            DB 'called between a comparison and its branch.', 0DH, 0AH, '$'

; -----------------------------------------------------------------------------
; CODE SEGMENT
; -----------------------------------------------------------------------------
.CODE
START:
    MOV AX, @DATA
    MOV DS, AX

    LEA DX, M_TITLE
    CALL PRINT_MESSAGE
    LEA DX, M_SET
    CALL PRINT_MESSAGE

    ; ---- the flag word itself, for the record -------------------------------
    SUB AX, AX
    PUSHF
    POP BX

    LEA DX, M_WORD
    CALL PRINT_MESSAGE
    MOV AX, BX
    CALL PRINT_HEX

    ; -------------------------------------------------------------------------
    ; THE CONDITION IS ESTABLISHED, THEN A PROCEDURE RUNS, THEN THE CONDITION IS
    ; TESTED. THAT IS THE SHAPE THAT MAKES FLAG PRESERVATION MATTER AT ALL.
    ; -------------------------------------------------------------------------
    SUB AX, AX                          ; Zero flag set
    CALL CAREFUL
    LEA DX, M_CARE
    CALL PRINT_MESSAGE
    JZ CAREFUL_KEPT
    LEA DX, M_LOST
    CALL PRINT_MESSAGE
    JMP TRY_CARELESS
CAREFUL_KEPT:
    LEA DX, M_KEPT
    CALL PRINT_MESSAGE

TRY_CARELESS:
    SUB AX, AX                          ; Zero flag set again
    CALL CARELESS
    LEA DX, M_CARELESS
    CALL PRINT_MESSAGE
    JZ CARELESS_KEPT
    LEA DX, M_LOST
    CALL PRINT_MESSAGE
    JMP SHOW_AFTER
CARELESS_KEPT:
    LEA DX, M_KEPT
    CALL PRINT_MESSAGE

SHOW_AFTER:
    SUB AX, AX
    CALL CAREFUL
    PUSHF
    POP BX
    LEA DX, M_AFTER
    CALL PRINT_MESSAGE
    MOV AX, BX
    CALL PRINT_HEX

    LEA DX, M_WHY
    CALL PRINT_MESSAGE

    MOV AH, 4CH
    INT 21H

; -----------------------------------------------------------------------------
; CAREFUL
;
; Does some arithmetic and leaves every flag exactly as it found it.
;
; PUSHF must come first, before anything alters them, and POPF last. The
; registers are saved inside that, which is the ordinary nesting.
; -----------------------------------------------------------------------------
CAREFUL PROC
    PUSHF
    PUSH AX
    PUSH BX

    MOV AX, 7
    MOV BX, 3
    ADD AX, BX                          ; Clears the zero flag
    CMP AX, 0                           ; And again, deliberately

    POP BX
    POP AX
    POPF
    RET
CAREFUL ENDP

; -----------------------------------------------------------------------------
; CARELESS
;
; The same arithmetic without saving the flags. It restores the registers, so it
; looks well behaved, and the damage is invisible until a caller branches on a
; condition it set before the call.
; -----------------------------------------------------------------------------
CARELESS PROC
    PUSH AX
    PUSH BX

    MOV AX, 7
    MOV BX, 3
    ADD AX, BX
    CMP AX, 0

    POP BX
    POP AX
    RET
CARELESS ENDP

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
; 1. Registers are not the whole state:
;    - A procedure that restores every register can still have destroyed the flags.
;    - The damage only shows when the caller branches on something set before the call.
;    - That makes it one of the hardest kinds of bug to attribute.
; 2. PUSHF outermost:
;    - It has to happen before any instruction in the body alters the flags.
;    - POPF has to be the last thing before RET, after the registers are back.
;    - Popping the flags before the registers would let the pops themselves change them.
; 3. Not every procedure needs it:
;    - A procedure whose whole purpose is to set a condition must not preserve them.
;    - A comparison helper returning its answer in the flags is the usual example.
;    - What matters is that the contract is stated, not that it is always the same.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
