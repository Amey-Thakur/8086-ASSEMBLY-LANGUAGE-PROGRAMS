; =============================================================================
; TITLE: Leap Years And The Day Of The Year
; DESCRIPTION: The full leap year rule, including the century exception that most implementations get wrong.
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
    YEARS   DW 1900, 1996, 2000, 2021, 2024, 2100
    HOWMANY EQU 6

    ; Days in each month of an ordinary year.
    MONTHS  DW 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31

    TEST_D  DW 14                       ; The date to place in the year
    TEST_M  DW 6

    M_TITLE DB 'The leap year rule, and the day of the year', 0DH, 0AH, '$'
    M_RULE  DB 'Divisible by four, except centuries, unless divisible by 400.'
            DB 0DH, 0AH, '$'
    M_HEAD  DB 0DH, 0AH, 'year   by 4  by 100  by 400  leap   days  14 June is day'
            DB 0DH, 0AH, '$'
    M_YES   DB 'yes    $'
    M_NO    DB 'no     $'
    M_GAP   DB '   $'
    M_GAP2  DB '    $'
    M_WHY   DB 0DH, 0AH
            DB '1900 is divisible by four and by a hundred but not by four '
            DB 'hundred, so it is not a leap year. 2000 is, because it is '
            DB 'divisible by four hundred.', 0DH, 0AH, '$'
    M_BUG   DB 'Software that tested only for divisibility by four treated 1900 '
            DB 'and 2100 as leap years, which is where a whole class of date '
            DB 'bugs came from.', 0DH, 0AH, '$'

; -----------------------------------------------------------------------------
; CODE SEGMENT
; -----------------------------------------------------------------------------
.CODE
START:
    MOV AX, @DATA
    MOV DS, AX

    LEA DX, M_TITLE
    CALL PRINT_MESSAGE
    LEA DX, M_RULE
    CALL PRINT_MESSAGE
    LEA DX, M_HEAD
    CALL PRINT_MESSAGE

    XOR SI, SI
    MOV CX, HOWMANY

EACH_YEAR:
    PUSH CX

    MOV AX, YEARS[SI]
    CALL PRINT_DECIMAL
    LEA DX, M_GAP
    CALL PRINT_MESSAGE

    ; ---- the three tests, each shown ----------------------------------------
    MOV AX, YEARS[SI]
    MOV BX, 4
    CALL DIVIDES_EXACTLY
    CALL SAY_YES_NO

    MOV AX, YEARS[SI]
    MOV BX, 100
    CALL DIVIDES_EXACTLY
    CALL SAY_YES_NO

    MOV AX, YEARS[SI]
    MOV BX, 400
    CALL DIVIDES_EXACTLY
    CALL SAY_YES_NO

    ; ---- and the verdict ----------------------------------------------------
    MOV AX, YEARS[SI]
    CALL IS_LEAP_YEAR
    MOV BP, AX                          ; 1 when it is a leap year
    CALL SAY_YES_NO

    ; ---- days in the year ---------------------------------------------------
    MOV AX, 365
    ADD AX, BP
    CALL PRINT_DECIMAL
    LEA DX, M_GAP2
    CALL PRINT_MESSAGE

    ; ---- and which day of the year the test date falls on -------------------
    CALL DAY_OF_YEAR
    CALL PRINT_DECIMAL
    CALL NEWLINE

    ADD SI, 2
    POP CX
    LOOP EACH_YEAR

    LEA DX, M_WHY
    CALL PRINT_MESSAGE
    LEA DX, M_BUG
    CALL PRINT_MESSAGE

    MOV AH, 4CH
    INT 21H

; -----------------------------------------------------------------------------
; IS_LEAP_YEAR
;
; Returns 1 in AX when the year in AX is a leap year, 0 otherwise.
;
; The order matters. Divisibility by four hundred is checked first, because it
; overrides the century exception, which in turn overrides the rule of four.
; -----------------------------------------------------------------------------
IS_LEAP_YEAR PROC
    PUSH BX
    PUSH DX
    PUSH SI

    MOV SI, AX

    MOV BX, 400
    CALL DIVIDES_EXACTLY
    CMP AX, 1
    JE IS_LEAP                          ; 2000 lands here

    MOV AX, SI
    MOV BX, 100
    CALL DIVIDES_EXACTLY
    CMP AX, 1
    JE NOT_LEAP                         ; 1900 and 2100 land here

    MOV AX, SI
    MOV BX, 4
    CALL DIVIDES_EXACTLY
    CMP AX, 1
    JE IS_LEAP

NOT_LEAP:
    XOR AX, AX
    JMP LEAP_DONE

IS_LEAP:
    MOV AX, 1

LEAP_DONE:
    POP SI
    POP DX
    POP BX
    RET
IS_LEAP_YEAR ENDP

; -----------------------------------------------------------------------------
; DIVIDES_EXACTLY
;
; Returns 1 in AX when BX divides AX with no remainder.
; -----------------------------------------------------------------------------
DIVIDES_EXACTLY PROC
    PUSH DX

    XOR DX, DX
    DIV BX

    CMP DX, 0
    JNE NOT_EXACT
    MOV AX, 1
    JMP EXACT_DONE

NOT_EXACT:
    XOR AX, AX

EXACT_DONE:
    POP DX
    RET
DIVIDES_EXACTLY ENDP

; -----------------------------------------------------------------------------
; DAY_OF_YEAR
;
; Which day of the year TEST_D of TEST_M falls on, for the year at SI. BP says
; whether that year is a leap year.
;
; February is the only month whose length depends on the year, so the extra day
; is added only when the date is in March or later.
; -----------------------------------------------------------------------------
DAY_OF_YEAR PROC
    PUSH BX
    PUSH CX
    PUSH DX
    PUSH DI

    XOR AX, AX                          ; The running total
    XOR DI, DI                          ; Month index, from zero

    MOV CX, TEST_M
    DEC CX                              ; Only the months BEFORE this one
    JCXZ ADD_THE_DAY

ADD_MONTHS:
    ADD AX, MONTHS[DI]
    ADD DI, 2
    LOOP ADD_MONTHS

ADD_THE_DAY:
    ADD AX, TEST_D

    ; The leap day belongs to February, so it counts only from March onwards.
    CMP TEST_M, 3
    JB DAY_DONE
    ADD AX, BP

DAY_DONE:
    POP DI
    POP DX
    POP CX
    POP BX
    RET
DAY_OF_YEAR ENDP

; -----------------------------------------------------------------------------
; SAY_YES_NO
;
; Prints yes or no for the value in AX, leaving it unchanged.
; -----------------------------------------------------------------------------
SAY_YES_NO PROC
    PUSH AX
    PUSH DX

    CMP AX, 1
    JE SAY_YES

    LEA DX, M_NO
    CALL PRINT_MESSAGE
    JMP SAY_DONE

SAY_YES:
    LEA DX, M_YES
    CALL PRINT_MESSAGE

SAY_DONE:
    POP DX
    POP AX
    RET
SAY_YES_NO ENDP

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

; -----------------------------------------------------------------------------
; PRINT_MESSAGE
;
; Prints the dollar terminated string at DS:DX, leaving AX exactly as it was.
;
; Service 09H needs the service number in AH, and AH is the top half of AX. A
; caller that has just computed a result into AX and then sets AH for itself
; destroys that result: 500 becomes 09F4H, which prints as 2548. Doing the call
; in here, around a push and a pop, removes the trap for good.
; -----------------------------------------------------------------------------
PRINT_MESSAGE PROC
    PUSH AX

    MOV AH, 09H
    INT 21H

    POP AX
    RET
PRINT_MESSAGE ENDP

END START

; =============================================================================
; TECHNICAL NOTES
; =============================================================================
; 1. The order of the three tests:
;    - Four hundred is checked first because it overrides everything else.
;    - A hundred is checked next, and rejects the centuries that survived.
;    - Four is checked last, and only reaches years that are not centuries.
; 2. The leap day belongs to February:
;    - A date in January or February is unaffected by whether the year is a leap year.
;    - The extra day is added only from March onwards, which is the whole correction.
;    - Adding it unconditionally puts every January date one day late.
; 3. Where the real bugs came from:
;    - Testing only for divisibility by four makes 1900 and 2100 leap years.
;    - A great deal of software did exactly that, and 2000 hid the error for a century.
;    - 2000 is a leap year, so the naive rule happened to be right through the changeover.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
