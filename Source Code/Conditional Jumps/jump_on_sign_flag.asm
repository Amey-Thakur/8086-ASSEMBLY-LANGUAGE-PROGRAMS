; =============================================================================
; TITLE: Branching on the Sign Flag
; DESCRIPTION: Classifies a set of values as negative, zero or positive using
;              JS and JZ, the shortest way to take the sign of a number.
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
    VALUES  DW -17, 0, 250, -1, 32767
    HOWMANY EQU 5
    M_NEG   DB 'negative', 0DH, 0AH, '$'
    M_ZERO  DB 'zero', 0DH, 0AH, '$'
    M_POS   DB 'positive', 0DH, 0AH, '$'

; -----------------------------------------------------------------------------
; CODE SEGMENT
; -----------------------------------------------------------------------------
.CODE
START:
    MOV AX, @DATA
    MOV DS, AX

    LEA SI, VALUES
    MOV CX, HOWMANY

CLASSIFY_LOOP:
    ; -------------------------------------------------------------------------
    ; OR A REGISTER WITH ITSELF CHANGES NOTHING BUT SETS THE FLAGS FROM ITS
    ; VALUE. IT IS THE USUAL WAY TO ASK "WHAT SIGN IS THIS" WITHOUT A COMPARE
    ; AGAINST ZERO, AND IT IS ONE BYTE SHORTER.
    ; -------------------------------------------------------------------------
    MOV AX, [SI]
    OR  AX, AX

    JS  IS_NEGATIVE
    JZ  IS_ZERO

    LEA DX, M_POS
    JMP REPORT

IS_NEGATIVE:
    LEA DX, M_NEG
    JMP REPORT

IS_ZERO:
    LEA DX, M_ZERO

REPORT:
    MOV AH, 09H
    INT 21H

    ADD SI, 2
    LOOP CLASSIFY_LOOP

    MOV AH, 4CH
    INT 21H

END START

; =============================================================================
; TECHNICAL NOTES
; =============================================================================
; 1. THE SIGN FLAG IS A COPY:
;    - It is simply the most significant bit of the result. Nothing is
;    - computed; the bit is copied into the flag.
; 2. ORDER OF THE TESTS:
;    - Zero is not negative, so JS has to be tested first only because
;    - zero has its sign bit clear. Either order works here; testing JZ
;    - first would be equally correct.
; 3. OR AGAINST CMP:
;    - CMP AX, 0 does the same job in three bytes. OR AX, AX does it in
;    - two and is the idiom most assembly programmers reach for.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
