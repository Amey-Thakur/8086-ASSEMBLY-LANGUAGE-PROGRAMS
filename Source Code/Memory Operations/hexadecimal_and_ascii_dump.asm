; =============================================================================
; TITLE: A Hexadecimal And ASCII Dump Of Memory
; DESCRIPTION: Prints a block sixteen bytes to the row, giving the offset, the
;              bytes in hexadecimal and the same bytes as text, with a short
;              final row padded so that the text column still lines up.
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
    SAMPLE  DB 'Amey Thakur', 0DH, 0AH, '8086 Assembly', 0, 1, 2, 3, 'MEMORY'
            DB 0FFH, 07FH, 020H, 07EH
    SPAN    EQU $ - SAMPLE               ; Measured, so the last row cannot overrun
    PER_ROW EQU 16                       ; Sixteen fits a narrow screen and halves neatly

    DIGITS  DB '0123456789ABCDEF'        ; XLAT turns a nibble into one of these

    LOWEST  EQU 20H                      ; The first printable code, a space
    HIGHEST EQU 7EH                      ; The last one, a tilde

    M_TITLE DB 'A dump of the block, sixteen bytes to the row.', 0DH, 0AH
            DB 'Offset, then the bytes in hexadecimal, then the same bytes as', 0DH, 0AH
            DB 'text, with anything outside 20H to 7EH shown as a full stop.'
            DB 0DH, 0AH, 0DH, 0AH, '$'
    M_GAP   DB '  $'                     ; Between the offset and the bytes
    M_SP    DB ' $'                      ; After each pair of digits
    M_PAD   DB '   $'                    ; The three columns a missing byte would fill
    M_OPEN  DB ' |$'
    M_SHUT  DB '|$'
    M_COUNT DB 0DH, 0AH, 'Bytes dumped: $'

; -----------------------------------------------------------------------------
; CODE SEGMENT
; -----------------------------------------------------------------------------
.CODE
START:
    MOV AX, @DATA
    MOV DS, AX

    LEA DX, M_TITLE
    CALL PRINT_MESSAGE

    XOR SI, SI                          ; Offset within the block of the next row

NEXT_ROW:
    CMP SI, SPAN                        ; Unsigned: an offset is never negative
    JAE DUMP_DONE

    MOV AX, SI
    CALL HEX_QUAD
    LEA DX, M_GAP
    CALL PRINT_MESSAGE

    ; -------------------------------------------------------------------------
    ; HOW LONG THIS ROW IS HAS TO BE WORKED OUT RATHER THAN ASSUMED. THE LAST
    ; ROW OF A BLOCK IS USUALLY SHORT, AND A DUMP THAT PRINTS A FULL SIXTEEN
    ; REGARDLESS WOULD REPORT WHATEVER HAPPENS TO FOLLOW THE BLOCK IN MEMORY.
    ; -------------------------------------------------------------------------
    MOV BX, SPAN
    SUB BX, SI                          ; Bytes left in the block
    CMP BX, PER_ROW
    JBE ROW_COUNTED
    MOV BX, PER_ROW
ROW_COUNTED:

    ; ---- the hexadecimal column ----------------------------------------------
    ; The guard above proves at least one byte is left, so BX cannot be zero.
    MOV DI, SI
    MOV CX, BX

HEX_NEXT:
    MOV AL, SAMPLE[DI]
    CALL HEX_PAIR
    LEA DX, M_SP
    CALL PRINT_MESSAGE
    INC DI
    LOOP HEX_NEXT

    ; ---- pad a short row so the text column stays where it belongs ------------
    MOV CX, PER_ROW
    SUB CX, BX
    JCXZ ROW_PADDED                     ; A full row has nothing to pad

PAD_NEXT:
    LEA DX, M_PAD
    CALL PRINT_MESSAGE
    LOOP PAD_NEXT

ROW_PADDED:
    LEA DX, M_OPEN
    CALL PRINT_MESSAGE

    ; ---- the same bytes as text ----------------------------------------------
    MOV DI, SI
    MOV CX, BX

TEXT_NEXT:
    MOV AL, SAMPLE[DI]

    ; Unsigned comparisons, because a byte such as 0FFH is above 7EH here and
    ; not below zero. A signed test would print it and hide a control code.
    CMP AL, LOWEST
    JB  NOT_PRINTABLE
    CMP AL, HIGHEST
    JA  NOT_PRINTABLE
    JMP SHOW_BYTE

NOT_PRINTABLE:
    MOV AL, '.'

SHOW_BYTE:
    MOV DL, AL
    MOV AH, 02H
    INT 21H
    INC DI
    LOOP TEXT_NEXT

    LEA DX, M_SHUT
    CALL PRINT_MESSAGE
    CALL NEWLINE

    ADD SI, PER_ROW
    JMP NEXT_ROW

DUMP_DONE:
    LEA DX, M_COUNT
    CALL PRINT_MESSAGE
    MOV AX, SPAN
    CALL PRINT_DECIMAL
    CALL NEWLINE

    MOV AH, 4CH
    INT 21H

; -----------------------------------------------------------------------------
; HEX_QUAD
;
; Prints AX as four hexadecimal digits, high byte first and no trailing letter,
; which is the form an offset column wants.
; -----------------------------------------------------------------------------
HEX_QUAD PROC
    PUSH AX
    PUSH CX

    MOV CH, AL                          ; The low byte has to outlive the high one
    MOV AL, AH
    CALL HEX_PAIR
    MOV AL, CH
    CALL HEX_PAIR

    POP CX
    POP AX
    RET
HEX_QUAD ENDP

; -----------------------------------------------------------------------------
; HEX_PAIR
;
; Prints AL as two hexadecimal digits, high nibble first.
; -----------------------------------------------------------------------------
HEX_PAIR PROC
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX

    MOV BL, AL                          ; Keep the byte; AL is about to be shifted
    MOV CL, 4
    SHR AL, CL                          ; The 8086 shifts by one or by CL, nothing else
    CALL EMIT_DIGIT

    MOV AL, BL
    AND AL, 0FH
    CALL EMIT_DIGIT

    POP DX
    POP CX
    POP BX
    POP AX
    RET
HEX_PAIR ENDP

; -----------------------------------------------------------------------------
; EMIT_DIGIT
;
; Prints the value 0 to 15 held in AL as one hexadecimal character.
; -----------------------------------------------------------------------------
EMIT_DIGIT PROC
    PUSH AX
    PUSH BX
    PUSH DX

    LEA BX, DIGITS
    XLAT                                ; AL becomes DIGITS[AL], table lookup in one

    MOV DL, AL
    MOV AH, 02H
    INT 21H

    POP DX
    POP BX
    POP AX
    RET
EMIT_DIGIT ENDP

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
; 1. Why the last row is measured:
;    - The bytes left in the block are the block length less the row offset.
;    - The row takes the smaller of that and sixteen, so it can never overrun.
;    - Padding the difference keeps the text column under the same place on every row.
; 2. Why the printable range is tested unsigned:
;    - A byte of 0FFH is 255 to an unsigned compare and minus one to a signed one.
;    - JB and JA read the carry flag, which is what an unsigned compare sets.
;    - JL and JG would let 0FFH through as printable and hide it in the text column.
; 3. Why XLAT rather than arithmetic:
;    - Digits and letters are not adjacent in ASCII, so one addition will not do.
;    - The usual fix is a compare and a second addition of seven for A to F.
;    - A sixteen byte table answers the same question with no branch at all.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
