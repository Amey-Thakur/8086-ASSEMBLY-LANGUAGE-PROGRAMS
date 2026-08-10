; =============================================================================
; TITLE: Exit Codes
; DESCRIPTION: Ends a program with a value the caller can test, which is how a
;              batch file decides what to do next.
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
    THRESHOLD EQU 100
    READING   DW 137

    M_CHECK  DB 'The reading is $'
    M_OVER   DB ', which is over the limit. Exiting with code 1.', 0DH, 0AH, '$'
    M_UNDER  DB ', which is within the limit. Exiting with code 0.', 0DH, 0AH, '$'

; -----------------------------------------------------------------------------
; CODE SEGMENT
; -----------------------------------------------------------------------------
.CODE
START:
    MOV AX, @DATA
    MOV DS, AX

    LEA DX, M_CHECK
    MOV AH, 09H
    INT 21H
    MOV AX, READING
    CALL PRINT_DECIMAL

    MOV AX, READING
    CMP AX, THRESHOLD
    JA  TOO_HIGH

    LEA DX, M_UNDER
    MOV AH, 09H
    INT 21H

    ; -------------------------------------------------------------------------
    ; THE CODE GOES IN AL AND THE SERVICE NUMBER IN AH, SO BOTH CAN BE SET
    ; WITH ONE INSTRUCTION: MOV AX, 4C00H IS SERVICE 4CH WITH A CODE OF NOUGHT.
    ; THAT IS WHY THE FORM IS SO OFTEN WRITTEN THAT WAY.
    ; -------------------------------------------------------------------------
    MOV AX, 4C00H
    INT 21H

TOO_HIGH:
    LEA DX, M_OVER
    MOV AH, 09H
    INT 21H

    MOV AX, 4C01H                       ; Service 4Ch, exit code 1
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
; 1. NOUGHT MEANS SUCCESS:
;    - A convention older than DOS and still in use everywhere. Any other
;    - value means something went wrong, and which value means what is up
;    - to the program.
; 2. MOV AH, 4CH ALONE IS A TRAP:
;    - It leaves whatever was in AL as the exit code, so the program
;    - reports a failure it never had. Setting the whole of AX is the
;    - safer habit.
; 3. THE OLD WAY:
;    - INT 20h also ends a program, but it cannot return a code and it
;    - requires CS to point at the program segment prefix. Service 4Ch
;    - replaced it and there is no reason to use the older form.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
