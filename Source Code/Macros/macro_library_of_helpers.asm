; =============================================================================
; TITLE: A Small Macro Library
; DESCRIPTION: Macros built out of other macros, which is how an assembly project grows a vocabulary of its own.
; AUTHOR: Amey Thakur (https://github.com/Amey-Thakur)
; REPOSITORY: https://github.com/Amey-Thakur/8086-ASSEMBLY-LANGUAGE-PROGRAMS
; LICENSE: MIT License
; =============================================================================

.MODEL SMALL
.STACK 100H

; -----------------------------------------------------------------------------
; MACRO DEFINITIONS
;
; The lower macros do one thing each. The higher ones are written in terms of
; them, which is the same discipline as any other kind of programming: the top
; layer reads like a description of the task.
; -----------------------------------------------------------------------------

; ---- layer one: the primitives ----------------------------------------------
SAY MACRO WHICH
    LEA DX, WHICH
    CALL PRINT_MESSAGE
ENDM

SHOW MACRO VALUE
    MOV AX, VALUE
    CALL PRINT_DECIMAL
ENDM

BREAK_LINE MACRO
    CALL NEWLINE
ENDM

; ---- layer two: built from layer one ----------------------------------------
LABELLED MACRO WHICH, VALUE
    SAY WHICH
    SHOW VALUE
    BREAK_LINE
ENDM

; ---- layer three: built from layer two --------------------------------------
; The whole report is one line of source. Changing the layout means changing
; LABELLED, and every use follows.
REPORT_PAIR MACRO NAME_A, VAL_A, NAME_B, VAL_B
    LABELLED NAME_A, VAL_A
    LABELLED NAME_B, VAL_B
ENDM

; -----------------------------------------------------------------------------
; DATA SEGMENT
; -----------------------------------------------------------------------------
.DATA
    WIDTH_W  DW 24
    HEIGHT_W DW 8
    COUNT_W  DW 15
    PRICE_W  DW 250

    M_TITLE  DB 'Macros written in terms of other macros', 0DH, 0AH, '$'
    M_WIDTH  DB 'width:  $'
    M_HEIGHT DB 'height: $'
    M_COUNT  DB 'count:  $'
    M_PRICE  DB 'price:  $'
    M_AREA   DB 'area:   $'
    M_TOTAL  DB 'total:  $'
    M_DEPTH  DB 0DH, 0AH
             DB 'REPORT_PAIR expanded to LABELLED twice, which expanded to SAY, '
             DB 'SHOW and BREAK_LINE six times in all.', 0DH, 0AH, '$'

; -----------------------------------------------------------------------------
; CODE SEGMENT
; -----------------------------------------------------------------------------
.CODE
START:
    MOV AX, @DATA
    MOV DS, AX

    SAY M_TITLE

    ; -------------------------------------------------------------------------
    ; ONE LINE OF SOURCE, SIX MACRO EXPANSIONS DEEP.
    ; -------------------------------------------------------------------------
    REPORT_PAIR M_WIDTH, WIDTH_W, M_HEIGHT, HEIGHT_W
    REPORT_PAIR M_COUNT, COUNT_W, M_PRICE, PRICE_W

    ; -------------------------------------------------------------------------
    ; THE COMPUTED LINES USE THE SAME VOCABULARY. THE PRODUCT IS WORKED OUT
    ; FIRST BECAUSE A MACRO ARGUMENT IS TEXT AND CANNOT CARRY ARITHMETIC DONE
    ; AT RUN TIME.
    ; -------------------------------------------------------------------------
    MOV AX, WIDTH_W
    MOV BX, HEIGHT_W
    MUL BX
    SAY M_AREA
    CALL PRINT_DECIMAL
    BREAK_LINE

    MOV AX, COUNT_W
    MOV BX, PRICE_W
    MUL BX
    SAY M_TOTAL
    CALL PRINT_DECIMAL
    BREAK_LINE

    SAY M_DEPTH

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
; 1. Order of definition matters:
;    - A macro must be defined before the macro that uses it is expanded.
;    - Defining the primitives first and building upwards satisfies that naturally.
;    - The assembler expands from the outside in, one layer at a time.
; 2. Where the limit is:
;    - Expansion is bounded to stop a macro that invokes itself without end.
;    - A recursive macro therefore needs a conditional base case, not just a call.
;    - Three or four layers is usually as deep as anything readable goes.
; 3. Arguments are text, not values:
;    - SHOW WIDTH_W becomes MOV AX, WIDTH_W, which reads memory at run time.
;    - A product cannot be an argument, because the assembler has no result to substitute.
;    - That is why the two computed lines call the primitives directly.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
