; =============================================================================
; TITLE: Fibonacci by Recursion
; DESCRIPTION: Computes a Fibonacci number the way the definition reads, and
;              counts the calls to show what that costs.
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
    WANTED  DW 12
    M_VALUE DB 'Fibonacci term 12 is $'
    M_CALLS DB 'It took $'
    M_TAIL  DB ' calls to work out', 0DH, 0AH, '$'
    CALLS   DW 0

; -----------------------------------------------------------------------------
; CODE SEGMENT
; -----------------------------------------------------------------------------
.CODE
START:
    MOV AX, @DATA
    MOV DS, AX

    MOV AX, WANTED
    PUSH AX
    CALL FIBONACCI
    ADD SP, 2

    PUSH AX
    LEA DX, M_VALUE
    MOV AH, 09H
    INT 21H
    POP AX
    CALL PRINT_DECIMAL
    CALL NEWLINE

    LEA DX, M_CALLS
    MOV AH, 09H
    INT 21H
    MOV AX, CALLS
    CALL PRINT_DECIMAL
    LEA DX, M_TAIL
    MOV AH, 09H
    INT 21H

    MOV AH, 4CH
    INT 21H

; -----------------------------------------------------------------------------
; FIBONACCI
;
; [BP+4] holds which term is wanted. The value comes back in AX.
; -----------------------------------------------------------------------------
FIBONACCI PROC
    PUSH BP
    MOV BP, SP
    PUSH BX

    INC CALLS

    MOV AX, [BP+4]
    CMP AX, 1
    JBE FIB_BASE                        ; Terms 0 and 1 are themselves

    ; -------------------------------------------------------------------------
    ; TWO RECURSIVE CALLS PER LEVEL, AND NEITHER KNOWS THE OTHER EXISTS. THAT
    ; IS WHY THE SAME TERMS ARE RECOMPUTED OVER AND OVER.
    ; -------------------------------------------------------------------------
    DEC AX
    PUSH AX
    CALL FIBONACCI                      ; term n-1
    ADD SP, 2
    MOV BX, AX                          ; Hold it while the other runs

    MOV AX, [BP+4]
    SUB AX, 2
    PUSH AX
    CALL FIBONACCI                      ; term n-2
    ADD SP, 2

    ADD AX, BX
    JMP FIB_RETURN

FIB_BASE:
    ; AX already holds the term number, which is the answer

FIB_RETURN:
    POP BX
    POP BP
    RET
FIBONACCI ENDP

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
; 1. THE COST IS THE POINT:
;    - Term twelve takes hundreds of calls, because term ten is worked
;    - out twice, term nine three times, and so on. The call count
;    - printed here grows almost as fast as the answer.
; 2. THE ITERATIVE FORM IS BETTER:
;    - A loop keeping two values computes the same term in twelve
;    - additions. Recursion is the clearer way to state the definition
;    - and the worse way to compute it.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
