; =============================================================================
; TITLE: Find the Highest Set Bit
; DESCRIPTION: Reports the position of the most significant one bit of a word,
;              and rebuilds that bit on its own, which is the largest power of
;              two the value contains.
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
    SAMPLES DW 0B4D2H, 0001H, 00FFH, 1000H, 07FFFH, 0024H, 0000H
    SPAN    EQU $ - SAMPLES             ; Measured, never counted by hand

    M_TITLE DB 'The most significant one bit of each word', 0DH, 0AH, '$'
    M_BIT   DB '   bit $'
    M_ALONE DB '   isolated $'
    M_NONE  DB '   has no bits set at all$'

; -----------------------------------------------------------------------------
; CODE SEGMENT
; -----------------------------------------------------------------------------
.CODE
START:
    ; Context setup
    MOV AX, @DATA
    MOV DS, AX

    LEA DX, M_TITLE
    CALL PRINT_MESSAGE

    ; -------------------------------------------------------------------------
    ; THE OUTER WALK
    ;
    ; The list is walked by comparing the offset against its measured length
    ; rather than with LOOP, because CX is wanted for the bit position and a
    ; program with two claims on one register is a program with a bug waiting.
    ; -------------------------------------------------------------------------
    XOR SI, SI

EACH_WORD:
    CMP SI, SPAN
    JAE ALL_READ                        ; Offsets are unsigned, so JAE not JGE

    MOV AX, SAMPLES[SI]
    CALL PRINT_HEX

    MOV BX, AX                          ; A copy to destroy while searching
    OR  BX, BX
    JZ  NO_BITS_HERE                    ; Nothing to find, and the scan would
                                        ; never see a one bit

    ; -------------------------------------------------------------------------
    ; THE SCAN
    ;
    ; The working copy is shifted up until its sign bit is set. Counting down
    ; from fifteen as it goes means the counter already names the position the
    ; bit started from.
    ; -------------------------------------------------------------------------
    MOV CX, 15

SCAN_DOWN:
    OR  BX, BX
    JS  TOP_FOUND                       ; The sign flag is bit fifteen of BX
    SHL BX, 1
    DEC CX
    JMP SCAN_DOWN

TOP_FOUND:
    LEA DX, M_BIT
    CALL PRINT_MESSAGE
    MOV AX, CX
    CALL PRINT_DECIMAL

    LEA DX, M_ALONE
    CALL PRINT_MESSAGE
    MOV AX, 1
    SHL AX, CL                          ; One shifted up to that position is the
    CALL PRINT_HEX                      ; bit by itself
    CALL NEWLINE
    JMP NEXT_WORD

NO_BITS_HERE:
    LEA DX, M_NONE
    CALL PRINT_MESSAGE
    CALL NEWLINE

NEXT_WORD:
    ADD SI, 2
    JMP EACH_WORD

ALL_READ:
    ; End process
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
; 1. WHY ZERO IS REJECTED FIRST:
;    - The scan stops when a one bit reaches the sign position, and a word of
;    - zeros never produces one.
;    - Without the guard the counter would run past zero and wrap to 65535.
; 2. WHY THE SEARCH GOES UPWARD:
;    - The sign flag is a free test of the top bit, so shifting up and asking
;    - JS costs nothing beyond the shift itself.
;    - Searching downward would need a mask that has to be built and moved.
; 3. WHAT THE ISOLATED VALUE MEANS:
;    - One shifted left by the position is the largest power of two that does
;    - not exceed the value, which is what a size or an alignment usually wants.
;    - The lowest set bit is found instead by the identity X AND minus X.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
