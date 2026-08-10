; =============================================================================
; TITLE: Seconds to Hours, Minutes and Seconds
; DESCRIPTION: Breaks a count of seconds into a clock reading, with each part
;              padded to two digits.
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
    ; 65535 is the largest a word can hold, which is 18:12:15. A full day of
    ; 86399 seconds does not fit and would wrap silently to 20863.
    SAMPLES DW 3661, 65535, 45, 7200
    HOWMANY EQU 4

    M_IS    DB ' seconds is $'
    COLON   DB ':$'

; -----------------------------------------------------------------------------
; CODE SEGMENT
; -----------------------------------------------------------------------------
.CODE
START:
    MOV AX, @DATA
    MOV DS, AX

    LEA SI, SAMPLES
    MOV CX, HOWMANY

EACH:
    MOV BX, [SI]

    PUSH CX
    PUSH SI

    MOV AX, BX
    CALL PRINT_DECIMAL
    LEA DX, M_IS
    MOV AH, 09H
    INT 21H

    ; -------------------------------------------------------------------------
    ; TWO DIVISIONS DO IT. THE FIRST BY 3600 SEPARATES THE HOURS, AND THE
    ; SECOND BY 60 SPLITS WHAT IS LEFT INTO MINUTES AND SECONDS.
    ; -------------------------------------------------------------------------
    MOV AX, BX
    XOR DX, DX
    MOV CX, 3600
    DIV CX                              ; AX = hours, DX = the rest
    PUSH DX
    CALL PRINT_TWO_DIGITS

    LEA DX, COLON
    MOV AH, 09H
    INT 21H

    POP AX
    XOR DX, DX
    MOV CX, 60
    DIV CX                              ; AX = minutes, DX = seconds
    PUSH DX
    CALL PRINT_TWO_DIGITS

    LEA DX, COLON
    MOV AH, 09H
    INT 21H

    POP AX
    CALL PRINT_TWO_DIGITS
    CALL NEWLINE

    POP SI
    POP CX
    ADD SI, 2
    LOOP EACH

    MOV AH, 4CH
    INT 21H

; -----------------------------------------------------------------------------
; PRINT_TWO_DIGITS
;
; Prints AX with a leading zero when it is below ten, which is what makes a
; clock reading line up.
; -----------------------------------------------------------------------------
PRINT_TWO_DIGITS PROC
    PUSH AX
    PUSH DX

    CMP AX, 10
    JAE PT_PRINT

    PUSH AX
    MOV DL, '0'
    MOV AH, 02H
    INT 21H
    POP AX

PT_PRINT:
    CALL PRINT_DECIMAL

    POP DX
    POP AX
    RET
PRINT_TWO_DIGITS ENDP

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
; 1. THE ORDER OF THE DIVISIONS:
;    - Largest unit first, and each remainder feeds the next division.
;    - The same shape works for any set of units, including days and
;    - weeks, by adding divisions at the front.
; 2. A WHOLE DAY DOES NOT FIT:
;    - A word reaches 65535, which is 18:12:15. The 86399 seconds in a
;    - full day need seventeen bits, so a program that stores a time of
;    - day as seconds in one word is already broken and will show 20863
;    - for the last second before midnight.
;    - Either hold the count in a pair of words, or store the hours,
;    - minutes and seconds separately, which is what DOS does.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
