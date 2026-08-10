; =============================================================================
; TITLE: Binary Text to Hexadecimal Text
; DESCRIPTION: Converts between two written forms directly, four bits at a
;              time, without turning the value into a number first.
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
    BINARY  DB '1011010011010010'
    BITS    EQU $ - BINARY
    HEXOUT  DB 4 DUP(0)
    DIGITS  DB '0123456789ABCDEF'

    M_BIN   DB 'Binary:      $'
    M_HEX   DB 0DH, 0AH, 'Hexadecimal: $'
    M_TAIL  DB 'h', 0DH, 0AH, '$'

; -----------------------------------------------------------------------------
; CODE SEGMENT
; -----------------------------------------------------------------------------
.CODE
START:
    MOV AX, @DATA
    MOV DS, AX

    LEA DX, M_BIN
    MOV AH, 09H
    INT 21H
    LEA SI, BINARY
    MOV CX, BITS
    CALL PRINT_TEXT

    ; -------------------------------------------------------------------------
    ; EACH HEXADECIMAL DIGIT IS EXACTLY FOUR BINARY ONES, WHICH IS WHY THE
    ; TWO NOTATIONS CONVERT WITHOUT ANY ARITHMETIC. FOUR CHARACTERS ARE READ,
    ; ASSEMBLED INTO A NIBBLE, AND LOOKED UP.
    ; -------------------------------------------------------------------------
    LEA SI, BINARY
    LEA DI, HEXOUT
    MOV CX, BITS / 4                    ; One output digit per four input bits

GROUP:
    XOR BL, BL                          ; The nibble being assembled
    MOV DX, 4

NIBBLE:
    SHL BL, 1
    MOV AL, [SI]
    CMP AL, '1'
    JNE NOT_SET
    OR  BL, 1

NOT_SET:
    INC SI
    DEC DX
    JNZ NIBBLE

    XOR BH, BH
    MOV AL, DIGITS[BX]
    MOV [DI], AL
    INC DI

    LOOP GROUP

    LEA DX, M_HEX
    MOV AH, 09H
    INT 21H
    LEA SI, HEXOUT
    MOV CX, BITS / 4
    CALL PRINT_TEXT
    LEA DX, M_TAIL
    MOV AH, 09H
    INT 21H

    MOV AH, 4CH
    INT 21H

; -----------------------------------------------------------------------------
; PRINT_TEXT
;
; Prints CX characters starting at DS:SI. Both are left as they were found.
; -----------------------------------------------------------------------------
PRINT_TEXT PROC
    PUSH AX
    PUSH CX
    PUSH DX
    PUSH SI

    JCXZ PT_DONE                        ; Nothing to print

PT_LOOP:
    MOV DL, [SI]
    MOV AH, 02H
    INT 21H
    INC SI
    LOOP PT_LOOP

PT_DONE:
    POP SI
    POP DX
    POP CX
    POP AX
    RET
PRINT_TEXT ENDP

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
; 1. NO NUMBER IN THE MIDDLE:
;    - Converting to a value and back would work but would be limited to
;    - what a register can hold. Working four characters at a time will
;    - convert a binary string of any length at all.
; 2. THE GROUPS COME FROM THE LEFT:
;    - Which only works because the length is a multiple of four. An
;    - awkward length has to be padded at the front, not the back, or
;    - every digit comes out wrong.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
