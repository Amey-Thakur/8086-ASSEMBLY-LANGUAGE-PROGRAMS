; =============================================================================
; TITLE: Count Set Bits (Kernighan's Method)
; DESCRIPTION: Counts the one bits in a 16-bit word by repeatedly clearing the
;              lowest set bit, which costs one iteration per set bit rather
;              than one per bit position.
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
    VALUE  DW 0B4D2H                    ; 1011 0100 1101 0010, eight bits set
    MSG    DB 'Set bits: $'
    DIGITS DB '00', 0DH, 0AH, '$'

; -----------------------------------------------------------------------------
; CODE SEGMENT
; -----------------------------------------------------------------------------
.CODE
START:
    ; Context setup
    MOV AX, @DATA
    MOV DS, AX

    MOV BX, VALUE                       ; Working copy
    XOR CX, CX                          ; CX = running count

    ; -------------------------------------------------------------------------
    ; KERNIGHAN'S LOOP
    ;
    ; BX AND (BX - 1) clears the lowest set bit and leaves every other bit
    ; alone, so the loop runs exactly as many times as there are set bits.
    ; -------------------------------------------------------------------------
COUNT_LOOP:
    OR  BX, BX                          ; Any bits left?
    JZ  DONE_COUNT                      ; No, the count is final

    MOV AX, BX
    DEC AX                              ; AX = BX - 1
    AND BX, AX                          ; Clear the lowest set bit
    INC CX                              ; One more bit accounted for
    JMP COUNT_LOOP

DONE_COUNT:
    ; Convert the two digit count to ASCII
    MOV AX, CX
    MOV BL, 10
    DIV BL                              ; AL = tens, AH = units
    ADD AL, '0'
    ADD AH, '0'
    MOV DIGITS[0], AL
    MOV DIGITS[1], AH

    ; Report
    LEA DX, MSG
    MOV AH, 09H
    INT 21H
    LEA DX, DIGITS
    MOV AH, 09H
    INT 21H

    ; End process
    MOV AH, 4CH
    INT 21H

END START

; =============================================================================
; TECHNICAL NOTES
; =============================================================================
; 1. WHY IT TERMINATES:
;    - Subtracting one turns the lowest set bit into a zero and every bit
;      below it into a one. ANDing that back therefore removes exactly one
;      set bit per iteration and can never add one.
; 2. COST:
;    - O(number of set bits), not O(16). For a word with two bits set the
;      loop runs twice, whatever the width of the register.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
