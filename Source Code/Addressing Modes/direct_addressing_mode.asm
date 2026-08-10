; =============================================================================
; TITLE: Direct Addressing Mode
; DESCRIPTION: The address is a fixed number written into the instruction by the assembler, which is what a plain variable name means.
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
    FIRST   DW 4321
    SECOND  DW 1234
    TALLY   DW 0

    M_TITLE DB 'Direct addressing: the assembler writes the address down', 0DH, 0AH, '$'
    M_READ  DB 'MOV AX, FIRST        AX = $'
    M_WRITE DB 'MOV FIRST, 8765      FIRST = $'
    M_BOTH  DB 'FIRST + SECOND       = $'
    M_SAME  DB 'Two reads of one name always agree: $'
    M_AND   DB ' and $'
    M_TALLY DB 'A running total kept in memory: $'

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
    ; A NAME ON ITS OWN IS A DIRECT REFERENCE. THE ASSEMBLER REPLACES IT WITH
    ; THE OFFSET IT ALLOCATED, SO THE INSTRUCTION CARRIES A FIXED SIXTEEN BIT
    ; ADDRESS AND THE PROCESSOR ADDS ONLY THE SEGMENT BASE.
    ; -------------------------------------------------------------------------
    MOV AX, FIRST
    LEA DX, M_READ
    CALL PRINT_MESSAGE
    CALL PRINT_DECIMAL
    CALL NEWLINE

    ; The same name as a destination stores rather than loads.
    MOV FIRST, 8765
    LEA DX, M_WRITE
    CALL PRINT_MESSAGE
    MOV AX, FIRST
    CALL PRINT_DECIMAL
    CALL NEWLINE

    ; Two direct operands in one instruction are not allowed, so the sum goes
    ; through a register. This is the rule that shapes most 8086 arithmetic.
    MOV AX, FIRST
    ADD AX, SECOND
    LEA DX, M_BOTH
    CALL PRINT_MESSAGE
    CALL PRINT_DECIMAL
    CALL NEWLINE

    LEA DX, M_SAME

    CALL PRINT_MESSAGE
    MOV AX, SECOND
    CALL PRINT_DECIMAL
    LEA DX, M_AND
    CALL PRINT_MESSAGE
    MOV BX, SECOND
    MOV AX, BX
    CALL PRINT_DECIMAL
    CALL NEWLINE

    ; -------------------------------------------------------------------------
    ; A DIRECT LOCATION SURVIVES BETWEEN ITERATIONS WITHOUT TYING UP A
    ; REGISTER, WHICH IS THE USUAL REASON TO PREFER IT TO A REGISTER.
    ; -------------------------------------------------------------------------
    MOV CX, 5
ACCUMULATE:
    MOV AX, TALLY
    ADD AX, CX
    MOV TALLY, AX
    LOOP ACCUMULATE

    LEA DX, M_TALLY

    CALL PRINT_MESSAGE
    MOV AX, TALLY
    CALL PRINT_DECIMAL
    CALL NEWLINE

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
; 1. A name is an address:
;    - FIRST is not a variable in the high level sense but a fixed offset.
;    - MOV AX, FIRST reads the word there; MOV AX, OFFSET FIRST loads the number itself.
;    - Confusing the two is the most common mistake beginners make with this mode.
; 2. One memory operand per instruction:
;    - The 8086 cannot add one memory word to another in a single instruction.
;    - FIRST + SECOND therefore becomes a load, an add against memory, and a store.
;    - Every arithmetic sequence in this repository is shaped by that limit.
; 3. Segment defaults:
;    - A direct reference uses DS unless a prefix says otherwise.
;    - That is why every program sets DS from @DATA before touching its data.
;    - Forgetting it reads whatever the loader happened to leave in DS.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
