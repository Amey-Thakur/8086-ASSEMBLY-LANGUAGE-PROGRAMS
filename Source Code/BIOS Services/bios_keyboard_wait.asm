; =============================================================================
; TITLE: Waiting for a Key with INT 16h
; DESCRIPTION: Reads a keystroke through the BIOS, which returns the scan code
;              as well as the character.
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
    M_ASK   DB 'Press a key: $'
    M_ASCII DB 0DH, 0AH, 'ASCII code: $'
    M_SCAN  DB 0DH, 0AH, 'Scan code:  $'
    M_SPEC  DB 0DH, 0AH, 'That key has no ASCII value; it is a function or', 0DH, 0AH
            DB 'arrow key, known only by its scan code.', 0DH, 0AH, '$'
    CRLF    DB 0DH, 0AH, '$'

; -----------------------------------------------------------------------------
; CODE SEGMENT
; -----------------------------------------------------------------------------
.CODE
START:
    MOV AX, @DATA
    MOV DS, AX

    LEA DX, M_ASK
    MOV AH, 09H
    INT 21H

    ; -------------------------------------------------------------------------
    ; SERVICE 00H WAITS FOR A KEY AND RETURNS TWO THINGS: THE CHARACTER IN AL
    ; AND THE SCAN CODE IN AH. THE SCAN CODE SAYS WHICH PHYSICAL KEY WAS
    ; PRESSED, WHICH IS THE ONLY WAY TO TELL THE ARROW KEYS APART FROM EACH
    ; OTHER, BECAUSE THEY ALL RETURN A CHARACTER OF NOUGHT.
    ; -------------------------------------------------------------------------
    MOV AH, 00H
    INT 16H

    MOV BL, AL                          ; The character
    MOV BH, AH                          ; The scan code

    LEA DX, M_ASCII
    MOV AH, 09H
    INT 21H
    MOV AL, BL
    XOR AH, AH
    CALL PRINT_DECIMAL

    LEA DX, M_SCAN
    MOV AH, 09H
    INT 21H
    MOV AL, BH
    XOR AH, AH
    CALL PRINT_DECIMAL

    OR  BL, BL
    JNZ ORDINARY_KEY

    LEA DX, M_SPEC
    MOV AH, 09H
    INT 21H
    JMP FINISH

ORDINARY_KEY:
    LEA DX, CRLF
    MOV AH, 09H
    INT 21H

FINISH:
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
; 1. TWO VALUES, NOT ONE:
;    - DOS service 01h gives only the character. The BIOS gives the scan
;    - code as well, and without it the four arrow keys are
;    - indistinguishable.
; 2. A CHARACTER OF NOUGHT MEANS A SPECIAL KEY:
;    - Function keys, arrows and Home all report nought in AL, and the
;    - scan code in AH is what identifies them.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
