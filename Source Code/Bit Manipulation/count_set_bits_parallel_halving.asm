; =============================================================================
; TITLE: Count Set Bits by Parallel Halving
; DESCRIPTION: Counts the one bits of a word without any loop at all, by adding
;              the bits in pairs, the pairs in nibbles, the nibbles in bytes and
;              the bytes together.
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
    SAMPLES  DW 0B4D2H, 0FFFFH, 8001H, 00F0H
    SPAN     EQU $ - SAMPLES            ; Measured, never counted by hand
    HOWMANY  EQU SPAN / 2

    M_TITLE  DB 'Population count by parallel halving, one stage at a time'
             DB 0DH, 0AH, '$'
    M_PAIRS  DB '  pairs $'
    M_NIBS   DB '  nibbles $'
    M_BYTES  DB '  bytes $'
    M_TOTAL  DB '  total $'
    M_SUM    DB 'Sum of the four counts: $'

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

    XOR SI, SI                          ; Byte offset into the sample list
    XOR DI, DI                          ; Running total over the samples
    MOV CX, HOWMANY

EACH_WORD:
    MOV AX, SAMPLES[SI]
    CALL PRINT_HEX
    CALL HALVING_COUNT                  ; AX comes back holding the count

    LEA DX, M_TOTAL
    CALL PRINT_MESSAGE
    ADD DI, AX
    CALL PRINT_DECIMAL
    CALL NEWLINE

    ADD SI, 2
    LOOP EACH_WORD

    LEA DX, M_SUM
    CALL PRINT_MESSAGE
    MOV AX, DI
    CALL PRINT_DECIMAL
    CALL NEWLINE

    ; End process
    MOV AH, 4CH
    INT 21H

; -----------------------------------------------------------------------------
; HALVING_COUNT
;
; Takes a word in AX and returns its number of one bits in AX, printing each
; intermediate stage as it goes. AX alone is not restored, because it carries
; the answer back out; BX and DX are.
;
; The idea is that a count of one bits is a sum, and a sum can be done in
; parallel. After the first stage the word is eight independent two bit sums,
; after the second it is four four bit sums, and so on until one sum remains.
; -----------------------------------------------------------------------------
HALVING_COUNT PROC
    PUSH BX
    PUSH DX

    ; -------------------------------------------------------------------------
    ; STAGE ONE: EACH PAIR OF BITS BECOMES THE COUNT OF THAT PAIR
    ;
    ; Subtracting the odd bits from the value is exactly right for two bits:
    ; 11 less 01 is 10, 10 less 01 is 01, 01 less 00 is 01 and 00 stays 00.
    ; -------------------------------------------------------------------------
    MOV BX, AX
    SHR BX, 1
    AND BX, 5555H
    SUB AX, BX

    LEA DX, M_PAIRS
    CALL PRINT_MESSAGE
    CALL PRINT_HEX

    ; -------------------------------------------------------------------------
    ; STAGE TWO: PAIRS ADD INTO NIBBLES
    ;
    ; Both halves are masked before the addition, because a two bit field can
    ; hold 2 and 2, and their sum needs the third bit that the mask makes room
    ; for.
    ; -------------------------------------------------------------------------
    MOV BX, AX
    SHR BX, 2
    AND BX, 3333H
    AND AX, 3333H
    ADD AX, BX

    LEA DX, M_NIBS
    CALL PRINT_MESSAGE
    CALL PRINT_HEX

    ; -------------------------------------------------------------------------
    ; STAGE THREE: NIBBLES ADD INTO BYTES
    ;
    ; A nibble count is at most 4, so two of them cannot exceed 8 and cannot
    ; carry out of four bits. That is why one mask after the addition is enough.
    ; -------------------------------------------------------------------------
    MOV BX, AX
    SHR BX, 4
    ADD AX, BX
    AND AX, 0F0FH

    LEA DX, M_BYTES
    CALL PRINT_MESSAGE
    CALL PRINT_HEX

    ; -------------------------------------------------------------------------
    ; STAGE FOUR: THE TWO BYTE COUNTS ADD TOGETHER
    ; -------------------------------------------------------------------------
    MOV BX, AX
    SHR BX, 8
    ADD AX, BX
    AND AX, 00FFH

    POP DX
    POP BX
    RET
HALVING_COUNT ENDP

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
; 1. WHY THERE IS NO LOOP:
;    - Every stage halves the number of separate sums, so sixteen bits are
;    - finished in four stages whatever the value happens to be.
;    - The cost is therefore fixed rather than proportional to the bits set.
; 2. WHERE THE MASKS COME FROM:
;    - 5555H selects the odd bits, 3333H every other pair and 0F0FH every other
;    - nibble, so each one names the fields that are about to be added.
;    - Each mask is the previous one with its runs of ones twice as long.
; 3. WHY STAGE THREE NEEDS ONLY ONE MASK:
;    - Two nibble counts cannot exceed eight, so their sum still fits in four
;    - bits and cannot spill into the neighbouring field.
;    - Stage two has no such slack, which is why both halves are masked there.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
