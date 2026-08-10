; =============================================================================
; TITLE: Echoing Characters Until Enter
; DESCRIPTION: Reads and echoes one character at a time, counting what arrives, and stops on a carriage return.
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
    LIMIT   EQU 40                      ; A hard stop, in case Enter never comes

    LETTERS DW 0
    DIGITS  DW 0
    OTHERS  DW 0
    TOTAL   DW 0

    M_TITLE DB 'Echoing characters and counting them as they arrive', 0DH, 0AH, '$'
    M_ASK   DB 'Type something and press Enter: $'
    M_TOTAL DB 0DH, 0AH, 'Characters read: $'
    M_LET   DB 0DH, 0AH, 'letters: $'
    M_DIG   DB 0DH, 0AH, 'digits:  $'
    M_OTH   DB 0DH, 0AH, 'others:  $'
    M_STOP  DB 0DH, 0AH, 'Stopped at the limit of forty without seeing Enter.'
            DB 0DH, 0AH, '$'
    M_ENTER DB 0DH, 0AH, 'Stopped on Enter.', 0DH, 0AH, '$'
    M_WHY   DB 0DH, 0AH
            DB 'The limit matters: a loop waiting only for Enter never ends if '
            DB 'the input runs out first.', 0DH, 0AH, '$'

; -----------------------------------------------------------------------------
; CODE SEGMENT
; -----------------------------------------------------------------------------
.CODE
START:
    MOV AX, @DATA
    MOV DS, AX

    LEA DX, M_TITLE
    CALL PRINT_MESSAGE
    LEA DX, M_ASK
    CALL PRINT_MESSAGE

    ; -------------------------------------------------------------------------
    ; TWO WAYS OUT: A CARRIAGE RETURN, OR THE LIMIT. THE LIMIT IS NOT A
    ; DECORATION. A LOOP THAT ONLY WATCHES FOR ENTER RUNS FOR EVER ONCE THE
    ; INPUT IS EXHAUSTED, WHICH IS EXACTLY WHAT HAPPENS UNDER A TEST HARNESS.
    ; -------------------------------------------------------------------------
    MOV CX, LIMIT

EACH_CHARACTER:
    MOV AH, 01H                         ; Read and echo
    INT 21H

    CMP AL, 0DH
    JE SAW_ENTER

    INC TOTAL

    ; ---- classify it --------------------------------------------------------
    CMP AL, '0'
    JB IS_OTHER
    CMP AL, '9'
    JBE IS_DIGIT

    ; Fold the case so one pair of comparisons covers both.
    OR AL, 20H
    CMP AL, 'a'
    JB IS_OTHER
    CMP AL, 'z'
    JA IS_OTHER

    INC LETTERS
    JMP NEXT_CHARACTER

IS_DIGIT:
    INC DIGITS
    JMP NEXT_CHARACTER

IS_OTHER:
    INC OTHERS

NEXT_CHARACTER:
    LOOP EACH_CHARACTER

    LEA DX, M_STOP
    CALL PRINT_MESSAGE
    JMP REPORT

SAW_ENTER:
    LEA DX, M_ENTER
    CALL PRINT_MESSAGE

REPORT:
    LEA DX, M_TOTAL
    CALL PRINT_MESSAGE
    MOV AX, TOTAL
    CALL PRINT_DECIMAL

    LEA DX, M_LET
    CALL PRINT_MESSAGE
    MOV AX, LETTERS
    CALL PRINT_DECIMAL

    LEA DX, M_DIG
    CALL PRINT_MESSAGE
    MOV AX, DIGITS
    CALL PRINT_DECIMAL

    LEA DX, M_OTH
    CALL PRINT_MESSAGE
    MOV AX, OTHERS
    CALL PRINT_DECIMAL

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
; 1. Always have a second way out:
;    - A loop waiting only for Enter cannot end if the input runs dry.
;    - Under a test harness that is not hypothetical: the queue empties.
;    - A counted limit costs one register and removes the whole failure mode.
; 2. Folding the case:
;    - ORing with 20h turns an upper case letter into its lower case form.
;    - That halves the comparisons needed to recognise a letter.
;    - It is safe here because the digits were already dealt with above.
; 3. The counters live in memory:
;    - Four totals plus a loop counter would use most of the register file.
;    - Memory is the right place for anything the loop only increments.
;    - Registers are better spent on the pointer and the count.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
