; =============================================================================
; TITLE: Two Procedures Calling Each Other
; DESCRIPTION: Decides whether a number is even using two procedures that each
;              call the other, which is mutual recursion.
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
    SAMPLES DW 7, 10, 0, 13
    HOWMANY EQU 4
    SEP     DB ' is $'
    M_EVEN  DB 'even', 0DH, 0AH, '$'
    M_ODD   DB 'odd', 0DH, 0AH, '$'

; -----------------------------------------------------------------------------
; CODE SEGMENT
; -----------------------------------------------------------------------------
.CODE
START:
    MOV AX, @DATA
    MOV DS, AX

    LEA SI, SAMPLES
    MOV CX, HOWMANY

EACH:
    MOV AX, [SI]

    PUSH CX
    PUSH SI

    CALL PRINT_DECIMAL
    LEA DX, SEP
    MOV AH, 09H
    INT 21H

    POP SI
    PUSH SI
    MOV AX, [SI]
    PUSH AX
    CALL IS_EVEN
    ADD SP, 2

    OR  AX, AX
    JZ  IT_IS_ODD
    LEA DX, M_EVEN
    JMP REPORT

IT_IS_ODD:
    LEA DX, M_ODD

REPORT:
    MOV AH, 09H
    INT 21H

    POP SI
    POP CX
    ADD SI, 2
    LOOP EACH

    MOV AH, 4CH
    INT 21H

; -----------------------------------------------------------------------------
; IS_EVEN
;
; Returns 1 in AX when [BP+4] is even.
;     even(0) is true
;     even(n) is odd(n - 1)
; -----------------------------------------------------------------------------
IS_EVEN PROC
    PUSH BP
    MOV BP, SP

    MOV AX, [BP+4]
    OR  AX, AX
    JZ  EVEN_YES                        ; Zero is even

    DEC AX
    PUSH AX
    CALL IS_ODD                         ; Hand the question to the other one
    ADD SP, 2
    JMP EVEN_RETURN

EVEN_YES:
    MOV AX, 1

EVEN_RETURN:
    POP BP
    RET
IS_EVEN ENDP

; -----------------------------------------------------------------------------
; IS_ODD
;
;     odd(0) is false
;     odd(n) is even(n - 1)
; -----------------------------------------------------------------------------
IS_ODD PROC
    PUSH BP
    MOV BP, SP

    MOV AX, [BP+4]
    OR  AX, AX
    JZ  ODD_NO                          ; Zero is not odd

    DEC AX
    PUSH AX
    CALL IS_EVEN
    ADD SP, 2
    JMP ODD_RETURN

ODD_NO:
    XOR AX, AX

ODD_RETURN:
    POP BP
    RET
IS_ODD ENDP

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
; 1. FORWARD REFERENCES BOTH WAYS:
;    - IS_EVEN calls IS_ODD before it has been assembled. The two pass
;    - assembler resolves the address on the second pass, which is
;    - exactly the case forward references exist for.
; 2. CORRECT BUT ABSURD:
;    - Deciding whether 10 is even takes eleven calls. TEST AX, 1 answers
;    - the same question in one instruction. This is here for the shape,
;    - not the method.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
