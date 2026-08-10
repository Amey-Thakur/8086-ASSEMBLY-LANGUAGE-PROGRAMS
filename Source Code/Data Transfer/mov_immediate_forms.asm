; =============================================================================
; TITLE: MOV With an Immediate Operand
; DESCRIPTION: Loads constants written in every base the assembler accepts, and
;              shows that they all produce the same value.
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
    MSG DB 'Sixty five written five ways:', 0DH, 0AH, '$'

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

    MOV AX, 65                          ; Decimal
    CALL PRINT_DECIMAL
    CALL NEWLINE

    MOV AX, 41H                         ; Hexadecimal, trailing H
    CALL PRINT_DECIMAL
    CALL NEWLINE

    MOV AX, 01000001B                   ; Binary, trailing B
    CALL PRINT_DECIMAL
    CALL NEWLINE

    MOV AX, 101Q                        ; Octal, trailing Q
    CALL PRINT_DECIMAL
    CALL NEWLINE

    MOV AL, 'A'                         ; A character literal is its code
    XOR AH, AH
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
; 1. THE LEADING ZERO RULE:
;    - A hexadecimal constant that begins with a letter needs a leading
;    - zero: 0A7H, not A7H. Without it the assembler cannot tell the
;    - number from a symbol, and will look for a label called A7H.
; 2. CHARACTER LITERALS:
;    - A quoted character assembles to its ASCII code, so MOV AL, 41H and
;    - MOV AL, 'A' are the same instruction. The letter form says what
;    - the program means and should be preferred.
; 3. NOT FOR SEGMENT REGISTERS:
;    - MOV DS, 1000H is not encodable. A segment register can only be
;    - loaded from another register or from memory, which is why every
;    - program here begins MOV AX, @DATA and then MOV DS, AX.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
