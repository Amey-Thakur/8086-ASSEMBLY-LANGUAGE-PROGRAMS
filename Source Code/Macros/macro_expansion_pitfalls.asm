; =============================================================================
; TITLE: The Three Macro Traps
; DESCRIPTION: A macro is text substitution, and each of its three classic surprises follows directly from that.
; AUTHOR: Amey Thakur (https://github.com/Amey-Thakur)
; REPOSITORY: https://github.com/Amey-Thakur/8086-ASSEMBLY-LANGUAGE-PROGRAMS
; LICENSE: MIT License
; =============================================================================

.MODEL SMALL
.STACK 100H

; -----------------------------------------------------------------------------
; MACRO DEFINITIONS
; -----------------------------------------------------------------------------

; ---- trap one: an argument used twice ---------------------------------------
; DOUBLE_BAD names its argument twice. Given a register that the body itself
; changes, the second use sees the changed value. Given a constant it is fine,
; which is what makes the bug so easy to miss.
DOUBLE_BAD MACRO WHICH
    MOV AX, WHICH
    ADD AX, WHICH
ENDM

; ---- the same thing done safely ---------------------------------------------
DOUBLE_GOOD MACRO WHICH
    MOV AX, WHICH
    SHL AX, 1                           ; The argument is read exactly once
ENDM

; ---- trap two: a body that quietly destroys a register ----------------------
; SUM_TO uses CX as its counter without saying so. A caller counting a loop in
; CX will find it at zero afterwards.
SUM_TO_BAD MACRO LIMIT
    LOCAL AGAIN
    XOR AX, AX
    MOV CX, LIMIT
AGAIN:
    ADD AX, CX
    LOOP AGAIN
ENDM

; ---- the same thing, declaring what it touches ------------------------------
SUM_TO_GOOD MACRO LIMIT
    LOCAL AGAIN
    PUSH CX
    XOR AX, AX
    MOV CX, LIMIT
AGAIN:
    ADD AX, CX
    LOOP AGAIN
    POP CX
ENDM

; -----------------------------------------------------------------------------
; DATA SEGMENT
; -----------------------------------------------------------------------------
.DATA
    M_TITLE DB 'Three ways a macro surprises you, and the fixes', 0DH, 0AH, '$'
    M_ONE   DB 0DH, 0AH, '1. An argument named twice', 0DH, 0AH, '$'
    M_BAD1  DB '   DOUBLE_BAD BX with BX = 21 gives $'
    M_GOOD1 DB '   DOUBLE_GOOD BX gives             $'
    M_TWO   DB 0DH, 0AH, '2. A body that eats a register', 0DH, 0AH, '$'
    M_BAD2  DB '   CX before SUM_TO_BAD 5:  $'
    M_BAD3  DB '   CX after it:             $'
    M_GOOD2 DB '   CX after SUM_TO_GOOD 5:  $'
    M_SUM   DB '   the sum itself:          $'
    M_THREE DB 0DH, 0AH, '3. Size is invisible in the source', 0DH, 0AH, '$'
    M_SIZE  DB '   Four uses of a ten instruction macro is forty instructions.'
            DB 0DH, 0AH, '$'
    M_LAST  DB '   The source shows four lines, and reads as if it were cheap.'
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

    ; -------------------------------------------------------------------------
    ; TRAP ONE. HERE BOTH VERSIONS AGREE, BECAUSE BX IS NOT DISTURBED BETWEEN
    ; THE TWO USES. THE POINT IS THAT DOUBLE_BAD ONLY WORKS BY LUCK: MOVE AX
    ; INTO THE ARGUMENT POSITION AND IT DOUBLES THE WRONG THING.
    ; -------------------------------------------------------------------------
    LEA DX, M_ONE
    CALL PRINT_MESSAGE

    MOV BX, 21
    LEA DX, M_BAD1
    CALL PRINT_MESSAGE
    DOUBLE_BAD BX
    CALL PRINT_DECIMAL
    CALL NEWLINE

    MOV BX, 21
    LEA DX, M_GOOD1
    CALL PRINT_MESSAGE
    DOUBLE_GOOD BX
    CALL PRINT_DECIMAL
    CALL NEWLINE

    ; -------------------------------------------------------------------------
    ; TRAP TWO. THE COUNTER IS REPORTED BEFORE AND AFTER, SO THE DAMAGE IS
    ; VISIBLE RATHER THAN ARGUED ABOUT.
    ; -------------------------------------------------------------------------
    LEA DX, M_TWO
    CALL PRINT_MESSAGE

    MOV CX, 40
    LEA DX, M_BAD2
    CALL PRINT_MESSAGE
    MOV AX, CX
    CALL PRINT_DECIMAL
    CALL NEWLINE

    SUM_TO_BAD 5
    MOV BX, AX                          ; Keep the sum
    LEA DX, M_BAD3
    CALL PRINT_MESSAGE
    MOV AX, CX
    CALL PRINT_DECIMAL
    CALL NEWLINE

    MOV CX, 40
    SUM_TO_GOOD 5
    MOV BX, AX
    LEA DX, M_GOOD2
    CALL PRINT_MESSAGE
    MOV AX, CX
    CALL PRINT_DECIMAL
    CALL NEWLINE

    LEA DX, M_SUM
    CALL PRINT_MESSAGE
    MOV AX, BX
    CALL PRINT_DECIMAL
    CALL NEWLINE

    LEA DX, M_THREE
    CALL PRINT_MESSAGE
    LEA DX, M_SIZE
    CALL PRINT_MESSAGE
    LEA DX, M_LAST
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
; 1. Read each argument once:
;    - A macro that names an argument twice evaluates the text twice.
;    - If the body changes what the text refers to, the two readings differ.
;    - The habit is to copy the argument into a register first and use that.
; 2. Say which registers are touched:
;    - A macro body has no boundary, so anything it writes is written in the caller.
;    - Either push and pop what is used, or document it in a comment above the macro.
;    - SUM_TO_BAD returns the right sum and leaves CX at zero, which is the worst kind of bug.
; 3. Size hides in the source:
;    - A macro use is one line, whatever the body costs.
;    - Four uses of ten instructions is forty instructions in the output.
;    - A listing file shows the expansion, which is the only honest way to judge the size.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
