; =============================================================================
; TITLE: Fixed Point Arithmetic in Q8.8
; DESCRIPTION: Holds a fractional value as a whole number of two hundred and
;              fifty sixths, so that addition needs nothing new and only the
;              multiply and the divide have to correct the scale.
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
    ; A Q8.8 value is the real value multiplied by 256, so the top byte is the
    ; whole part and the bottom byte counts two hundred and fifty sixths.
    X_FIX   DW 896                      ; 3.5
    Y_FIX   DW 576                      ; 2.25
    PI_FIX  DW 804                      ; The closest Q8.8 has to pi
    TENTH   DW 26                       ; The closest it has to a tenth
    RADIUS  DW 5                        ; A plain whole number, not scaled
    ROUNDS  EQU 10

    SCALE   DW 256                      ; One whole, expressed in the format

    M_TITLE DB 'Q8.8 keeps a value as itself multiplied by 256', 0DH, 0AH, '$'
    M_PLUS  DB ' + $'
    M_MINUS DB ' - $'
    M_TIMES DB ' x $'
    M_OVER  DB ' / $'
    M_EQ    DB ' = $'
    M_AREA  DB 0DH, 0AH, 'A circle of radius $'
    M_HASA  DB ' has an area of $'
    M_DRIFT DB 0DH, 0AH, 'A tenth added ten times gives $'
    M_NOT   DB ', and not 1.000', 0DH, 0AH, '$'
    M_BIG   DB 'more than the format will hold$'

; -----------------------------------------------------------------------------
; CODE SEGMENT
; -----------------------------------------------------------------------------
.CODE
START:
    MOV AX, @DATA
    MOV DS, AX

    LEA DX, M_TITLE
    CALL PRINT_MESSAGE

    ; -------------------------------------------------------------------------
    ; STEP 1: ADDITION AND SUBTRACTION NEED NO CORRECTION AT ALL, BECAUSE BOTH
    ; OPERANDS CARRY THE SAME SCALE AND THE ANSWER INHERITS IT UNCHANGED.
    ; -------------------------------------------------------------------------
    MOV AX, X_FIX
    CALL PRINT_FIXED
    LEA DX, M_PLUS
    CALL PRINT_MESSAGE
    MOV AX, Y_FIX
    CALL PRINT_FIXED
    LEA DX, M_EQ
    CALL PRINT_MESSAGE
    MOV AX, X_FIX
    ADD AX, Y_FIX
    CALL PRINT_FIXED
    CALL NEWLINE

    MOV AX, X_FIX
    CALL PRINT_FIXED
    LEA DX, M_MINUS
    CALL PRINT_MESSAGE
    MOV AX, Y_FIX
    CALL PRINT_FIXED
    LEA DX, M_EQ
    CALL PRINT_MESSAGE
    MOV AX, X_FIX
    SUB AX, Y_FIX
    CALL PRINT_FIXED
    CALL NEWLINE

    ; -------------------------------------------------------------------------
    ; STEP 2: A PRODUCT CARRIES THE SCALE TWICE OVER AND MUST SHED ONE OF THEM
    ; -------------------------------------------------------------------------
    MOV AX, X_FIX
    CALL PRINT_FIXED
    LEA DX, M_TIMES
    CALL PRINT_MESSAGE
    MOV AX, Y_FIX
    CALL PRINT_FIXED
    LEA DX, M_EQ
    CALL PRINT_MESSAGE

    MOV AX, X_FIX
    MUL Y_FIX                           ; DX:AX carries the scale twice
    CMP DH, 0
    JNE MUL_TOO_BIG                     ; Shedding one scale still leaves too much

    ; Dividing the pair by 256 is a shift of eight places, and a shift of eight
    ; places across a byte boundary is only a rearrangement of the bytes.
    MOV AL, AH
    MOV AH, DL
    CALL PRINT_FIXED
    JMP AFTER_MUL

MUL_TOO_BIG:
    LEA DX, M_BIG
    CALL PRINT_MESSAGE

AFTER_MUL:
    CALL NEWLINE

    ; -------------------------------------------------------------------------
    ; STEP 3: A QUOTIENT LOSES THE SCALE ALTOGETHER, SO ONE IS PUT BACK FIRST
    ; -------------------------------------------------------------------------
    MOV AX, X_FIX
    CALL PRINT_FIXED
    LEA DX, M_OVER
    CALL PRINT_MESSAGE
    MOV AX, Y_FIX
    CALL PRINT_FIXED
    LEA DX, M_EQ
    CALL PRINT_MESSAGE

    MOV AX, X_FIX
    MUL SCALE                           ; The dividend is widened, not shifted
    MOV BX, Y_FIX
    CMP DX, BX
    JAE DIV_TOO_BIG                     ; The quotient would not fit in AX
    DIV BX
    CALL PRINT_FIXED
    JMP AFTER_DIV

DIV_TOO_BIG:
    LEA DX, M_BIG
    CALL PRINT_MESSAGE

AFTER_DIV:
    CALL NEWLINE

    ; -------------------------------------------------------------------------
    ; STEP 4: MULTIPLYING BY A PLAIN WHOLE NUMBER NEEDS NO CORRECTION, SINCE
    ; THE WHOLE NUMBER CARRIES NO SCALE OF ITS OWN TO SHED.
    ; -------------------------------------------------------------------------
    LEA DX, M_AREA
    CALL PRINT_MESSAGE
    MOV AX, RADIUS
    CALL PRINT_DECIMAL
    LEA DX, M_HASA
    CALL PRINT_MESSAGE

    MOV AX, RADIUS
    MUL RADIUS                          ; The radius squared, still a whole number
    MUL PI_FIX
    CMP DX, 0
    JNE AREA_TOO_BIG
    CALL PRINT_FIXED
    JMP AFTER_AREA

AREA_TOO_BIG:
    LEA DX, M_BIG
    CALL PRINT_MESSAGE

AFTER_AREA:
    CALL NEWLINE

    ; -------------------------------------------------------------------------
    ; STEP 5: A TENTH IS NOT A WHOLE NUMBER OF TWO HUNDRED AND FIFTY SIXTHS, SO
    ; THE STORED VALUE IS ALREADY WRONG AND EVERY ADDITION REPEATS THE ERROR.
    ; -------------------------------------------------------------------------
    LEA DX, M_DRIFT
    CALL PRINT_MESSAGE

    XOR AX, AX
    MOV CX, ROUNDS

ADD_TENTH:
    ADD AX, TENTH
    LOOP ADD_TENTH

    CALL PRINT_FIXED
    LEA DX, M_NOT
    CALL PRINT_MESSAGE

    MOV AH, 4CH
    INT 21H

; -----------------------------------------------------------------------------
; PRINT_FIXED
;
; Prints the Q8.8 value in AX as a whole part, a point and three decimals.
;
; The decimals come from multiplying the fraction byte by ten and taking the
; carry into the top byte as the next digit. That is long multiplication done
; one digit at a time, and it produces leading zeros without any special case.
; -----------------------------------------------------------------------------
PRINT_FIXED PROC
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX

    MOV BX, AX                          ; The raw value, kept while AX is in use

    MOV CL, 8
    SHR AX, CL                          ; The whole part is the top byte
    CALL PRINT_DECIMAL

    MOV DL, '.'
    MOV AH, 02H
    INT 21H

    MOV AL, BL                          ; The fraction is the bottom byte
    MOV CX, 3                           ; Three places is enough to show the error

PF_DIGIT:
    MOV BL, 10
    MUL BL                              ; AX = AL times ten, so AH is the digit
    PUSH AX
    MOV DL, AH
    ADD DL, '0'
    MOV AH, 02H
    INT 21H
    POP AX
    MOV AH, 0                           ; Keep only the fraction still unspent
    LOOP PF_DIGIT

    POP DX
    POP CX
    POP BX
    POP AX
    RET
PRINT_FIXED ENDP

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
; 1. Why the scale has to be corrected:
;    - Every stored value already carries a factor of 256.
;    - A product therefore carries it twice and must be divided by 256 once.
;    - A quotient carries it not at all, so the dividend is multiplied first.
; 2. Shifting by whole bytes is free:
;    - Dividing a thirty two bit product by 256 shifts it eight places.
;    - Eight places is exactly one byte, so the bytes need only be rearranged.
;    - Two register moves do the work of a shift instruction repeated eight times.
; 3. What the format cannot represent:
;    - Only values that are whole numbers of two hundred and fifty sixths fit.
;    - A tenth is not one of them, so it is stored slightly large.
;    - Repeated addition then repeats that error, which binary floating point does too.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
