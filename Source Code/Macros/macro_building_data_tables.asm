; =============================================================================
; TITLE: Building A Data Table With A Macro
; DESCRIPTION: Macros can emit data as readily as instructions, which keeps a table and its length honest with each other.
; AUTHOR: Amey Thakur (https://github.com/Amey-Thakur)
; REPOSITORY: https://github.com/Amey-Thakur/8086-ASSEMBLY-LANGUAGE-PROGRAMS
; LICENSE: MIT License
; =============================================================================

.MODEL SMALL
.STACK 100H

; -----------------------------------------------------------------------------
; MACRO DEFINITIONS
; -----------------------------------------------------------------------------

; ---- one row of the table ---------------------------------------------------
; Each row is a word for the code and a word for the price. Emitting them
; through a macro means the shape of a row is stated once.
ITEM MACRO CODE_NO, PRICE
    DW CODE_NO
    DW PRICE
ENDM

; ---- a run of zero words ----------------------------------------------------
RESERVE MACRO HOWMANY
    REPT HOWMANY
    DW 0
    ENDM
ENDM

; -----------------------------------------------------------------------------
; DATA SEGMENT
; -----------------------------------------------------------------------------
.DATA
    ; The table is written as five ITEM lines. The length is measured from the
    ; labels rather than counted by hand, so adding a row cannot get it wrong.
    TABLE   LABEL WORD
    ITEM 101, 250
    ITEM 102, 175
    ITEM 103, 990
    ITEM 104, 45
    ITEM 105, 1200
    TABLE_END LABEL WORD

    ROW_BYTES EQU 4
    ROWS      EQU (TABLE_END - TABLE) / ROW_BYTES

    SPARE   LABEL WORD
    RESERVE 4
    SPARE_END LABEL WORD

    M_TITLE DB 'A table emitted by a macro, and measured not counted', 0DH, 0AH, '$'
    M_ROWS  DB 'Rows in the table:  $'
    M_BYTES DB 'Bytes in the table: $'
    M_SPARE DB 'Words reserved:     $'
    M_HEAD  DB 0DH, 0AH, 'code  price', 0DH, 0AH, '$'
    M_GAP   DB '   $'
    M_TOTAL DB 0DH, 0AH, 'Total of the prices: $'
    M_WHY   DB 0DH, 0AH
            DB 'Adding a sixth ITEM line would change every number above '
            DB 'without another edit.', 0DH, 0AH, '$'

; -----------------------------------------------------------------------------
; CODE SEGMENT
; -----------------------------------------------------------------------------
.CODE
START:
    MOV AX, @DATA
    MOV DS, AX

    LEA DX, M_TITLE
    CALL PRINT_MESSAGE

    LEA DX, M_ROWS
    CALL PRINT_MESSAGE
    MOV AX, ROWS
    CALL PRINT_DECIMAL
    CALL NEWLINE

    LEA DX, M_BYTES
    CALL PRINT_MESSAGE
    MOV AX, TABLE_END - TABLE
    CALL PRINT_DECIMAL
    CALL NEWLINE

    LEA DX, M_SPARE
    CALL PRINT_MESSAGE
    MOV AX, (SPARE_END - SPARE) / 2
    CALL PRINT_DECIMAL
    CALL NEWLINE

    LEA DX, M_HEAD
    CALL PRINT_MESSAGE

    ; -------------------------------------------------------------------------
    ; THE LOOP TAKES ITS COUNT FROM THE MEASURED ROW TOTAL, SO IT FOLLOWS THE
    ; TABLE AUTOMATICALLY. THE PRICES ARE TOTALLED IN DI AS IT GOES.
    ; -------------------------------------------------------------------------
    LEA SI, TABLE
    XOR DI, DI
    MOV CX, ROWS

EACH_ROW:
    MOV AX, [SI]                        ; The code
    CALL PRINT_DECIMAL
    LEA DX, M_GAP
    CALL PRINT_MESSAGE

    MOV AX, [SI+2]                      ; The price
    ADD DI, AX
    CALL PRINT_DECIMAL
    CALL NEWLINE

    ADD SI, ROW_BYTES
    LOOP EACH_ROW

    LEA DX, M_TOTAL
    CALL PRINT_MESSAGE
    MOV AX, DI
    CALL PRINT_DECIMAL
    CALL NEWLINE

    LEA DX, M_WHY
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
; 1. Macros are not limited to instructions:
;    - ITEM emits two DW directives, which is data rather than code.
;    - The assembler does not distinguish; a macro simply produces source lines.
;    - This is how a table with a repeated shape is kept readable.
; 2. Measure, never count:
;    - ROWS is computed from the distance between two labels, divided by the row size.
;    - Adding or removing an ITEM line changes the count with no other edit.
;    - A hand written count is the single most common stale number in assembly source.
; 3. LABEL WORD marks a position:
;    - It gives a name to the current location without reserving any space.
;    - Two of them around a region measure it exactly.
;    - The same idea appears as EQU $ minus a label elsewhere in this repository.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
