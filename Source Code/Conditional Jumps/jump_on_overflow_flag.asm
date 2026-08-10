; =============================================================================
; TITLE: Branching on the Overflow Flag
; DESCRIPTION: Detects a signed addition whose result is wrong, and shows that
;              the carry flag stays clear while it happens.
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
    NEAR_MAX DW 32000                   ; Close to the signed limit of 32767
    ADDEND   DW 1000
    M_HEAD   DB '32000 + 1000 as a signed word:', 0DH, 0AH, '$'
    M_OVER   DB '  OF is set: the answer will not fit', 0DH, 0AH, '$'
    M_NOOVER DB '  OF is clear: the answer fits', 0DH, 0AH, '$'
    M_NOCARR DB '  CF is clear: as unsigned it fits perfectly', 0DH, 0AH, '$'
    M_CARRY  DB '  CF is set', 0DH, 0AH, '$'

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

    ; -------------------------------------------------------------------------
    ; 33000 IS BEYOND 32767, SO AS A SIGNED WORD THE RESULT WRAPS TO A
    ; NEGATIVE NUMBER. AS AN UNSIGNED WORD 33000 IS PERFECTLY ORDINARY, SO
    ; THE CARRY STAYS CLEAR. ONE ADDITION, TWO VERDICTS.
    ; -------------------------------------------------------------------------
    MOV AX, NEAR_MAX
    ADD AX, ADDEND
    PUSHF                               ; Keep both flags for two tests

    JNO NO_OVERFLOW
    LEA DX, M_OVER
    JMP SHOW_OVERFLOW

NO_OVERFLOW:
    LEA DX, M_NOOVER

SHOW_OVERFLOW:
    MOV AH, 09H
    INT 21H

    POPF                                ; The same flags again
    JC  HAD_CARRY
    LEA DX, M_NOCARR
    JMP SHOW_CARRY

HAD_CARRY:
    LEA DX, M_CARRY

SHOW_CARRY:
    MOV AH, 09H
    INT 21H

    MOV AH, 4CH
    INT 21H

END START

; =============================================================================
; TECHNICAL NOTES
; =============================================================================
; 1. WHEN OF IS SET:
;    - Adding two values of the same sign and getting the other sign.
;    - Two positives cannot sum to a negative, so if they appear to, the
;    - true answer was too large for the word.
; 2. OF AND CF ARE INDEPENDENT:
;    - Either, both or neither can be set by one addition. They answer
;    - different questions about the same bits.
; 3. INTO:
;    - INTO raises interrupt 4 when OF is set, which is a way of checking
;    - for signed overflow without writing a branch after every sum.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
