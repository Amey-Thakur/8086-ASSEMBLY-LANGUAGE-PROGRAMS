; =============================================================================
; TITLE: Indexed Addressing Mode
; DESCRIPTION: An index register plus a constant, the mode written as ARRAY[SI] and used for every element by number.
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
    DATA_W  DW 10, 20, 30, 40, 50
    HOWMANY EQU 5

    M_TITLE DB 'Indexed addressing: an index register plus a constant', 0DH, 0AH, '$'
    M_WORDS DB 'A word is two bytes, so element n sits at byte offset n*2', 0DH, 0AH, '$'
    M_ELEM  DB 'element $'
    M_IS    DB ' at offset $'
    M_EQ    DB ' holds $'
    M_TOTAL DB 'Sum of all five: $'
    M_LAST  DB 'One past the end, DATA_W[HOWMANY*2], would be out of bounds.', 0DH, 0AH, '$'

; -----------------------------------------------------------------------------
; CODE SEGMENT
; -----------------------------------------------------------------------------
.CODE
START:
    MOV AX, @DATA
    MOV DS, AX

    LEA DX, M_TITLE

    CALL PRINT_MESSAGE
    LEA DX, M_WORDS
    CALL PRINT_MESSAGE

    ; -------------------------------------------------------------------------
    ; SI COUNTS BYTES, NOT ELEMENTS. THE LOOP THEREFORE ADDS TWO EACH TIME AND
    ; THE ELEMENT NUMBER IS TRACKED SEPARATELY IN BX FOR THE REPORT.
    ; -------------------------------------------------------------------------
    XOR SI, SI                          ; Byte offset into the array
    XOR BX, BX                          ; Element number
    MOV CX, HOWMANY

SHOW_EACH:
    LEA DX, M_ELEM
    CALL PRINT_MESSAGE
    MOV AX, BX
    CALL PRINT_DECIMAL

    LEA DX, M_IS

    CALL PRINT_MESSAGE
    MOV AX, SI
    CALL PRINT_DECIMAL

    LEA DX, M_EQ

    CALL PRINT_MESSAGE
    MOV AX, DATA_W[SI]
    CALL PRINT_DECIMAL
    CALL NEWLINE

    INC BX
    ADD SI, 2
    LOOP SHOW_EACH
    CALL NEWLINE

    ; -------------------------------------------------------------------------
    ; THE SAME MODE DRIVES A RUNNING TOTAL. NOTHING BUT SI CHANGES BETWEEN
    ; ITERATIONS, SO THE INSTRUCTION ITSELF IS IDENTICAL EACH TIME ROUND.
    ; -------------------------------------------------------------------------
    XOR SI, SI
    XOR DI, DI                          ; The total
    MOV CX, HOWMANY
ADD_EACH:
    MOV AX, DATA_W[SI]
    ADD DI, AX
    ADD SI, 2
    LOOP ADD_EACH

    LEA DX, M_TOTAL

    CALL PRINT_MESSAGE
    MOV AX, DI
    CALL PRINT_DECIMAL
    CALL NEWLINE

    LEA DX, M_LAST

    CALL PRINT_MESSAGE

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
; 1. Bytes, not elements:
;    - SI is a byte offset, so a word array steps by two and a byte array by one.
;    - The 8086 has no scaled index mode; that arrives with the 386.
;    - Element n of a word array is at DATA_W[n*2], which the assembler folds if n is a constant.
; 2. Indexed against based:
;    - The encodings differ but the arithmetic is the same: one register plus a constant.
;    - By convention SI and DI index into data while BX bases a record.
;    - The processor does not enforce the convention; only the segment default for BP differs.
; 3. Why the loop body never changes:
;    - MOV AX, DATA_W[SI] is one fixed instruction whatever SI holds.
;    - That is what lets a five element loop and a five thousand element loop share code.
;    - Only the count in CX and the stride on SI decide how far it goes.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
