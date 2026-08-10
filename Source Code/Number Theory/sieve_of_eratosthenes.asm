; =============================================================================
; TITLE: Sieve of Eratosthenes
; DESCRIPTION: Finds every prime below fifty by striking out the multiples of
;              each prime in turn, rather than testing each number separately.
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
    LIMIT   EQU 50
    MARKS   DB LIMIT DUP(0)             ; 0 means still a candidate
    MSG     DB 'Primes below 50:', 0DH, 0AH, '$'
    SPACE   DB ' $'

; -----------------------------------------------------------------------------
; CODE SEGMENT
; -----------------------------------------------------------------------------
.CODE
START:
    MOV AX, @DATA
    MOV DS, AX

    LEA DX, MSG
    MOV AH, 09H
    INT 21H

    ; -------------------------------------------------------------------------
    ; STRIKE OUT THE MULTIPLES OF EACH NUMBER FROM TWO UPWARD. ANYTHING STILL
    ; UNMARKED WHEN ITS TURN COMES HAS NO SMALLER FACTOR, SO IT IS PRIME.
    ; -------------------------------------------------------------------------
    MOV BX, 2                           ; The candidate being considered

SIEVE_OUTER:
    CMP BX, LIMIT
    JAE SIEVE_DONE

    LEA SI, MARKS
    ADD SI, BX
    CMP BYTE PTR [SI], 0
    JNE SIEVE_NEXT                      ; Already struck out, so not prime

    ; BX is prime. Strike out every multiple of it.
    MOV AX, BX
    ADD AX, BX                          ; Start at twice BX

STRIKE:
    CMP AX, LIMIT
    JAE SIEVE_NEXT

    LEA SI, MARKS
    ADD SI, AX
    MOV BYTE PTR [SI], 1

    ADD AX, BX
    JMP STRIKE

SIEVE_NEXT:
    INC BX
    JMP SIEVE_OUTER

SIEVE_DONE:
    ; Report whatever survived
    MOV BX, 2

REPORT_LOOP:
    CMP BX, LIMIT
    JAE FINISH

    LEA SI, MARKS
    ADD SI, BX
    CMP BYTE PTR [SI], 0
    JNE REPORT_NEXT

    MOV AX, BX
    CALL PRINT_DECIMAL
    LEA DX, SPACE
    MOV AH, 09H
    INT 21H

REPORT_NEXT:
    INC BX
    JMP REPORT_LOOP

FINISH:
    CALL NEWLINE
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

END START

; =============================================================================
; TECHNICAL NOTES
; =============================================================================
; 1. WHY IT IS FASTER THAN TESTING EACH:
;    - Testing every number for divisibility does the same divisions over
;    - and over. The sieve does one pass of additions per prime, and
;    - addition is far cheaper than division on this processor.
; 2. THE MARK ARRAY IS THE ANSWER:
;    - Nothing is computed at the end. The array already holds the result
;    - and the second loop only reads it out.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
