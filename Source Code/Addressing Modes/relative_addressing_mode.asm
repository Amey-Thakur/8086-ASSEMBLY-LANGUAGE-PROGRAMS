; =============================================================================
; TITLE: Relative Addressing For Jumps
; DESCRIPTION: A jump stores the distance to its target rather than the address, which is what makes code work wherever it is loaded.
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
    M_TITLE DB 'Relative addressing: jumps carry a distance, not an address', 0DH, 0AH, '$'
    M_FWD   DB 'A forward jump skipped the next line.', 0DH, 0AH, '$'
    M_SKIP  DB 'THIS LINE SHOULD NEVER APPEAR.', 0DH, 0AH, '$'
    M_DOWN  DB 'A backward jump counting down: $'
    M_SPACE DB ' $'
    M_TABLE DB 'An indirect jump through a register is absolute, not relative.', 0DH, 0AH, '$'
    M_ONE   DB 'Branch one was taken.', 0DH, 0AH, '$'
    M_TWO   DB 'Branch two was taken.', 0DH, 0AH, '$'

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
    ; THE ASSEMBLER WORKS OUT THE DISTANCE FROM THE END OF THE JUMP TO THE
    ; LABEL AND STORES THAT SIGNED NUMBER. NOTHING IN THE INSTRUCTION SAYS
    ; WHERE THE CODE LIVES, SO THE SAME BYTES RUN AT ANY LOAD ADDRESS.
    ; -------------------------------------------------------------------------
    JMP AHEAD

    LEA DX, M_SKIP                      ; Jumped over, never reached
    CALL PRINT_MESSAGE

AHEAD:
    LEA DX, M_FWD
    CALL PRINT_MESSAGE

    ; -------------------------------------------------------------------------
    ; A LOOP IS A BACKWARD RELATIVE JUMP, SO ITS DISPLACEMENT IS NEGATIVE. THE
    ; SHORT FORM REACHES 128 BYTES BACK AND 127 FORWARD, WHICH IS WHY A LONG
    ; LOOP BODY SOMETIMES NEEDS THE TEST AND THE JUMP TAKEN APART.
    ; -------------------------------------------------------------------------
    LEA DX, M_DOWN
    CALL PRINT_MESSAGE

    MOV CX, 5
COUNT_DOWN:
    MOV AX, CX
    CALL PRINT_DECIMAL
    LEA DX, M_SPACE
    CALL PRINT_MESSAGE
    LOOP COUNT_DOWN                     ; Relative, and negative
    CALL NEWLINE
    CALL NEWLINE

    ; -------------------------------------------------------------------------
    ; A CONDITIONAL BRANCH IS ALWAYS THE SHORT RELATIVE FORM ON AN 8086. WHEN
    ; THE TARGET IS TOO FAR THE ANSWER IS TO BRANCH THE OTHER WAY ROUND OVER
    ; AN UNCONDITIONAL JUMP, WHICH IS WHAT AN ASSEMBLER DOES AUTOMATICALLY ON
    ; LATER PROCESSORS BUT NOT ON THIS ONE.
    ; -------------------------------------------------------------------------
    MOV AX, 5
    CMP AX, 5
    JE BRANCH_ONE
    JMP BRANCH_TWO

BRANCH_ONE:
    LEA DX, M_ONE
    CALL PRINT_MESSAGE
    JMP AFTER_BRANCHES

BRANCH_TWO:
    LEA DX, M_TWO
    CALL PRINT_MESSAGE

AFTER_BRANCHES:
    LEA DX, M_TABLE
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
; 1. Measured from the next instruction:
;    - The displacement is added to IP after the jump has been fetched.
;    - JMP to the very next instruction therefore encodes a displacement of zero.
;    - That is why the distance is counted from the end of the jump, not its start.
; 2. Short, near and far:
;    - A short jump is one signed byte and reaches -128 to +127.
;    - A near jump is one signed word and reaches anywhere in the segment.
;    - A far jump carries a whole segment and offset and is absolute, not relative.
; 3. Conditional branches are short only:
;    - Every Jcc on an 8086 takes a one byte displacement.
;    - A target out of reach gives a relative jump out of range error at assembly time.
;    - The fix is to invert the condition and jump over an unconditional JMP.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
