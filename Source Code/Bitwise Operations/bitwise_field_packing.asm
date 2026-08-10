; =============================================================================
; TITLE: Packing Several Fields Into One Word
; DESCRIPTION: A date squeezed into sixteen bits, and taken out again, which is what masks and shifts are for.
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
    ; The layout DOS itself uses for a file date:
    ;   bits 0 to 4    day of the month, 1 to 31
    ;   bits 5 to 8    month, 1 to 12
    ;   bits 9 to 15   year since 1980, 0 to 127
    DAY_BITS   EQU 5
    MONTH_BITS EQU 4

    DAY_MASK   EQU 001FH                ; five bits
    MONTH_MASK EQU 000FH                ; four bits
    YEAR_MASK  EQU 007FH                ; seven bits

    IN_DAY   DW 14
    IN_MONTH DW 6
    IN_YEAR  DW 2021

    PACKED_W DW 0

    M_TITLE DB 'Three fields packed into one word, then unpacked', 0DH, 0AH, '$'
    M_IN    DB 0DH, 0AH, 'going in:   day $'
    M_INM   DB '  month $'
    M_INY   DB '  year $'
    M_PACK  DB 0DH, 0AH, 'packed word: $'
    M_OUT   DB 0DH, 0AH, 'coming out: day $'
    M_OUTM  DB '  month $'
    M_OUTY  DB '  year $'
    M_SAME  DB 0DH, 0AH, 0DH, 0AH, 'Everything came back unchanged.', 0DH, 0AH, '$'
    M_DIFF  DB 0DH, 0AH, 0DH, 0AH, 'Something did not survive the round trip.', 0DH, 0AH, '$'
    M_WHY   DB 'Sixteen bits hold a date to the day from 1980 to 2107. Three '
            DB 'separate words would take three times the space.', 0DH, 0AH, '$'

; -----------------------------------------------------------------------------
; CODE SEGMENT
; -----------------------------------------------------------------------------
.CODE
START:
    MOV AX, @DATA
    MOV DS, AX

    LEA DX, M_TITLE
    CALL PRINT_MESSAGE

    LEA DX, M_IN
    CALL PRINT_MESSAGE
    MOV AX, IN_DAY
    CALL PRINT_DECIMAL
    LEA DX, M_INM
    CALL PRINT_MESSAGE
    MOV AX, IN_MONTH
    CALL PRINT_DECIMAL
    LEA DX, M_INY
    CALL PRINT_MESSAGE
    MOV AX, IN_YEAR
    CALL PRINT_DECIMAL

    ; -------------------------------------------------------------------------
    ; PACKING. EACH FIELD IS MASKED TO ITS OWN WIDTH BEFORE BEING SHIFTED INTO
    ; PLACE, SO A VALUE TOO LARGE TRUNCATES INSTEAD OF SPILLING INTO THE FIELD
    ; ABOVE IT AND CORRUPTING BOTH.
    ; -------------------------------------------------------------------------
    MOV AX, IN_YEAR
    SUB AX, 1980
    AND AX, YEAR_MASK
    MOV CL, DAY_BITS + MONTH_BITS
    SHL AX, CL
    MOV BX, AX

    MOV AX, IN_MONTH
    AND AX, MONTH_MASK
    MOV CL, DAY_BITS
    SHL AX, CL
    OR BX, AX

    MOV AX, IN_DAY
    AND AX, DAY_MASK
    OR BX, AX

    MOV PACKED_W, BX

    LEA DX, M_PACK
    CALL PRINT_MESSAGE
    MOV AX, PACKED_W
    CALL PRINT_HEX

    ; -------------------------------------------------------------------------
    ; UNPACKING IS THE SAME STEPS BACKWARDS: SHIFT THE FIELD DOWN TO BIT ZERO,
    ; THEN MASK OFF EVERYTHING ABOVE IT. MASKING WITHOUT SHIFTING FIRST WOULD
    ; TAKE THE WRONG BITS.
    ; -------------------------------------------------------------------------
    MOV AX, PACKED_W
    AND AX, DAY_MASK
    MOV SI, AX                          ; Day

    MOV AX, PACKED_W
    MOV CL, DAY_BITS
    SHR AX, CL
    AND AX, MONTH_MASK
    MOV DI, AX                          ; Month

    MOV AX, PACKED_W
    MOV CL, DAY_BITS + MONTH_BITS
    SHR AX, CL
    AND AX, YEAR_MASK
    ADD AX, 1980
    MOV BP, AX                          ; Year

    LEA DX, M_OUT
    CALL PRINT_MESSAGE
    MOV AX, SI
    CALL PRINT_DECIMAL
    LEA DX, M_OUTM
    CALL PRINT_MESSAGE
    MOV AX, DI
    CALL PRINT_DECIMAL
    LEA DX, M_OUTY
    CALL PRINT_MESSAGE
    MOV AX, BP
    CALL PRINT_DECIMAL

    ; ---- checked, not assumed -----------------------------------------------
    MOV AX, SI
    CMP AX, IN_DAY
    JNE ROUND_TRIP_FAILED
    MOV AX, DI
    CMP AX, IN_MONTH
    JNE ROUND_TRIP_FAILED
    MOV AX, BP
    CMP AX, IN_YEAR
    JNE ROUND_TRIP_FAILED

    LEA DX, M_SAME
    CALL PRINT_MESSAGE
    JMP EXPLAIN

ROUND_TRIP_FAILED:
    LEA DX, M_DIFF
    CALL PRINT_MESSAGE

EXPLAIN:
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
; PRINT_HEX
;
; Prints the value in AX as four hexadecimal digits followed by H.
; -----------------------------------------------------------------------------
PRINT_HEX PROC
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX

    MOV BX, AX                          ; Keep the value; AX is needed for DOS
    MOV CX, 4                           ; Four nibbles, most significant first

PH_NEXT:
    ROL BX, 4                           ; Bring the next nibble to the bottom
    MOV DL, BL
    AND DL, 0FH

    ADD DL, '0'                         ; 0 to 9 sit just after '0'
    CMP DL, '9'
    JBE PH_EMIT
    ADD DL, 7                           ; A to F sit seven further on

PH_EMIT:
    MOV AH, 02H
    INT 21H
    LOOP PH_NEXT

    MOV DL, 'H'
    MOV AH, 02H
    INT 21H

    POP DX
    POP CX
    POP BX
    POP AX
    RET
PRINT_HEX ENDP

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
; 1. Mask before shifting in, shift before masking out:
;    - Going in, the mask stops an oversized value spilling into the next field.
;    - Coming out, the shift brings the field to bit zero so the mask takes the right bits.
;    - Getting the order wrong either way corrupts the neighbouring field silently.
; 2. The mask is the field width:
;    - Five bits is 1Fh, four bits is 0Fh, seven bits is 7Fh: one less than a power of two.
;    - Writing the widths as named constants keeps the masks and the shifts in step.
;    - A mask written as a literal in two places is a mask that will disagree with itself.
; 3. This is a real format:
;    - It is exactly how DOS stores a file date in a directory entry.
;    - Seven bits of year from 1980 runs out in 2107.
;    - Packing like this was not a trick but the ordinary way to use a scarce sixteen bits.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
