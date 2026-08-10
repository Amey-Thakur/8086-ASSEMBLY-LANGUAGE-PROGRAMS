; =============================================================================
; TITLE: A Macro Taking A Register Name
; DESCRIPTION: Because a macro argument is text, a register name can be passed as an argument, which no procedure can do.
; AUTHOR: Amey Thakur (https://github.com/Amey-Thakur)
; REPOSITORY: https://github.com/Amey-Thakur/8086-ASSEMBLY-LANGUAGE-PROGRAMS
; LICENSE: MIT License
; =============================================================================

.MODEL SMALL
.STACK 100H

; -----------------------------------------------------------------------------
; MACRO DEFINITIONS
; -----------------------------------------------------------------------------

; ---- clear whichever register is named --------------------------------------
; The argument is substituted as text, so CLEAR BX assembles XOR BX, BX. A
; procedure could never do this: it would have to be told which register at run
; time and then branch on the answer.
CLEAR MACRO WHICH
    XOR WHICH, WHICH
ENDM

; ---- add up three registers into a fourth -----------------------------------
TOTAL_OF MACRO INTO, ONE, TWO, THREE
    MOV INTO, ONE
    ADD INTO, TWO
    ADD INTO, THREE
ENDM

; ---- print any register without disturbing it -------------------------------
; PRINT_DECIMAL works on AX only, so the named register is moved into AX and AX
; is protected around it.
SHOW_REG MACRO WHICH, LABEL_NAME
    PUSH AX
    LEA DX, LABEL_NAME
    CALL PRINT_MESSAGE
    MOV AX, WHICH
    CALL PRINT_DECIMAL
    CALL NEWLINE
    POP AX
ENDM

; -----------------------------------------------------------------------------
; DATA SEGMENT
; -----------------------------------------------------------------------------
.DATA
    M_TITLE DB 'A macro argument is text, so it can name a register', 0DH, 0AH, '$'
    M_CLEAR DB 'After CLEAR on each of them:', 0DH, 0AH, '$'
    M_SET   DB 0DH, 0AH, 'Then loaded with 100, 200 and 300:', 0DH, 0AH, '$'
    M_SUM   DB 0DH, 0AH, 'TOTAL_OF DI, BX, CX, SI gave:', 0DH, 0AH, '$'
    M_BX    DB 'BX = $'
    M_CX    DB 'CX = $'
    M_SI    DB 'SI = $'
    M_DI    DB 'DI = $'
    M_NOTE  DB 0DH, 0AH
            DB 'One macro cleared four different registers. A procedure would '
            DB 'have needed four copies or a run time decision.', 0DH, 0AH, '$'

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
    ; FOUR EXPANSIONS OF ONE MACRO, EACH NAMING A DIFFERENT REGISTER.
    ; -------------------------------------------------------------------------
    MOV BX, 1111
    MOV CX, 2222
    MOV SI, 3333
    MOV DI, 4444

    CLEAR BX
    CLEAR CX
    CLEAR SI
    CLEAR DI

    LEA DX, M_CLEAR
    CALL PRINT_MESSAGE
    SHOW_REG BX, M_BX
    SHOW_REG CX, M_CX
    SHOW_REG SI, M_SI
    SHOW_REG DI, M_DI

    LEA DX, M_SET
    CALL PRINT_MESSAGE
    MOV BX, 100
    MOV CX, 200
    MOV SI, 300
    SHOW_REG BX, M_BX
    SHOW_REG CX, M_CX
    SHOW_REG SI, M_SI

    ; -------------------------------------------------------------------------
    ; THE DESTINATION IS AN ARGUMENT TOO, WHICH IS WHY THE MACRO CAN TOTAL INTO
    ; WHICHEVER REGISTER THE CALLER HAPPENS TO HAVE FREE.
    ; -------------------------------------------------------------------------
    TOTAL_OF DI, BX, CX, SI

    LEA DX, M_SUM
    CALL PRINT_MESSAGE
    SHOW_REG DI, M_DI

    LEA DX, M_NOTE
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
; 1. Text substitution is the whole trick:
;    - CLEAR BX becomes XOR BX, BX before the assembler looks at the instruction.
;    - The macro never knows it was given a register rather than a name.
;    - A label, a memory reference or a constant would be substituted just as happily.
; 2. Which is why it can be misused:
;    - CLEAR of something that cannot be exclusive ored gives an error inside the macro.
;    - The message points at the expansion, which can be confusing to read.
;    - A macro that documents what its arguments must be avoids most of that.
; 3. The destination as an argument:
;    - TOTAL_OF names its own output, so no register is hard coded.
;    - The caller keeps control of which registers are in play.
;    - This is the closest assembly gets to a function that returns into a chosen place.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
