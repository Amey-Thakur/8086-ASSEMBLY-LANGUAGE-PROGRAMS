; =============================================================================
; TITLE: Sampling A Thermometer And Averaging
; DESCRIPTION: A single reading from a sensor is noise; a running average of several is a measurement.
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
    THERM_PORT EQU 125

    ; The simulator returns zero from a port never written, so the readings are
    ; supplied here and sent to the port before being read back. That keeps the
    ; program honest about where a reading comes from while still being
    ; reproducible.
    READINGS DB 21, 23, 22, 45, 22, 21, 23, 22
    SAMPLES  EQU 8
    SPIKE    EQU 10                     ; How far from the average is suspicious

    TOTAL_W DW 0
    KEPT_W  DW 0

    M_TITLE DB 'Averaging a sensor, and refusing an obvious spike', 0DH, 0AH, '$'
    M_HEAD  DB 0DH, 0AH, 'sample  reading  running mean  verdict', 0DH, 0AH, '$'
    M_GAP   DB '       $'
    M_GAP2  DB '        $'
    M_TAKE  DB 'accepted', 0DH, 0AH, '$'
    M_DROP  DB 'rejected as a spike', 0DH, 0AH, '$'
    M_FINAL DB 0DH, 0AH, 'Mean of the accepted readings: $'
    M_COUNT DB 0DH, 0AH, 'Readings accepted: $'
    M_OUTOF DB ' out of $'
    M_WHY   DB 0DH, 0AH
            DB 'The first reading has nothing to compare against, so it is '
            DB 'always accepted. A filter that rejected it would never start.'
            DB 0DH, 0AH, '$'

; -----------------------------------------------------------------------------
; CODE SEGMENT
; -----------------------------------------------------------------------------
.CODE
START:
    MOV AX, @DATA
    MOV DS, AX

    LEA DX, M_TITLE
    CALL PRINT_MESSAGE
    LEA DX, M_HEAD
    CALL PRINT_MESSAGE

    XOR SI, SI
    MOV CX, SAMPLES

EACH_SAMPLE:
    PUSH CX

    ; ---- the sample number --------------------------------------------------
    MOV AX, SI
    INC AX
    CALL PRINT_DECIMAL
    LEA DX, M_GAP
    CALL PRINT_MESSAGE

    ; -------------------------------------------------------------------------
    ; THE READING GOES OUT TO THE PORT AND IS READ BACK IN, WHICH IS WHAT A REAL
    ; PROGRAM WOULD DO WITH ONLY THE SECOND HALF. THE PORT IS THE SOURCE OF
    ; TRUTH EITHER WAY.
    ; -------------------------------------------------------------------------
    MOV AL, READINGS[SI]
    OUT THERM_PORT, AL
    IN AL, THERM_PORT
    XOR AH, AH
    MOV BX, AX                          ; The reading

    CALL PRINT_DECIMAL
    LEA DX, M_GAP2
    CALL PRINT_MESSAGE

    ; -------------------------------------------------------------------------
    ; A READING IS REFUSED WHEN IT IS FURTHER THAN SPIKE FROM THE MEAN SO FAR.
    ; THE FIRST ONE HAS NO MEAN TO COMPARE AGAINST AND IS ALWAYS TAKEN.
    ; -------------------------------------------------------------------------
    CMP KEPT_W, 0
    JE ACCEPT_IT

    ; ---- the mean so far ----------------------------------------------------
    MOV AX, TOTAL_W
    XOR DX, DX
    MOV DI, KEPT_W
    DIV DI
    MOV DI, AX                          ; The mean

    ; ---- the distance from it, whichever way round -------------------------
    MOV AX, BX
    CMP AX, DI
    JAE READING_ABOVE
    XCHG AX, DI
READING_ABOVE:
    SUB AX, DI

    CMP AX, SPIKE
    JBE ACCEPT_IT

    ; ---- refused ------------------------------------------------------------
    MOV AX, TOTAL_W
    XOR DX, DX
    MOV DI, KEPT_W
    DIV DI
    CALL PRINT_DECIMAL
    LEA DX, M_GAP2
    CALL PRINT_MESSAGE
    LEA DX, M_DROP
    CALL PRINT_MESSAGE
    JMP NEXT_SAMPLE

ACCEPT_IT:
    MOV AX, TOTAL_W
    ADD AX, BX
    MOV TOTAL_W, AX
    INC KEPT_W

    MOV AX, TOTAL_W
    XOR DX, DX
    MOV DI, KEPT_W
    DIV DI
    CALL PRINT_DECIMAL
    LEA DX, M_GAP2
    CALL PRINT_MESSAGE
    LEA DX, M_TAKE
    CALL PRINT_MESSAGE

NEXT_SAMPLE:
    INC SI
    POP CX
    LOOP EACH_SAMPLE

    LEA DX, M_FINAL
    CALL PRINT_MESSAGE
    MOV AX, TOTAL_W
    XOR DX, DX
    MOV DI, KEPT_W
    DIV DI
    CALL PRINT_DECIMAL

    LEA DX, M_COUNT
    CALL PRINT_MESSAGE
    MOV AX, KEPT_W
    CALL PRINT_DECIMAL
    LEA DX, M_OUTOF
    CALL PRINT_MESSAGE
    MOV AX, SAMPLES
    CALL PRINT_DECIMAL

    LEA DX, M_WHY
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
; 1. The first sample cannot be filtered:
;    - With nothing accepted yet there is no mean to measure a distance from.
;    - A filter that rejected the first reading would reject every reading for ever.
;    - So the count is tested before the distance, and zero means accept.
; 2. Distance without a sign:
;    - The reading may be above or below the mean, and both are equally suspicious.
;    - Exchanging the two so the larger is on top avoids needing a signed subtraction.
;    - JAE rather than JGE, because a sensor reading is an unsigned quantity.
; 3. Dividing by the count, not the samples:
;    - The mean is the total over the number accepted, not the number taken.
;    - Dividing by the sample count would pull the answer towards zero for every rejection.
;    - KEPT_W is therefore incremented only on the accepting path.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
