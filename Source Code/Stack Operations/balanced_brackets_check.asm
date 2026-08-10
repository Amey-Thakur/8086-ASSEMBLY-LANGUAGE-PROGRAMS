; =============================================================================
; TITLE: Checking Brackets With A Stack
; DESCRIPTION: The classic use of a stack: every opening bracket is pushed and must be matched by the right closing one.
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
    CASE_1  DB '(a[b]{c})'
    LEN_1   EQU $ - CASE_1
    CASE_2  DB '([)]'
    LEN_2   EQU $ - CASE_2
    CASE_3  DB '((a+b)'
    LEN_3   EQU $ - CASE_3
    CASE_4  DB 'a)b('
    LEN_4   EQU $ - CASE_4

    M_TITLE DB 'Bracket matching, the textbook use of a stack', 0DH, 0AH, '$'
    M_TEXT  DB 'text: $'
    M_OK    DB '   balanced', 0DH, 0AH, '$'
    M_BAD   DB '   not balanced', 0DH, 0AH, '$'
    M_HOW   DB 0DH, 0AH
            DB 'An opener is pushed. A closer must match the top. Anything '
            DB 'left over at the end is unclosed.', 0DH, 0AH, '$'

; -----------------------------------------------------------------------------
; CODE SEGMENT
; -----------------------------------------------------------------------------
.CODE
START:
    MOV AX, @DATA
    MOV DS, AX

    LEA DX, M_TITLE
    CALL PRINT_MESSAGE

    LEA SI, CASE_1
    MOV CX, LEN_1
    CALL REPORT

    LEA SI, CASE_2
    MOV CX, LEN_2
    CALL REPORT

    LEA SI, CASE_3
    MOV CX, LEN_3
    CALL REPORT

    LEA SI, CASE_4
    MOV CX, LEN_4
    CALL REPORT

    LEA DX, M_HOW
    CALL PRINT_MESSAGE

    MOV AH, 4CH
    INT 21H

; -----------------------------------------------------------------------------
; REPORT
;
; Prints the text at DS:SI of length CX and then whether it is balanced.
; -----------------------------------------------------------------------------
REPORT PROC
    PUSH AX
    PUSH CX
    PUSH DX
    PUSH SI

    LEA DX, M_TEXT
    CALL PRINT_MESSAGE
    CALL PRINT_TEXT

    CALL BALANCED                       ; AL = 1 when balanced
    CMP AL, 1
    JE SAY_OK

    LEA DX, M_BAD
    CALL PRINT_MESSAGE
    JMP REPORT_DONE

SAY_OK:
    LEA DX, M_OK
    CALL PRINT_MESSAGE

REPORT_DONE:
    POP SI
    POP DX
    POP CX
    POP AX
    RET
REPORT ENDP

; -----------------------------------------------------------------------------
; BALANCED
;
; Tests the CX characters at DS:SI. Returns AL = 1 when balanced, 0 otherwise.
;
; BP counts how many openers are on the stack, so the routine can tell an empty
; stack from a mismatched one and can clear up before returning either way.
; -----------------------------------------------------------------------------
BALANCED PROC
    PUSH BX
    PUSH CX
    PUSH DX
    PUSH SI
    PUSH BP

    XOR BP, BP                          ; Nothing pushed yet
    JCXZ ALL_MATCHED                    ; An empty text is balanced

EACH_CHARACTER:
    MOV BL, [SI]
    INC SI

    ; ---- an opener goes on the stack ----------------------------------------
    CMP BL, '('
    JE PUSH_IT
    CMP BL, '['
    JE PUSH_IT
    CMP BL, '{'
    JE PUSH_IT

    ; ---- a closer must match the top ----------------------------------------
    CMP BL, ')'
    JE POP_IT
    CMP BL, ']'
    JE POP_IT
    CMP BL, '}'
    JE POP_IT

    JMP NEXT_CHARACTER                  ; Anything else is ignored

PUSH_IT:
    XOR BH, BH
    PUSH BX
    INC BP
    JMP NEXT_CHARACTER

POP_IT:
    CMP BP, 0
    JE UNMATCHED                        ; A closer with nothing open

    POP DX                              ; DL is the opener it should match
    DEC BP

    CMP BL, ')'
    JNE TRY_SQUARE
    CMP DL, '('
    JNE UNMATCHED
    JMP NEXT_CHARACTER

TRY_SQUARE:
    CMP BL, ']'
    JNE TRY_CURLY
    CMP DL, '['
    JNE UNMATCHED
    JMP NEXT_CHARACTER

TRY_CURLY:
    CMP DL, '{'
    JNE UNMATCHED

NEXT_CHARACTER:
    LOOP EACH_CHARACTER

    ; ---- anything still on the stack was never closed -----------------------
    CMP BP, 0
    JNE UNMATCHED

ALL_MATCHED:
    MOV AL, 1
    JMP BALANCED_DONE

UNMATCHED:
    ; The stack must be emptied before returning, or the pops below take the
    ; wrong words and RET jumps into nowhere. BP says how many are left.
    MOV AL, 0
DISCARD:
    CMP BP, 0
    JE BALANCED_DONE
    POP DX
    DEC BP
    JMP DISCARD

BALANCED_DONE:
    POP BP
    POP SI
    POP DX
    POP CX
    POP BX
    RET
BALANCED ENDP

; -----------------------------------------------------------------------------
; PRINT_TEXT
;
; Prints CX characters starting at DS:SI. Both are left as they were found.
; -----------------------------------------------------------------------------
PRINT_TEXT PROC
    PUSH AX
    PUSH CX
    PUSH DX
    PUSH SI

    JCXZ PT_DONE                        ; Nothing to print

PT_LOOP:
    MOV DL, [SI]
    MOV AH, 02H
    INT 21H
    INC SI
    LOOP PT_LOOP

PT_DONE:
    POP SI
    POP DX
    POP CX
    POP AX
    RET
PRINT_TEXT ENDP

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
; 1. Why a stack and not a counter:
;    - A single counter accepts ([)] because it only tracks how many are open.
;    - The stack remembers which kind was opened and in what order.
;    - That is exactly the information needed to reject a crossed pair.
; 2. Three ways to fail:
;    - A closer of the wrong kind, as in ([)].
;    - A closer with nothing open, as in a)b(.
;    - An opener never closed, which only shows up once the text runs out.
; 3. Clean up before returning:
;    - An early exit leaves the pushed openers behind and unbalances the stack.
;    - BP counts them so the discard loop knows exactly how many to drop.
;    - Getting this wrong makes RET return to whatever the leftover word happened to be.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
