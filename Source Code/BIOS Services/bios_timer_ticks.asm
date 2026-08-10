; =============================================================================
; TITLE: Reading the System Timer
; DESCRIPTION: Asks the BIOS how many timer ticks have passed since midnight
;              and turns that back into a time of day.
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
    M_TICKS DB 'Ticks since midnight: $'
    M_SECS  DB 'That is $'
    M_TAIL  DB ' seconds, or $'
    COLON   DB ':$'
    CRLF    DB 0DH, 0AH, '$'

; -----------------------------------------------------------------------------
; CODE SEGMENT
; -----------------------------------------------------------------------------
.CODE
START:
    MOV AX, @DATA
    MOV DS, AX

    ; -------------------------------------------------------------------------
    ; SERVICE 00H OF INT 1AH RETURNS A THIRTY TWO BIT COUNT IN CX:DX, WHERE CX
    ; IS THE HIGH HALF. THE TIMER RUNS AT 18.2 TICKS A SECOND, WHICH IS NOT A
    ; ROUND NUMBER BECAUSE IT COMES FROM DIVIDING THE 1.19318 MEGAHERTZ CLOCK
    ; BY 65536.
    ; -------------------------------------------------------------------------
    MOV AH, 00H
    INT 1AH

    PUSH CX
    PUSH DX

    LEA DX, M_TICKS
    MOV AH, 09H
    INT 21H
    POP AX                              ; The low half
    PUSH AX
    CALL PRINT_DECIMAL
    CALL NEWLINE

    POP DX                              ; low half
    POP CX                              ; high half

    ; -------------------------------------------------------------------------
    ; THE COUNT IS GENUINELY THIRTY TWO BITS: A FULL DAY IS OVER 1.5 MILLION
    ; TICKS, WHICH IS FAR PAST WHAT ONE WORD HOLDS. USING ONLY THE LOW HALF
    ; GIVES A PLAUSIBLE BUT WRONG TIME, SO BOTH HALVES HAVE TO TAKE PART.
    ;
    ; DIVIDING BY 18.2 IN WHOLE NUMBERS IS MULTIPLYING BY FIVE AND DIVIDING
    ; BY 91. THE MULTIPLICATION IS DONE IN TWO PARTS BECAUSE MUL TAKES ONLY
    ; SIXTEEN BITS AT A TIME: THE LOW HALF FIRST, THEN THE HIGH HALF WITH
    ; WHATEVER CARRIED OUT OF THE LOW ONE ADDED IN.
    ; -------------------------------------------------------------------------
    MOV AX, DX                          ; The low half of the tick count
    MOV BX, 5
    MUL BX                              ; DX:AX = low times five
    MOV SI, AX                          ; Keep the low result
    MOV DI, DX                          ; and what carried into the high half

    MOV AX, CX                          ; The high half of the tick count
    MUL BX                              ; times five
    ADD AX, DI                          ; plus the carry from below

    MOV DX, AX                          ; The whole product, now in DX:AX
    MOV AX, SI

    MOV BX, 91
    DIV BX                              ; Seconds since midnight

    MOV BP, AX

    PUSH BP
    LEA DX, M_SECS
    MOV AH, 09H
    INT 21H
    POP AX
    PUSH AX
    CALL PRINT_DECIMAL
    LEA DX, M_TAIL
    MOV AH, 09H
    INT 21H

    ; Turn the seconds into hours, minutes and seconds
    POP AX
    XOR DX, DX
    MOV BX, 3600
    DIV BX
    PUSH DX
    CALL PRINT_TWO

    LEA DX, COLON
    MOV AH, 09H
    INT 21H

    POP AX
    XOR DX, DX
    MOV BX, 60
    DIV BX
    PUSH DX
    CALL PRINT_TWO

    LEA DX, COLON
    MOV AH, 09H
    INT 21H

    POP AX
    CALL PRINT_TWO
    CALL NEWLINE

    MOV AX, 4C00H
    INT 21H

; -----------------------------------------------------------------------------
; PRINT_TWO
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
; 1. WHY 18.2 AND NOT 20:
;    - The original PC divided its 1.19318 MHz clock by 65536, which is
;    - the largest a sixteen bit counter allows. That gave 18.2065 ticks
;    - a second and nobody has changed it since.
; 2. MULTIPLY THEN DIVIDE:
;    - Five times the ticks divided by 91 is the same as dividing by
;    - 18.2, done entirely in whole numbers. Dividing first would lose
;    - everything below eighteen ticks.
; 3. BOTH HALVES OF THE COUNT MATTER:
;    - A full day is 1,573,040 ticks, which needs twenty one bits. Taking
;    - only DX and ignoring CX gives an answer that looks like a time and
;    - is wrong by however many times the count has passed 65536.
;    - This program used to do exactly that and reported 00:29:52 for
;    - half past nine in the morning.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
