; =============================================================================
; TITLE: Converting Between Temperature Scales
; DESCRIPTION: Converts Celsius to Fahrenheit and to Kelvin, using integer
;              arithmetic ordered so that no precision is thrown away early.
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
    READINGS DW -40, 0, 37, 100, 25
    HOWMANY  EQU 5

    M_C     DB 'C: $'
    M_F     DB '   F: $'
    M_K     DB '   K: $'

; -----------------------------------------------------------------------------
; CODE SEGMENT
; -----------------------------------------------------------------------------
.CODE
START:
    MOV AX, @DATA
    MOV DS, AX

    LEA SI, READINGS
    MOV CX, HOWMANY

EACH:
    MOV BX, [SI]                        ; The Celsius reading

    PUSH CX
    PUSH SI

    LEA DX, M_C
    MOV AH, 09H
    INT 21H
    MOV AX, BX
    CALL PRINT_SIGNED_VALUE

    ; -------------------------------------------------------------------------
    ; FAHRENHEIT IS NINE FIFTHS OF CELSIUS PLUS THIRTY TWO. MULTIPLYING BEFORE
    ; DIVIDING KEEPS THE ANSWER EXACT FOR ANY CELSIUS VALUE THAT IS A MULTIPLE
    ; OF FIVE, AND LOSES ONLY THE FRACTION OTHERWISE. DIVIDING FIRST WOULD
    ; THROW AWAY MOST OF THE VALUE BEFORE THE MULTIPLICATION EVER HAPPENED.
    ; -------------------------------------------------------------------------
    LEA DX, M_F
    MOV AH, 09H
    INT 21H

    MOV AX, BX
    MOV DX, 9
    IMUL DX                             ; Nine times, signed
    MOV CX, 5
    CWD
    IDIV CX                             ; Divided by five
    ADD AX, 32
    CALL PRINT_SIGNED_VALUE

    ; Kelvin is simply an offset, so nothing can be lost
    LEA DX, M_K
    MOV AH, 09H
    INT 21H

    MOV AX, BX
    ADD AX, 273
    CALL PRINT_SIGNED_VALUE
    CALL NEWLINE

    POP SI
    POP CX
    ADD SI, 2
    LOOP EACH

    MOV AH, 4CH
    INT 21H

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
; 1. MULTIPLY BEFORE DIVIDING:
;    - Thirty seven times nine is 333, and divided by five that is 66,
;    - giving 98 Fahrenheit. Dividing first gives seven, then 63, then
;    - 95, which is wrong by three degrees.
; 2. CWD BEFORE EVERY IDIV:
;    - IMUL leaves the high half of its product in DX, and IDIV would
;    - then divide by a number built from it. The sign extension has to
;    - replace whatever IMUL left there.
; 3. MINUS FORTY IS THE CHECK:
;    - It is the one temperature where both scales agree, so a conversion
;    - that returns minus forty for minus forty is almost certainly
;    - right.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
