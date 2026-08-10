; =============================================================================
; TITLE: Packing A Date Into A Single Word
; DESCRIPTION: Folds a year, a month and a day into sixteen bits the way a
;              directory entry does, unpacks them again, and shows that the
;              packed words compare in date order.
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
    ; Year, month and day, three words to a date
    DATES   DW 2026, 8, 9
            DW 1980, 1, 1
            DW 2020, 2, 29
            DW 2107, 12, 31
    DATESPAN EQU 6
    HOWMANY EQU 4
    BASEYR  EQU 1980                    ; Year zero of the seven bit field
    FIRSTAT EQU 6                       ; Where 1980-01-01 sits in the list
    LASTAT  EQU 18                      ; Where 2107-12-31 sits in the list

    YEARV   DW 0
    MONTHV  DW 0
    DAYV    DW 0
    DATEAT  DW 0                        ; Byte offset of the date in hand
    FIRSTW  DW 0                        ; The word packed from 1980-01-01
    LASTW   DW 0                        ; The word packed from 2107-12-31

    M_TITLE DB 'A date folded into sixteen bits: seven for the year, four for '
            DB 'the month, five for the day', 0DH, 0AH, 0DH, 0AH, '$'
    M_TO    DB '   packs to   $'
    M_IS    DB '   which is   $'
    M_BACK  DB '   and unpacks to   $'
    M_DASH  DB '-$'
    M_ORDER DB 0DH, 0AH
            DB 'The day sits in the lowest bits and the year in the highest, '
            DB 'so the packed words rank in date order.', 0DH, 0AH, '$'
    M_PAIR  DB 'Comparing $'
    M_WITH  DB ' with $'
    M_UNS   DB 'Unsigned, the earlier date is $'
    M_SGN   DB 'Signed, JL would answer $'
    M_WRONG DB '   which is wrong, because FF9FH reads as a negative number'
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

    XOR AX, AX
    MOV DATEAT, AX
    MOV CX, HOWMANY

DATE_LOOP:
    MOV SI, DATEAT
    MOV AX, DATES[SI]
    MOV YEARV, AX
    MOV AX, DATES[SI+2]
    MOV MONTHV, AX
    MOV AX, DATES[SI+4]
    MOV DAYV, AX

    CALL PRINT_DATE
    LEA DX, M_TO
    CALL PRINT_MESSAGE

    CALL PACK_DATE                      ; AX holds the packed word from here on
    PUSH AX
    CALL PRINT_HEX
    LEA DX, M_IS
    CALL PRINT_MESSAGE
    POP AX
    PUSH AX
    CALL PRINT_DECIMAL

    LEA DX, M_BACK
    CALL PRINT_MESSAGE
    POP AX
    CALL UNPACK_DATE                    ; Writes the three fields back
    CALL PRINT_DATE
    CALL NEWLINE

    ; The two ends of the range are kept for the comparison further down
    MOV AX, DATEAT
    CMP AX, FIRSTAT
    JNE NOT_FIRST
    CALL PACK_DATE
    MOV FIRSTW, AX

NOT_FIRST:
    MOV AX, DATEAT
    CMP AX, LASTAT
    JNE NOT_LAST
    CALL PACK_DATE
    MOV LASTW, AX

NOT_LAST:
    MOV AX, DATEAT
    ADD AX, DATESPAN
    MOV DATEAT, AX
    LOOP DATE_LOOP

    ; -------------------------------------------------------------------------
    ; THE ORDER TEST. 0021H AND FF9FH ARE THE FIRST AND LAST DATES THE FORMAT
    ; CAN HOLD. JB IS THE UNSIGNED COMPARISON AND ANSWERS CORRECTLY; JL WOULD
    ; READ FF9FH AS A NEGATIVE NUMBER AND CALL THE LAST DATE THE EARLIER ONE.
    ; -------------------------------------------------------------------------
    LEA DX, M_ORDER
    CALL PRINT_MESSAGE

    LEA DX, M_PAIR
    CALL PRINT_MESSAGE
    MOV AX, FIRSTW
    CALL PRINT_HEX
    LEA DX, M_WITH
    CALL PRINT_MESSAGE
    MOV AX, LASTW
    CALL PRINT_HEX
    CALL NEWLINE

    LEA DX, M_UNS
    CALL PRINT_MESSAGE
    MOV AX, FIRSTW
    CMP AX, LASTW
    JB  UNSIGNED_FIRST
    MOV AX, LASTW

UNSIGNED_FIRST:
    CALL UNPACK_DATE
    CALL PRINT_DATE
    CALL NEWLINE

    LEA DX, M_SGN
    CALL PRINT_MESSAGE
    MOV AX, FIRSTW
    CMP AX, LASTW
    JL  SIGNED_FIRST
    MOV AX, LASTW

SIGNED_FIRST:
    CALL UNPACK_DATE
    CALL PRINT_DATE
    LEA DX, M_WRONG
    CALL PRINT_MESSAGE

    MOV AH, 4CH
    INT 21H

; -----------------------------------------------------------------------------
; PACK_DATE
;
; Builds the packed word from YEARV, MONTHV and DAYV and returns it in AX.
;
; The shift counts are loaded into CL. The 8086 allows only one or CL as the
; count on a shift, so anything wider than a single place has to go that way.
; -----------------------------------------------------------------------------
PACK_DATE PROC
    PUSH BX
    PUSH CX

    MOV AX, YEARV
    SUB AX, BASEYR                      ; The field counts years from 1980
    MOV CL, 9
    SHL AX, CL                          ; Bits 15 to 9

    MOV BX, MONTHV
    MOV CL, 5
    SHL BX, CL                          ; Bits 8 to 5
    OR  AX, BX

    OR  AX, DAYV                        ; Bits 4 to 0

    POP CX
    POP BX
    RET
PACK_DATE ENDP

; -----------------------------------------------------------------------------
; UNPACK_DATE
;
; Splits the packed word in AX back into YEARV, MONTHV and DAYV.
;
; Each field is taken from a fresh copy of the word. Shifting the working copy
; step by step would destroy the bits the next field still needs.
; -----------------------------------------------------------------------------
UNPACK_DATE PROC
    PUSH AX
    PUSH BX
    PUSH CX

    MOV BX, AX

    AND AX, 1FH                         ; Five bits hold the day
    MOV DAYV, AX

    MOV AX, BX
    MOV CL, 5
    SHR AX, CL
    AND AX, 0FH                         ; Four bits hold the month
    MOV MONTHV, AX

    MOV AX, BX
    MOV CL, 9
    SHR AX, CL                          ; Seven bits hold the year
    ADD AX, BASEYR
    MOV YEARV, AX

    POP CX
    POP BX
    POP AX
    RET
UNPACK_DATE ENDP

; -----------------------------------------------------------------------------
; PRINT_DATE
;
; Prints YEARV, MONTHV and DAYV as a dated line, the month and the day padded
; to two figures so that written dates sort the same way the packed words do.
; -----------------------------------------------------------------------------
PRINT_DATE PROC
    PUSH AX
    PUSH DX

    MOV AX, YEARV
    CALL PRINT_DECIMAL
    LEA DX, M_DASH
    CALL PRINT_MESSAGE

    MOV AX, MONTHV
    CALL PRINT_PADDED
    LEA DX, M_DASH
    CALL PRINT_MESSAGE

    MOV AX, DAYV
    CALL PRINT_PADDED

    POP DX
    POP AX
    RET
PRINT_DATE ENDP

; -----------------------------------------------------------------------------
; PRINT_PADDED
;
; Prints AX as two figures, writing a leading zero for anything below ten.
; -----------------------------------------------------------------------------
PRINT_PADDED PROC
    PUSH AX
    PUSH DX

    CMP AX, 10
    JAE PP_PLAIN                        ; A count is unsigned, so JAE not JGE

    PUSH AX
    MOV DL, '0'
    MOV AH, 02H
    INT 21H
    POP AX

PP_PLAIN:
    CALL PRINT_DECIMAL

    POP DX
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
; 1. WHY THE YEAR IS COUNTED FROM 1980:
;    - A full year needs eleven bits and there are only seven to spare.
;    - Storing the difference from a fixed year fits, at the price of a
;    - range that ends in 2107 and cannot reach back before 1980.
; 2. WHY THE FIELD ORDER MATTERS:
;    - With the year uppermost and the day lowest, an ordinary unsigned
;    - comparison of two packed words gives the chronological order, so a
;    - list of dates can be sorted without unpacking any of them.
; 3. WHY THE COMPARISON MUST BE UNSIGNED:
;    - Any date from October 2043 onwards sets bit fifteen. JL would read
;    - that as negative and place the latest dates first, which is the
;    - commonest way this format is misused.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
