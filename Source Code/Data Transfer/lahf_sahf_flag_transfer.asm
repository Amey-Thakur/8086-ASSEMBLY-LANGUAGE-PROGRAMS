; =============================================================================
; TITLE: Moving the Flags Through AH
; DESCRIPTION: Copies the arithmetic flags into AH with LAHF and restores them
;              with SAHF, the cheaper alternative to PUSHF and POPF.
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
    MSG_SAVED DB 'Flags byte saved in AH: $'
    MSG_KEPT  DB 'Zero and carry both came back.', 0DH, 0AH, '$'
    MSG_LOST  DB 'A flag was lost.', 0DH, 0AH, '$'

; -----------------------------------------------------------------------------
; CODE SEGMENT
; -----------------------------------------------------------------------------
.CODE
START:
    MOV AX, @DATA
    MOV DS, AX

    ; -------------------------------------------------------------------------
    ; SET UP A KNOWN STATE: SUBTRACTING A VALUE FROM ITSELF SETS THE ZERO
    ; FLAG, AND STC THEN SETS THE CARRY.
    ; -------------------------------------------------------------------------
    MOV BX, 5
    SUB BX, 5                           ; ZF = 1
    STC                                 ; CF = 1

    LAHF                                ; The low flags byte is now in AH
    MOV BL, AH                          ; Keep it somewhere safe

    LEA DX, MSG_SAVED
    MOV AH, 09H
    INT 21H
    MOV AL, BL
    XOR AH, AH
    CALL PRINT_HEX
    CALL NEWLINE

    ; Destroy the flags thoroughly
    MOV CX, 1
    OR  CX, CX

    MOV AH, BL
    SAHF                                ; And put them back

    JNZ WRONG
    JNC WRONG

    LEA DX, MSG_KEPT
    JMP REPORT

WRONG:
    LEA DX, MSG_LOST

REPORT:
    MOV AH, 09H
    INT 21H

    MOV AH, 4CH
    INT 21H

; -----------------------------------------------------------------------------
; PRINT_HEX
;
; Prints the value in AX as four hexadecimal digits followed by H.
; -----------------------------------------------------------------------------
PRINT_HEX PROC
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX

    MOV BX, AX                          ; Keep the value; AX is needed for DOS
    MOV CX, 4                           ; Four nibbles, most significant first

PH_NEXT:
    ROL BX, 4                           ; Bring the next nibble to the bottom
    MOV DL, BL
    AND DL, 0FH

    ADD DL, '0'                         ; 0 to 9 sit just after '0'
    CMP DL, '9'
    JBE PH_EMIT
    ADD DL, 7                           ; A to F sit seven further on

PH_EMIT:
    MOV AH, 02H
    INT 21H
    LOOP PH_NEXT

    MOV DL, 'H'
    MOV AH, 02H
    INT 21H

    POP DX
    POP CX
    POP BX
    POP AX
    RET
PRINT_HEX ENDP

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
; 1. WHICH FLAGS TRAVEL:
;    - Only the low byte: carry, parity, auxiliary carry, zero and sign.
;    - The overflow flag lives in the high byte and does not move, so a
;    - routine that cares about overflow needs PUSHF instead.
; 2. WHY THESE FIVE:
;    - They are the five the 8080 had, in the same bit positions. LAHF
;    - and SAHF exist so that 8080 code could be translated instruction
;    - by instruction onto the 8086.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
