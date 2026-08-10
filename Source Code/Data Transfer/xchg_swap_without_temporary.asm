; =============================================================================
; TITLE: Swap Two Values with XCHG
; DESCRIPTION: Exchanges two registers, and then a register and a memory word,
;              without the third variable the same job needs in most languages.
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
    STORED  DW 999
    MSG_1   DB 'Registers before: $'
    MSG_2   DB 'Registers after:  $'
    MSG_3   DB 'Memory after:     $'
    SPACER  DB ' and $'

; -----------------------------------------------------------------------------
; CODE SEGMENT
; -----------------------------------------------------------------------------
.CODE
START:
    MOV AX, @DATA
    MOV DS, AX

    MOV BX, 11
    MOV CX, 22

    LEA DX, MSG_1
    MOV AH, 09H
    INT 21H
    CALL SHOW_PAIR

    XCHG BX, CX                         ; One instruction, no temporary

    LEA DX, MSG_2
    MOV AH, 09H
    INT 21H
    CALL SHOW_PAIR

    ; -------------------------------------------------------------------------
    ; XCHG ALSO WORKS BETWEEN A REGISTER AND MEMORY, WHICH IS WHAT MAKES IT
    ; USEFUL INSIDE A SORT: THE ARRAY ELEMENT AND THE HELD VALUE TRADE PLACES
    ; IN ONE STEP.
    ; -------------------------------------------------------------------------
    XCHG BX, STORED

    LEA DX, MSG_3
    MOV AH, 09H
    INT 21H
    MOV AX, STORED
    CALL PRINT_DECIMAL
    CALL NEWLINE

    MOV AH, 4CH
    INT 21H

; -----------------------------------------------------------------------------
; SHOW_PAIR
;
; Prints BX and CX on one line.
; -----------------------------------------------------------------------------
SHOW_PAIR PROC
    MOV AX, BX
    CALL PRINT_DECIMAL
    LEA DX, SPACER
    MOV AH, 09H
    INT 21H
    MOV AX, CX
    CALL PRINT_DECIMAL
    CALL NEWLINE
    RET
SHOW_PAIR ENDP

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
; 1. WHY NO TEMPORARY IS NEEDED:
;    - The processor holds both values internally for the duration of the
;    - instruction. Nothing can observe a half completed exchange.
; 2. THE MEMORY FORM LOCKS THE BUS:
;    - XCHG with a memory operand asserts the bus lock automatically on
;    - the 8086, even without the LOCK prefix. That is what makes it the
;    - instruction a semaphore is built from.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
