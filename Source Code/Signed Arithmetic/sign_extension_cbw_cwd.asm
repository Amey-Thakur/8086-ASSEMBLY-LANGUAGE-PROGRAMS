; =============================================================================
; TITLE: Widening a Signed Value
; DESCRIPTION: Extends a signed byte to a word and a word to a double word,
;              and shows why copying with a zero high half is wrong.
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
    SMALL_B DB -5
    M_WRONG DB 'Zero extended: $'
    M_RIGHT DB 'Sign extended: $'
    M_CWD   DB 'CWD on -1000 gave DX = $'

; -----------------------------------------------------------------------------
; CODE SEGMENT
; -----------------------------------------------------------------------------
.CODE
START:
    MOV AX, @DATA
    MOV DS, AX

    ; -------------------------------------------------------------------------
    ; CLEARING THE HIGH BYTE TURNS -5 INTO 251, BECAUSE FBH READ AS A WORD IS
    ; AN ORDINARY POSITIVE NUMBER. THE BITS WERE COPIED CORRECTLY AND THE
    ; MEANING WAS LOST.
    ; -------------------------------------------------------------------------
    MOV AL, SMALL_B
    XOR AH, AH

    MOV BX, AX
    LEA DX, M_WRONG
    MOV AH, 09H
    INT 21H
    MOV AX, BX
    CALL PRINT_SIGNED
    CALL NEWLINE

    ; -------------------------------------------------------------------------
    ; CBW COPIES THE SIGN BIT OF AL THROUGH THE WHOLE OF AH, WHICH KEEPS THE
    ; VALUE AS WELL AS THE BITS.
    ; -------------------------------------------------------------------------
    MOV AL, SMALL_B
    CBW

    MOV BX, AX
    LEA DX, M_RIGHT
    MOV AH, 09H
    INT 21H
    MOV AX, BX
    CALL PRINT_SIGNED
    CALL NEWLINE

    ; -------------------------------------------------------------------------
    ; CWD DOES THE SAME ONE SIZE UP: IT FILLS DX WITH COPIES OF THE SIGN BIT
    ; OF AX, WHICH IS WHAT IDIV NEEDS BEFORE A WORD DIVISION.
    ; -------------------------------------------------------------------------
    MOV AX, -1000
    CWD

    MOV BX, DX
    LEA DX, M_CWD
    MOV AH, 09H
    INT 21H
    MOV AX, BX
    CALL PRINT_HEX
    CALL NEWLINE

    MOV AH, 4CH
    INT 21H

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

END START

; =============================================================================
; TECHNICAL NOTES
; =============================================================================
; 1. ZERO EXTEND OR SIGN EXTEND:
;    - Unsigned values are widened with zeros, signed values with copies
;    - of the sign. Choosing the wrong one is invisible for small
;    - positive numbers and wrong for everything else.
; 2. CWD BEFORE EVERY IDIV:
;    - IDIV divides the pair DX:AX. Leaving DX holding something from an
;    - earlier calculation gives an answer with no relation to the one
;    - that was wanted.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
