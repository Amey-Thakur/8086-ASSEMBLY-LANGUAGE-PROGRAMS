; =============================================================================
; TITLE: Printing Signed Numbers
; DESCRIPTION: A negative word printed as unsigned reads as a large positive one, so the sign has to be handled deliberately.
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
    DATA_W  DW 0, 1, -1, 100, -100, 32767, -32768, -12345
    HOWMANY EQU 8

    M_TITLE DB 'The same words read as signed and as unsigned', 0DH, 0AH, '$'
    M_HEAD  DB 0DH, 0AH, 'signed, then the same bits unsigned, then in hex:'
            DB 0DH, 0AH, '$'
    M_GAP1  DB '   =   $'
    M_GAP2  DB '   =   $'
    M_WHY   DB 0DH, 0AH
            DB 'The bits are identical. Only the interpretation differs, which '
            DB 'is why the choice of jump family matters so much.', 0DH, 0AH, '$'
    M_EDGE  DB 'Minus 32768 has no positive counterpart, so negating it leaves '
            DB 'it unchanged.', 0DH, 0AH, '$'

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
    MOV AX, DATA_W[SI]
    CALL PRINT_SIGNED
    LEA DX, M_GAP1
    CALL PRINT_MESSAGE

    MOV AX, DATA_W[SI]
    CALL PRINT_DECIMAL
    LEA DX, M_GAP2
    CALL PRINT_MESSAGE

    MOV AX, DATA_W[SI]
    CALL PRINT_HEX
    CALL NEWLINE

    ADD SI, 2
    LOOP EACH_VALUE

    LEA DX, M_WHY
    CALL PRINT_MESSAGE
    LEA DX, M_EDGE
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
; PRINT_SIGNED
;
; Prints AX as a signed value, with a minus sign when it is negative.
; -----------------------------------------------------------------------------
PRINT_SIGNED PROC
    PUSH AX
    PUSH DX

    OR  AX, AX
    JNS PS_POSITIVE                     ; Sign flag clear means not negative

    PUSH AX
    MOV DL, '-'
    MOV AH, 02H
    INT 21H
    POP AX
    NEG AX                              ; Print the magnitude

PS_POSITIVE:
    CALL PRINT_DECIMAL

    POP DX
    POP AX
    RET
PRINT_SIGNED ENDP

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
; 1. The bits do not change:
;    - Minus one and 65535 are the same sixteen bits, FFFFh.
;    - Printing is where the interpretation is chosen, not storage.
;    - So a program must know which it means before it prints or compares.
; 2. Printing a signed value:
;    - Test the sign bit, print a minus, negate, then print the magnitude.
;    - NEG is the instruction for that, and it sets the flags as a subtraction would.
;    - The magnitude of a negative word can still be printed unsigned once negated.
; 3. The one value that cannot be negated:
;    - Minus 32768 is 8000h, and its positive counterpart needs seventeen bits.
;    - NEG leaves it as 8000h and sets the overflow flag to say so.
;    - Any signed arithmetic has to allow for that single asymmetric case.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
