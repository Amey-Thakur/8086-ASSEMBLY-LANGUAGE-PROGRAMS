; =============================================================================
; TITLE: A Hexadecimal Dump Of A Block
; DESCRIPTION: Prints a block of memory eight bytes to a line, the offset on
;              the left, the hexadecimal in the middle and the printable
;              characters on the right.
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
    ; Text, a tab, more text, a return and a feed, then four bytes that no
    ; terminal can show. A dump has to survive all of them.
    DUMPME  DB 'Amey Thakur', 09H, '8086', 0DH, 0AH, 00H, 7FH, 80H, 0FFH
    SPAN    EQU $ - DUMPME              ; Measured, never counted by hand
    PERLINE EQU 8

    ROWAT   DW 0                        ; Offset of this row within the block
    STILL   DW 0                        ; Bytes not yet shown
    THISROW DW 0                        ; Bytes on this row, eight or fewer
    ROWS    DW 0

    M_TITLE DB 'A dump of $'
    M_BYTES DB ' bytes, eight to a line', 0DH, 0AH, 0DH, 0AH, '$'
    M_HEAD  DB 'offset  bytes in hexadecimal    characters', 0DH, 0AH, '$'
    M_GAP   DB '    $'                 ; Four, so the columns line up with the
                                        ; six letters of the heading and a gap
    M_PAD   DB '   $'
    M_BAR   DB '|$'
    M_ROWS  DB 0DH, 0AH, 'Rows printed: $'

; -----------------------------------------------------------------------------
; CODE SEGMENT
; -----------------------------------------------------------------------------
.CODE
START:
    MOV AX, @DATA
    MOV DS, AX

    LEA DX, M_TITLE
    CALL PRINT_MESSAGE
    MOV AX, SPAN
    CALL PRINT_DECIMAL
    LEA DX, M_BYTES
    CALL PRINT_MESSAGE
    LEA DX, M_HEAD
    CALL PRINT_MESSAGE

    XOR AX, AX
    MOV ROWAT, AX
    MOV ROWS, AX
    MOV AX, SPAN
    MOV STILL, AX
    OR  AX, AX
    JZ  DUMP_END                        ; An empty block prints no rows at all

ROW_LOOP:
    ; -------------------------------------------------------------------------
    ; THE OFFSET SHOWN IS THE POSITION WITHIN THE BLOCK, NOT THE ADDRESS IN
    ; THE SEGMENT, SO THE DUMP READS THE SAME WHEREVER THE ASSEMBLER HAPPENS
    ; TO HAVE PLACED THE DATA.
    ; -------------------------------------------------------------------------
    MOV AX, ROWAT
    CALL HEX_WORD
    LEA DX, M_GAP
    CALL PRINT_MESSAGE

    ; The last row is usually short, so take the smaller of eight and the rest
    MOV AX, STILL
    CMP AX, PERLINE
    JBE ROW_PART                        ; A count is unsigned, so JBE not JLE
    MOV AX, PERLINE

ROW_PART:
    MOV THISROW, AX

    LEA SI, DUMPME
    ADD SI, ROWAT
    MOV CX, THISROW

HEX_COLUMN:
    MOV AL, [SI]
    CALL HEX_BYTE
    MOV DL, ' '
    MOV AH, 02H
    INT 21H
    INC SI
    LOOP HEX_COLUMN

    ; -------------------------------------------------------------------------
    ; PAD THE MISSING BYTES OF A SHORT ROW WITH THREE SPACES EACH, WHICH IS
    ; WHAT A PAIR OF DIGITS AND ITS SEPARATOR OCCUPY, SO THE CHARACTER COLUMN
    ; STAYS WHERE IT IS.
    ; -------------------------------------------------------------------------
    MOV CX, PERLINE
    SUB CX, THISROW
    JCXZ FULL_ROW                       ; A full row needs no padding at all

PAD_LOOP:
    LEA DX, M_PAD
    CALL PRINT_MESSAGE
    LOOP PAD_LOOP

FULL_ROW:
    LEA DX, M_BAR
    CALL PRINT_MESSAGE

    LEA SI, DUMPME
    ADD SI, ROWAT
    MOV CX, THISROW

CHAR_COLUMN:
    MOV AL, [SI]
    CMP AL, 20H
    JB  NOT_SHOWN                       ; Control codes have no glyph
    CMP AL, 7EH
    JA  NOT_SHOWN                       ; Nor has anything above the tilde
    JMP EMIT_CHAR

NOT_SHOWN:
    MOV AL, '.'

EMIT_CHAR:
    MOV DL, AL
    MOV AH, 02H
    INT 21H
    INC SI
    LOOP CHAR_COLUMN

    LEA DX, M_BAR
    CALL PRINT_MESSAGE
    CALL NEWLINE

    INC ROWS
    MOV AX, ROWAT
    ADD AX, THISROW
    MOV ROWAT, AX
    MOV AX, STILL
    SUB AX, THISROW
    MOV STILL, AX
    OR  AX, AX
    JNZ ROW_LOOP

DUMP_END:
    LEA DX, M_ROWS
    CALL PRINT_MESSAGE
    MOV AX, ROWS
    CALL PRINT_DECIMAL
    CALL NEWLINE

    MOV AH, 4CH
    INT 21H

; -----------------------------------------------------------------------------
; HEX_BYTE
;
; Prints AL as exactly two hexadecimal digits, leading zero included.
;
; PRINT_HEX would print four digits and an H, which is right for a value and
; wrong for a column of bytes, so a dump needs its own narrower version.
; -----------------------------------------------------------------------------
HEX_BYTE PROC
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX

    MOV BL, AL                          ; Keep the value; AX is needed for DOS
    MOV CX, 2

HB_NEXT:
    ROL BL, 4                           ; Bring the next nibble to the bottom
    MOV DL, BL
    AND DL, 0FH

    ADD DL, '0'                         ; 0 to 9 sit just after '0'
    CMP DL, '9'
    JBE HB_EMIT
    ADD DL, 7                           ; A to F sit seven further on

HB_EMIT:
    MOV AH, 02H
    INT 21H
    LOOP HB_NEXT

    POP DX
    POP CX
    POP BX
    POP AX
    RET
HEX_BYTE ENDP

; -----------------------------------------------------------------------------
; HEX_WORD
;
; Prints AX as exactly four hexadecimal digits, with no H after them, which is
; what an offset column wants.
; -----------------------------------------------------------------------------
HEX_WORD PROC
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX

    MOV BX, AX
    MOV CX, 4                           ; Four nibbles, most significant first

HW_NEXT:
    ROL BX, 4
    MOV DL, BL
    AND DL, 0FH

    ADD DL, '0'
    CMP DL, '9'
    JBE HW_EMIT
    ADD DL, 7

HW_EMIT:
    MOV AH, 02H
    INT 21H
    LOOP HW_NEXT

    POP DX
    POP CX
    POP BX
    POP AX
    RET
HEX_WORD ENDP

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
; 1. WHY THE CHARACTER COLUMN EARNS ITS PLACE:
;    - Hexadecimal alone hides the shape of the data. Seeing the letters
;    - beside the codes is what tells an engineer at a glance whether a
;    - buffer holds text, a record or nothing that was ever written.
; 2. WHY BYTES ARE REPLACED BY A FULL STOP:
;    - Anything below 20H is a control code, and a return or a feed sent
;    - to the console would move the cursor and wreck the layout. Only the
;    - range 20H to 7EH is safe to send unchanged.
; 3. WHY THE PADDING IS COUNTED, NOT GUESSED:
;    - The last row here holds six bytes of the twenty two. Two missing
;    - entries of three characters each are made up before the bar, so the
;    - character column begins in the same place on every line.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
