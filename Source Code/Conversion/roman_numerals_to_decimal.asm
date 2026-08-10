; =============================================================================
; TITLE: Roman Numerals to Decimal
; DESCRIPTION: Reads a Roman numeral by adding each letter's value, unless it
;              is smaller than the one after it, in which case it is taken away.
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
    ONE     DB 'MCMXCIV'
    ONELEN  EQU $ - ONE
    TWO     DB 'MMXXII'
    TWOLEN  EQU $ - TWO
    THREE   DB 'XLIX'
    THREELEN EQU $ - THREE

    M_IS    DB ' is $'

; -----------------------------------------------------------------------------
; CODE SEGMENT
; -----------------------------------------------------------------------------
.CODE
START:
    MOV AX, @DATA
    MOV DS, AX

    LEA SI, ONE
    MOV CX, ONELEN
    CALL CONVERT_ONE

    LEA SI, TWO
    MOV CX, TWOLEN
    CALL CONVERT_ONE

    LEA SI, THREE
    MOV CX, THREELEN
    CALL CONVERT_ONE

    MOV AH, 4CH
    INT 21H

; -----------------------------------------------------------------------------
; CONVERT_ONE
;
; Prints the numeral at DS:SI of length CX, then its value.
; -----------------------------------------------------------------------------
CONVERT_ONE PROC
    PUSH SI
    PUSH CX

    CALL PRINT_TEXT
    LEA DX, M_IS
    MOV AH, 09H
    INT 21H

    POP CX
    POP SI

    CALL FROM_ROMAN
    CALL PRINT_DECIMAL
    CALL NEWLINE
    RET
CONVERT_ONE ENDP

; -----------------------------------------------------------------------------
; FROM_ROMAN
;
; SI points at CX Roman letters. The value comes back in AX.
; -----------------------------------------------------------------------------
FROM_ROMAN PROC
    PUSH BX
    PUSH CX
    PUSH DX
    PUSH SI

    XOR DI, DI                          ; The running total

FR_LOOP:
    JCXZ FR_DONE

    MOV AL, [SI]
    CALL ROMAN_VALUE                    ; AX = what this letter is worth
    MOV BX, AX

    ; -------------------------------------------------------------------------
    ; THE RULE IN ONE COMPARISON: A LETTER WORTH LESS THAN THE ONE AFTER IT IS
    ; SUBTRACTED RATHER THAN ADDED. THAT IS ALL THERE IS TO IV, IX, XL, XC,
    ; CD AND CM, AND NO LIST OF THEM IS NEEDED.
    ; -------------------------------------------------------------------------
    CMP CX, 1
    JE  FR_ADD                          ; The last letter is always added

    MOV AL, [SI+1]
    CALL ROMAN_VALUE
    CMP BX, AX
    JAE FR_ADD

    SUB DI, BX                          ; Smaller before larger, so take away
    JMP FR_NEXT

FR_ADD:
    ADD DI, BX

FR_NEXT:
    INC SI
    DEC CX
    JMP FR_LOOP

FR_DONE:
    MOV AX, DI

    POP SI
    POP DX
    POP CX
    POP BX
    RET
FROM_ROMAN ENDP

; -----------------------------------------------------------------------------
; ROMAN_VALUE
;
; Turns the letter in AL into its value, in AX.
; -----------------------------------------------------------------------------
ROMAN_VALUE PROC
    CMP AL, 'I'
    JNE RV_TRY_V
    MOV AX, 1
    RET

RV_TRY_V:
    CMP AL, 'V'
    JNE RV_TRY_X
    MOV AX, 5
    RET

RV_TRY_X:
    CMP AL, 'X'
    JNE RV_TRY_L
    MOV AX, 10
    RET

RV_TRY_L:
    CMP AL, 'L'
    JNE RV_TRY_C
    MOV AX, 50
    RET

RV_TRY_C:
    CMP AL, 'C'
    JNE RV_TRY_D
    MOV AX, 100
    RET

RV_TRY_D:
    CMP AL, 'D'
    JNE RV_TRY_M
    MOV AX, 500
    RET

RV_TRY_M:
    CMP AL, 'M'
    JNE RV_UNKNOWN
    MOV AX, 1000
    RET

RV_UNKNOWN:
    XOR AX, AX                          ; Not a numeral, so worth nothing
    RET
ROMAN_VALUE ENDP

; -----------------------------------------------------------------------------
; PRINT_TEXT
;
; Prints CX characters starting at DS:SI. Both are left as they were found.
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

END START

; =============================================================================
; TECHNICAL NOTES
; =============================================================================
; 1. ONE LOOKAHEAD IS ENOUGH:
;    - Comparing each letter with the next decides between adding and
;    - subtracting. No numeral needs more context than that, which is
;    - why the whole reading is a single pass.
; 2. IT ACCEPTS MORE THAN IT SHOULD:
;    - IIII and IM both produce a number here, though neither is a valid
;    - numeral. Reading is deliberately more forgiving than writing,
;    - which is the usual arrangement.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
