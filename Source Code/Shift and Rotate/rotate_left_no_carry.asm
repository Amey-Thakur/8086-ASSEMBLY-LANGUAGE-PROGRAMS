; =============================================================================
; TITLE: Rotate Left Without the Carry
; DESCRIPTION: Rotates a bit pattern left one place at a time, showing that ROL
;              loses nothing: after sixteen rotations the value returns.
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
    VALUE DW 8421H
    MSG   DB 'Rotating 8421H left, four places at a time:', 0DH, 0AH, '$'

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

    MOV BX, VALUE
    MOV CX, 4                           ; Four steps of four places is a full turn

ROTATE_LOOP:
    ROL BX, 4
    MOV AX, BX
    CALL PRINT_HEX
    CALL NEWLINE
    LOOP ROTATE_LOOP

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
; 1. ROTATION LOSES NOTHING:
;    - The bit leaving the top comes back in at the bottom, so a rotation
;    - is a permutation of the bits. Sixteen single rotations of a word
;    - return it exactly, which the last line here shows.
; 2. THE CARRY STILL MOVES:
;    - ROL copies the bit that wrapped into the carry flag as well. The
;    - carry is a report of what happened, not part of the ring.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
