; =============================================================================
; TITLE: Reading a Sensor and Scaling It
; DESCRIPTION: Reads a converter port and turns the raw byte into engineering
;              units, which is where the arithmetic order matters.
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
    SENSOR  EQU 125                     ; The thermometer port
    HEATER  EQU 127

    ; The converter returns nought to 255 across a range of nought to 100
    ; degrees, so a reading of 128 is about fifty.
    LIMIT   EQU 60                       ; Above this the heater goes off

    M_RAW   DB 'Raw reading: $'
    M_TEMP  DB '   scaled: $'
    M_DEG   DB ' degrees$'
    M_ON    DB '   heater on', 0DH, 0AH, '$'
    M_OFF   DB '   heater off', 0DH, 0AH, '$'

    SAMPLES DB 0, 64, 128, 192, 255
    HOWMANY EQU 5

; -----------------------------------------------------------------------------
; CODE SEGMENT
; -----------------------------------------------------------------------------
.CODE
START:
    MOV AX, @DATA
    MOV DS, AX

    LEA SI, SAMPLES
    MOV CX, HOWMANY

EACH_SAMPLE:
    ; -------------------------------------------------------------------------
    ; THE SIMULATOR HAS NO REAL SENSOR, SO EACH SAMPLE IS WRITTEN TO THE PORT
    ; FIRST AND THEN READ BACK. ON REAL HARDWARE ONLY THE IN WOULD BE THERE,
    ; AND EVERYTHING AFTER IT IS THE SAME EITHER WAY.
    ; -------------------------------------------------------------------------
    MOV AL, [SI]
    OUT SENSOR, AL

    IN  AL, SENSOR                      ; The reading
    MOV BL, AL

    PUSH CX
    PUSH SI

    LEA DX, M_RAW
    MOV AH, 09H
    INT 21H
    MOV AL, BL
    XOR AH, AH
    CALL PRINT_DECIMAL

    ; -------------------------------------------------------------------------
    ; SCALING: READING TIMES 100, DIVIDED BY 255. MULTIPLYING FIRST KEEPS THE
    ; PRECISION; DIVIDING FIRST WOULD GIVE NOUGHT FOR EVERY READING BELOW 255
    ; AND THE SENSOR WOULD APPEAR BROKEN.
    ; -------------------------------------------------------------------------
    MOV AL, BL
    XOR AH, AH
    MOV DX, 100
    MUL DX                              ; Up to 25500, which needs a word
    MOV BX, 255
    DIV BX                              ; Now in degrees

    MOV BP, AX

    LEA DX, M_TEMP
    MOV AH, 09H
    INT 21H
    MOV AX, BP
    CALL PRINT_DECIMAL
    LEA DX, M_DEG
    MOV AH, 09H
    INT 21H

    ; Decide what the heater should do
    CMP BP, LIMIT
    JA  TOO_WARM

    MOV AL, 1                           ; Heater on
    OUT HEATER, AL
    LEA DX, M_ON
    JMP REPORT

TOO_WARM:
    MOV AL, 0
    OUT HEATER, AL
    LEA DX, M_OFF

REPORT:
    MOV AH, 09H
    INT 21H

    POP SI
    POP CX
    INC SI
    LOOP EACH_SAMPLE

    MOV AL, 0
    OUT HEATER, AL

    MOV AX, 4C00H
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
; 1. MULTIPLY BEFORE DIVIDING:
;    - A reading of 128 times 100 is 12800, divided by 255 is 50. Dividing
;    - first gives nought, then nought, and every reading looks like
;    - freezing point.
; 2. THE PRODUCT NEEDS A WORD:
;    - 255 times 100 is 25500, so the multiplication has to be done in AX
;    - and not AL. A byte multiply would overflow at a reading of three.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
