; =============================================================================
; TITLE: Averaging Without Overflowing
; DESCRIPTION: Ten large readings whose total will not fit in one word. Shows
;              the wrong answer a single word gives, then two methods that are
;              right: a wide accumulator, and dividing each term first.
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
    READING DW 60123, 59187, 61044, 58260, 62391
            DW 57008, 63500, 56777, 64100, 55617
    HOWMANY EQU 10

    TOTAL_LOW  DW ?                     ; The wide total, kept in memory because
    TOTAL_HIGH DW ?                     ; DX has to carry message addresses

    M_TITLE DB 'Ten readings, each close to sixty thousand', 0DH, 0AH, '$'
    M_SPACE DB ' $'
    M_NAIVE DB 0DH, 0AH, 'One word for the total:', 0DH, 0AH
            DB '   total as stored: $'
    M_NAVG  DB '   average from it: $'
    M_WRONG DB '   which is wrong, because the total passed 65535 and wrapped'
            DB 0DH, 0AH, '$'
    M_WIDE  DB 0DH, 0AH, 'A wide accumulator:', 0DH, 0AH
            DB '   total in DX:AX: $'
    M_WAVG  DB '   average: $'
    M_REM   DB '   remainder: $'
    M_SPLIT DB 0DH, 0AH, 'Dividing each reading first:', 0DH, 0AH
            DB '   sum of the quotients: $'
    M_RSUM  DB '   sum of the remainders: $'
    M_SAVG  DB '   average: $'
    M_AGREE DB '   which agrees with the wide accumulator', 0DH, 0AH, '$'

; -----------------------------------------------------------------------------
; CODE SEGMENT
; -----------------------------------------------------------------------------
.CODE
START:
    MOV AX, @DATA
    MOV DS, AX

    LEA DX, M_TITLE
    CALL PRINT_MESSAGE

    XOR SI, SI
    MOV CX, HOWMANY

SHOW_EACH:
    MOV AX, READING[SI]
    CALL PRINT_DECIMAL
    LEA DX, M_SPACE
    CALL PRINT_MESSAGE
    ADD SI, 2
    LOOP SHOW_EACH
    CALL NEWLINE

    ; -------------------------------------------------------------------------
    ; STEP 1: THE TOTAL IN A SINGLE WORD. NOTHING FAULTS AND NOTHING WARNS. THE
    ; ACCUMULATOR SIMPLY WRAPS PAST 65535 AND THE AVERAGE IS NONSENSE.
    ; -------------------------------------------------------------------------
    XOR AX, AX
    XOR SI, SI
    MOV CX, HOWMANY

NARROW_SUM:
    ADD AX, READING[SI]
    ADD SI, 2
    LOOP NARROW_SUM

    MOV DI, AX                          ; DX is needed for the message address
    LEA DX, M_NAIVE
    CALL PRINT_MESSAGE
    MOV AX, DI
    CALL PRINT_DECIMAL
    CALL NEWLINE

    LEA DX, M_NAVG
    CALL PRINT_MESSAGE
    MOV AX, DI
    XOR DX, DX
    MOV BX, HOWMANY
    DIV BX
    CALL PRINT_DECIMAL
    CALL NEWLINE

    LEA DX, M_WRONG
    CALL PRINT_MESSAGE

    ; -------------------------------------------------------------------------
    ; STEP 2: THE SAME ADDITION ACROSS DX AND AX. ADC ADDS NOTHING BUT THE CARRY
    ; TO THE HIGH WORD, WHICH IS ALL A RUNNING TOTAL EVER NEEDS.
    ; -------------------------------------------------------------------------
    XOR AX, AX
    XOR DX, DX
    XOR SI, SI
    MOV CX, HOWMANY

WIDE_SUM:
    ADD AX, READING[SI]
    ADC DX, 0
    ADD SI, 2
    LOOP WIDE_SUM

    MOV TOTAL_LOW, AX                   ; Kept, since DX must carry addresses
    MOV TOTAL_HIGH, DX

    LEA DX, M_WIDE
    CALL PRINT_MESSAGE
    MOV AX, TOTAL_LOW
    MOV DX, TOTAL_HIGH
    CALL PRINT_LONG
    CALL NEWLINE

    ; DIV takes the whole of DX:AX, so a thirty two bit total divides in one
    ; instruction. It is only safe because the quotient still fits in a word,
    ; which it must here: the average cannot exceed the largest reading.
    MOV AX, TOTAL_LOW
    MOV DX, TOTAL_HIGH
    MOV BX, HOWMANY
    DIV BX
    MOV DI, AX                          ; The average
    MOV BP, DX                          ; The remainder

    LEA DX, M_WAVG
    CALL PRINT_MESSAGE
    MOV AX, DI
    CALL PRINT_DECIMAL
    LEA DX, M_REM
    CALL PRINT_MESSAGE
    MOV AX, BP
    CALL PRINT_DECIMAL
    CALL NEWLINE

    ; -------------------------------------------------------------------------
    ; STEP 3: NO WIDE ACCUMULATOR AT ALL. EACH READING IS DIVIDED BY THE COUNT
    ; AS IT ARRIVES, AND ONLY THE REMAINDERS ARE CARRIED. NEITHER RUNNING TOTAL
    ; CAN OVERFLOW: THE QUOTIENTS AVERAGE TO THE ANSWER, AND EACH REMAINDER IS
    ; SMALLER THAN THE COUNT, SO THEIR SUM IS SMALLER THAN THE COUNT SQUARED.
    ; -------------------------------------------------------------------------
    XOR DI, DI                          ; Sum of the quotients
    XOR BP, BP                          ; Sum of the remainders
    XOR SI, SI
    MOV CX, HOWMANY

SPLIT_SUM:
    MOV AX, READING[SI]
    XOR DX, DX
    MOV BX, HOWMANY
    DIV BX
    ADD DI, AX
    ADD BP, DX
    ADD SI, 2
    LOOP SPLIT_SUM

    LEA DX, M_SPLIT
    CALL PRINT_MESSAGE
    MOV AX, DI
    CALL PRINT_DECIMAL
    CALL NEWLINE

    LEA DX, M_RSUM
    CALL PRINT_MESSAGE
    MOV AX, BP
    CALL PRINT_DECIMAL
    CALL NEWLINE

    MOV AX, BP                          ; The remainders contribute their own share
    XOR DX, DX
    MOV BX, HOWMANY
    DIV BX
    ADD AX, DI
    MOV DI, AX
    MOV BP, DX

    LEA DX, M_SAVG
    CALL PRINT_MESSAGE
    MOV AX, DI
    CALL PRINT_DECIMAL
    LEA DX, M_REM
    CALL PRINT_MESSAGE
    MOV AX, BP
    CALL PRINT_DECIMAL
    CALL NEWLINE

    LEA DX, M_AGREE
    CALL PRINT_MESSAGE

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
; PRINT_LONG
;
; Prints the thirty two bit unsigned value in DX:AX as decimal.
;
; DIV would overflow if the whole value were offered to it at once, so the top
; word is divided first and its remainder is carried down into the bottom word.
; That remainder is smaller than ten, so the second division can never produce
; a quotient too large for AX.
; -----------------------------------------------------------------------------
PRINT_LONG PROC
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX
    PUSH SI

    MOV SI, DX                          ; The high word of the running quotient
    XOR CX, CX                          ; How many digits have been stacked
    MOV BX, 10

PL_DIVIDE:
    PUSH AX
    MOV AX, SI
    XOR DX, DX
    DIV BX                              ; The high half, leaving DX to carry down
    MOV SI, AX
    POP AX
    DIV BX                              ; DX:AX is now safely under ten times AX

    PUSH DX                             ; Digits arrive lowest first
    INC CX

    MOV DX, SI
    OR  DX, AX                          ; Is anything left of the quotient?
    JNZ PL_DIVIDE

PL_EMIT:
    POP DX                              ; Unstacking reverses them into order
    ADD DL, '0'
    MOV AH, 02H
    INT 21H
    LOOP PL_EMIT

    POP SI
    POP DX
    POP CX
    POP BX
    POP AX
    RET
PRINT_LONG ENDP

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
; 1. Why the narrow total is dangerous:
;    - Nothing faults. The carry flag is set and then quietly discarded.
;    - Ten readings near sixty thousand pass 65535 on the second addition.
;    - The average that follows is arithmetically sound on a wrong total.
; 2. The wide accumulator:
;    - ADC DX, 0 adds only the carry, which is the whole cost of the method.
;    - One DIV then consumes DX:AX, since the instruction is built for it.
;    - It is safe here only because the average cannot exceed the largest term.
; 3. Dividing before adding:
;    - The quotients sum to the average less whatever the remainders contribute.
;    - Each remainder is below the count, so their sum stays small.
;    - This is the method to reach for when no wide accumulator is available.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
