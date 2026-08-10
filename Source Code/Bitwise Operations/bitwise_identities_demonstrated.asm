; =============================================================================
; TITLE: The Bitwise Identities Worth Knowing
; DESCRIPTION: Six identities that turn a loop into a single instruction, each demonstrated on real values rather than asserted.
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
    SAMPLE  DW 0B4D0H, 0080H, 0FFFFH, 0001H, 1000H, 0000H
    HOWMANY EQU 6

    M_TITLE DB 'Six identities, checked on six values', 0DH, 0AH, '$'
    M_HEAD  DB 0DH, 0AH
            DB '  x      x&(x-1)  x&(-x)   x|(x-1)  x^(x-1)  x&(x+1)', 0DH, 0AH
            DB '         clear     lowest   fill      mask     clear', 0DH, 0AH
            DB '         lowest    set bit  below     to low   lowest run'
            DB 0DH, 0AH, '$'
    M_GAP   DB '   $'
    M_NOTE1 DB 0DH, 0AH, 'x AND (x-1) clears the lowest set bit, so it is zero '
            DB 'exactly when x is a power of two or zero.', 0DH, 0AH, '$'
    M_NOTE2 DB 'x AND minus x leaves only the lowest set bit, which is how a '
            DB 'scheduler picks the next ready task.', 0DH, 0AH, '$'
    M_NOTE3 DB 'x XOR (x-1) covers the lowest set bit and everything below it, '
            DB 'which gives a mask in one instruction.', 0DH, 0AH, '$'

; -----------------------------------------------------------------------------
; CODE SEGMENT
; -----------------------------------------------------------------------------
.CODE
START:
    MOV AX, @DATA
    MOV DS, AX

    LEA DX, M_TITLE
    CALL PRINT_MESSAGE
    LEA DX, M_HEAD
    CALL PRINT_MESSAGE

    XOR SI, SI
    MOV CX, HOWMANY

EACH_VALUE:
    PUSH CX

    MOV AX, SAMPLE[SI]
    CALL PRINT_HEX
    LEA DX, M_GAP
    CALL PRINT_MESSAGE

    ; ---- clear the lowest set bit -------------------------------------------
    MOV AX, SAMPLE[SI]
    MOV BX, AX
    DEC BX
    AND AX, BX
    CALL PRINT_HEX
    LEA DX, M_GAP
    CALL PRINT_MESSAGE

    ; ---- isolate the lowest set bit -----------------------------------------
    MOV AX, SAMPLE[SI]
    MOV BX, AX
    NEG BX
    AND AX, BX
    CALL PRINT_HEX
    LEA DX, M_GAP
    CALL PRINT_MESSAGE

    ; ---- fill in everything below the lowest set bit ------------------------
    MOV AX, SAMPLE[SI]
    MOV BX, AX
    DEC BX
    OR AX, BX
    CALL PRINT_HEX
    LEA DX, M_GAP
    CALL PRINT_MESSAGE

    ; ---- a mask covering the lowest set bit and below -----------------------
    MOV AX, SAMPLE[SI]
    MOV BX, AX
    DEC BX
    XOR AX, BX
    CALL PRINT_HEX
    LEA DX, M_GAP
    CALL PRINT_MESSAGE

    ; ---- clear the lowest run of ones ---------------------------------------
    MOV AX, SAMPLE[SI]
    MOV BX, AX
    INC BX
    AND AX, BX
    CALL PRINT_HEX
    CALL NEWLINE

    ADD SI, 2
    POP CX
    LOOP EACH_VALUE

    LEA DX, M_NOTE1
    CALL PRINT_MESSAGE
    LEA DX, M_NOTE2
    CALL PRINT_MESSAGE
    LEA DX, M_NOTE3
    CALL PRINT_MESSAGE

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
; 1. Why subtracting one is so useful:
;    - One less than a value flips its lowest set bit and sets everything below it.
;    - ANDing therefore clears that bit, ORing fills below it, and XORing covers both.
;    - Three different identities out of the same single subtraction.
; 2. Negation isolates:
;    - Minus x is the complement plus one, so it agrees with x only at the lowest set bit.
;    - ANDing the two leaves exactly that bit and nothing else.
;    - This is how a ready queue held as a bit mask finds its next task.
; 3. The zero case:
;    - Zero AND minus zero is zero, and zero AND minus one is zero.
;    - So every identity here is well behaved at zero rather than needing a guard.
;    - The last row of the table shows it rather than claiming it.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
