; =============================================================================
; TITLE: Summing an Array by Recursion
; DESCRIPTION: Adds an array by taking the first element and asking for the sum
;              of what remains.
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
    VALUES  DW 11, 22, 33, 44, 55, 66
    HOWMANY EQU 6
    M_HEAD  DB 'The array adds up to $'

; -----------------------------------------------------------------------------
; CODE SEGMENT
; -----------------------------------------------------------------------------
.CODE
START:
    MOV AX, @DATA
    MOV DS, AX

    LEA AX, VALUES
    PUSH AX
    MOV AX, HOWMANY
    PUSH AX
    CALL ARRAY_SUM
    ADD SP, 4

    PUSH AX
    LEA DX, M_HEAD
    MOV AH, 09H
    INT 21H
    POP AX
    CALL PRINT_DECIMAL
    CALL NEWLINE

    MOV AH, 4CH
    INT 21H

; -----------------------------------------------------------------------------
; ARRAY_SUM
;
; [BP+6] points at the first element, [BP+4] says how many remain.
; -----------------------------------------------------------------------------
ARRAY_SUM PROC
    PUSH BP
    MOV BP, SP
    PUSH BX
    PUSH SI

    MOV AX, [BP+4]
    OR  AX, AX
    JZ  AS_EMPTY                        ; No elements left, so the sum is zero

    MOV SI, [BP+6]
    MOV BX, [SI]                        ; This element, held across the call

    ADD SI, 2                           ; The rest of the array
    PUSH SI
    MOV AX, [BP+4]
    DEC AX
    PUSH AX
    CALL ARRAY_SUM
    ADD SP, 4

    ADD AX, BX
    JMP AS_RETURN

AS_EMPTY:
    XOR AX, AX

AS_RETURN:
    POP SI
    POP BX
    POP BP
    RET
ARRAY_SUM ENDP

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
; 1. THE SHAPE OF EVERY LIST RECURSION:
;    - One element plus the answer for the rest. The empty case returns
;    - the identity of the operation, which for addition is zero.
; 2. WHY BX IS SAVED IN THE FRAME:
;    - The deeper call needs BX for its own element. Pushing it as part
;    - of the frame gives each level its own copy.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
