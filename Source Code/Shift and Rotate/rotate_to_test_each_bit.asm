; =============================================================================
; TITLE: Test Every Bit by Rotating
; DESCRIPTION: Prints the binary representation of a word by rotating it left
;              sixteen times and reading the carry after each rotation.
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
    VALUE DW 0B4D2H
    MSG   DB 'B4D2H in binary: $'

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
    MOV CX, 16

    ; -------------------------------------------------------------------------
    ; ROL BRINGS THE TOP BIT ROUND TO THE BOTTOM AND ALSO LEAVES IT IN THE
    ; CARRY. READING THE CARRY THEREFORE READS THE BITS FROM THE MOST
    ; SIGNIFICANT DOWNWARD, WHICH IS THE ORDER THEY ARE WRITTEN IN.
    ; -------------------------------------------------------------------------
BIT_LOOP:
    ROL BX, 1
    MOV DL, '0'
    JNC EMIT_BIT
    MOV DL, '1'

EMIT_BIT:
    MOV AH, 02H
    INT 21H
    LOOP BIT_LOOP

    CALL NEWLINE

    MOV AH, 4CH
    INT 21H

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
; 1. WHY ROTATE AND NOT SHIFT:
;    - Sixteen rotations leave BX exactly as it started, so the value is
;    - still available afterwards. Sixteen shifts would leave zero.
; 2. READING ORDER:
;    - Binary is written most significant bit first, and ROL delivers the
;    - bits in that order. Rotating right would print them backwards.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
