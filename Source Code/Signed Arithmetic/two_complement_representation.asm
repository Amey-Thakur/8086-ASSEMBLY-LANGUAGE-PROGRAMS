; =============================================================================
; TITLE: How a Negative Number is Stored
; DESCRIPTION: Shows the bit pattern the processor keeps for a negative value,
;              and that adding a number to its negation gives zero.
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
    VALUE   DW 25
    M_POS   DB '  25 is stored as $'
    M_NEG   DB ' -25 is stored as $'
    M_SUM   DB 'Their sum is $'

; -----------------------------------------------------------------------------
; CODE SEGMENT
; -----------------------------------------------------------------------------
.CODE
START:
    MOV AX, @DATA
    MOV DS, AX

    LEA DX, M_POS
    MOV AH, 09H
    INT 21H
    MOV AX, VALUE
    CALL PRINT_HEX
    CALL NEWLINE

    ; -------------------------------------------------------------------------
    ; NEG INVERTS EVERY BIT AND ADDS ONE. THERE IS NO SIGN BIT SET ASIDE FOR
    ; THE PURPOSE; THE TOP BIT ONLY LOOKS LIKE ONE BECAUSE OF HOW THE
    ; PATTERNS FALL OUT.
    ; -------------------------------------------------------------------------
    MOV BX, VALUE
    NEG BX

    LEA DX, M_NEG
    MOV AH, 09H
    INT 21H
    MOV AX, BX
    CALL PRINT_HEX
    CALL NEWLINE

    ; -------------------------------------------------------------------------
    ; THE TEST OF THE REPRESENTATION: A VALUE PLUS ITS NEGATION IS ZERO, WITH
    ; THE SEVENTEENTH BIT FALLING OFF THE TOP INTO THE CARRY.
    ; -------------------------------------------------------------------------
    MOV AX, VALUE
    ADD AX, BX

    MOV SI, AX
    LEA DX, M_SUM
    MOV AH, 09H
    INT 21H
    MOV AX, SI
    CALL PRINT_HEX
    CALL NEWLINE

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
; 1. WHY THIS SCHEME AND NOT A SIGN BIT:
;    - One addition circuit handles both signs. A separate sign bit would
;    - need the hardware to decide whether to add or subtract first.
; 2. THE ASYMMETRY:
;    - A word holds -32768 to 32767. There is one more negative value
;    - than positive, because zero occupies a positive pattern.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
