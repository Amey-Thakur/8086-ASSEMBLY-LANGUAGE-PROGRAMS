; =============================================================================
; TITLE: Printing A Table In Aligned Columns
; DESCRIPTION: Right aligns numbers and pads names, so a table reads as a table rather than as a ragged list.
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
    ; Five rows: a name of eight bytes, a quantity and a price.
    NAMES   DB 'BOLT    ', 'WASHER  ', 'NUT     ', 'SCREW   ', 'RIVET   '
    NAME_W  EQU 8
    QTY_W   DW 7, 250, 42, 150, 96
    PRICE_W DW 125, 3, 8, 45, 120
    ROWS    EQU 5

    NUMBER_W EQU 6                      ; Columns each number is padded to

    M_TITLE DB 'A table with the numbers right aligned', 0DH, 0AH, 0DH, 0AH, '$'
    M_HEAD  DB 'item        qty   price   total', 0DH, 0AH
            DB '--------  ------  ------  ------', 0DH, 0AH, '$'
    M_GAP   DB '  $'
    M_SPACE DB ' $'
    M_RULE2 DB '--------  ------  ------  ------', 0DH, 0AH, '$'
    M_SUM   DB 'TOTAL                     $'
    M_WHY   DB 0DH, 0AH
            DB 'A number is measured before it is printed, and the difference '
            DB 'is filled with spaces. That is all alignment is.', 0DH, 0AH, '$'

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

    XOR SI, SI                          ; Row number
    XOR BP, BP                          ; Grand total
    MOV CX, ROWS

EACH_ROW:
    ; ---- the name, already padded in the data -------------------------------
    PUSH CX
    MOV AX, SI
    MOV DX, NAME_W
    MUL DX
    MOV DI, AX

    PUSH SI
    LEA SI, NAMES
    ADD SI, DI
    MOV CX, NAME_W
    CALL PRINT_TEXT
    POP SI

    LEA DX, M_GAP
    CALL PRINT_MESSAGE

    ; ---- the quantity, right aligned ----------------------------------------
    MOV DI, SI
    SHL DI, 1                           ; Words, so twice the row number
    MOV AX, QTY_W[DI]
    CALL PRINT_PADDED

    LEA DX, M_GAP
    CALL PRINT_MESSAGE

    ; ---- the price ----------------------------------------------------------
    MOV AX, PRICE_W[DI]
    CALL PRINT_PADDED

    LEA DX, M_GAP
    CALL PRINT_MESSAGE

    ; ---- and the product, which is what the table is for --------------------
    MOV AX, QTY_W[DI]
    MOV DX, PRICE_W[DI]
    MUL DX
    ADD BP, AX
    CALL PRINT_PADDED
    CALL NEWLINE

    INC SI
    POP CX
    LOOP EACH_ROW

    LEA DX, M_RULE2
    CALL PRINT_MESSAGE
    LEA DX, M_SUM
    CALL PRINT_MESSAGE
    MOV AX, BP
    CALL PRINT_PADDED
    CALL NEWLINE

    LEA DX, M_WHY
    CALL PRINT_MESSAGE

    MOV AH, 4CH
    INT 21H

; -----------------------------------------------------------------------------
; PRINT_PADDED
;
; Prints AX right aligned in NUMBER_W columns.
;
; The width is counted first by dividing the value down, then that many spaces
; short of the field are printed before the number itself. Printing and then
; padding would left align it instead.
; -----------------------------------------------------------------------------
PRINT_PADDED PROC
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX
    PUSH DI                             ; The caller keeps its row offset here

    ; ---- how many digits? ---------------------------------------------------
    MOV BX, AX                          ; Keep the value
    MOV CX, 1                           ; Every number has at least one digit
    MOV DX, 10

COUNT_DIGITS:
    CMP AX, 10
    JB DIGITS_COUNTED

    XOR DX, DX
    MOV DI, 10
    DIV DI
    INC CX
    JMP COUNT_DIGITS

DIGITS_COUNTED:
    ; ---- the padding --------------------------------------------------------
    MOV AX, NUMBER_W
    SUB AX, CX
    MOV CX, AX
    JCXZ NO_PADDING

PAD_ONE:
    LEA DX, M_SPACE
    CALL PRINT_MESSAGE
    LOOP PAD_ONE

NO_PADDING:
    MOV AX, BX
    CALL PRINT_DECIMAL

    POP DI
    POP DX
    POP CX
    POP BX
    POP AX
    RET
PRINT_PADDED ENDP

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
; PRINT_TEXT
;
; Prints CX characters starting at DS:SI. Both are left as they were found.
; -----------------------------------------------------------------------------
PRINT_TEXT PROC
    PUSH AX
    PUSH CX
    PUSH DX
    PUSH SI

    JCXZ PT_DONE                        ; Nothing to print

PT_LOOP:
    MOV DL, [SI]
    MOV AH, 02H
    INT 21H
    INC SI
    LOOP PT_LOOP

PT_DONE:
    POP SI
    POP DX
    POP CX
    POP AX
    RET
PRINT_TEXT ENDP

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
; 1. Count first, then pad:
;    - The width of a number is not known until it has been divided down.
;    - So the digits are counted, the padding printed, and the number printed last.
;    - Printing first and padding afterwards would left align it.
; 2. Names padded in the data:
;    - Every name occupies eight bytes whether it needs them or not.
;    - That makes the row a fixed size and the column arithmetic a multiply.
;    - Variable length names would need a length byte and a padding loop each.
; 3. Two strides in one loop:
;    - The name table is indexed by row times eight, the number tables by row times two.
;    - Keeping the row number in SI and deriving both is clearer than two pointers.
;    - Mixing the strides up is the classic table driven bug.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
