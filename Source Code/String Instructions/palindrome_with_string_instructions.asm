; =============================================================================
; TITLE: Palindrome Test Using CMPSB
; DESCRIPTION: Decides whether a word reads the same backward by comparing it
;              against its own reversal.
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
    WORD_A  DB 'MALAYALAM'
    LENGTH  EQU 9
    MIRROR  DB 9 DUP(0)
    M_YES   DB 'MALAYALAM is a palindrome.', 0DH, 0AH, '$'
    M_NO    DB 'MALAYALAM is not a palindrome.', 0DH, 0AH, '$'

; -----------------------------------------------------------------------------
; CODE SEGMENT
; -----------------------------------------------------------------------------
.CODE
START:
    MOV AX, @DATA
    MOV DS, AX
    MOV ES, AX

    ; -------------------------------------------------------------------------
    ; BUILD THE REVERSAL BY READING FORWARD AND WRITING BACKWARD. LODSB
    ; ADVANCES SI WHATEVER THE DIRECTION FLAG SAYS FOR DI, SO THE TWO
    ; POINTERS CAN TRAVEL OPPOSITE WAYS WITHIN ONE LOOP.
    ; -------------------------------------------------------------------------
    LEA SI, WORD_A
    LEA DI, MIRROR
    ADD DI, LENGTH - 1
    MOV CX, LENGTH

BUILD_MIRROR:
    CLD
    LODSB                               ; Read forward
    STD
    STOSB                               ; Write backward
    LOOP BUILD_MIRROR

    ; -------------------------------------------------------------------------
    ; NOW ONE COMPARISON DECIDES IT.
    ; -------------------------------------------------------------------------
    LEA SI, WORD_A
    LEA DI, MIRROR
    MOV CX, LENGTH
    CLD
    REPE CMPSB
    JNE NOT_PALINDROME

    LEA DX, M_YES
    JMP REPORT

NOT_PALINDROME:
    LEA DX, M_NO

REPORT:
    MOV AH, 09H
    INT 21H

    MOV AH, 4CH
    INT 21H

END START

; =============================================================================
; TECHNICAL NOTES
; =============================================================================
; 1. THE DIRECTION FLAG IS SHARED:
;    - It governs both pointers, so reading forward while writing
;    - backward means changing it between the two instructions. Comparing
;    - from both ends inward avoids that entirely and is the shorter way.
; 2. WHY BUILD THE MIRROR AT ALL:
;    - Only to show CMPSB doing the comparison. A palindrome test that
;    - walks two pointers toward each other needs no second buffer.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
