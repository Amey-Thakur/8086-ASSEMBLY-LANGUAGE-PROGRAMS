; =============================================================================
; TITLE: Isolate the Lowest Set Bit
; DESCRIPTION: Extracts the least significant set bit of a value and reports its
;              position, using the two's complement identity X AND -X.
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
    VALUE  DW 0B4C0H                    ; Lowest set bit is bit 6
    MSG    DB 'Lowest set bit is at position $'
    DIGITS DB '00', 0DH, 0AH, '$'
    NONE   DB 'No bits are set.', 0DH, 0AH, '$'

; -----------------------------------------------------------------------------
; CODE SEGMENT
; -----------------------------------------------------------------------------
.CODE
START:
    ; Context setup
    MOV AX, @DATA
    MOV DS, AX

    MOV BX, VALUE
    OR  BX, BX
    JZ  NO_BITS

    ; -------------------------------------------------------------------------
    ; ISOLATION
    ;
    ; Negating a value in two's complement inverts every bit and adds one,
    ; which leaves the lowest set bit in place and clears everything above it.
    ; ANDing the two therefore keeps that one bit and nothing else.
    ; -------------------------------------------------------------------------
    MOV AX, BX
    NEG AX
    AND AX, BX                          ; AX now holds exactly one bit

    ; Walk it down to find which position it occupies
    XOR CX, CX
POSITION_LOOP:
    SHR AX, 1
    JC  FOUND
    INC CX
    JMP POSITION_LOOP

FOUND:
    MOV AX, CX
    MOV BL, 10
    DIV BL
    ADD AL, '0'
    ADD AH, '0'
    MOV DIGITS[0], AL
    MOV DIGITS[1], AH

    LEA DX, MSG
    MOV AH, 09H
    INT 21H
    LEA DX, DIGITS
    MOV AH, 09H
    INT 21H
    JMP FINISH

NO_BITS:
    LEA DX, NONE
    MOV AH, 09H
    INT 21H

FINISH:
    ; End process
    MOV AH, 4CH
    INT 21H

END START

; =============================================================================
; TECHNICAL NOTES
; =============================================================================
; 1. WHY X AND -X WORKS:
;    - -X is NOT X plus one. The addition ripples through the trailing zeros
;      and stops at the lowest set bit, leaving that bit set in both values
;      and every higher bit different.
; 2. POSITION NUMBERING:
;    - Bit zero is the least significant, matching the way the manuals number
;      the bits of the flags register.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
