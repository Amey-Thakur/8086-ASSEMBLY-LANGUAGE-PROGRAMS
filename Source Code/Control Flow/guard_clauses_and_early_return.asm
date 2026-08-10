; =============================================================================
; TITLE: Guard Clauses Against Nested Conditions
; DESCRIPTION: The same validation written as a pyramid of nested tests and as a flat run of guards, with the same verdicts.
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
    ; Age, then years of service, then grade. Five applicants.
    AGES    DW 25, 17, 45, 30, 64
    SERVICE DW  3,  1, 20,  0,  8
    GRADES  DW  5,  2,  7,  9,  4
    HOWMANY EQU 5

    M_TITLE DB 'Guard clauses and nested tests, compared', 0DH, 0AH, '$'
    M_HEAD  DB 0DH, 0AH, 'age  service  grade   nested   guards', 0DH, 0AH, '$'
    M_G1    DB '    $'
    M_G2    DB '       $'
    M_G3    DB '       $'
    M_YES   DB 'yes      $'
    M_NO    DB 'no       $'
    M_AGREE DB 0DH, 0AH, 'Both forms agreed on all five.', 0DH, 0AH, '$'
    M_DIFF  DB 0DH, 0AH, 'The two forms disagreed, so one of them is wrong.', 0DH, 0AH, '$'
    M_WHY   DB 'The guard form has no nesting at all, so a sixth condition adds '
            DB 'a line rather than a level.', 0DH, 0AH, '$'

; -----------------------------------------------------------------------------
; CODE SEGMENT
; -----------------------------------------------------------------------------
.CODE
START:
    MOV AX, @DATA
    MOV DS, AX

    LEA DX, M_TITLE
    CALL PRINT_MESSAGE
    LEA DX, M_HEAD
    CALL PRINT_MESSAGE

    XOR SI, SI
    MOV BP, 1                           ; 1 while the two forms still agree
    MOV CX, HOWMANY

EACH_APPLICANT:
    PUSH CX

    MOV AX, AGES[SI]
    CALL PRINT_DECIMAL
    LEA DX, M_G1
    CALL PRINT_MESSAGE

    MOV AX, SERVICE[SI]
    CALL PRINT_DECIMAL
    LEA DX, M_G2
    CALL PRINT_MESSAGE

    MOV AX, GRADES[SI]
    CALL PRINT_DECIMAL
    LEA DX, M_G3
    CALL PRINT_MESSAGE

    CALL NESTED_FORM                    ; AL = 1 eligible
    MOV BL, AL
    CALL SAY_VERDICT

    CALL GUARD_FORM
    MOV BH, AL
    CALL SAY_VERDICT
    CALL NEWLINE

    CMP BL, BH
    JE STILL_AGREED
    MOV BP, 0
STILL_AGREED:

    ADD SI, 2
    POP CX
    LOOP EACH_APPLICANT

    CMP BP, 1
    JNE THEY_DIFFER
    LEA DX, M_AGREE
    CALL PRINT_MESSAGE
    JMP EXPLAIN

THEY_DIFFER:
    LEA DX, M_DIFF
    CALL PRINT_MESSAGE

EXPLAIN:
    LEA DX, M_WHY
    CALL PRINT_MESSAGE

    MOV AH, 4CH
    INT 21H

; -----------------------------------------------------------------------------
; NESTED_FORM
;
; Eligible when at least eighteen, at most sixty, with two or more years of
; service and a grade of four or better. Written as nested tests, which is how
; the rule reads in prose and how most people write it first.
; -----------------------------------------------------------------------------
NESTED_FORM PROC
    PUSH BX
    PUSH DX

    MOV BX, AGES[SI]
    CMP BX, 18
    JB NESTED_NO
        CMP BX, 60
        JA NESTED_NO
            MOV BX, SERVICE[SI]
            CMP BX, 2
            JB NESTED_NO
                MOV BX, GRADES[SI]
                CMP BX, 4
                JB NESTED_NO
                    MOV AL, 1
                    JMP NESTED_DONE

NESTED_NO:
    MOV AL, 0

NESTED_DONE:
    POP DX
    POP BX
    RET
NESTED_FORM ENDP

; -----------------------------------------------------------------------------
; GUARD_FORM
;
; The same rule as a run of guards. Each one refuses and leaves at once, so the
; interesting path is the one that reaches the bottom.
;
; The indentation above shows what is being avoided: four conditions is four
; levels deep, and a fifth would be a fifth.
; -----------------------------------------------------------------------------
GUARD_FORM PROC
    PUSH BX
    PUSH DX

    MOV AL, 0                           ; Refused unless everything passes

    MOV BX, AGES[SI]
    CMP BX, 18
    JB GUARD_DONE

    CMP BX, 60
    JA GUARD_DONE

    MOV BX, SERVICE[SI]
    CMP BX, 2
    JB GUARD_DONE

    MOV BX, GRADES[SI]
    CMP BX, 4
    JB GUARD_DONE

    MOV AL, 1

GUARD_DONE:
    POP DX
    POP BX
    RET
GUARD_FORM ENDP

; -----------------------------------------------------------------------------
; SAY_VERDICT
;
; Prints yes or no for the value in AL, without disturbing it.
; -----------------------------------------------------------------------------
SAY_VERDICT PROC
    PUSH AX
    PUSH DX

    CMP AL, 1
    JE VERDICT_YES

    LEA DX, M_NO
    CALL PRINT_MESSAGE
    JMP VERDICT_DONE

VERDICT_YES:
    LEA DX, M_YES
    CALL PRINT_MESSAGE

VERDICT_DONE:
    POP DX
    POP AX
    RET
SAY_VERDICT ENDP

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
; 1. Nesting grows with the conditions:
;    - Four conditions written as nested tests is four levels of indentation.
;    - The guard form is flat however many conditions there are.
;    - In assembly the difference is smaller than in a high level language, but the labels still multiply.
; 2. Refuse first, accept last:
;    - AL is set to refused at the top, so every early exit is already correct.
;    - Only the path that survives every guard reaches the instruction that accepts.
;    - Forgetting to set the default is how a guard form accidentally accepts everything.
; 3. Two forms, checked against each other:
;    - Both are computed for every applicant and the answers compared.
;    - A rewrite that changes behaviour shows up immediately rather than in use.
;    - This is the cheapest form of the technique usually called differential testing.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
