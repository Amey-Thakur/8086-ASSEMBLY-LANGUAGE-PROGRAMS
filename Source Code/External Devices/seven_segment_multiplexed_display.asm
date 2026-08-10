; =============================================================================
; TITLE: Multiplexing A Four Digit Display
; DESCRIPTION: One set of segment lines shared between four digits, lit one at a time fast enough to look continuous.
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
    SEG_PORT   EQU 199                  ; The seven segment lines
    DIGIT_PORT EQU 9                    ; Which digit is currently enabled

    SEGMENTS DB 0111111B, 0000110B, 1011011B, 1001111B, 1100110B
             DB 1101101B, 1111101B, 0000111B, 1111111B, 1101111B

    NUMBER  DW 2021
    DIGITS  DB 4 DUP (0)

    ; What the current step is doing, kept here so the reporting does not have
    ; to compete with the display loop for registers.
    NOW_SWEEP DW 0
    NOW_PLACE DW 0
    NOW_SEGS  DW 0
    NOW_EN    DW 0
    PLACES  EQU 4
    SWEEPS  EQU 3                       ; How many times round the display

    M_TITLE DB 'A four digit display, multiplexed one digit at a time', 0DH, 0AH, '$'
    M_SHOW  DB 'Showing $'
    M_HEAD  DB 0DH, 0AH, 0DH, 0AH, 'sweep  place  digit  segments  enable'
            DB 0DH, 0AH, '$'
    M_GAP   DB '      $'
    M_TOTAL DB 0DH, 0AH, 'Port writes altogether: $'
    M_WHY   DB 0DH, 0AH
            DB 'Four digits share seven segment lines, so only one may be lit '
            DB 'at any instant. Sweeping faster than the eye makes all four '
            DB 'appear lit at once.', 0DH, 0AH, '$'

; -----------------------------------------------------------------------------
; CODE SEGMENT
; -----------------------------------------------------------------------------
.CODE
START:
    MOV AX, @DATA
    MOV DS, AX

    LEA DX, M_TITLE
    CALL PRINT_MESSAGE
    LEA DX, M_SHOW
    CALL PRINT_MESSAGE
    MOV AX, NUMBER
    CALL PRINT_DECIMAL
    LEA DX, M_HEAD
    CALL PRINT_MESSAGE

    ; ---- split the number, lowest place first -------------------------------
    MOV AX, NUMBER
    LEA DI, DIGITS
    MOV CX, PLACES
SPLIT:
    XOR DX, DX
    MOV BX, 10
    DIV BX
    MOV [DI], DL
    INC DI
    LOOP SPLIT

    ; -------------------------------------------------------------------------
    ; THE SWEEP. EACH PASS WRITES THE SEGMENT PATTERN AND THEN ENABLES EXACTLY
    ; ONE DIGIT, IN THAT ORDER. ENABLING FIRST WOULD BRIEFLY SHOW THE PREVIOUS
    ; DIGIT ON THE NEW POSITION, WHICH IS THE GHOSTING SEEN ON A BADLY WRITTEN
    ; DRIVER.
    ; -------------------------------------------------------------------------
    XOR BP, BP                          ; Port writes
    MOV CX, SWEEPS

EACH_SWEEP:
    PUSH CX
    MOV AX, SWEEPS
    SUB AX, CX
    MOV NOW_SWEEP, AX                   ; Which sweep this is, counting from zero

    MOV SI, PLACES
    DEC SI                              ; Highest place first, left to right

EACH_PLACE:
    ; ---- the pattern for this digit -----------------------------------------
    MOV BL, DIGITS[SI]
    XOR BH, BH
    MOV AL, SEGMENTS[BX]
    OUT SEG_PORT, AL
    INC BP

    XOR AH, AH
    MOV NOW_SEGS, AX                    ; The pattern, for the report

    ; ---- then enable this digit and no other --------------------------------
    MOV AX, PLACES
    DEC AX
    SUB AX, SI                          ; Position from the left
    MOV NOW_PLACE, AX

    MOV CL, AL
    MOV AL, 1
    SHL AL, CL
    OUT DIGIT_PORT, AL
    INC BP

    XOR AH, AH
    MOV NOW_EN, AX                      ; The enable pattern, for the report

    CALL REPORT_STEP

    DEC SI
    CMP SI, 0
    JGE EACH_PLACE

    POP CX
    LOOP EACH_SWEEP

    ; The display is blanked at the end, or the last digit stays lit alone and
    ; brighter than the rest.
    XOR AL, AL
    OUT DIGIT_PORT, AL
    INC BP

    LEA DX, M_TOTAL
    CALL PRINT_MESSAGE
    MOV AX, BP
    CALL PRINT_DECIMAL

    LEA DX, M_WHY
    CALL PRINT_MESSAGE

    MOV AH, 4CH
    INT 21H

; -----------------------------------------------------------------------------
; REPORT_STEP
;
; Prints one line of the sweep, reading everything it needs from memory. SI is
; still the index into DIGITS, which is the only thing the display loop and the
; report agree to share.
; -----------------------------------------------------------------------------
REPORT_STEP PROC
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX

    MOV AX, NOW_SWEEP
    CALL PRINT_DECIMAL
    LEA DX, M_GAP
    CALL PRINT_MESSAGE

    MOV AX, NOW_PLACE
    CALL PRINT_DECIMAL
    LEA DX, M_GAP
    CALL PRINT_MESSAGE

    MOV BL, DIGITS[SI]
    XOR BH, BH
    MOV AX, BX
    CALL PRINT_DECIMAL
    LEA DX, M_GAP
    CALL PRINT_MESSAGE

    MOV AX, NOW_SEGS
    CALL PRINT_DECIMAL
    LEA DX, M_GAP
    CALL PRINT_MESSAGE

    MOV AX, NOW_EN
    CALL PRINT_DECIMAL
    CALL NEWLINE

    POP DX
    POP CX
    POP BX
    POP AX
    RET
REPORT_STEP ENDP

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
; 1. Pattern first, enable second:
;    - Setting the segments before enabling the digit means nothing wrong is ever lit.
;    - Enabling first shows the previous pattern on the new digit for an instant.
;    - That instant is the ghosting visible on a poorly written display driver.
; 2. One digit at a time:
;    - All four digits share the same seven segment lines, so only one may be enabled.
;    - The enable is a single bit, produced by shifting one left by the position.
;    - Enabling two at once would show the same pattern on both.
; 3. Blank before leaving:
;    - Stopping mid sweep leaves one digit lit continuously and much brighter.
;    - Writing zero to the enable port turns everything off.
;    - The same applies to any multiplexed output: leave it in a defined state.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
