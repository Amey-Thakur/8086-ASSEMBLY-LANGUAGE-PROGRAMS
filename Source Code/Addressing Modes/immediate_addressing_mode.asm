; =============================================================================
; TITLE: Immediate Addressing Mode
; DESCRIPTION: The operand is a constant carried inside the instruction itself, so no memory read is needed to fetch it.
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
    M_TITLE DB 'Immediate addressing: the value travels in the instruction', 0DH, 0AH, '$'
    M_MOV   DB 'MOV AX, 500      AX = $'
    M_ADD   DB 'ADD AX, 250      AX = $'
    M_SUB   DB 'SUB AX, 50       AX = $'
    M_BYTE  DB 'MOV BL, 25       BL = $'
    M_WIDE  DB 'MOV AX, 0FFFFH   AX = $'
    M_RULE  DB 'A constant can only be the source. It has no address, so it '
            DB 'can never be the destination.', 0DH, 0AH, '$'

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
    ; EACH OF THESE INSTRUCTIONS CARRIES ITS OPERAND IN THE BYTES THAT FOLLOW
    ; THE OPCODE. THE PROCESSOR NEVER GOES TO MEMORY FOR THE VALUE, WHICH IS
    ; WHY IMMEDIATE OPERANDS ARE THE FASTEST KIND.
    ; -------------------------------------------------------------------------
    MOV AX, 500
    LEA DX, M_MOV
    CALL PRINT_MESSAGE
    CALL PRINT_DECIMAL
    CALL NEWLINE

    ADD AX, 250
    LEA DX, M_ADD
    CALL PRINT_MESSAGE
    CALL PRINT_DECIMAL
    CALL NEWLINE

    SUB AX, 50
    LEA DX, M_SUB
    CALL PRINT_MESSAGE
    CALL PRINT_DECIMAL
    CALL NEWLINE

    ; An eight bit register takes an eight bit constant.
    MOV BL, 25
    LEA DX, M_BYTE
    CALL PRINT_MESSAGE
    XOR AX, AX
    MOV AL, BL
    CALL PRINT_DECIMAL
    CALL NEWLINE

    ; The widest constant a sixteen bit register can hold.
    MOV AX, 0FFFFH
    LEA DX, M_WIDE
    CALL PRINT_MESSAGE
    CALL PRINT_DECIMAL
    CALL NEWLINE
    CALL NEWLINE

    LEA DX, M_RULE

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
; 1. What makes it immediate:
;    - The operand is assembled into the instruction stream directly after the opcode.
;    - MOV AX, 500 is three bytes: the opcode and then 500 as a little endian word.
;    - No effective address is calculated and no data segment is touched.
; 2. Width must match:
;    - MOV BL, 25 stores one byte because BL is one byte wide.
;    - MOV AX, 25 stores a word, with the high byte zero.
;    - A constant larger than the destination is an assembly error, not a silent truncation.
; 3. Why it cannot be a destination:
;    - A destination has to be somewhere the processor can write.
;    - A constant lives in the code stream, which is read only in practice.
;    - MOV 500, AX is rejected by the assembler for that reason.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
