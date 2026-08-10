; =============================================================================
; TITLE: Reading the Date and the Time
; DESCRIPTION: Asks DOS what day and time it is and lays both out in the
;              conventional order.
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
    M_DATE  DB 'Date: $'
    M_TIME  DB 'Time: $'
    SLASH   DB '/$'
    COLON   DB ':$'
    CRLF    DB 0DH, 0AH, '$'

    DAYS    DB 'SunMonTueWedThuFriSat'
    M_DAY   DB '   Day: $'

; -----------------------------------------------------------------------------
; CODE SEGMENT
; -----------------------------------------------------------------------------
.CODE
START:
    MOV AX, @DATA
    MOV DS, AX

    ; -------------------------------------------------------------------------
    ; SERVICE 2AH RETURNS THE DATE ACROSS FOUR REGISTERS: THE YEAR AS A FULL
    ; NUMBER IN CX, THE MONTH IN DH, THE DAY IN DL, AND WHICH DAY OF THE WEEK
    ; IT IS IN AL, COUNTING FROM SUNDAY AS NOUGHT.
    ; -------------------------------------------------------------------------
    MOV AH, 2AH
    INT 21H

    PUSH AX                             ; The weekday
    PUSH CX                             ; The year
    PUSH DX                             ; Month and day

    LEA DX, M_DATE
    MOV AH, 09H
    INT 21H

    POP DX
    PUSH DX
    MOV AL, DL                          ; The day of the month
    XOR AH, AH
    CALL PRINT_DECIMAL

    LEA DX, SLASH
    MOV AH, 09H
    INT 21H

    POP DX
    MOV AL, DH                          ; The month
    XOR AH, AH
    CALL PRINT_DECIMAL

    LEA DX, SLASH
    MOV AH, 09H
    INT 21H

    POP AX                              ; The year
    CALL PRINT_DECIMAL

    ; The name of the weekday, three letters from the table
    LEA DX, M_DAY
    MOV AH, 09H
    INT 21H

    POP AX
    XOR AH, AH
    MOV BX, 3
    MUL BX                              ; Three characters per name
    LEA SI, DAYS
    ADD SI, AX
    MOV CX, 3
    CALL PRINT_TEXT

    LEA DX, CRLF
    MOV AH, 09H
    INT 21H

    ; -------------------------------------------------------------------------
    ; SERVICE 2CH RETURNS THE TIME: HOURS IN CH, MINUTES IN CL, SECONDS IN DH
    ; AND HUNDREDTHS IN DL. THE HUNDREDTHS ARE REAL BUT THE CLOCK ONLY TICKS
    ; EIGHTEEN TIMES A SECOND, SO THEY MOVE IN STEPS OF ABOUT FIVE.
    ; -------------------------------------------------------------------------
    MOV AH, 2CH
    INT 21H

    PUSH DX
    PUSH CX

    LEA DX, M_TIME
    MOV AH, 09H
    INT 21H

    POP CX
    PUSH CX
    MOV AL, CH
    XOR AH, AH
    CALL PRINT_TWO

    LEA DX, COLON
    MOV AH, 09H
    INT 21H

    POP CX
    MOV AL, CL
    XOR AH, AH
    CALL PRINT_TWO

    LEA DX, COLON
    MOV AH, 09H
    INT 21H

    POP DX
    MOV AL, DH
    XOR AH, AH
    CALL PRINT_TWO

    LEA DX, CRLF
    MOV AH, 09H
    INT 21H

    MOV AH, 4CH
    INT 21H

; -----------------------------------------------------------------------------
; PRINT_TWO
;
; Prints AX with a leading zero below ten, as a clock reading needs.
; -----------------------------------------------------------------------------
PRINT_TWO PROC
    PUSH AX
    PUSH DX

    CMP AX, 10
    JAE PT_SHOW

    PUSH AX
    MOV DL, '0'
    MOV AH, 02H
    INT 21H
    POP AX

PT_SHOW:
    CALL PRINT_DECIMAL

    POP DX
    POP AX
    RET
PRINT_TWO ENDP

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
; 1. THE YEAR IS A FULL NUMBER:
;    - CX holds 2022 and not 22, which is why DOS programs were not the
;    - ones that broke at the turn of the century. The two digit years
;    - came from applications storing it that way.
; 2. THE HUNDREDTHS ARE NOT SMOOTH:
;    - The hardware timer ticks 18.2 times a second, so the value moves
;    - in jumps of five or six. It is precise but not that precise.
; 3. IN THE SIMULATOR:
;    - The clock is fixed rather than live, so a program prints the same
;    - time on every run. That is what makes the output testable.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
