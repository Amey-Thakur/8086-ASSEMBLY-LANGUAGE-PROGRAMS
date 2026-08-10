; =============================================================================
; TITLE: Last In First Out Order
; DESCRIPTION: Pushes a list and pops it back to show that a stack reverses whatever passes through it.
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
    DATA_W  DW 10, 20, 30, 40, 50, 60
    HOWMANY EQU 6
    OUT_W   DW HOWMANY DUP (0)

    M_TITLE DB 'A stack hands things back in the opposite order', 0DH, 0AH, '$'
    M_IN    DB 'Pushed in this order:  $'
    M_OUT   DB 'Popped in this order:  $'
    M_STORE DB 'The popped list, kept in memory: $'
    M_USE   DB 'This is the shortest way to reverse anything on this processor.', 0DH, 0AH, '$'
    M_SPACE DB ' $'

; -----------------------------------------------------------------------------
; CODE SEGMENT
; -----------------------------------------------------------------------------
.CODE
START:
    MOV AX, @DATA
    MOV DS, AX

    LEA DX, M_TITLE
    CALL PRINT_MESSAGE

    LEA DX, M_IN
    CALL PRINT_MESSAGE
    LEA SI, DATA_W
    MOV CX, HOWMANY
    CALL SHOW_WORDS
    CALL NEWLINE

    ; -------------------------------------------------------------------------
    ; EVERYTHING GOES ON THE STACK FIRST. CX MUST BE PRESERVED ACROSS THE TWO
    ; LOOPS, SO THE SECOND LOOP RELOADS IT RATHER THAN RELYING ON THE FIRST.
    ; -------------------------------------------------------------------------
    LEA SI, DATA_W
    MOV CX, HOWMANY
PUSH_EACH:
    MOV AX, [SI]
    PUSH AX
    ADD SI, 2
    LOOP PUSH_EACH

    ; -------------------------------------------------------------------------
    ; AND COMES BACK OFF IN REVERSE. THE POPS ARE WRITTEN STRAIGHT INTO OUT_W
    ; IN ASCENDING ORDER, WHICH LEAVES THE REVERSED LIST IN MEMORY.
    ; -------------------------------------------------------------------------
    LEA DX, M_OUT
    CALL PRINT_MESSAGE

    LEA DI, OUT_W
    MOV CX, HOWMANY
POP_EACH:
    POP AX
    MOV [DI], AX
    CALL PRINT_DECIMAL
    LEA DX, M_SPACE
    CALL PRINT_MESSAGE
    ADD DI, 2
    LOOP POP_EACH
    CALL NEWLINE

    LEA DX, M_STORE
    CALL PRINT_MESSAGE
    LEA SI, OUT_W
    MOV CX, HOWMANY
    CALL SHOW_WORDS
    CALL NEWLINE
    CALL NEWLINE

    LEA DX, M_USE
    CALL PRINT_MESSAGE

    MOV AH, 4CH
    INT 21H

; -----------------------------------------------------------------------------
; SHOW_WORDS
;
; Prints CX words starting at DS:SI, separated by spaces.
; -----------------------------------------------------------------------------
SHOW_WORDS PROC
    PUSH AX
    PUSH CX
    PUSH DX
    PUSH SI

EACH_WORD:
    MOV AX, [SI]
    CALL PRINT_DECIMAL
    LEA DX, M_SPACE
    CALL PRINT_MESSAGE
    ADD SI, 2
    LOOP EACH_WORD

    POP SI
    POP DX
    POP CX
    POP AX
    RET
SHOW_WORDS ENDP

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
; 1. Reversal for free:
;    - Pushing a sequence and popping it yields the sequence backwards.
;    - No index arithmetic and no second buffer are needed for the reversal itself.
;    - The cost is stack space proportional to the length of the list.
; 2. The counter has to be reloaded:
;    - LOOP leaves CX at zero, so the second loop cannot inherit it.
;    - Reloading from HOWMANY is clearer than pushing CX around the first loop.
;    - A mismatched count would pop items the program never pushed.
; 3. Depth is finite:
;    - The .STACK 100H directive reserves 256 bytes, which is 128 words.
;    - Pushing more than that runs into whatever lies below the stack.
;    - A list longer than the stack has to be reversed in place instead.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
