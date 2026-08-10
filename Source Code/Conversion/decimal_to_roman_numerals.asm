; =============================================================================
; TITLE: Decimal to Roman Numerals
; DESCRIPTION: Writes a number in Roman numerals by taking away the largest
;              value that still fits, over and over.
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
    ; The subtractive forms are in the table alongside the plain ones, in
    ; descending order. Including IV and IX here is what removes the need for
    ; any special handling of them later.
    VALUES  DW 1000, 900, 500, 400, 100, 90, 50, 40, 10, 9, 5, 4, 1
    SYMBOLS DB 'M', 0, 'C', 'M', 'D', 0, 'C', 'D', 'C', 0, 'X', 'C'
            DB 'L', 0, 'X', 'L', 'X', 0, 'I', 'X', 'V', 0, 'I', 'V', 'I', 0
    ENTRIES EQU 13

    SAMPLES DW 1994, 2022, 49, 3888, 4
    HOWMANY EQU 5

    M_IS    DB ' is $'

; -----------------------------------------------------------------------------
; CODE SEGMENT
; -----------------------------------------------------------------------------
.CODE
START:
    MOV AX, @DATA
    MOV DS, AX

    LEA SI, SAMPLES
    MOV CX, HOWMANY

EACH_SAMPLE:
    MOV AX, [SI]

    PUSH CX
    PUSH SI

    PUSH AX
    CALL PRINT_DECIMAL
    LEA DX, M_IS
    MOV AH, 09H
    INT 21H
    POP AX

    CALL TO_ROMAN
    CALL NEWLINE

    POP SI
    POP CX
    ADD SI, 2
    LOOP EACH_SAMPLE

    MOV AH, 4CH
    INT 21H

; -----------------------------------------------------------------------------
; TO_ROMAN
;
; Prints AX in Roman numerals.
; -----------------------------------------------------------------------------
TO_ROMAN PROC
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX
    PUSH SI

    MOV BX, AX                          ; What is left to write
    XOR SI, SI                          ; Which table entry is being tried

TR_ENTRY:
    CMP SI, ENTRIES
    JAE TR_DONE

    ; -------------------------------------------------------------------------
    ; TAKE THE LARGEST VALUE THAT STILL FITS, AS MANY TIMES AS IT FITS. THE
    ; TABLE IS IN DESCENDING ORDER, SO WORKING DOWN IT ONCE PRODUCES THE
    ; CANONICAL FORM WITH NO BACKTRACKING.
    ; -------------------------------------------------------------------------
    MOV DI, SI
    SHL DI, 1
    MOV CX, VALUES[DI]                  ; The value of this symbol

TR_REPEAT:
    CMP BX, CX
    JB  TR_NEXT_ENTRY

    SUB BX, CX

    ; Emit the one or two letters for this entry
    MOV DI, SI
    SHL DI, 1
    MOV DL, SYMBOLS[DI]
    MOV AH, 02H
    INT 21H

    MOV DI, SI
    SHL DI, 1
    MOV DL, SYMBOLS[DI+1]
    OR  DL, DL
    JZ  TR_REPEAT                       ; A zero means there was only one letter

    MOV AH, 02H
    INT 21H
    JMP TR_REPEAT

TR_NEXT_ENTRY:
    INC SI
    JMP TR_ENTRY

TR_DONE:
    POP SI
    POP DX
    POP CX
    POP BX
    POP AX
    RET
TO_ROMAN ENDP

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

END START

; =============================================================================
; TECHNICAL NOTES
; =============================================================================
; 1. THE SUBTRACTIVE FORMS BELONG IN THE TABLE:
;    - Treating IV and IX as special cases after the fact needs several
;    - awkward tests. Putting them in the table as values of four and
;    - nine makes the whole conversion one greedy pass.
; 2. WHY GREEDY IS CORRECT HERE:
;    - The Roman values are arranged so that taking the largest that fits
;    - never leaves an amount that cannot be made from the rest. That is
;    - not true of every set of denominations.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
