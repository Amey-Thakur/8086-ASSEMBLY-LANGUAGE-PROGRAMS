; =============================================================================
; TITLE: MOV Between Registers
; DESCRIPTION: Moves a value along a chain of registers, showing that MOV copies
;              rather than moves, and that the source is left untouched.
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
    MSG_AX DB 'AX = $'
    MSG_BX DB '   BX = $'
    MSG_CX DB '   CX = $'

; -----------------------------------------------------------------------------
; CODE SEGMENT
; -----------------------------------------------------------------------------
.CODE
START:
    MOV AX, @DATA
    MOV DS, AX

    ; -------------------------------------------------------------------------
    ; MOV COPIES. AFTER THE CHAIN, ALL THREE REGISTERS HOLD THE SAME VALUE
    ; RATHER THAN THE VALUE HAVING TRAVELLED AND LEFT ITS SOURCE EMPTY.
    ; -------------------------------------------------------------------------
    MOV AX, 1234
    MOV BX, AX                          ; BX takes a copy
    MOV CX, BX                          ; And so does CX

    LEA DX, MSG_AX
    MOV AH, 09H
    INT 21H
    MOV AX, 1234
    CALL PRINT_DECIMAL

    LEA DX, MSG_BX
    MOV AH, 09H
    INT 21H
    MOV AX, BX
    CALL PRINT_DECIMAL

    LEA DX, MSG_CX
    MOV AH, 09H
    INT 21H
    MOV AX, CX
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
; 1. THE NAME IS MISLEADING:
;    - MOV copies. Nothing leaves the source. A processor instruction that
;    - emptied its source would need two writes instead of one.
; 2. WHAT IS NOT ALLOWED:
;    - Both operands cannot be memory. There is one bus and one address
;    - in the instruction, so a memory to memory move has to go through a
;    - register, or use MOVSB, which is built for exactly that.
; 3. WIDTHS MUST AGREE:
;    - MOV AX, BL is not encodable. The two operands have to be the same
;    - size, and the assembler rejects the instruction rather than
;    - guessing which half was meant.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
