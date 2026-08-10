; =============================================================================
; TITLE: Reading a Number from Text
; DESCRIPTION: Turns a string of digits into a value, accepting a sign and
;              stopping at the first character that is not a digit.
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
    ONE     DB '4096', 0
    TWO     DB '-273', 0
    THREE   DB '31xyz', 0
    FOUR    DB 'abc', 0

    M_FROM  DB 'From "$'
    M_GOT   DB '" the value is $'

; -----------------------------------------------------------------------------
; CODE SEGMENT
; -----------------------------------------------------------------------------
.CODE
START:
    MOV AX, @DATA
    MOV DS, AX

    LEA SI, ONE
    CALL SHOW_CONVERSION
    LEA SI, TWO
    CALL SHOW_CONVERSION
    LEA SI, THREE
    CALL SHOW_CONVERSION
    LEA SI, FOUR
    CALL SHOW_CONVERSION

    MOV AH, 4CH
    INT 21H

; -----------------------------------------------------------------------------
; SHOW_CONVERSION
; -----------------------------------------------------------------------------
SHOW_CONVERSION PROC
    PUSH SI

    LEA DX, M_FROM
    MOV AH, 09H
    INT 21H

    POP SI
    PUSH SI
    CALL PRINT_ZERO_TERMINATED

    LEA DX, M_GOT
    MOV AH, 09H
    INT 21H

    POP SI
    CALL PARSE_INTEGER
    CALL PRINT_SIGNED_VALUE
    CALL NEWLINE
    RET
SHOW_CONVERSION ENDP

; -----------------------------------------------------------------------------
; PARSE_INTEGER
;
; SI points at a zero terminated string. The value comes back in AX.
; -----------------------------------------------------------------------------
PARSE_INTEGER PROC
    PUSH BX
    PUSH CX
    PUSH DX
    PUSH SI

    XOR BX, BX                          ; The value so far
    XOR CX, CX                          ; Whether it was negative

    CMP BYTE PTR [SI], '-'
    JNE PI_LOOP
    MOV CX, 1
    INC SI

PI_LOOP:
    MOV AL, [SI]

    ; -------------------------------------------------------------------------
    ; ANYTHING THAT IS NOT A DIGIT ENDS THE NUMBER, INCLUDING THE TERMINATOR.
    ; THAT ONE TEST COVERS BOTH THE END OF THE STRING AND A STRING THAT NEVER
    ; HELD A NUMBER AT ALL.
    ; -------------------------------------------------------------------------
    CMP AL, '0'
    JB  PI_FINISHED
    CMP AL, '9'
    JA  PI_FINISHED

    ; -------------------------------------------------------------------------
    ; TEN TIMES THE TOTAL PLUS THE NEW DIGIT. THE MULTIPLICATION IS DONE WITH
    ; TWO SHIFTS AND AN ADDITION, WHICH IS THE USUAL WAY IN A ROUTINE THAT
    ; RUNS ONCE PER CHARACTER.
    ; -------------------------------------------------------------------------
    MOV DX, BX
    SHL BX, 3                           ; Eight times
    SHL DX, 1                           ; Two times
    ADD BX, DX                          ; Ten times

    SUB AL, '0'
    XOR AH, AH
    ADD BX, AX

    INC SI
    JMP PI_LOOP

PI_FINISHED:
    MOV AX, BX
    OR  CX, CX
    JZ  PI_DONE
    NEG AX

PI_DONE:
    POP SI
    POP DX
    POP CX
    POP BX
    RET
PARSE_INTEGER ENDP

; -----------------------------------------------------------------------------
; PRINT_ZERO_TERMINATED
; -----------------------------------------------------------------------------
PRINT_ZERO_TERMINATED PROC
    PUSH AX
    PUSH DX
    PUSH SI

PZ_LOOP:
    MOV DL, [SI]
    OR  DL, DL
    JZ  PZ_DONE
    MOV AH, 02H
    INT 21H
    INC SI
    JMP PZ_LOOP

PZ_DONE:
    POP SI
    POP DX
    POP AX
    RET
PRINT_ZERO_TERMINATED ENDP

; -----------------------------------------------------------------------------
; PRINT_SIGNED_VALUE
; -----------------------------------------------------------------------------
PRINT_SIGNED_VALUE PROC
    PUSH AX
    PUSH DX

    OR  AX, AX
    JNS PS_POSITIVE

    PUSH AX
    MOV DL, '-'
    MOV AH, 02H
    INT 21H
    POP AX
    NEG AX

PS_POSITIVE:
    CALL PRINT_DECIMAL

    POP DX
    POP AX
    RET
PRINT_SIGNED_VALUE ENDP

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

END START

; =============================================================================
; TECHNICAL NOTES
; =============================================================================
; 1. THE ACCUMULATION:
;    - Each digit multiplies everything so far by ten and adds itself.
;    - Reading left to right needs no knowledge of how many digits are
;    - coming, which reading right to left would.
; 2. A STRING WITH NO DIGITS:
;    - The loop ends immediately and the total is nought, which is what
;    - this routine reports. A stricter one would distinguish that from
;    - the string "0", usually by returning a separate success flag.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
