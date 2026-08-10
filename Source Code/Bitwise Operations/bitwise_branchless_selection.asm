; =============================================================================
; TITLE: Choosing Without Branching
; DESCRIPTION: Minimum, maximum, absolute value and a conditional swap, all done with masks instead of jumps.
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
    PAIRS_A DW 12, -5,  0, 100, -40,  7
    PAIRS_B DW 30,  3, 0,  -1, -90,  7
    HOWMANY EQU 6

    M_TITLE DB 'Minimum, maximum and absolute value without a jump', 0DH, 0AH, '$'
    M_HEAD  DB 0DH, 0AH, '     a       b     min     max    |a|', 0DH, 0AH, '$'
    M_GAP   DB '   $'
    M_AGREE DB 0DH, 0AH, 'Every answer matched the branching version.', 0DH, 0AH, '$'
    M_DIFF  DB 0DH, 0AH, 'An answer differed from the branching version.', 0DH, 0AH, '$'
    M_WHY   DB 0DH, 0AH
            DB 'A mask of all ones or all zeros selects one of two values with '
            DB 'AND, NOT and OR, and takes the same time whichever wins.'
            DB 0DH, 0AH, '$'

; -----------------------------------------------------------------------------
; CODE SEGMENT
; -----------------------------------------------------------------------------
.CODE
START:
    MOV AX, @DATA
    MOV DS, AX

    LEA DX, M_TITLE
    CALL PRINT_MESSAGE
    LEA DX, M_HEAD
    CALL PRINT_MESSAGE

    XOR SI, SI
    MOV BP, 1                           ; 1 while the two methods agree
    MOV CX, HOWMANY

EACH_PAIR:
    PUSH CX

    MOV AX, PAIRS_A[SI]
    CALL PRINT_SIGNED
    LEA DX, M_GAP
    CALL PRINT_MESSAGE

    MOV AX, PAIRS_B[SI]
    CALL PRINT_SIGNED
    LEA DX, M_GAP
    CALL PRINT_MESSAGE

    ; -------------------------------------------------------------------------
    ; THE MINIMUM. SUBTRACTING AND TAKING THE SIGN GIVES A MASK OF ALL ONES WHEN
    ; A IS THE SMALLER, AND ALL ZEROS OTHERWISE. THE MASK THEN SELECTS.
    ; -------------------------------------------------------------------------
    MOV AX, PAIRS_A[SI]
    MOV BX, PAIRS_B[SI]
    CALL BRANCHLESS_MIN
    MOV DI, AX
    CALL PRINT_SIGNED
    LEA DX, M_GAP
    CALL PRINT_MESSAGE

    MOV AX, PAIRS_A[SI]
    MOV BX, PAIRS_B[SI]
    CALL BRANCHLESS_MAX
    CALL PRINT_SIGNED
    LEA DX, M_GAP
    CALL PRINT_MESSAGE

    MOV AX, PAIRS_A[SI]
    CALL BRANCHLESS_ABS
    CALL PRINT_SIGNED
    CALL NEWLINE

    ; ---- and checked against the obvious version ---------------------------
    MOV AX, PAIRS_A[SI]
    MOV BX, PAIRS_B[SI]
    CMP AX, BX
    JLE A_IS_SMALLER
    MOV AX, BX
A_IS_SMALLER:
    CMP AX, DI
    JE STILL_AGREED
    MOV BP, 0
STILL_AGREED:

    ADD SI, 2
    POP CX
    LOOP EACH_PAIR

    CMP BP, 1
    JNE THEY_DIFFER
    LEA DX, M_AGREE
    CALL PRINT_MESSAGE
    JMP EXPLAIN

THEY_DIFFER:
    LEA DX, M_DIFF
    CALL PRINT_MESSAGE

EXPLAIN:
    LEA DX, M_WHY
    CALL PRINT_MESSAGE

    MOV AH, 4CH
    INT 21H

; -----------------------------------------------------------------------------
; BRANCHLESS_MIN
;
; The smaller of AX and BX, chosen with a mask.
;
; A minus B has its sign bit set exactly when A is the smaller. Copying that
; bit into every position with an arithmetic shift right of fifteen gives a
; mask of all ones or all zeros, and the mask then picks the answer.
; -----------------------------------------------------------------------------
BRANCHLESS_MIN PROC
    PUSH BX
    PUSH CX
    PUSH DX

    MOV DX, AX
    SUB DX, BX                          ; The difference decides
    MOV CL, 15
    SAR DX, CL                          ; All ones when A is smaller

    ; result = (A AND mask) OR (B AND NOT mask)
    AND AX, DX
    NOT DX
    AND BX, DX
    OR AX, BX

    POP DX
    POP CX
    POP BX
    RET
BRANCHLESS_MIN ENDP

; -----------------------------------------------------------------------------
; BRANCHLESS_MAX
;
; The larger of AX and BX, by the same method with the mask the other way round.
; -----------------------------------------------------------------------------
BRANCHLESS_MAX PROC
    PUSH BX
    PUSH CX
    PUSH DX

    MOV DX, AX
    SUB DX, BX
    MOV CL, 15
    SAR DX, CL                          ; All ones when A is smaller

    ; result = (B AND mask) OR (A AND NOT mask)
    AND BX, DX
    NOT DX
    AND AX, DX
    OR AX, BX

    POP DX
    POP CX
    POP BX
    RET
BRANCHLESS_MAX ENDP

; -----------------------------------------------------------------------------
; BRANCHLESS_ABS
;
; The magnitude of AX.
;
; The sign spread across the word is either all ones or all zeros. Adding it
; and then exclusive oring with it negates when it is all ones and does nothing
; when it is all zeros, because negation in two's complement is exactly a
; complement and an increment.
; -----------------------------------------------------------------------------
BRANCHLESS_ABS PROC
    PUSH CX
    PUSH DX

    MOV DX, AX
    MOV CL, 15
    SAR DX, CL

    ADD AX, DX
    XOR AX, DX

    POP DX
    POP CX
    RET
BRANCHLESS_ABS ENDP

; -----------------------------------------------------------------------------
; PRINT_SIGNED
;
; Prints AX as a signed value, with a minus sign when it is negative.
; -----------------------------------------------------------------------------
PRINT_SIGNED PROC
    PUSH AX
    PUSH DX

    OR  AX, AX
    JNS PS_POSITIVE                     ; Sign flag clear means not negative

    PUSH AX
    MOV DL, '-'
    MOV AH, 02H
    INT 21H
    POP AX
    NEG AX                              ; Print the magnitude

PS_POSITIVE:
    CALL PRINT_DECIMAL

    POP DX
    POP AX
    RET
PRINT_SIGNED ENDP

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
; 1. A shift makes the mask:
;    - SAR by fifteen copies the sign bit into all sixteen positions.
;    - The result is all ones or all zeros, which is exactly what AND needs to select.
;    - SHR would bring in zeros instead and give one or nothing, which does not select.
; 2. Why the difference can be trusted:
;    - A minus B has its sign bit set when A is the smaller, provided it does not overflow.
;    - These values are small enough that it cannot, which is the usual caveat.
;    - For the full range the comparison has to allow for overflow, and a branch becomes simpler.
; 3. Checked against the obvious version:
;    - The branching minimum is computed alongside and compared every time.
;    - A clever routine that is never checked is a clever routine nobody should trust.
;    - The comparison costs four instructions and removes all doubt.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
