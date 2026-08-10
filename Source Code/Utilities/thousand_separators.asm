; =============================================================================
; TITLE: Printing A Number With Thousand Separators
; DESCRIPTION: Prints an unsigned word with a comma between each group of three
;              digits, by counting the digits first and placing the separator
;              from the count rather than from the value.
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
    AMOUNTS DW 7, 250, 1000, 12345, 20000
    HOWMANY EQU 5
    EDGES   DW 0, 9, 99, 999, 1000, 65535
    EDGENO  EQU 6
    RUNNING DW 0                        ; The total so far

    M_TITLE DB 'An unsigned word printed in groups of three digits'
            DB 0DH, 0AH, 0DH, 0AH, '$'
    M_LIST  DB 'Amounts:', 0DH, 0AH, '$'
    M_ITEM  DB '   $'
    M_TOTAL DB 'Total:  $'
    M_EDGE  DB 0DH, 0AH, 'Plain, then grouped:', 0DH, 0AH, '$'
    M_ARROW DB '   becomes   $'
    M_OVER  DB 'The running total has passed 65535 and is abandoned'
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
    LEA DX, M_LIST
    CALL PRINT_MESSAGE

    XOR AX, AX
    MOV RUNNING, AX

    XOR SI, SI
    MOV CX, HOWMANY

AMOUNT_LOOP:
    LEA DX, M_ITEM
    CALL PRINT_MESSAGE
    MOV AX, AMOUNTS[SI]
    CALL PRINT_GROUPED
    CALL NEWLINE

    ; -------------------------------------------------------------------------
    ; THE TOTAL IS ONLY A WORD WIDE, SO THE CARRY IS TESTED AFTER EVERY ADD.
    ; THESE FIVE AMOUNTS COME TO 33602 AND NEVER TRIP IT, BUT A RUNNING TOTAL
    ; THAT IS NOT CHECKED WILL WRAP IN SILENCE THE MOMENT ONE DOES.
    ; -------------------------------------------------------------------------
    MOV AX, AMOUNTS[SI]
    ADD AX, RUNNING
    JC  TOTAL_LOST
    MOV RUNNING, AX

    ADD SI, 2
    LOOP AMOUNT_LOOP

    LEA DX, M_TOTAL
    CALL PRINT_MESSAGE
    MOV AX, RUNNING
    CALL PRINT_GROUPED
    CALL NEWLINE
    JMP EDGE_SECTION

TOTAL_LOST:
    LEA DX, M_OVER
    CALL PRINT_MESSAGE

EDGE_SECTION:
    LEA DX, M_EDGE
    CALL PRINT_MESSAGE

    XOR SI, SI
    MOV CX, EDGENO

EDGE_LOOP:
    LEA DX, M_ITEM
    CALL PRINT_MESSAGE
    MOV AX, EDGES[SI]
    CALL PRINT_DECIMAL
    LEA DX, M_ARROW
    CALL PRINT_MESSAGE
    MOV AX, EDGES[SI]
    CALL PRINT_GROUPED
    CALL NEWLINE

    ADD SI, 2
    LOOP EDGE_LOOP

    MOV AH, 4CH
    INT 21H

; -----------------------------------------------------------------------------
; PRINT_GROUPED
;
; Prints the unsigned value in AX with a comma before every third digit from
; the right.
;
; The separator cannot be decided while the digits are being extracted, because
; they come out backwards. Stacking them first gives the digit count, and once
; the count is known a comma belongs after any digit that leaves a multiple of
; three still to come.
; -----------------------------------------------------------------------------
PRINT_GROUPED PROC
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX

    XOR CX, CX                          ; How many digits have been stacked
    MOV BX, 10

PG_DIVIDE:
    XOR DX, DX                          ; DX:AX is the dividend, so clear DX
    DIV BX
    PUSH DX
    INC CX
    OR  AX, AX
    JNZ PG_DIVIDE                       ; Zero still stacks one digit

PG_EMIT:
    POP DX
    ADD DL, '0'
    MOV AH, 02H
    INT 21H

    MOV AX, CX
    DEC AX                              ; Digits still to come after this one
    JZ  PG_NEXT                         ; The last digit never takes a comma

    XOR DX, DX
    MOV BX, 3
    DIV BX
    OR  DX, DX
    JNZ PG_NEXT                         ; Not on a group boundary

    MOV DL, ','
    MOV AH, 02H
    INT 21H

PG_NEXT:
    LOOP PG_EMIT

    POP DX
    POP CX
    POP BX
    POP AX
    RET
PRINT_GROUPED ENDP

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
; 1. WHY THE DIGITS ARE COUNTED FIRST:
;    - Division produces the units digit first and the leading digit last.
;    - Nothing can be said about grouping until the total number of digits
;    - is known, which is why the digits are stacked before any is printed.
; 2. WHY THE COUNT IN CX IS SAFE:
;    - The comma test needs a division, and division works on DX:AX. CX is
;    - untouched by DIV, so the same register can serve as the loop counter
;    - and as the number of digits still to come.
; 3. HOW FAR A WORD GOES:
;    - The largest word is 65535, so at most two separators are ever
;    - needed. A wider figure would have to be held across two words and
;    - divided in two stages, which is a different problem entirely.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
