; =============================================================================
; TITLE: A Unit Converter Driven By A Table
; DESCRIPTION: Converts between the imperial lengths by looking each unit up in
;              a table of names and factors, so a new unit costs one table row
;              and no code at all.
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
    ; Each row is an eight character name and the number of inches in one of
    ; the unit. The inch is the base, so every factor is exact and no rounding
    ; enters anywhere.
    UNITS   DB 'inch    '
            DW 1
            DB 'foot    '
            DW 12
            DB 'yard    '
            DW 36
            DB 'chain   '
            DW 792
            DB 'furlong '
            DW 7920
            DB 'mile    '
            DW 63360
    ROWSPAN EQU 10                      ; Eight name characters and one word

    ; Each job is a quantity, the row it is given in, and the row wanted.
    JOBS    DW 5, 2, 1
            DW 1, 5, 4
            DW 100, 1, 2
            DW 3, 3, 1
            DW 2, 5, 0
    JOBSPAN EQU 6
    HOWMANY EQU 5

    JOBAT   DW 0                        ; Byte offset of the job in hand
    QTY     DW 0
    FROMIX  DW 0
    TOIX    DW 0
    INCHES  DW 0
    OVER    DW 0                        ; What is left over, in inches

    M_TITLE DB 'Imperial lengths converted through a table of factors'
            DB 0DH, 0AH, 0DH, 0AH, '$'
    M_EQ    DB ' = $'
    M_IN    DB ' inch = $'
    M_AND   DB ' and $'
    M_TAIL  DB ' inch$'
    M_BIG   DB ' is more than 65535 inches, so it is refused$'
    M_SPACE DB ' $'

; -----------------------------------------------------------------------------
; CODE SEGMENT
; -----------------------------------------------------------------------------
.CODE
START:
    MOV AX, @DATA
    MOV DS, AX

    LEA DX, M_TITLE
    CALL PRINT_MESSAGE

    XOR AX, AX
    MOV JOBAT, AX
    MOV CX, HOWMANY

JOB_LOOP:
    ; -------------------------------------------------------------------------
    ; READ THE THREE FIELDS OF THIS JOB. THE OFFSET IS HELD IN MEMORY RATHER
    ; THAN A REGISTER BECAUSE EVERY PRINT NEEDS DX AND THE LOOP NEEDS CX.
    ; -------------------------------------------------------------------------
    MOV SI, JOBAT
    MOV AX, JOBS[SI]
    MOV QTY, AX
    MOV AX, JOBS[SI+2]
    MOV FROMIX, AX
    MOV AX, JOBS[SI+4]
    MOV TOIX, AX

    MOV AX, QTY
    CALL PRINT_DECIMAL
    LEA DX, M_SPACE
    CALL PRINT_MESSAGE
    MOV AX, FROMIX
    CALL PRINT_NAME

    ; -------------------------------------------------------------------------
    ; INTO INCHES FIRST. MUL RETURNS THIRTY TWO BITS, AND A NON ZERO DX IS THE
    ; ONLY WARNING THAT THE ANSWER HAS OUTGROWN A WORD, SO IT IS TESTED BEFORE
    ; ANYTHING IS PRINTED.
    ; -------------------------------------------------------------------------
    MOV AX, FROMIX
    CALL FACTOR_OF
    MOV BX, AX
    MOV AX, QTY
    MUL BX
    OR  DX, DX
    JNZ TOO_LARGE
    MOV INCHES, AX

    LEA DX, M_EQ
    CALL PRINT_MESSAGE
    MOV AX, INCHES
    CALL PRINT_DECIMAL

    ; -------------------------------------------------------------------------
    ; OUT OF INCHES INTO THE UNIT ASKED FOR. THE REMAINDER MATTERS, SO IT IS
    ; SAVED BEFORE THE QUOTIENT IS PRINTED: PRINTING USES DX AND WOULD LOSE IT.
    ; -------------------------------------------------------------------------
    LEA DX, M_IN
    CALL PRINT_MESSAGE

    MOV AX, TOIX
    CALL FACTOR_OF
    MOV BX, AX
    MOV AX, INCHES
    XOR DX, DX
    DIV BX
    MOV OVER, DX

    CALL PRINT_DECIMAL
    LEA DX, M_SPACE
    CALL PRINT_MESSAGE
    MOV AX, TOIX
    CALL PRINT_NAME
    LEA DX, M_AND
    CALL PRINT_MESSAGE
    MOV AX, OVER
    CALL PRINT_DECIMAL
    LEA DX, M_TAIL
    CALL PRINT_MESSAGE
    JMP JOB_END

TOO_LARGE:
    LEA DX, M_BIG
    CALL PRINT_MESSAGE

JOB_END:
    CALL NEWLINE

    MOV AX, JOBAT
    ADD AX, JOBSPAN
    MOV JOBAT, AX
    LOOP JOB_LOOP

    MOV AH, 4CH
    INT 21H

; -----------------------------------------------------------------------------
; FACTOR_OF
;
; Takes a row number in AX and returns that unit's factor in inches in AX.
; -----------------------------------------------------------------------------
FACTOR_OF PROC
    PUSH BX
    PUSH DX
    PUSH SI

    MOV BX, ROWSPAN
    MUL BX                              ; The byte offset of the row
    LEA SI, UNITS
    ADD SI, AX
    MOV AX, [SI+8]                      ; The word after the eight characters

    POP SI
    POP DX
    POP BX
    RET
FACTOR_OF ENDP

; -----------------------------------------------------------------------------
; PRINT_NAME
;
; Takes a row number in AX and prints that unit's name.
;
; The names are padded to eight characters so that every row is the same width
; and the offset is a multiplication. The padding is dropped on the way out.
; -----------------------------------------------------------------------------
PRINT_NAME PROC
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX
    PUSH SI

    MOV BX, ROWSPAN
    MUL BX
    LEA SI, UNITS
    ADD SI, AX
    MOV CX, 8

PN_LOOP:
    MOV DL, [SI]
    CMP DL, ' '
    JE  PN_DONE                         ; The padding starts here
    MOV AH, 02H
    INT 21H
    INC SI
    LOOP PN_LOOP

PN_DONE:
    POP SI
    POP DX
    POP CX
    POP BX
    POP AX
    RET
PRINT_NAME ENDP

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
; 1. WHY EVERYTHING GOES THROUGH ONE BASE UNIT:
;    - Six units would need thirty pairs of conversion constants. Storing
;    - the factor to the inch instead needs six, and any pair is then one
;    - multiplication followed by one division.
; 2. WHY THE ROWS ARE A FIXED WIDTH:
;    - Ten bytes a row turns a unit number into an address with a single
;    - multiply. Variable length names would need a scan through the table
;    - to find where each row began.
; 3. WHERE A WORD RUNS OUT:
;    - A mile is 63360 inches, which barely fits. Two miles does not, and
;    - the only sign of it is DX after the multiply. The program tests DX
;    - and refuses rather than printing the 61184 that the low half holds.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
