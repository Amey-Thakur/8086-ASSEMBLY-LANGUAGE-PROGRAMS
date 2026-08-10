; =============================================================================
; TITLE: Shifting by a Count Held in CL
; DESCRIPTION: Shifts by an amount decided at run time, which on the 8086 must
;              travel in CL, and shows why CX has to be preserved around it.
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
    VALUE  DW 1
    COUNTS DB 1, 3, 5, 7, 9
    HOWMANY EQU 5
    MSG    DB 'One shifted left by each of 1, 3, 5, 7, 9:', 0DH, 0AH, '$'

; -----------------------------------------------------------------------------
; CODE SEGMENT
; -----------------------------------------------------------------------------
.CODE
START:
    MOV AX, @DATA
    MOV DS, AX

    LEA DX, MSG
    MOV AH, 09H
    INT 21H

    LEA SI, COUNTS
    MOV BP, HOWMANY                     ; BP counts the list, since CX is needed

NEXT_COUNT:
    MOV BX, VALUE
    MOV CL, [SI]                        ; The shift count must be in CL
    SHL BX, CL

    MOV AX, BX
    CALL PRINT_DECIMAL
    CALL NEWLINE

    INC SI
    DEC BP
    JNZ NEXT_COUNT

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
; 1. ONLY CL WILL DO:
;    - The 8086 encodes a shift with either an implied count of one or a
;    - count taken from CL. No other register can carry it, and no
;    - immediate larger than one is encodable.
; 2. THE CLASH WITH LOOP:
;    - LOOP counts in CX, and CL is the bottom of CX. A loop that shifts
;    - by a variable amount cannot use both without saving one of them.
;    - Here the list is counted in BP instead, which sidesteps it.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
