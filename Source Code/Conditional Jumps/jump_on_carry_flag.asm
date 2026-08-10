; =============================================================================
; TITLE: Branching on the Carry Flag
; DESCRIPTION: Detects an unsigned addition that did not fit, which is the
;              carry flag's original purpose.
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
    SAFE_A   DW 30000
    SAFE_B   DW 20000
    OVER_A   DW 60000
    OVER_B   DW 10000
    M_FIT    DB 'Fits:      30000 + 20000 = $'
    M_CARRY  DB 'Overflows: 60000 + 10000 needs seventeen bits', 0DH, 0AH, '$'

; -----------------------------------------------------------------------------
; CODE SEGMENT
; -----------------------------------------------------------------------------
.CODE
START:
    MOV AX, @DATA
    MOV DS, AX

    MOV AX, SAFE_A
    ADD AX, SAFE_B
    JC  FIRST_OVERFLOWED                ; It will not

    MOV BX, AX
    LEA DX, M_FIT
    MOV AH, 09H
    INT 21H
    MOV AX, BX
    CALL PRINT_DECIMAL
    CALL NEWLINE

FIRST_OVERFLOWED:
    ; -------------------------------------------------------------------------
    ; 60000 PLUS 10000 IS 70000, WHICH NEEDS SEVENTEEN BITS. THE WORD KEEPS
    ; THE LOW SIXTEEN AND THE CARRY FLAG HOLDS THE SEVENTEENTH.
    ; -------------------------------------------------------------------------
    MOV AX, OVER_A
    ADD AX, OVER_B
    JNC FINISH

    LEA DX, M_CARRY
    MOV AH, 09H
    INT 21H

FINISH:
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

END START

; =============================================================================
; TECHNICAL NOTES
; =============================================================================
; 1. THE CARRY IS THE EXTRA BIT:
;    - It is not an error flag. It is the bit that did not fit, and ADC
;    - exists so it can be carried into the next word of a wider sum.
; 2. TEST IT IMMEDIATELY:
;    - Almost every arithmetic and logical instruction writes the carry.
;    - One instruction between the addition and the branch is usually
;    - enough to lose it.
; 3. UNSIGNED ONLY:
;    - For signed arithmetic the flag that matters is OF. The carry says
;    - nothing useful about whether a signed result was correct.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
