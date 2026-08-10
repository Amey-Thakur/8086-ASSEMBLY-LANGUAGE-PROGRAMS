; =============================================================================
; TITLE: Scan Codes for the Keys
; DESCRIPTION: Reads several keys and shows both what they mean and which
;              physical key produced them.
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
    HOWMANY EQU 4
    M_HEAD  DB 'Press four keys.', 0DH, 0AH
            DB 'key   ascii  scan', 0DH, 0AH, '$'
    M_NONE  DB '(none)$'
    GAP     DB '    $'
    CRLF    DB 0DH, 0AH, '$'

; -----------------------------------------------------------------------------
; CODE SEGMENT
; -----------------------------------------------------------------------------
.CODE
START:
    MOV AX, @DATA
    MOV DS, AX

    LEA DX, M_HEAD
    MOV AH, 09H
    INT 21H

    MOV CX, HOWMANY

EACH_KEY:
    PUSH CX

    MOV AH, 00H
    INT 16H
    MOV BL, AL                          ; character
    MOV BH, AH                          ; scan code

    ; -------------------------------------------------------------------------
    ; A PRINTABLE CHARACTER IS SHOWN AS ITSELF. ANYTHING BELOW A SPACE IS A
    ; CONTROL CODE OR A SPECIAL KEY AND HAS NOTHING TO SHOW, SO A PLACEHOLDER
    ; IS PRINTED INSTEAD.
    ; -------------------------------------------------------------------------
    CMP BL, ' '
    JB  NOT_PRINTABLE

    MOV DL, BL
    MOV AH, 02H
    INT 21H
    MOV DL, ' '
    MOV AH, 02H
    INT 21H
    MOV DL, ' '
    MOV AH, 02H
    INT 21H
    JMP SHOW_CODES

NOT_PRINTABLE:
    LEA DX, M_NONE
    MOV AH, 09H
    INT 21H

SHOW_CODES:
    LEA DX, GAP
    MOV AH, 09H
    INT 21H

    MOV AL, BL
    XOR AH, AH
    PUSH BX
    CALL PRINT_DECIMAL
    POP BX

    LEA DX, GAP
    MOV AH, 09H
    INT 21H

    MOV AL, BH
    XOR AH, AH
    CALL PRINT_DECIMAL
    CALL NEWLINE

    POP CX
    LOOP EACH_KEY

    MOV AX, 4C00H
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
; 1. THE SCAN CODE IS THE KEY, NOT THE LETTER:
;    - The A key reports scan code 30 whether shift is held or not. The
;    - character changes from 'a' to 'A'; the physical key does not.
; 2. WHY BOTH ARE RETURNED:
;    - A text editor wants the character. A game wants the key, so that
;    - the same physical position works whatever the keyboard layout.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
