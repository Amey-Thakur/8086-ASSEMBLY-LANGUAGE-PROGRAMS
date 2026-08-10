; =============================================================================
; TITLE: Packed BCD to Text and Back
; DESCRIPTION: Unpacks a byte holding two decimal digits into printable
;              characters, and packs them up again.
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
    PACKED  DB 79H                      ; The decimal digits 7 and 9
    TEXT    DB '  ', 0DH, 0AH, '$'
    REPACK  DB 0

    M_ONE   DB 'The byte 79h unpacks to $'
    M_TWO   DB 'Repacking those digits gives $'
    M_HEXT  DB 'h', 0DH, 0AH, '$'

; -----------------------------------------------------------------------------
; CODE SEGMENT
; -----------------------------------------------------------------------------
.CODE
START:
    MOV AX, @DATA
    MOV DS, AX

    ; -------------------------------------------------------------------------
    ; PACKED BCD KEEPS ONE DECIMAL DIGIT IN EACH NIBBLE, SO 79H IS SEVENTY
    ; NINE AND NOT ONE HUNDRED AND TWENTY ONE. UNPACKING IS A SHIFT FOR THE
    ; HIGH DIGIT AND A MASK FOR THE LOW ONE.
    ; -------------------------------------------------------------------------
    MOV AL, PACKED
    MOV BL, AL

    SHR AL, 4                           ; The high digit
    ADD AL, '0'
    MOV TEXT[0], AL

    MOV AL, BL
    AND AL, 0FH                         ; The low digit
    ADD AL, '0'
    MOV TEXT[1], AL

    LEA DX, M_ONE
    MOV AH, 09H
    INT 21H
    LEA DX, TEXT
    MOV AH, 09H
    INT 21H

    ; -------------------------------------------------------------------------
    ; PACKING IS THE REVERSE: TAKE THE DIGITS BACK OUT OF THE CHARACTERS, PUT
    ; ONE IN EACH NIBBLE, AND COMBINE THEM.
    ; -------------------------------------------------------------------------
    MOV AL, TEXT[0]
    SUB AL, '0'
    SHL AL, 4                           ; Into the high nibble

    MOV BL, TEXT[1]
    SUB BL, '0'
    OR  AL, BL                          ; And the low one alongside it
    MOV REPACK, AL

    LEA DX, M_TWO
    MOV AH, 09H
    INT 21H

    MOV AL, REPACK
    CALL PRINT_HEX_BYTE
    LEA DX, M_HEXT
    MOV AH, 09H
    INT 21H

    MOV AH, 4CH
    INT 21H

; -----------------------------------------------------------------------------
; PRINT_HEX_BYTE
;
; Prints AL as two hexadecimal digits.
; -----------------------------------------------------------------------------
PRINT_HEX_BYTE PROC
    PUSH AX
    PUSH CX
    PUSH DX

    MOV CL, AL
    SHR AL, 4
    CALL EMIT_NIBBLE

    MOV AL, CL
    AND AL, 0FH
    CALL EMIT_NIBBLE

    POP DX
    POP CX
    POP AX
    RET
PRINT_HEX_BYTE ENDP

EMIT_NIBBLE PROC
    ADD AL, '0'
    CMP AL, '9'
    JBE EN_EMIT
    ADD AL, 7                           ; A to F sit seven past the digits

EN_EMIT:
    MOV DL, AL
    MOV AH, 02H
    INT 21H
    RET
EMIT_NIBBLE ENDP

END START

; =============================================================================
; TECHNICAL NOTES
; =============================================================================
; 1. WHY PACKED BCD EXISTS:
;    - Two digits in a byte rather than one, and no conversion needed to
;    - display them. It is why prices and clock values were stored this
;    - way for decades.
; 2. ARITHMETIC NEEDS ADJUSTING:
;    - Adding two packed BCD bytes with ADD gives a binary answer. DAA
;    - immediately afterwards corrects it back into BCD, and without that
;    - the result contains nibbles above nine.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
