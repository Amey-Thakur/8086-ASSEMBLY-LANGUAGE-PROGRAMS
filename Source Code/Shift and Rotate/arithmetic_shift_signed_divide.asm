; =============================================================================
; TITLE: Divide a Signed Value with SAR
; DESCRIPTION: Halves a negative number correctly with SAR, and shows what SHR
;              produces for the same value to make the difference plain.
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
    VALUE  DW -40
    SAR_M  DB 'SAR gives  $'
    SHR_M  DB 'SHR gives  $'
    NEG_M  DB '-$'

; -----------------------------------------------------------------------------
; CODE SEGMENT
; -----------------------------------------------------------------------------
.CODE
START:
    MOV AX, @DATA
    MOV DS, AX

    ; -------------------------------------------------------------------------
    ; SAR: THE SIGN IS COPIED INWARD, SO -40 HALVES TO -20
    ; -------------------------------------------------------------------------
    LEA DX, SAR_M
    MOV AH, 09H
    INT 21H

    MOV BX, VALUE
    SAR BX, 1
    MOV AX, BX
    CALL PRINT_SIGNED
    CALL NEWLINE

    ; -------------------------------------------------------------------------
    ; SHR: A ZERO IS BROUGHT IN, SO THE SIGN IS LOST AND THE VALUE IS HUGE
    ; -------------------------------------------------------------------------
    LEA DX, SHR_M
    MOV AH, 09H
    INT 21H

    MOV BX, VALUE
    SHR BX, 1
    MOV AX, BX
    CALL PRINT_DECIMAL
    CALL NEWLINE

    MOV AH, 4CH
    INT 21H

; -----------------------------------------------------------------------------
; PRINT_SIGNED
;
; Prints AX as a signed value, with a minus sign when it is negative.
; -----------------------------------------------------------------------------
PRINT_SIGNED PROC
    PUSH AX
    PUSH DX

    OR  AX, AX
    JNS PS_POSITIVE                     ; Sign flag clear means not negative

    PUSH AX
    LEA DX, NEG_M
    MOV AH, 09H
    INT 21H
    POP AX
    NEG AX                              ; Print the magnitude

PS_POSITIVE:
    CALL PRINT_DECIMAL

    POP DX
    POP AX
    RET
PRINT_SIGNED ENDP

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
; 1. WHAT SAR PRESERVES:
;    - SAR copies the sign bit into the vacated position instead of a
;    - zero, so a negative value stays negative however far it shifts.
; 2. WHY SHR GIVES 32748:
;    - -40 is FFD8h. Shifting a zero into the top gives 7FECh, which as
;    - an unsigned value is 32748. The bits moved correctly; the meaning
;    - did not survive.
; 3. THE ROUNDING DIRECTION:
;    - SAR rounds toward negative infinity, so -5 shifted once gives -3
;    - and not -2. IDIV rounds toward zero. They disagree on odd
;    - negatives, which is a real source of bugs.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
