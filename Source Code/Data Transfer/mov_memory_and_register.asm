; =============================================================================
; TITLE: MOV Between Memory and Registers
; DESCRIPTION: Reads a value out of memory, changes it in a register and writes
;              it back, which is the shape of nearly every 8086 calculation.
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
    COUNTER DW 100
    BEFORE  DB 'Before: $'
    AFTER   DB 'After:  $'

; -----------------------------------------------------------------------------
; CODE SEGMENT
; -----------------------------------------------------------------------------
.CODE
START:
    MOV AX, @DATA
    MOV DS, AX

    LEA DX, BEFORE
    MOV AH, 09H
    INT 21H
    MOV AX, COUNTER                     ; Memory to register
    CALL PRINT_DECIMAL
    CALL NEWLINE

    ; -------------------------------------------------------------------------
    ; ARITHMETIC HAPPENS IN REGISTERS. THE VALUE COMES OUT OF MEMORY, IS
    ; WORKED ON, AND GOES BACK. THE 8086 CAN ADD DIRECTLY TO MEMORY, BUT THE
    ; THREE STEP FORM IS WHAT A LONGER CALCULATION LOOKS LIKE.
    ; -------------------------------------------------------------------------
    MOV AX, COUNTER
    ADD AX, 23
    MOV COUNTER, AX                     ; Register back to memory

    LEA DX, AFTER
    MOV AH, 09H
    INT 21H
    MOV AX, COUNTER
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
; 1. THE NAME IS AN ADDRESS:
;    - MOV AX, COUNTER reads what is stored at COUNTER. To load the
;    - address itself rather than the contents, LEA or OFFSET is needed.
; 2. WIDTH COMES FROM THE DECLARATION:
;    - COUNTER was declared with DW, so it is a word and pairs with AX.
;    - A DB variable pairs with AL. Mixing them needs BYTE PTR or WORD
;    - PTR to say which was meant.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
