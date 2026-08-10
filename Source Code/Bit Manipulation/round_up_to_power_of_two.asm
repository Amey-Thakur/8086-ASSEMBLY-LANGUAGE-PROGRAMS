; =============================================================================
; TITLE: Round a Value Up to the Next Power of Two
; DESCRIPTION: Smears the highest set bit downward so that the value becomes a
;              run of ones, then adds one to carry it up to the power of two
;              above, and reports the case that will not fit in a word.
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
    SAMPLES DW 0, 1, 2, 3, 5, 17, 1000, 4096, 32768, 32769
    SPAN    EQU $ - SAMPLES             ; Measured, never counted by hand
    HOWMANY EQU SPAN / 2

    M_TITLE DB 'The smallest power of two that is not smaller than each value'
            DB 0DH, 0AH, '$'
    M_UP    DB ' rounds up to $'
    M_HEX   DB ', which is $'
    M_OVER  DB ' would need 65536, which does not fit in sixteen bits$'

; -----------------------------------------------------------------------------
; CODE SEGMENT
; -----------------------------------------------------------------------------
.CODE
START:
    ; Context setup
    MOV AX, @DATA
    MOV DS, AX

    LEA DX, M_TITLE
    CALL PRINT_MESSAGE

    XOR SI, SI
    MOV CX, HOWMANY

EACH_VALUE:
    MOV AX, SAMPLES[SI]
    CALL PRINT_DECIMAL                  ; The printers leave AX as they found it
    CALL ROUND_UP

    OR  AX, AX
    JZ  WILL_NOT_FIT                    ; Zero back means the answer needed a
                                        ; seventeenth bit

    LEA DX, M_UP
    CALL PRINT_MESSAGE
    CALL PRINT_DECIMAL
    LEA DX, M_HEX
    CALL PRINT_MESSAGE
    CALL PRINT_HEX
    JMP END_OF_ROW

WILL_NOT_FIT:
    LEA DX, M_OVER
    CALL PRINT_MESSAGE

END_OF_ROW:
    CALL NEWLINE
    ADD SI, 2
    LOOP EACH_VALUE

    ; End process
    MOV AH, 4CH
    INT 21H

; -----------------------------------------------------------------------------
; ROUND_UP
;
; Takes a value in AX and returns the smallest power of two that is not smaller
; than it, or zero when that power of two is 65536 and will not fit in a word.
; BX is restored; AX is not, because it carries the answer out.
;
; The decrement at the start is what makes a value that is already a power of
; two answer with itself rather than with the next one up.
; -----------------------------------------------------------------------------
ROUND_UP PROC
    PUSH BX

    OR  AX, AX
    JZ  RU_ZERO                         ; Nothing to smear, and the smear of a
                                        ; borrowed word would give the wrong
                                        ; answer entirely

    DEC AX

    ; -------------------------------------------------------------------------
    ; THE SMEAR
    ;
    ; Each step copies the value down by twice as many places as the last and
    ; folds it in, so after four steps every bit below the highest one is set.
    ; Doubling the distance is what covers sixteen bits in four steps instead
    ; of fifteen.
    ; -------------------------------------------------------------------------
    MOV BX, AX
    SHR BX, 1
    OR  AX, BX

    MOV BX, AX
    SHR BX, 2
    OR  AX, BX

    MOV BX, AX
    SHR BX, 4
    OR  AX, BX

    MOV BX, AX
    SHR BX, 8
    OR  AX, BX

    INC AX                              ; A run of ones plus one is the power of
                                        ; two above it, and a full word of ones
                                        ; wraps to zero, which is the signal the
                                        ; caller tests for
    JMP RU_DONE

RU_ZERO:
    MOV AX, 1                           ; One is the smallest power of two, and
                                        ; it is not smaller than zero

RU_DONE:
    POP BX
    RET
ROUND_UP ENDP

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
; 1. WHY THE VALUE IS DECREMENTED FIRST:
;    - Without it, 4096 would smear to 8191 and answer 8192, which is the next
;    - power of two rather than the smallest one that is large enough.
;    - Taking one off first changes nothing for any value that is not one.
; 2. WHY THE STEPS DOUBLE:
;    - After shifting down by one, the top two bits are set; folding that in at
;    - two places sets four, then eight, then all sixteen.
;    - Fifteen shifts of one place would agree and cost four times as much.
; 3. THE CASE THAT CANNOT BE ANSWERED:
;    - Anything above 32768 rounds up to 65536, which needs seventeen bits.
;    - The smear leaves a full word of ones, so the increment wraps to zero and
;    - that zero is a reliable signal rather than a wrong number.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
