; =============================================================================
; TITLE: Test Whether a Value is a Power of Two
; DESCRIPTION: Decides in two instructions whether a 16-bit value is a power of
;              two, using the identity that such a value has exactly one bit set.
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
    VALUE   DW 0400H                    ; 1024, one bit set
    YES_MSG DB 'The value is a power of two.', 0DH, 0AH, '$'
    NO_MSG  DB 'The value is not a power of two.', 0DH, 0AH, '$'

; -----------------------------------------------------------------------------
; CODE SEGMENT
; -----------------------------------------------------------------------------
.CODE
START:
    ; Context setup
    MOV AX, @DATA
    MOV DS, AX

    MOV BX, VALUE
    OR  BX, BX                          ; Zero is not a power of two
    JZ  NOT_POWER

    ; -------------------------------------------------------------------------
    ; THE TEST
    ;
    ; A power of two has exactly one bit set, so subtracting one flips that
    ; bit off and every lower bit on. The two values therefore share no bits.
    ; -------------------------------------------------------------------------
    MOV AX, BX
    DEC AX
    AND AX, BX                          ; Zero only when one bit was set
    JNZ NOT_POWER

    LEA DX, YES_MSG
    JMP REPORT

NOT_POWER:
    LEA DX, NO_MSG

REPORT:
    MOV AH, 09H
    INT 21H

    ; End process
    MOV AH, 4CH
    INT 21H

END START

; =============================================================================
; TECHNICAL NOTES
; =============================================================================
; 1. THE ZERO CASE:
;    - Zero passes the AND test, because 0 AND -1 is zero, so it has to be
;      rejected first. It has no bits set and is not a power of anything.
; 2. WHY NOT COUNT THE BITS:
;    - Counting works but reads every bit. This decides the question with one
;      decrement and one AND, whatever the value.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
