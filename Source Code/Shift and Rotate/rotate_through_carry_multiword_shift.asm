; =============================================================================
; TITLE: Shift a 32-bit Value Using RCL
; DESCRIPTION: Shifts a value held across two registers as though it were one
;              32-bit number, by passing the carry from the low half to the high.
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
    HIGH_W DW 0001H                     ; The 32-bit value 0001_8000
    LOW_W  DW 8000H
    MSG    DB 'Doubling the 32-bit value 00018000H three times:', 0DH, 0AH, '$'
    SEP    DB '_$'

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

    MOV BX, HIGH_W
    MOV SI, LOW_W
    MOV CX, 3

SHIFT_LOOP:
    ; -------------------------------------------------------------------------
    ; THE LOW HALF FIRST, SO ITS TOP BIT LANDS IN THE CARRY, THEN THE HIGH
    ; HALF ROTATES THAT CARRY IN AT ITS BOTTOM. ORDER IS EVERYTHING HERE.
    ; -------------------------------------------------------------------------
    SHL SI, 1                           ; Low half; top bit leaves into CF
    RCL BX, 1                           ; High half; CF arrives at the bottom

    PUSH CX

    MOV AX, BX
    CALL PRINT_HEX
    LEA DX, SEP
    MOV AH, 09H
    INT 21H
    MOV AX, SI
    CALL PRINT_HEX
    CALL NEWLINE

    POP CX
    LOOP SHIFT_LOOP

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
; 1. WHY THE LOW HALF GOES FIRST:
;    - The bit that must travel is the one leaving the top of the low
;    - half. It can only travel through the carry flag, so the low half
;    - has to be shifted while the carry is still free to receive it.
; 2. RCL RATHER THAN SHL FOR THE HIGH HALF:
;    - SHL would bring in a zero and the bit would be lost. RCL brings in
;    - whatever the carry holds, which is exactly the arriving bit.
; 3. EXTENDING FURTHER:
;    - The same pattern chains to any width: one SHL for the lowest word,
;    - then one RCL for every word above it, working upward.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
