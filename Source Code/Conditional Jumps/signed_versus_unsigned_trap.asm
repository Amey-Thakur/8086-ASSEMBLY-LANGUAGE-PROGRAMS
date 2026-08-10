; =============================================================================
; TITLE: The Same Bytes, Two Different Answers
; DESCRIPTION: Compares one pair of values with both the signed and the unsigned
;              branches, and shows them reaching opposite conclusions.
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
    ; FFFEh is 65534 read as unsigned and -2 read as signed.
    ; 0002h is 2 either way.
    LEFT   DW 0FFFEH
    RIGHT  DW 0002H

    HEADER DB 'Comparing FFFEh with 0002h:', 0DH, 0AH, '$'
    U_ABV  DB '  unsigned: FFFEh is ABOVE 0002h', 0DH, 0AH, '$'
    U_BLW  DB '  unsigned: FFFEh is BELOW 0002h', 0DH, 0AH, '$'
    S_GTR  DB '  signed:   FFFEh is GREATER than 0002h', 0DH, 0AH, '$'
    S_LSS  DB '  signed:   FFFEh is LESS than 0002h', 0DH, 0AH, '$'

; -----------------------------------------------------------------------------
; CODE SEGMENT
; -----------------------------------------------------------------------------
.CODE
START:
    MOV AX, @DATA
    MOV DS, AX

    LEA DX, HEADER
    MOV AH, 09H
    INT 21H

    ; -------------------------------------------------------------------------
    ; ONE COMPARE, TWO QUESTIONS. THE FLAGS ARE SET ONCE AND BOTH FAMILIES OF
    ; BRANCH READ THEM, EACH IN ITS OWN WAY.
    ; -------------------------------------------------------------------------
    MOV AX, LEFT
    CMP AX, RIGHT

    JBE UNSIGNED_BELOW
    LEA DX, U_ABV
    MOV AH, 09H
    INT 21H
    JMP SIGNED_TEST

UNSIGNED_BELOW:
    LEA DX, U_BLW
    MOV AH, 09H
    INT 21H

SIGNED_TEST:
    MOV AX, LEFT
    CMP AX, RIGHT

    JLE SIGNED_LESS
    LEA DX, S_GTR
    MOV AH, 09H
    INT 21H
    JMP FINISH

SIGNED_LESS:
    LEA DX, S_LSS
    MOV AH, 09H
    INT 21H

FINISH:
    MOV AH, 4CH
    INT 21H

END START

; =============================================================================
; TECHNICAL NOTES
; =============================================================================
; 1. BOTH ANSWERS ARE CORRECT:
;    - The processor stores bits. Whether FFFEh means 65534 or -2 is not
;    - recorded anywhere; it is decided by which branch is chosen.
; 2. WHERE THIS BITES:
;    - A loop that compares a signed index against an unsigned length,
;    - or a sort written with JB on data that turns out to be signed.
;    - Both work perfectly until a value crosses 8000h.
; 3. CHOOSING:
;    - Decide what the data means before writing the comparison. Sizes,
;    - counts, addresses and characters are unsigned. Temperatures,
;    - balances and differences are signed.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
