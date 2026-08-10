; =============================================================================
; TITLE: Returning Several Values From One Procedure
; DESCRIPTION: One pass over an array hands back four answers at once, and a
;              second procedure returns a result together with a flag saying
;              whether the result is worth reading.
; AUTHOR: Amey Thakur (https://github.com/Amey-Thakur)
; REPOSITORY: https://github.com/Amey-Thakur/8086-ASSEMBLY-LANGUAGE-PROGRAMS
; LICENSE: MIT License
; =============================================================================

.MODEL SMALL
.STACK 200H

; -----------------------------------------------------------------------------
; DATA SEGMENT
; -----------------------------------------------------------------------------
.DATA
    VALUES   DW 34, 7, 91, 23, 60, 15, 78, 42
    SPAN     EQU $ - VALUES             ; Measured, never counted by hand

    SMALLEST DW ?                       ; The four answers, parked in memory
    LARGEST  DW ?                       ; the moment they come back, since
    TOTAL    DW ?                       ; printing needs AX for the value and
    EVENS    DW ?                       ; DX for the message address

    HOWMANY  DW ?                       ; Elements, kept for the division later
    QUOTIENT DW ?
    LEFTOVER DW ?
    REFUSED  DW ?                       ; Non zero when the divisor was zero

    M_TITLE DB 'One call over the array, four answers back', 0DH, 0AH, '$'
    M_MIN   DB 'smallest      $'
    M_MAX   DB 'largest       $'
    M_SUM   DB 'sum           $'
    M_EVEN  DB 'even values   $'
    M_MEAN  DB 0DH, 0AH, 'The mean as a quotient and a remainder', 0DH, 0AH, '$'
    M_DIV   DB ' divided by $'
    M_IS    DB ' is $'
    M_REM   DB ' remainder $'
    M_ZERO  DB ' was refused, the divisor was zero', 0DH, 0AH, '$'
    M_CLOSE DB 0DH, 0AH
            DB 'How many registers there are is the only limit on how many '
            DB 'answers a procedure may return, and the carry flag carries a '
            DB 'fifth one without using a register at all.', 0DH, 0AH, '$'

; -----------------------------------------------------------------------------
; CODE SEGMENT
; -----------------------------------------------------------------------------
.CODE
START:
    MOV AX, @DATA
    MOV DS, AX

    LEA DX, M_TITLE
    CALL PRINT_MESSAGE

    LEA SI, VALUES
    MOV CX, SPAN
    SHR CX, 1                           ; Bytes to elements, each a word
    MOV HOWMANY, CX

    CALL SURVEY

    ; -------------------------------------------------------------------------
    ; STORE ALL FOUR ANSWERS BEFORE ANYTHING IS PRINTED. THE FIRST LINE OF
    ; OUTPUT WOULD OTHERWISE OVERWRITE THE REGISTERS HOLDING THE OTHER THREE.
    ; -------------------------------------------------------------------------
    MOV SMALLEST, AX
    MOV LARGEST, BX
    MOV TOTAL, BP
    MOV EVENS, DI

    LEA DX, M_MIN
    CALL PRINT_MESSAGE
    MOV AX, SMALLEST
    CALL PRINT_DECIMAL
    CALL NEWLINE

    LEA DX, M_MAX
    CALL PRINT_MESSAGE
    MOV AX, LARGEST
    CALL PRINT_DECIMAL
    CALL NEWLINE

    LEA DX, M_SUM
    CALL PRINT_MESSAGE
    MOV AX, TOTAL
    CALL PRINT_DECIMAL
    CALL NEWLINE

    LEA DX, M_EVEN
    CALL PRINT_MESSAGE
    MOV AX, EVENS
    CALL PRINT_DECIMAL
    CALL NEWLINE

    ; -------------------------------------------------------------------------
    ; A RESULT AND A FLAG. THE CARRY SAYS WHETHER THE QUOTIENT AND REMAINDER
    ; MEAN ANYTHING, WHICH LETS THE CALLER BRANCH WITHOUT INSPECTING EITHER.
    ; -------------------------------------------------------------------------
    LEA DX, M_MEAN
    CALL PRINT_MESSAGE

    MOV AX, TOTAL
    MOV CX, HOWMANY
    CALL DIVIDE_SAFELY
    CALL SHOW_DIVISION

    MOV AX, TOTAL
    XOR CX, CX                          ; A divisor of zero, deliberately
    CALL DIVIDE_SAFELY
    CALL SHOW_DIVISION

    LEA DX, M_CLOSE
    CALL PRINT_MESSAGE

    MOV AH, 4CH
    INT 21H

; -----------------------------------------------------------------------------
; SURVEY
;
; Entry: SI = first word, CX = how many words.
; Exit:  AX = smallest, BX = largest, BP = sum, DI = how many were even.
;
; Four answers for one pass. Four separate procedures would read the same array
; four times over and arrive at exactly the same figures.
; -----------------------------------------------------------------------------
SURVEY PROC
    PUSH CX
    PUSH DX
    PUSH SI

    XOR AX, AX
    XOR BX, BX
    XOR BP, BP
    XOR DI, DI
    JCXZ SV_DONE                        ; An empty array has no smallest at all

    MOV AX, [SI]                        ; The first element is both extremes
    MOV BX, AX

SV_NEXT:
    MOV DX, [SI]                        ; DX is scratch here and nothing else

    CMP DX, AX
    JAE SV_NOT_SMALLER                  ; Unsigned, the data is all positive
    MOV AX, DX
SV_NOT_SMALLER:

    CMP DX, BX
    JBE SV_NOT_LARGER
    MOV BX, DX
SV_NOT_LARGER:

    ADD BP, DX

    TEST DX, 1                          ; Bit zero alone decides the parity
    JNZ SV_ODD
    INC DI
SV_ODD:

    ADD SI, 2
    LOOP SV_NEXT

SV_DONE:
    POP SI
    POP DX
    POP CX
    RET
SURVEY ENDP

; -----------------------------------------------------------------------------
; DIVIDE_SAFELY
;
; Entry: AX = dividend, CX = divisor.
; Exit:  AX = quotient, BX = remainder, carry clear. Carry set means the
;        divisor was zero and neither AX nor BX should be believed.
;
; DIV by zero raises interrupt zero on real hardware and ends the program, so
; the guard has to come before the instruction rather than after it.
; -----------------------------------------------------------------------------
DIVIDE_SAFELY PROC
    PUSH DX

    JCXZ DV_NO_DIVISOR

    XOR DX, DX                          ; DX:AX is the dividend
    DIV CX
    MOV BX, DX                          ; Take the remainder before DX is restored

    POP DX
    CLC                                 ; Set last, since POP leaves flags alone
    RET

DV_NO_DIVISOR:
    XOR AX, AX
    XOR BX, BX
    POP DX
    STC
    RET
DIVIDE_SAFELY ENDP

; -----------------------------------------------------------------------------
; SHOW_DIVISION
;
; Reports the outcome of the division just performed. The carry has to be read
; before any arithmetic is done, and PUSH and MOV are the two instructions that
; leave the flags exactly as they found them.
; -----------------------------------------------------------------------------
SHOW_DIVISION PROC
    PUSH AX
    PUSH BX
    PUSH DX

    MOV REFUSED, 0
    JNC SD_TRUSTED
    MOV REFUSED, 1
SD_TRUSTED:
    MOV QUOTIENT, AX
    MOV LEFTOVER, BX

    MOV AX, TOTAL
    CALL PRINT_DECIMAL
    LEA DX, M_DIV
    CALL PRINT_MESSAGE
    MOV AX, CX
    CALL PRINT_DECIMAL

    CMP REFUSED, 0
    JNE SD_REFUSED

    LEA DX, M_IS
    CALL PRINT_MESSAGE
    MOV AX, QUOTIENT
    CALL PRINT_DECIMAL
    LEA DX, M_REM
    CALL PRINT_MESSAGE
    MOV AX, LEFTOVER
    CALL PRINT_DECIMAL
    CALL NEWLINE
    JMP SD_DONE

SD_REFUSED:
    LEA DX, M_ZERO
    CALL PRINT_MESSAGE

SD_DONE:
    POP DX
    POP BX
    POP AX
    RET
SHOW_DIVISION ENDP

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
; 1. WHERE THE ANSWERS GO:
;    - Registers are the natural place while there are enough of them.
;    - Beyond that the caller passes the address of a block to be filled.
;    - Either way the interface has to be written down, in the header.
; 2. THE CARRY FLAG AS A RETURN VALUE:
;    - It costs no register and the caller tests it with a single JC.
;    - DOS uses exactly this convention for most of its own services.
;    - It must be set last, because almost every instruction moves it.
; 3. WHY THE DIVISION IS GUARDED:
;    - A divisor of zero raises interrupt zero and ends the program.
;    - So does a quotient too large for AX, which DIV cannot report either.
;    - Testing the divisor first turns a fault into an ordinary return.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
