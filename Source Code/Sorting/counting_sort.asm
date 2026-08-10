; =============================================================================
; TITLE: Counting Sort
; DESCRIPTION: Sorts without comparing anything, by counting how many of each
;              value there are and writing them back in order.
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
    DATA_W   DW 7, 3, 9, 3, 1, 7, 5, 9, 3
    HOWMANY  EQU 9
    RANGE    EQU 10                     ; Values are known to be 0 to 9
    TALLY    DW RANGE DUP(0)
    M_BEFORE DB 'Before: $'
    M_AFTER  DB 'After:  $'

; -----------------------------------------------------------------------------
; CODE SEGMENT
; -----------------------------------------------------------------------------
.CODE
START:
    MOV AX, @DATA
    MOV DS, AX

    LEA DX, M_BEFORE
    MOV AH, 09H
    INT 21H
    CALL SHOW_ARRAY

    ; -------------------------------------------------------------------------
    ; PASS ONE: COUNT HOW MANY TIMES EACH VALUE APPEARS. THE VALUE IS USED AS
    ; AN INDEX, WHICH IS WHY THE RANGE HAS TO BE KNOWN AND SMALL.
    ; -------------------------------------------------------------------------
    LEA SI, DATA_W
    MOV CX, HOWMANY

TALLY_LOOP:
    MOV BX, [SI]
    SHL BX, 1                           ; Words in the tally
    INC WORD PTR TALLY[BX]
    ADD SI, 2
    LOOP TALLY_LOOP

    ; -------------------------------------------------------------------------
    ; PASS TWO: WALK THE TALLY FROM THE LOWEST VALUE UPWARD, WRITING EACH ONE
    ; BACK AS MANY TIMES AS IT WAS COUNTED. THE ARRAY COMES OUT SORTED WITHOUT
    ; A SINGLE COMPARISON BETWEEN TWO ELEMENTS.
    ; -------------------------------------------------------------------------
    LEA DI, DATA_W
    XOR BX, BX                          ; The value being emitted

EMIT_VALUE:
    CMP BX, RANGE
    JAE DONE_SORTING

    MOV SI, BX
    SHL SI, 1
    MOV CX, TALLY[SI]
    JCXZ NEXT_VALUE                     ; None of this value

EMIT_ONE:
    MOV [DI], BX
    ADD DI, 2
    LOOP EMIT_ONE

NEXT_VALUE:
    INC BX
    JMP EMIT_VALUE

DONE_SORTING:
    LEA DX, M_AFTER
    MOV AH, 09H
    INT 21H
    CALL SHOW_ARRAY

    MOV AH, 4CH
    INT 21H

; -----------------------------------------------------------------------------
; SHOW_ARRAY
;
; Prints DATA_W on one line.
; -----------------------------------------------------------------------------
SHOW_ARRAY PROC
    PUSH AX
    PUSH CX
    PUSH DX
    PUSH SI

    LEA SI, DATA_W
    MOV CX, HOWMANY

SA_LOOP:
    MOV AX, [SI]
    PUSH CX
    PUSH SI
    CALL PRINT_DECIMAL
    MOV DL, ' '
    MOV AH, 02H
    INT 21H
    POP SI
    POP CX
    ADD SI, 2
    LOOP SA_LOOP

    CALL NEWLINE

    POP SI
    POP DX
    POP CX
    POP AX
    RET
SHOW_ARRAY ENDP

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
; 1. FASTER THAN COMPARISON ALLOWS:
;    - No comparison sort can beat n log n. Counting sort is linear
;    - because it never compares two elements; it uses the values
;    - themselves as addresses.
; 2. THE PRICE IS THE RANGE:
;    - It needs one counter per possible value. For digits that is ten
;    - words; for arbitrary sixteen bit values it would be 128 kilobytes,
;    - which is more memory than the whole segment.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
