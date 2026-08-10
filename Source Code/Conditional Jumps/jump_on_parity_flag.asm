; =============================================================================
; TITLE: Branching on the Parity Flag
; DESCRIPTION: Uses the parity flag to check whether a byte has an even number
;              of set bits, the flag's original use in serial communication.
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
    SAMPLES DB 03H, 07H, 0FFH, 01H
    HOWMANY EQU 4
    M_EVEN  DB ' has even parity', 0DH, 0AH, '$'
    M_ODD   DB ' has odd parity', 0DH, 0AH, '$'

; -----------------------------------------------------------------------------
; CODE SEGMENT
; -----------------------------------------------------------------------------
.CODE
START:
    MOV AX, @DATA
    MOV DS, AX

    LEA SI, SAMPLES
    MOV CX, HOWMANY

PARITY_LOOP:
    MOV AL, [SI]
    PUSH CX
    PUSH SI

    XOR AH, AH
    CALL PRINT_HEX

    ; -------------------------------------------------------------------------
    ; THE FLAGS HAVE TO BE SET FROM THE BYTE AGAIN, BECAUSE PRINTING RAN
    ; MANY INSTRUCTIONS. OR AL, AL SETS PF FROM THE LOW EIGHT BITS.
    ; -------------------------------------------------------------------------
    POP SI
    MOV AL, [SI]
    OR  AL, AL

    JPO ODD_PARITY
    LEA DX, M_EVEN
    JMP REPORT

ODD_PARITY:
    LEA DX, M_ODD

REPORT:
    MOV AH, 09H
    INT 21H

    POP CX
    INC SI
    LOOP PARITY_LOOP

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

END START

; =============================================================================
; TECHNICAL NOTES
; =============================================================================
; 1. ONLY THE LOW BYTE COUNTS:
;    - Parity is computed from the bottom eight bits of the result and
;    - nothing else, even for a sixteen bit operation. This surprises
;    - people who expect it to describe the whole word.
; 2. EVEN MEANS SET:
;    - PF is set when the number of one bits is even. 03h has two, so PF
;    - is set; 07h has three, so it is clear. JPE and JP are the same
;    - instruction, as are JPO and JNP.
; 3. WHY IT EXISTS:
;    - Serial links sent seven data bits and one parity bit so that a
;    - single corrupted bit could be detected. The flag made checking it
;    - a single instruction.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
