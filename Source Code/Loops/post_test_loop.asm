; =============================================================================
; TITLE: A Loop That Always Runs Once
; DESCRIPTION: Puts the test at the bottom, so the body runs before anything is
;              checked, which is the do-while shape.
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
    VALUE  DW 1000
    M_HEAD DB 'Halving 1000 until it reaches zero:', 0DH, 0AH, '$'
    SPACE  DB ' $'
    M_PASS DB 0DH, 0AH, 'Passes: $'

; -----------------------------------------------------------------------------
; CODE SEGMENT
; -----------------------------------------------------------------------------
.CODE
START:
    MOV AX, @DATA
    MOV DS, AX

    LEA DX, M_HEAD
    MOV AH, 09H
    INT 21H

    MOV BX, VALUE
    XOR DI, DI

    ; -------------------------------------------------------------------------
    ; NOTHING IS TESTED BEFORE THE FIRST PASS. THE BODY RUNS, AND ONLY THEN
    ; IS THE CONDITION EXAMINED, SO THE LOOP ALWAYS EXECUTES AT LEAST ONCE.
    ; -------------------------------------------------------------------------
HALVE:
    SHR BX, 1
    INC DI

    PUSH BX
    MOV AX, BX
    CALL PRINT_DECIMAL
    LEA DX, SPACE
    MOV AH, 09H
    INT 21H
    POP BX

    OR  BX, BX                          ; The test, at the bottom
    JNZ HALVE

    LEA DX, M_PASS
    MOV AH, 09H
    INT 21H
    MOV AX, DI
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

END START

; =============================================================================
; TECHNICAL NOTES
; =============================================================================
; 1. ONE TEST, NOT TWO:
;    - A pre-test loop needs a jump to the test before the first pass, or
;    - the test written twice. A post-test loop needs neither, which is
;    - why it produces less code.
; 2. WHEN IT IS WRONG:
;    - Whenever the body must not run on an empty case. A post-test loop
;    - over an array with no elements reads one that is not there.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
