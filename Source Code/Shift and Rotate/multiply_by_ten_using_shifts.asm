; =============================================================================
; TITLE: Multiply by Ten Without MUL
; DESCRIPTION: Computes ten times a value using two shifts and one addition,
;              which is how a decimal input routine accumulates its digits.
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
    VALUE DW 37
    MSG   DB 'Ten times 37 is $'

; -----------------------------------------------------------------------------
; CODE SEGMENT
; -----------------------------------------------------------------------------
.CODE
START:
    MOV AX, @DATA
    MOV DS, AX

    ; -------------------------------------------------------------------------
    ; TEN IS EIGHT PLUS TWO, AND BOTH ARE POWERS OF TWO, SO TEN TIMES A VALUE
    ; IS THAT VALUE SHIFTED THREE PLACES PLUS THE SAME VALUE SHIFTED ONE.
    ; -------------------------------------------------------------------------
    MOV AX, VALUE
    MOV BX, AX

    SHL AX, 3                           ; Eight times
    SHL BX, 1                           ; Two times
    ADD AX, BX                          ; Ten times
    MOV SI, AX

    LEA DX, MSG
    MOV AH, 09H
    INT 21H

    MOV AX, SI
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
; 1. THE GENERAL METHOD:
;    - Any constant multiplier can be written as a sum of powers of two,
;    - which is just its binary representation. Ten is 1010, so the
;    - shifts needed are by three and by one.
; 2. WHY IT IS WORTH DOING:
;    - MUL takes around seventy cycles on an 8086. Two shifts and an add
;    - take about ten. For a routine that reads decimal digits and runs
;    - this once per digit, the difference is easily noticed.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
