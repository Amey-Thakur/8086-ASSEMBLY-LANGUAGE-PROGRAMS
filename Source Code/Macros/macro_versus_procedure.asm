; =============================================================================
; TITLE: A Macro Against A Procedure
; DESCRIPTION: The same job written both ways, with the trade being code size against the cost of a call.
; AUTHOR: Amey Thakur (https://github.com/Amey-Thakur)
; REPOSITORY: https://github.com/Amey-Thakur/8086-ASSEMBLY-LANGUAGE-PROGRAMS
; LICENSE: MIT License
; =============================================================================

.MODEL SMALL
.STACK 100H

; -----------------------------------------------------------------------------
; MACRO DEFINITIONS
;
; A macro is expanded by the assembler wherever it is used, so three uses
; produce three copies of the body. A procedure exists once and is reached by a
; call, which costs a push of the return address and a jump each way.
; -----------------------------------------------------------------------------
TRIPLE_IT MACRO VALUE
    MOV AX, VALUE
    MOV BX, AX
    SHL AX, 1                           ; times two
    ADD AX, BX                          ; plus one more makes three
ENDM

; -----------------------------------------------------------------------------
; DATA SEGMENT
; -----------------------------------------------------------------------------
.DATA
    M_TITLE DB 'The same work as a macro and as a procedure', 0DH, 0AH, '$'
    M_MACRO DB 'by macro:     $'
    M_PROC  DB 'by procedure: $'
    M_SPACE DB ' $'
    M_SIZE  DB 0DH, 0AH
            DB 'Three uses of the macro assembled three copies of the body. '
            DB 'Three calls shared one.', 0DH, 0AH, '$'
    M_PICK  DB 'A macro is faster and larger. A procedure is smaller and '
            DB 'slower. Short and hot favours the macro.', 0DH, 0AH, '$'

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
    ; THREE EXPANSIONS. THE ASSEMBLER SUBSTITUTES THE ARGUMENT TEXTUALLY, SO
    ; EACH ONE BECOMES FOUR REAL INSTRUCTIONS IN THE OUTPUT.
    ; -------------------------------------------------------------------------
    LEA DX, M_MACRO
    CALL PRINT_MESSAGE

    TRIPLE_IT 7
    CALL PRINT_DECIMAL
    LEA DX, M_SPACE
    CALL PRINT_MESSAGE

    TRIPLE_IT 25
    CALL PRINT_DECIMAL
    LEA DX, M_SPACE
    CALL PRINT_MESSAGE

    TRIPLE_IT 300
    CALL PRINT_DECIMAL
    CALL NEWLINE

    ; -------------------------------------------------------------------------
    ; THREE CALLS TO ONE COPY. THE ARGUMENT ARRIVES IN AX BECAUSE A PROCEDURE
    ; HAS NO TEXTUAL PARAMETERS TO SUBSTITUTE.
    ; -------------------------------------------------------------------------
    LEA DX, M_PROC
    CALL PRINT_MESSAGE

    MOV AX, 7
    CALL TRIPLE_PROC
    CALL PRINT_DECIMAL
    LEA DX, M_SPACE
    CALL PRINT_MESSAGE

    MOV AX, 25
    CALL TRIPLE_PROC
    CALL PRINT_DECIMAL
    LEA DX, M_SPACE
    CALL PRINT_MESSAGE

    MOV AX, 300
    CALL TRIPLE_PROC
    CALL PRINT_DECIMAL
    CALL NEWLINE

    LEA DX, M_SIZE
    CALL PRINT_MESSAGE
    LEA DX, M_PICK
    CALL PRINT_MESSAGE

    MOV AH, 4CH
    INT 21H

; -----------------------------------------------------------------------------
; TRIPLE_PROC
;
; Returns three times AX in AX. Exists once, however often it is called.
; -----------------------------------------------------------------------------
TRIPLE_PROC PROC
    PUSH BX

    MOV BX, AX
    SHL AX, 1
    ADD AX, BX

    POP BX
    RET
TRIPLE_PROC ENDP

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
; 1. When the substitution happens:
;    - A macro is expanded at assembly time, before any code exists.
;    - A procedure is entered at run time, by a call that costs a push and two jumps.
;    - Nothing about a macro survives into the object file; the name disappears.
; 2. The trade:
;    - Three macro uses cost three copies of the body and no call overhead.
;    - Three calls cost one copy and three lots of overhead.
;    - For a body of four instructions the overhead is comparable to the work itself.
; 3. Arguments differ in kind:
;    - A macro argument is text, so TRIPLE_IT 7 assembles MOV AX, 7 directly.
;    - A procedure argument is a value, and has to arrive in a register or on the stack.
;    - A macro can therefore take a register name or a label as an argument; a procedure cannot.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
