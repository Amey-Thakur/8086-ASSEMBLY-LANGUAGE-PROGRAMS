; =============================================================================
; TITLE: Gray Code
; DESCRIPTION: Converts to and from the code in which consecutive values differ
;              in exactly one bit, which is why it is used on rotary encoders.
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
    HOWMANY EQU 8
    M_HEAD  DB 'value  gray   back', 0DH, 0AH, '$'
    M_GAP   DB '   $'
    M_FAIL  DB 'The round trip failed.', 0DH, 0AH, '$'
    M_OK    DB 'Every value converted and came back unchanged.', 0DH, 0AH, '$'

; -----------------------------------------------------------------------------
; CODE SEGMENT
; -----------------------------------------------------------------------------
.CODE
START:
    MOV AX, @DATA
    MOV DS, AX

    LEA DX, M_HEAD
    MOV AH, 09H
    INT 21H

    XOR BX, BX                          ; The value being converted
    MOV DI, 1                           ; Set to zero if any round trip fails

NEXT_VALUE:
    CMP BX, HOWMANY
    JAE FINISHED

    ; The value itself
    MOV AX, BX
    CALL PRINT_BINARY_4
    LEA DX, M_GAP
    MOV AH, 09H
    INT 21H

    ; -------------------------------------------------------------------------
    ; TO GRAY: EXCLUSIVE OR THE VALUE WITH ITSELF SHIFTED RIGHT ONE PLACE.
    ; EACH BIT BECOMES THE DIFFERENCE BETWEEN ITSELF AND THE ONE ABOVE, WHICH
    ; IS WHAT MAKES NEIGHBOURING VALUES DIFFER IN ONLY ONE PLACE.
    ; -------------------------------------------------------------------------
    MOV AX, BX
    MOV CX, AX
    SHR CX, 1
    XOR AX, CX
    MOV SI, AX                          ; The Gray code

    CALL PRINT_BINARY_4
    LEA DX, M_GAP
    MOV AH, 09H
    INT 21H

    ; -------------------------------------------------------------------------
    ; BACK AGAIN: EXCLUSIVE OR EACH BIT WITH EVERY BIT ABOVE IT, WHICH MEANS
    ; SHIFTING AND FOLDING IN REPEATEDLY UNTIL NOTHING IS LEFT TO SHIFT.
    ; -------------------------------------------------------------------------
    MOV AX, SI
    MOV CX, AX

UNGRAY:
    SHR CX, 1
    JZ  UNGRAY_DONE
    XOR AX, CX
    JMP UNGRAY

UNGRAY_DONE:
    CALL PRINT_BINARY_4
    CALL NEWLINE

    CMP AX, BX
    JE  ROUND_TRIP_OK
    XOR DI, DI

ROUND_TRIP_OK:
    INC BX
    JMP NEXT_VALUE

FINISHED:
    OR  DI, DI
    JZ  ROUND_TRIP_FAILED

    LEA DX, M_OK
    JMP REPORT

ROUND_TRIP_FAILED:
    LEA DX, M_FAIL

REPORT:
    MOV AH, 09H
    INT 21H

    MOV AH, 4CH
    INT 21H

; -----------------------------------------------------------------------------
; PRINT_BINARY_4
;
; Prints the low four bits of AX as ones and zeros.
; -----------------------------------------------------------------------------
PRINT_BINARY_4 PROC
    PUSH AX
    PUSH CX
    PUSH DX

    MOV CX, 4
    SHL AX, 12                          ; Bring bit 3 to the top of the word

PB_LOOP:
    SHL AX, 1
    MOV DL, '0'
    JNC PB_EMIT
    MOV DL, '1'

PB_EMIT:
    PUSH AX
    MOV AH, 02H
    INT 21H
    POP AX
    LOOP PB_LOOP

    POP DX
    POP CX
    POP AX
    RET
PRINT_BINARY_4 ENDP

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
; 1. WHY ONLY ONE BIT CHANGES:
;    - On a rotary encoder read while it is turning, two bits changing at
;    - once can be caught half way and produce a value that was never
;    - there. Gray code makes that impossible.
; 2. THE CONVERSIONS ARE NOT SYMMETRIC:
;    - Going to Gray is one shift and one exclusive or. Coming back needs
;    - every higher bit folded in, so it is a loop. Checking that the
;    - round trip returns the original is the cheapest proof both are
;    - right.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
