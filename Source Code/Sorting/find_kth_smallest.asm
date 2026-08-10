; =============================================================================
; TITLE: Finding the k-th Smallest Without Sorting
; DESCRIPTION: Selects the third smallest element by running only as many
;              selection passes as needed, rather than ordering the whole array.
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
    DATA_W   DW 42, 17, 93, 8, 65, 31, 76, 4
    HOWMANY  EQU 8
    K        EQU 3
    M_HEAD   DB 'The third smallest value is $'

; -----------------------------------------------------------------------------
; CODE SEGMENT
; -----------------------------------------------------------------------------
.CODE
START:
    MOV AX, @DATA
    MOV DS, AX

    ; -------------------------------------------------------------------------
    ; A FULL SORT WOULD DO SEVEN PASSES. ONLY THREE ARE NEEDED TO KNOW WHICH
    ; VALUE IS THIRD, SO THE SELECTION IS STOPPED AS SOON AS IT HAS ARRIVED.
    ; -------------------------------------------------------------------------
    MOV CX, K
    LEA SI, DATA_W

OUTER:
    PUSH CX
    MOV DI, SI
    MOV BX, SI
    ADD BX, 2
    MOV CX, HOWMANY
    SUB CX, K                           ; How many remain beyond this position
    ADD CX, K
    SUB CX, 1
    MOV DX, SI
    SUB DX, OFFSET DATA_W
    SHR DX, 1                           ; The index of this position
    MOV CX, HOWMANY
    SUB CX, DX
    DEC CX                              ; Elements after this one

SCAN:
    JCXZ PLACE
    MOV AX, [BX]
    CMP AX, [DI]
    JAE NOT_SMALLER
    MOV DI, BX

NOT_SMALLER:
    ADD BX, 2
    DEC CX
    JMP SCAN

PLACE:
    MOV AX, [SI]
    XCHG AX, [DI]
    MOV [SI], AX

    ADD SI, 2
    POP CX
    LOOP OUTER

    ; -------------------------------------------------------------------------
    ; AFTER K PASSES THE FIRST K POSITIONS HOLD THE K SMALLEST IN ORDER, SO
    ; THE ANSWER IS AT INDEX K MINUS ONE.
    ; -------------------------------------------------------------------------
    MOV SI, K - 1
    SHL SI, 1
    MOV AX, DATA_W[SI]
    MOV BX, AX

    LEA DX, M_HEAD
    MOV AH, 09H
    INT 21H
    MOV AX, BX
    CALL PRINT_DECIMAL
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
; 1. ONLY AS MUCH SORTING AS THE QUESTION NEEDS:
;    - Selection sort settles one position per pass, so stopping after k
;    - passes answers the question at a fraction of the cost.
; 2. THE MEDIAN IS THE USUAL CASE:
;    - Setting k to half the count finds the median, which is what this
;    - technique is normally wanted for.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
