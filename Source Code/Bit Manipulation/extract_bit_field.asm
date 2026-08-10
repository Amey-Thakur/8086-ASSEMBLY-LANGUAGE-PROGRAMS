; =============================================================================
; TITLE: Extract a Bit Field
; DESCRIPTION: Reads a run of bits from an arbitrary position within a word by
;              shifting the field down and masking off everything above it.
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
    VALUE  DW 0B4D2H
    START_ DB 4                         ; First bit of the field
    WIDTH  DB 5                         ; How many bits it spans
    MSG    DB 'Field value: $'
    DIGITS DB '00', 0DH, 0AH, '$'

; -----------------------------------------------------------------------------
; CODE SEGMENT
; -----------------------------------------------------------------------------
.CODE
START:
    ; Context setup
    MOV AX, @DATA
    MOV DS, AX

    ; -------------------------------------------------------------------------
    ; STEP ONE: BRING THE FIELD DOWN TO BIT ZERO
    ; -------------------------------------------------------------------------
    MOV AX, VALUE
    MOV CL, START_
    SHR AX, CL

    ; -------------------------------------------------------------------------
    ; STEP TWO: BUILD A MASK OF THE RIGHT WIDTH AND APPLY IT
    ;
    ; One shifted left by the width, less one, gives a run of set bits exactly
    ; that wide: 1 SHL 5 is 32, and 31 is 0001 1111.
    ; -------------------------------------------------------------------------
    MOV BX, 1
    MOV CL, WIDTH
    SHL BX, CL
    DEC BX
    AND AX, BX                          ; AX now holds the field alone

    ; Report it as two decimal digits
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

    ; End process
    MOV AH, 4CH
    INT 21H

END START

; =============================================================================
; TECHNICAL NOTES
; =============================================================================
; 1. ORDER MATTERS:
;    - Shift first, then mask. Masking first would need a mask positioned at
;      the field rather than at bit zero, which is more work to build.
; 2. THE SHIFT COUNT:
;    - Any count other than one has to travel in CL on the 8086. Loading CL
;      from a variable is the usual way a field position becomes a shift.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
